package Sentra::Engine::DependabotMetrics {
    use strict;
    use warnings;
    use JSON;
    use Sentra::Utils::UserAgent;
    use Sentra::Utils::Repositories_List;

    sub new {
        my ($class, $org, $token, $per_page) = @_;
        
        my $userAgent = Sentra::Utils::UserAgent -> new($token);
        my @repositories_list = Sentra::Utils::Repositories_List -> new($org, $token);
        
        my $output         = "";
        my $total_alerts   = 0;
        my %severity_count = (
            low      => 0, 
            medium   => 0, 
            high     => 0, 
            critical => 0
        );

        foreach my $repository (@repositories_list) {
            my $alert_page = 1;
            my $alert_url  = "https://api.github.com/repos/$repository/dependabot/alerts?state=open&per_page=$per_page&page=$alert_page";
            my $request    = $userAgent -> get($alert_url);
                
            if ($request -> code() == 200) {
                my $alert_data = decode_json($request -> content());
                
                last unless @$alert_data;
                    
                $total_alerts += scalar @$alert_data;
                    
                for my $alert (@$alert_data) {
                    my $severity = $alert -> {security_vulnerability}{severity} || 'unknown';
                    
                    $severity_count{$severity}++ if exists $severity_count{$severity};
                }               
            }
        }
        
        $output .= "Severity $_: $severity_count{$_}\n" for keys %severity_count;
        $output .= "Total DependaBot Alerts: $total_alerts\n";

        return $output;
    }
}

1;