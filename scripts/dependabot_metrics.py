#!/usr/bin/env python3

import requests
import argparse

def get_alerts(repo, token):    
    response = requests.get(f'https://api.github.com/repos/{repo}/dependabot/alerts?state=open', headers={'Authorization': f'Bearer {token}'})

    if response.status_code == 200:
        alerts = response.json()
        return alerts
    
    return False

def repositories(org, token):
    response = requests.get(f'https://api.github.com/orgs/{org}/repos?per_page=100', headers={'Authorization': f'Bearer {token}'})

    if response.status_code == 200:
        repos = [f'{org}/{repo["name"]}' for repo in response.json() if not repo["archived"]]
        return repos
    
    return False

def main():
    parse = argparse.ArgumentParser(description='A script that fetches and analyzes DependaBot alerts from GitHub repositories of a specified organization.')
    parse.add_argument('--org', help='Specify the name of the organization for which you want to retrieve DependaBot alerts.\ne.g. DependaBot.py --org org_name', required=True)
    parse.add_argument('--token', help='Set the Github Token to use during actions.', required=True)
    args = parse.parse_args()
    
    total_alerts = 0
    severity_count = {'low': 0, 'medium': 0, 'high': 0, 'critical': 0}

    if args.org:
        list_repositories = repositories(args.org, args.token)

        if list_repositories:
            for repositorie in list_repositories:
                alerts = get_alerts(repositorie, args.token)

                if alerts:
                    total_alerts += len(alerts)
            
                    for alert in alerts:
                        severity_count[alert['security_vulnerability']['severity']] += 1
    
            for severity, count in severity_count.items():
                print(f'Severity {severity}: {count}')

            return f'Total DependaBot Alerts: {total_alerts}'
        return 'Error when trying to request information from Github, please review the parameters provided.'
        
if __name__ == '__main__':
    print (main())