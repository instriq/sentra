#!/usr/bin/env python3
import requests
import argparse
import sys

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
    parser.add_argument("-m", "--message", help="Enter what you want to send or use this with STDIN.\n\ne.g. $ ./slack_webhook.py --message/-m \"something[...]\"\nor\n$ echo -n \"bla bla bla\" | ./slack_webhook.py --webhook \"https://webhook_url/\"")
    parser.add_argument('--webhook', help='Set the webhook adress', required=True)

    args = parser.parse_args()

    if args.message:
        print(message(args.message, args.webhook))
    else:
        data = sys.stdin.read()
        if data:
            print(message(data, args.webhook))
        else:
            print("No input data provided.")

if __name__ == '__main__':
    main()
