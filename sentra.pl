#!/usr/bin/env perl

use 5.030;
use strict;
use warnings;
use lib './lib/';
use Getopt::Long qw(:config no_ignore_case);
use Sentra::Utils::Helper;
use Sentra::Engine::Maintained;
use Sentra::Engine::SearchFiles;
use Sentra::Engine::SlackWebhook;
use Sentra::Engine::DependabotMetrics;

sub main {
    my ($org, $token, $webhook, $message, $help, %options);
    
    my $per_page = 100;
    
    GetOptions (
        'o|org=s'       => \$org,
        't|token=s'     => \$token,
        'w|webhook=s'   => \$webhook,
        'm|message=s'   => \$message,
        'h|help'        => \$help,
        'mt|maintained' => \$options{'maintained'},
        'd|dependency'  => \$options{'dependency'},
        'M|metrics'     => \$options{'metrics'},
    );

    my %dispatch_table = (
        'metrics'    => sub { Sentra::Engine::DependabotMetrics->new($org, $token, $per_page) },
        'dependency' => sub { Sentra::Engine::SearchFiles->new($org, $token, $per_page) },
        'maintained' => sub { Sentra::Engine::Maintained->new($org, $token, $per_page) },
    );

    for my $option (keys %options) {
        if ($options{$option} && exists $dispatch_table{$option}) {
            print $dispatch_table{$option}->();
        }
    }

    if ($webhook && $message) {
        return Sentra::Engine::SlackWebhook -> new($message, $webhook) -> send();
    }

    if ($help) {
        print Sentra::Utils::Helper -> new();
        
        return 0;
    }

    return 1;
}

exit main();