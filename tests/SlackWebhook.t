package SlackWebhook;

use strict;
use warnings;
use lib "../lib/";
use Test::More;
use Test::MockModule;
use Sentra::Engine::SlackWebhook;
use Mojo::Transaction::HTTP;

my $mock_ua = Test::MockModule->new('Mojo::UserAgent');
$mock_ua->mock('post', sub {
    my ($self, $url, $headers, $payload) = @_;
    my $tx = Mojo::Transaction::HTTP->new;
    $tx->res->code(200);
    $tx->res->body('ok');
    return $tx;
});

subtest 'SlackWebhook' => sub {
    plan tests => 1;
    my $webhook = Sentra::Engine::SlackWebhook->new('Test message', 'https://hooks.slack.com/services/xxx/yyy/zzz');
    like($webhook, qr/Message sent successfully/, 'Webhook message sent successfully');
};

done_testing();

1;