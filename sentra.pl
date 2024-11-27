#!/usr/bin/env perl

use 5.030;
use strict;
use warnings;
use Getopt::Long;
use lib './lib/';
use Sentra::Engine::DependabotMetrics;
use Sentra::Engine::SearchFiles;
use Sentra::Engine::SlackWebhook;
use Sentra::Utils::Helper;

sub main {
    my ($org, $token, $webhook, $message, $maintained, $dependency, $per_page);

    GetOptions(
        'o|org=s'        => \$org,
        't|token=s'      => \$token,
        'w|webhook=s'    => \$webhook,
        'm|message=s'    => \$message,
        'mt|maintained'  => \$maintained,
        'd|dependency'   => \$dependency,
        'p|per_page=i'   => \$per_page
    );

    $per_page ||= 100;

    my %actions = (
        'dependabot-metrics' => ($org && $token && !$maintained && !$dependency)
            ? sub { Sentra::Engine::DependabotMetrics->new($org, $token, $per_page) }
            : undef,
        'repository-check' => ($org && $token && ($maintained || $dependency))
            ? sub { Sentra::Engine::SearchFiles->new($org, $token, $maintained, $dependency, $per_page) }
            : undef,
        'send-webhook' => ($webhook)
            ? sub { Sentra::Engine::SlackWebhook->new($message, $webhook) }
            : undef,
    );

    for my $action (grep { defined } values %actions) {
        print $action->();
        return 0;
    }

    print Sentra::Utils::Helper->new();
    return 1;
}

exit main();
