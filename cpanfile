requires "Getopt::Long", "2.54";
requires "Mojo::UserAgent";
requires "JSON";
requires "DateTime";
requires "DateTime::Format::ISO8601";

on 'test' => sub {
    requires "Test::More";
    requires "Test::MockModule";
    requires "Mojo::Transaction::HTTP";
};
