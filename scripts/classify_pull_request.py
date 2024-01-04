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

def pull_requests(repository, token):
    response = requests.get(
        f'https://api.github.com/repos/{repository}/pulls',
        headers = {'Authorization': f'Bearer {token}'}
    )

    if response.status_code == 200:
        infos = response.json()
        return infos
        
    return False

def classify(pull_request_list, token):
    for info in pull_request_list:
        user   = info['user']['login']
        number = info['number']
        label  = "security"

        if user == "dependabot[bot]":
            match = re.search(r'from (\d+\.\d+\.\d+) to (\d+\.\d+\.\d+)', info['title'])
    
            if match:
                current_version, next_version = match.group(1, 2)

                current_version_list = list(map(int, current_version.split('.')))
                next_version_list = list(map(int, next_version.split('.')))

                version_labels = {0: "major", 1: "minor", 2: "patch"}

                for index, (next_v, current_v) in enumerate(zip(next_version_list, current_version_list)):
                    if next_v > current_v:
                        label = version_labels[index]
                        break

        response = requests.post(
            f'https://api.github.com/repos/{repository}/issues/{number}/labels',
            headers = {
                'Authorization': f'Token {token}',
                'Accept': 'application/vnd.github.v3+json'
            }, 
            json = {'labels': [label]}
        )

        if response.status_code == 200:
            print(f'The label "{label}" has been successfully added to the Pull Request #{number}.')
        else:
            print(f'Error adding label: {response.status_code} - {response.text}')

if __name__ == '__main__':
    parse = argparse.ArgumentParser(description='Dependabot PR classification based on SemVer approach')
    parse.add_argument('--org', help='Specify the name of the organization\ne.g. DependaBot.py --org org_name', required=True)
    parse.add_argument('--token', help='Set the Github Token to use during actions.', required=True)
    args = parse.parse_args()

    if args.org:
        repos = repositories(args.org, args.token)
        
        for repository in repos:
            prs = pull_requests(repository, args.token)
            classify(prs, args.token)