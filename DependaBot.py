#!/usr/bin/env python3

import requests
import argparse

token = ''

def bot_alerts(repo):
    response = requests.get(
        f'https://api.github.com/repos/{repo}/dependabot/alerts?state=open',
        headers={'Authorization': f'Bearer {token}'}
    )

    if response.status_code == 200:
        alerts = response.json()
        return alerts
    
    else:
        return []

def repositories(org):
    response = requests.get(
        f'https://api.github.com/orgs/{org}/repos',
        headers={'Authorization': f'Bearer {token}'}
    )

    if response.status_code == 200:
        repos = [f'{org}/{repo["name"]}' for repo in response.json()]
        orgRepo = []
        
        for repo in repos:
            temp = bot_alerts(repo)
            orgRepo.extend(temp)
        return orgRepo
    
    else:
        print(f'Error when trying to list the organization repositories [{org}]: {response.status_code}')
        return []

def main():
    parse = argparse.ArgumentParser(description='A script that fetches and analyzes DependaBot alerts from GitHub repositories of a specified organization.')
    parse.add_argument('--org', help='Specify the name of the organization for which you want to retrieve DependaBot alerts.\ne.g. DependaBot.py --org org_name', required=True)
    args = parse.parse_args()

    if args.org:
        total_alerts = 0
        severity_count = {'low': 0, 'medium': 0, 'high': 0, 'critical': 0}

        alerts = repositories(args.org)
        total_alerts += len(alerts)
        
        for alert in alerts:
            severity_count[alert['security_vulnerability']['severity']] += 1

    print(f'Total DependaBot Alerts: {total_alerts}')
    
    for severity, count in severity_count.items():
        print(f'Severity {severity}: {count}')

if __name__ == '__main__':
    main()
