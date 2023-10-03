import requests

token = ''
apiURL = 'https://api.github.com/repos/'

def BOTalerts(repository):
    url = f'{apiURL}{repository}/dependabot/alerts?state=open'
    response = requests.get(url, headers={'Authorization': f'token {token}'})

    if response.status_code == 200:
        alerts = response.json()
        return alerts
    else:
        print(f'Erro ao obter alertas do repositório {repository}: {response.status_code}')
        return False

def main():
    repositorios = ['', '', '']
    
    total_alerts = 0
    severity = {'low': 0, 'medium': 0, 'high': 0, 'critical': 0}

    for repo in repositorios:
        alerts = BOTalerts(repo)
        total_alerts += len(alerts)
        for alert in alerts:
            severity[alert['security_advisory']['severity']] += 1

    print(f'Total de Alertas do DependaBot: {total_alerts}')
    for s, c in severity.items():
        print(f'Severidade {s}: {c}')

if __name__ == '__main__':
    main()
