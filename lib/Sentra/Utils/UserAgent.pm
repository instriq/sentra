package Sentra::Utils::UserAgent {
    use strict;
    use warnings;
    use Mojo::UserAgent;

    sub new {
        my $userAgent = Mojo::UserAgent -> new();
        
        my $headers = {
            'X-GitHub-Api-Version' => '2022-11-28',
            'Accept'               => 'application/vnd.github+json',
            'User-Agent'           => 'Sentra 0.0.3',
            'Authorization'        => "Bearer $token"
        };

        return "";
    }
}

1;