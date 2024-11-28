package SearchFiles;

use strict;
use warnings;
use lib "../lib/";
use Test::More;
use Test::MockModule;
use Sentra::Engine::SearchFiles;
use DateTime;
use Mojo::Transaction::HTTP;

my $mock_ua = Test::MockModule->new('Mojo::UserAgent');

$mock_ua->mock('get', sub {
    my ($self, $url) = @_;
    my $tx = Mojo::Transaction::HTTP->new;

    if ($url =~ /\/repos\?/x) {
        $tx->res->code(200);
        $tx->res->body('[{"name":"repo1","archived":false},{"name":"repo2","archived":true}]');
    }
    
    elsif ($url =~ /\/contents\/\.github\/dependabot\.yaml/x) {
        $tx->res->code(404);
    }
    
    elsif ($url =~ /\/commits/x) {
        my $date = DateTime->now->subtract(days => 100)->iso8601;
        $tx->res->code(200);
        $tx->res->body(qq{[{"commit":{"committer":{"date":"$date"}}}]});
    }
    
    return $tx;
});

subtest 'SearchFiles' => sub {
    plan tests => 2;
    my $search = Sentra::Engine::SearchFiles->new('test-org', 'test-token', 1, 1, 100);

    my $dependabot_msg_part1 = qr/The\ dependabot\.yml\ file\ was\ not\ found/x;
    my $repo_url_part1 = qr/in\ this\ repository:\s*/x;
    my $repo_url_part2 = qr/https:\/\/github\.com\/test-org\/repo1/x;

    my $not_found_msg = qr/$dependabot_msg_part1\s*$repo_url_part1\s*$repo_url_part2/x;

    my $old_repo_msg_part1 = qr/The\ repository\ /x;
    my $old_repo_url = qr/https:\/\/github\.com\/test-org\/repo1/x;
    my $old_repo_msg_part2 = qr/has\ not\ been\ updated\ for\ more\ than\ 90\ days/x;

    my $old_repo_msg_full = qr/$old_repo_msg_part1$old_repo_url\s*$old_repo_msg_part2/x;

    my $output = $search;

    like($output, $not_found_msg, 'Dependabot file not found');
    like($output, $old_repo_msg_full, 'Old repository detected');
};

done_testing();

1;