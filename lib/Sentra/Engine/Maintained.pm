package Sentra::Engine::Maintained {
    use strict;
    use warnings;
    use JSON;
    use DateTime;
    use DateTime::Format::ISO8601;
    use Sentra::Utils::UserAgent;
    use Sentra::Utils::Repositories_List;

    sub new {
        my ($class, $org, $token, $per_page) = @_;
        
        my $output            = '';
        my $userAgent         = Sentra::Utils::UserAgent -> new($token);
        my @repositories_list = Sentra::Utils::Repositories_List -> new($org, $token);
        
        foreach my $repository (@repositories_list) {
            my $get_commits  = $userAgent -> get("https://api.github.com/repos/$repository/commits");

            if ($get_commits -> code() == 200) {
                my $commits = decode_json($get_commits -> content());
                        
                if (@$commits) {
                    my $last_commit_date_str = $commits->[0]{commit}{committer}{date};
                    my $last_commit_date     = DateTime::Format::ISO8601 -> parse_datetime($last_commit_date_str);
                            
                    if (DateTime -> now -> subtract(days => 90) > $last_commit_date) {
                        $output .= "The repository https://github.com/$repository has not been updated for more than 90 days.\n";
                    }
                }
            }    
        }

        return $output;
    }
}

1;