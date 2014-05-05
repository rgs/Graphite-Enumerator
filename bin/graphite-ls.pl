#!perl

use 5.14.1;
use Graphite::Enumerator;
use JSON;

my $basepath = shift // '';
my $gren = Graphite::Enumerator->new(
    host => 'https://graphite.example.com',
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
