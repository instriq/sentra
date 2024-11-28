package Sentra::Engine::SlackWebhook {
    use strict;
    use warnings;
    use Mojo::UserAgent;
    use Mojo::JSON qw(encode_json);

    sub new {
        my ($class, $message, $webhook) = @_;

        my $userAgent = Mojo::UserAgent -> new();
        my $payload   = encode_json({text => $message});

        my $tx = $userAgent -> post($webhook => {
            'Content-Type' => 'application/json'
        } => $payload);

        my $res = $tx -> result;
        
        unless ($res) {
            my $err = $tx->error;
            return "Failed to send message: [" . ($err->{message} || "Unknown error") . "]\n";
        }

        return "Failed to send message: [" . $res->message . "]\n" unless $res->is_success;

        return "Message sent successfully! [" . $res->body . "]\n";
    }
}

1;