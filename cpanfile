requires "Getopt::Long", "2.54";
requires "Mojo::UserAgent";
requires "LWP::UserAgent";
requires "JSON";
requires "DateTime::Format::ISO8601";
requires "DateTime";

on 'test' => sub {
    requires "Test::More";
    requires "Test::MockModule";
    requires "Mojo::Transaction::HTTP";
};