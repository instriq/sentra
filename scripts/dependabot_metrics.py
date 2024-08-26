#!/usr/bin/env python3

import requests
import argparse

HEADERS = {
    'X-GitHub-Api-Version': '2022-11-28',
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'Sentra 0.0.1'
}

def get_alerts(repo, token):
    alerts = []
    page = 1
    while True:
        url = f'https://api.github.com/repos/{repo}/dependabot/alerts?state=open&per_page=100&page={page}'
        headers = HEADERS.copy()
        headers['Authorization'] = f'Bearer {token}'
        
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            data = response.json()
            if not data:
                break
            alerts.extend(data)
            page += 1
        else:
            print(f'Error fetching alerts: {response.status_code} - {response.reason}')
            break
    
    return alerts

def repositories(org, token):
    repos = []
    page = 1
    while True:
        url = f'https://api.github.com/orgs/{org}/repos?per_page=100&page={page}'
        headers = HEADERS.copy()
        headers['Authorization'] = f'Bearer {token}'
        
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            data = response.json()
            if not data:
                break
            repos.extend(f'{org}/{repo["name"]}' for repo in data if not repo["archived"])
            page += 1
        else:
            print(f'Error fetching repositories: {response.status_code} - {response.reason}')
            break
    
    return repos

def main():
    parse = argparse.ArgumentParser(description='A script that fetches and analyzes DependaBot alerts from GitHub repositories of a specified organization.')
    parse.add_argument('--org', help='Specify the name of the organization for which you want to retrieve DependaBot alerts.\ne.g. script.py --org org_name', required=True)
    parse.add_argument('--token', help='Set the GitHub Token to use during actions.', required=True)
    args = parse.parse_args()
    
    total_alerts = 0
    severity_count = {'low': 0, 'medium': 0, 'high': 0, 'critical': 0}

    if args.org:
        list_repositories = repositories(args.org, args.token)

        if list_repositories:
            for repository in list_repositories:
                alerts = get_alerts(repository, args.token)

                if alerts:
                    total_alerts += len(alerts)
            
                    for alert in alerts:
                        severity = alert.get('security_vulnerability', {}).get('severity', 'unknown')
                        if severity in severity_count:
                            severity_count[severity] += 1
    
            for severity, count in severity_count.items():
                print(f'Severity {severity}: {count}')

            return f'Total DependaBot Alerts: {total_alerts}'
        return 'Error when trying to request information from GitHub, please review the parameters provided.'
        
if __name__ == '__main__':
    print(main())