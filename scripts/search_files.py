#!/usr/bin/env python3

import re
import requests
import argparse

def repositories(org, token):
    response = requests.get(
        f'https://api.github.com/orgs/{org}/repos',
        headers = {'Authorization': f'Bearer {token}'}
    )

    if response.status_code == 200:
        repos = [f'{org}/{repo["name"]}' for repo in response.json()]
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

if __name__ == '__main__':
    parse = argparse.ArgumentParser(description='Search for specific files in the repositories of an organization.')
    parse.add_argument('--org', help='Specify the name of the organization\n', required=True)
    parse.add_argument('--token', help='Set the Github Token to use during actions.', required=True)
    args = parse.parse_args()

    if args.org:
        repos = repositories(args.org, args.token)
        
        for repository in repos:
            dependabot = search_file(repository, args.token)

            print (dependabot) if dependabot else None