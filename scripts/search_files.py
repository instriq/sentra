#!/usr/bin/env python3

import re
import requests
import argparse
from datetime import datetime, timedelta

def repositories(org, token):
    response = requests.get(
        f'https://api.github.com/orgs/{org}/repos',
        headers = {'Authorization': f'Bearer {token}'}
    )

    if response.status_code == 200:
        repos = [f'{org}/{repo["name"]}' for repo in response.json() if not repo["archived"]]
        return repos
    
    return False

def search_file(repository, token):
    response = requests.get(
        f'https://api.github.com/repos/{repository}/contents/.github/dependabot.yaml',
        headers = {'Authorization': f'Bearer {token}'}
    )
    
    if response.status_code == 404:
        return (f'The dependabot.yml file was not found in this repository: https://github.com/{repository}')

    return False

def last_commit_date(repository, token):
    response = requests.get(
        f'https://api.github.com/repos/{repository}/commits',
        headers={'Authorization': f'Bearer {token}'}
    )

    if response.status_code == 200:
        if len(response.json()) > 0:
            last_commit_date_str = response.json()[0]['commit']['committer']['date']
            last_commit_date = datetime.strptime(last_commit_date_str, "%Y-%m-%dT%H:%M:%SZ")
            return last_commit_date
    return None

if __name__ == '__main__':
    parse = argparse.ArgumentParser(description='Search for specific files in the repositories of an organization.')
    parse.add_argument('--org', help='Specify the name of the organization\n', required=True)
    parse.add_argument('--token', help='Set the Github Token to use during actions.', required=True)
    parse.add_argument('--maintained', help='Check last commit date of repositories.', action='store_true')
    parse.add_argument('--dependency', help='Check for dependabot.yaml file in repositories.', action='store_true')
    args = parse.parse_args()

    if args.org:
        repos = repositories(args.org, args.token)
        
        if args.dependency:
            for repository in repos:
                dependabot = search_file(repository, args.token)
                
                if dependabot:
                    print(dependabot)

        if args.maintained:
            for repository in repos:
                last_commit = last_commit_date(repository, args.token)

                if last_commit and datetime.utcnow() - last_commit > timedelta(days=90):
                    print(f'The repository {repository} has not been updated for more than 90 days.')