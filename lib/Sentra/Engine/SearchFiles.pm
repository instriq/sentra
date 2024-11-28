package Sentra::Engine::SearchFiles {
    use strict;
    use warnings;
    use Mojo::UserAgent;
    use Mojo::JSON qw(decode_json);

    sub new {
        my ($class, $org, $token, $per_page) = @_;
        
        my $userAgent = Mojo::UserAgent -> new();
        
        my $headers = {
            'Authorization'        => "Bearer $token",
            'Accept'               => 'application/vnd.github+json',
            'X-GitHub-Api-Version' => '2022-11-28'
        };

        my $output   = '';
        my $repo_url = "https://api.github.com/orgs/$org/repos?per_page=$per_page";
        my $repo_tx  = $userAgent -> get($repo_url => $headers);

        my $res = $repo_tx -> result();
        
        if ($res -> is_success) {
            my $repos = $res -> json();
       
            for my $repo (@$repos) {
                next if $repo -> {archived};
                
                my $full_name = "$org/$repo->{name}";

                my $dependabot_url = "https://api.github.com/repos/$full_name/contents/.github/dependabot.yaml";
                my $dependabot_tx = $userAgent -> get($dependabot_url => $headers);
                
                if ($dependabot_tx -> result -> code == 404) {
                    $output .= "The dependabot.yml file was not found in this repository: https://github.com/$full_name\n";
                }  
            }
        }

        return $output || "No issues found.";
    }
}

1;