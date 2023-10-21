#!/usr/bin/env python3

import requests
import argparse

def message(data, webhook):
    try:
        payload = {"text": data}
        headers = {"Content-type": "application/json"}
        response = requests.post(webhook, json=payload, headers=headers)

        if response.status_code == 200:
            return f"Message sent successfully! [{response.text}]"

        return f"Failed to send message: [{response.status_code}]"
    
    except requests.exceptions.RequestException as e:
        return f"Error sending message: {str(e)}"


def main():
    parser = argparse.ArgumentParser(description="An output forwarder script for webhooks.")
    parser.add_argument("-m", "--message", help="Enter what you want to send.\n\ne.g. slack.py --message/-m \"something[...]\"", required=True)
    parser.add_argument('--webhook', help='Set the webhook adress', required=True)

    args = parser.parse_args()

    if args.message:
        try:
            return message(args.message, args.webhook)
        except EOFError:
            exit(1)

if __name__ == '__main__':
    print (main())