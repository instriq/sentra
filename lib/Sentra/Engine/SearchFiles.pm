package Sentra::Engine::SearchFiles {
    use strict;
    use warnings;
    use JSON;
    use Sentra::Utils::UserAgent;
    use Sentra::Utils::Repositories_List;

    sub new {
        my ($class, $org, $token, $per_page) = @_;
        
        my $output            = '';
        my $userAgent         = Sentra::Utils::UserAgent -> new($token);
        my @repositories_list = Sentra::Utils::Repositories_List -> new($org, $token);
        my @files             = (".github/dependabot.yaml");

        foreach my $repository (@repositories_list) {
            foreach my $file (@files) {
                my $dependabot_url = "https://api.github.com/repos/$repository/contents/$file";
                my $request        = $userAgent -> get($dependabot_url);
                    
                if ($request -> code == 404) {
                    $output .= "The $file file was not found in this repository: https://github.com/$repository\n";
                }  
            }
        }

        return $output;
    }
}

1;