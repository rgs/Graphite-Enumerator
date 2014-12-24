#!perl

use 5.14.1;
use Graphite::Enumerator;

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

$gren->enumerate( sub {
    my ($path) = @_;
    say $path;
} );
