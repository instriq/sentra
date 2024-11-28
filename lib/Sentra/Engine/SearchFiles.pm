package Sentra::Engine::SearchFiles {
    use strict;
    use warnings;
    use Mojo::UserAgent;
    use Mojo::JSON qw(decode_json);
    use DateTime;
    use DateTime::Format::ISO8601;

    sub new {
        my ($class, $org, $token, $maintained, $dependency, $per_page) = @_;
        
        my $ua = Mojo::UserAgent->new;
        my $headers = {
            'Authorization' => "Bearer $token",
            'Accept' => 'application/vnd.github+json',
            'X-GitHub-Api-Version' => '2022-11-28'
        };

        my $output = '';

        my $repo_url = "https://api.github.com/orgs/$org/repos?per_page=$per_page";
        my $repo_tx = $ua->get($repo_url => $headers);

        my $res = $repo_tx->result or return "Error fetching repositories: " . $repo_tx->error->{message} . "\n";
        $res->is_success or return "Error fetching repositories: " . $res->message . "\n";

        my $repos = $res->json;
       
        for my $repo (@$repos) {
            next if $repo->{archived};
            
            my $full_name = "$org/$repo->{name}";

            if ($dependency) {
                my $dependabot_url = "https://api.github.com/repos/$full_name/contents/.github/dependabot.yaml";
                my $dependabot_tx = $ua->get($dependabot_url => $headers);
                
                $output .= "The dependabot.yml file was not found in this repository: https://github.com/$full_name\n"
                    if $dependabot_tx->result->code == 404;
            }

            if ($maintained) {
                my $commits_url = "https://api.github.com/repos/$full_name/commits";
                my $commits_tx = $ua->get($commits_url => $headers);
                my $commits_res = $commits_tx->result;
                
                if ($commits_res && $commits_res->is_success) {
                    my $commits = $commits_res->json;
                    
                    if (@$commits) {
                        my $last_commit_date_str = $commits->[0]{commit}{committer}{date};
                        my $last_commit_date = DateTime::Format::ISO8601->parse_datetime($last_commit_date_str);
                        
                        $output .= "The repository https://github.com/$full_name has not been updated for more than 90 days.\n"
                            if DateTime->now->subtract(days => 90) > $last_commit_date;
                    }
                }
            }
        }

        return $output || "No issues found.";
    }
}

1;