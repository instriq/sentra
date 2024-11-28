package Sentra::Engine::DependabotMetrics {
    use strict;
    use warnings;
    use Mojo::UserAgent;
    use Mojo::JSON qw(decode_json);

    sub new {
        my ($class, $org, $token, $per_page) = @_;
        
        my $userAgent = Mojo::UserAgent -> new();
        
        my $headers = {
            'X-GitHub-Api-Version' => '2022-11-28',
            'Accept'               => 'application/vnd.github+json',
            'User-Agent'           => 'Sentra 0.0.2',
            'Authorization'        => "Bearer $token"
        };

        my @repos;
        my $repo_page = 1;

        while (1) {
            my $repo_url = "https://api.github.com/orgs/$org/repos?per_page=$per_page&page=$repo_page";
            my $repo_tx  = $userAgent -> get($repo_url => $headers);
            my $res      = $repo_tx -> result or return "Error fetching repositories: " . $repo_tx->error->{message} . "\n";
            
            $res->is_success or return "Error fetching repositories: " . $res->message . "\n";

            my $repo_data = $res -> json;
            
            last unless @$repo_data;
            
            push @repos, map { "$org/$_->{name}" } grep { !$_->{archived} } @$repo_data;
            
            $repo_page++;
        }

        return "Error when trying to request information from GitHub, please review the parameters provided." unless @repos;

        my $total_alerts = 0;
        my %severity_count = (low => 0, medium => 0, high => 0, critical => 0);

        for my $repo (@repos) {
            my $alert_page = 1;

            while (1) {
                my $alert_url = "https://api.github.com/repos/$repo/dependabot/alerts?state=open&per_page=$per_page&page=$alert_page";
                my $alert_tx  = $userAgent->get($alert_url => $headers);
                my $res       = $alert_tx->result or return "Error fetching alerts for $repo: " . $alert_tx->error->{message} . "\n";
                
                $res->is_success or return "Error fetching alerts for $repo: " . $res->message . "\n";

                my $alert_data = $res->json;
                
                last unless @$alert_data;
                
                $total_alerts += scalar @$alert_data;
                
                for my $alert (@$alert_data) {
                    my $severity = $alert->{security_vulnerability}{severity} || 'unknown';
                    $severity_count{$severity}++ if exists $severity_count{$severity};
                }
                
                $alert_page++;
            }
        }

        my $output = "";
        
        $output .= "Severity $_: $severity_count{$_}\n" for keys %severity_count;
        $output .= "Total DependaBot Alerts: $total_alerts\n";

        return $output;
    }
}

1;