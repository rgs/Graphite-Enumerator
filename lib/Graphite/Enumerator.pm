package Graphite::Enumerator;

use 5.14.1;
use Carp qw/croak/;
use LWP::UserAgent;
use JSON;

# Recognized constructor options:
# - host (base URL)
# - basepath (top-level metric to scan)
# - lwp_options (hashref)

sub new {
    my ($class, %args) = @_;
    $args{host} or croak "No host provided";
    $args{host} =~ m{^https?://} or $args{host} = "http://".$args{host};
    $args{host} =~ m{/$} or $args{host} .= '/';
    if (defined $args{basepath}) {
        $args{basepath} =~ /\.$/ or $args{basepath} .= '.';
    }
    else {
        $args{basepath} = '';
    }
    $args{_finder} = $args{host} . 'metrics/find?format=completer&query=';
    $args{_ua} = LWP::UserAgent->new( %{ $args{lwp_options} || {} } );
    bless \%args, $class;
}

sub enumerate {
    my ($self, $callback, $path) = @_;
    $path //= $self->{basepath};
    my $url = $self->{_finder} . $path;
    my $res = $self->{_ua}->get($url);
    if ($res->is_success) {
        my $completer_answer = eval { decode_json($res->content) };
        if (!$completer_answer) {
            $self->log_warning("URL <$url>: Couldn't decode JSON string: <" . $res->content . ">: $@");
            return 0;
        }
        return 0 if !$completer_answer->{metrics};
        for my $metric (@{ $completer_answer->{metrics} }) {
            if ($metric->{is_leaf}) {
                $callback->($metric->{path});
            }
            else {
                $self->enumerate($callback, $metric->{path});
            }
        }
        return 1;
    }
    else {
        $self->log_warning("Can't get <$url>: " . $res->status_line);
        return 0;
    }
}

sub host {
    my ($self) = @_;
    return $self->{host};
}

sub ua {
    my ($self) = @_;
    return $self->{_ua};
}

sub log_message {
    my ($self, $message) = @_;
    print $message, "\n";
}

sub log_warning {
    my ($self, $message) = @_;
    warn $message, "\n";
}

1;
