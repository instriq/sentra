#!/usr/bin/env python3

import requests
import argparse

webhook = ''

def message(data):
    try:
        payload = {"text": data}
        headers = {"Content-type": "application/json"}
        response = requests.post(webhook, json=payload, headers=headers)

        if response.status_code == 200:
            print(f"Message sent successfully! [{response.text}]")
        else:
            print(f"Failed to send message: [{response.status_code}]")
    except requests.exceptions.RequestException as e:
        print(f"Error sending message: {str(e)}")


def main():
    parser = argparse.ArgumentParser(description="An output forwarder script for webhooks.")
    parser.add_argument("-m", "--message", help="Enter what you want to send.\n\ne.g. slack.py --message/-m \"something[...]\"", required=True)
    args = parser.parse_args()

    if args.message:
        try:
            message(args.message)
        except KeyboardInterrupt:
            exit(1)
        except EOFError:
            exit(1)

if __name__ == '__main__':
    main()