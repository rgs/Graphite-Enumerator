#!perl

# Finds all metrics in the general.metrics.* namespace that have
# not been written to in the last day.

use 5.14.1;
use Graphite::Enumerator;
use JSON;

my $interval = '1day';
my $verbose = 0;

my $gren = Graphite::Enumerator->new(
    host => 'https://graphite.example.com',
    basepath => 'general.metrics',
    lwp_options => {
        env_proxy => 0,
        keep_alive => 1,
    },
);

$gren->enumerate( sub {
    my ($path) = @_;
    my $last_hour_data_url = $gren->host . "render/?format=json&from=-$interval&target=summarize($path,%22$interval%22,%22max%22,true)";
    my $res = $gren->ua->get($last_hour_data_url);
    if ($res->is_success) {
        my $last_hour_data = decode_json($res->content);
        return if !$last_hour_data || !@$last_hour_data;
        my $datapoint = $last_hour_data->[0]{datapoints}[0][0];
        if (defined $datapoint) {
            say "> $path is still used" if $verbose;
        }
        else {
            say "> $path is no longer used";
        }
    }
    else {
        $gren->log_warning("Can't get <$last_hour_data_url>: " . $res->status_line);
    }
} );
