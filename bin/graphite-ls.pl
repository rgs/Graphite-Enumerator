#!perl

use 5.14.1;
use Graphite::Enumerator;

@ARGV or do {
    print <<USAGE;
Usage: $0 http://graphite.example.com my.metric.prefix
USAGE
    exit;
};
my $host = shift; # e.g. 'http://graphite.example.com'
my $basepath = shift // '';
my $gren = Graphite::Enumerator->new(
    host => $host,
    basepath => $basepath,
    lwp_options => {
        env_proxy => 0,
        keep_alive => 1,
    },
);

my $count = $gren->enumerate( sub {
    my ($path) = @_;
    say $path;
} );
say "- $count metrics found";
