package Helper;

use strict;
use warnings;
use lib "../lib/";
use Sentra::Utils::Helper;
use Test::More;

subtest 'Helper' => sub {
    plan tests => 6;

    my $helper_output = Sentra::Utils::Helper->new();

    ok(defined $helper_output, 'Helper output is defined');
    is(ref $helper_output, '', 'Helper output is a string');

    like($helper_output, qr/Sentra \s v0\.0\.1/x, 'Contains version information');
    like($helper_output, qr/Core \s Commands/x, 'Contains "Core Commands" section');

    my @expected_options = (
        '-o, --org',
        '-t, --token',
        '-w, --webhook',
        '-m, --message',
        '-mt, --maintained',
        '-d, --dependency',
        '-p, --per_page',
    );

    my @missing_options;
    for my $option (@expected_options) {
        push @missing_options, $option unless $helper_output =~ m/\Q$option\E/x;
    }

    is(scalar @missing_options, 0, 'All expected command options are present')
        or diag "Missing options: " . join ", ", @missing_options;

    my $options_debug = "Options found:\n";
    for my $option (@expected_options) {
        $options_debug .= sprintf "%s: %s\n", $option, $helper_output =~ m/\Q$option\E/x ? "Yes" : "No";
    }
    diag $options_debug;
    pass('Printed debug information about options');
};

done_testing();

1;
