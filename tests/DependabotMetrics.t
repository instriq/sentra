package DependabotMetrics;

use strict;
use warnings;
use lib "../lib/";
use Test::More;
use Test::MockModule;
use Sentra::Engine::DependabotMetrics;
use Mojo::Transaction::HTTP;

my $repo_page_count = 0;
my $alert_page_count = 0;

my $mock_ua = Test::MockModule->new('Mojo::UserAgent');
$mock_ua->mock('get', sub {
    my ($self, $url) = @_;
    my $tx = Mojo::Transaction::HTTP->new;

    if ($url =~ /\/repos\?/x) {
        $repo_page_count++;
        if ($repo_page_count < 3) {
            $tx->res->code(200);
            $tx->res->body('[{"name":"repo1","archived":false},{"name":"repo2","archived":true}]');
            return $tx;
        }
        $tx->res->code(200);
        $tx->res->body('[]');
    }
    elsif ($url =~ /\/dependabot\/alerts/x) {
        $alert_page_count++;
        if ($alert_page_count == 1) {
            $tx->res->code(200);
            $tx->res->body('[{"security_vulnerability":{"severity":"high"}},{"security_vulnerability":{"severity":"low"}}]');
            return $tx;
        }

        $tx->res->code(200);
        $tx->res->body('[]');
    }

    return $tx;
});

subtest 'DependabotMetrics' => sub {
    plan tests => 3;

    my $metrics = Sentra::Engine::DependabotMetrics->new('test-org', 'test-token', 100);

    like($metrics, qr/Severity\ high:\ 1/x, 'High severity alert counted');
    like($metrics, qr/Severity\ low:\ 1/x, 'Low severity alert counted');
    like($metrics, qr/Total\ DependaBot\ Alerts:\ 2/x, 'Total alerts counted correctly');
};

done_testing();

1;