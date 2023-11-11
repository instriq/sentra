<p align="center">
  <p align="center"><b>Runbooks</b></p>

---

### Summary

This project provides scripts that will assist and improve operations involving the security and maturity of your project. For example, [DependaBot.py](https://github.com/instriq/runbooks/blob/main/DependaBot.py) is responsible for analyzing [DependaBot](https://github.com/dependabot) alerts in a specific organization's GitHub repositories and listing the level of severity of its alerts, while [Slack.py](https://github.com/instriq/runbooks/blob/main/slack.py) aims to direct an arbitrary output to a Slack WebHook channel.

The idea is that our independent scripts work together in harmony to provide more practicality, maturity and security for your projects.

---

### Github Actions

You need to generate a token with:
- ✅ repo - Full control of private repositories
- ✅ read:org - Read org and team membership, read org projects
  
Next, you need to insert the generated token into the `token` variable at the beginning of the [DependaBot.py](https://github.com/instriq/runbooks/blob/main/DependaBot.py) script:

```python
#!/usr/bin/env python3

import requests
import argparse

token = 'YOUR_TOKEN_HERE'

[...]
```

---

### Installation and basic usability

```bash
# Download
$ git clone https://github.com/instriq/runbooks && cd runbooks
    
# Install libs dependencies and make it executable
$ pip3 install -r requirements.txt && chmod +x DependaBot.py slack.py

# DependaBot basic usage
$ ./DependaBot.py --help


# DependaBot.py v0.0.1
-----------------
usage: DependaBot.py [-h] --org ORG

A script that fetches and analyzes DependaBot alerts from GitHub repositories
of a specified organization.

options:
  -h, --help  show this help message and exit
  --org ORG   Specify the name of the organization for which you want to
              retrieve DependaBot alerts. e.g. DependaBot.py --org org_name 


# slack.py v0.0.1
-----------------
usage: slack.py [-h] -m MESSAGE

An output forwarder script for webhooks in Slack.

options:
  -h, --help            show this help message and exit
  -m MESSAGE, --message MESSAGE
                        Enter what you want to send. e.g. slack.py
                        --message/-m "something[...]"
```

---

### Contribution

Your contributions and suggestions are heartily ♥ welcome. [See here the contribution guidelines.](/.github/CONTRIBUTING.md) Please, report bugs via [issues page](https://github.com/instriq/security-gate/issues) and for security issues, see here the [security policy.](/SECURITY.md) (✿ ◕‿◕)

---

### License

This work is licensed under [MIT License.](/LICENSE.md)