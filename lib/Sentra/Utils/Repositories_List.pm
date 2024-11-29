package Sentra::Utils::Repositories_List {
    use strict;
    use warnings;
    use JSON;
    use Sentra::Utils::UserAgent;
    
    sub new {
        my ($self, $org, $token) = @_;

        my @repos;
        my $page = 1;
        my $userAgent = Sentra::Utils::UserAgent -> new($token);

        while (1) {
            my $url      = "https://api.github.com/orgs/$org/repos?per_page=100&page=$page";
            my $response = $userAgent -> get($url);

            if ($response -> code() == 200) {
                my $data  = decode_json($response -> content());
                
                if (scalar(@$data) == 0) {
                    last;
                }

                for my $repo (@$data) {
                    push @repos, "$org/$repo->{name}" unless $repo->{archived};
                }

                $page++;
            }
        }

        return @repos;
    }
}

1;