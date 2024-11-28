package Sentra::Utils::Helper {
    use strict;
    use warnings;

    sub new {
        return <<"EOT";

Sentra v0.0.1
Core Commands
==============
Command                         Description
-------                         -----------
-o, --org                       Specify the name of the organization
-t, --token                     Set the GitHub Token to use during actions
-w, --webhook                   Set the webhook address for Slack
-m, --message                   Message to send via Slack webhook
-mt, --maintained               Check last commit date of repositories
-d, --dependency                Check for dependabot.yaml file in repositories
-p, --per_page                  Set the number of items per page in API requests (default: 100)

EOT
    }
}

1;