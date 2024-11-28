package Sentra::Utils::Helper {
    use strict;
    use warnings;

    sub new {
        return "
            \rSentra v0.0.3
            \rCore Commands
            \r==============
            \r\tCommand                         Description
            \r\t-------                         -----------
            \r\t-o, --org                       Specify the name of the organization
            \r\t-t, --token                     Set the GitHub Token to use during actions
            \r\t-mt, --maintained               Get alerts about repositories with a last commit date greater than 90 days old
            \r\t-d, --dependency                Check if repositories has dependabot.yaml file
            \r\t-M, --metrics                   See some metrics based on GHAS
            \r\t-w, --webhook                   Set the webhook address for Slack
            \r\t-m, --message                   Message to send via Slack webhook\n\n";
    }
}

1;