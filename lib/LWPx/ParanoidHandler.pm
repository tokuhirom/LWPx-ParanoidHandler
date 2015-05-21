package LWPx::ParanoidHandler;
use strict;
use warnings;
use 5.008008;
our $VERSION = '0.07';
use parent qw/Exporter/;
use Net::DNS::Paranoid;

our @EXPORT = qw/make_paranoid/;

sub make_paranoid {
    my ($ua, $paranoid) = @_;
    $ua->add_handler(request_send => _paranoid_handler($paranoid));
}

sub _paranoid_handler {
    my ($paranoid) = @_;
    $paranoid ||= Net::DNS::Paranoid->new();

    sub {
        my ($request, $ua, $h) = @_;
        $request->{_time_begin} ||= time();

        my $host = $request->uri->host;
        my ($addrs, $errmsg) = $paranoid->resolve($host, $request->{_time_begin});
        if ($errmsg) {
            my $err_res = HTTP::Response->new(403, "Unauthorized access to blocked host($errmsg)");
            $err_res->request($request);
            $err_res->header("Client-Warning" => "Internal response");
            $err_res->header("Content-Type" => "text/plain");
            $err_res->content("403 Unauthorized access to blocked host\n");
            return $err_res;
        }
        return; # fallthrough
    }
}

1;
__END__

=encoding utf8

=head1 NAME

LWPx::ParanoidHandler - Handler for LWP::UserAgent that protects you from harm

=head1 SYNOPSIS

    use LWPx::ParanoidHandler;
    use LWP::UserAgent;

    my $ua = LWP::UserAgent->new();
    make_paranoid($ua);

    my $res = $ua->request(GET 'http://127.0.0.1/');
    # my $res = $ua->request(GET 'http://google.com/');
    use Data::Dumper; warn Dumper($res);
    warn $res->status_line;

=head1 DESCRIPTION

LWPx::ParanoidHandler is a clever firewall for L<LWP::UserAgent>.

This module provides a handler to prevent a request from reaching or
being (re)directed to internal servers, loopbacks, or multicast
addresses.

It is useful when implementing OpenID servers, crawlers, etc.

=head1 FUNCTIONS

=over 4

=item make_paranoid($ua[, $dns]);

Make your LWP::UserAgent instance paranoid.

The optional $dns argument is an instance of L<Net::DNS::Paranoid>.
Useful if you want to add your own blocked_hosts or whitelisted_hosts,
or adjust the timeout on DNS lookups.

=back

=head1 FAQ

=over 4

=item How can I set a timeout for the whole request?

L<LWP::UserAgent> does not provide a timeout over the whole request
(its timeout is only on inactivity on the server connection). Since
LWPx::ParanoidHandler uses LWP::UserAgent's handler protocol, it
cannot change this.

You may want to protect your whole request with a timeout to stop it
getting stuck in a malicious tar-pit (as provided by the timeout in
L<LWPx::ParanoidAgent>).

You can do this as follows by using alarm():

    my $res = eval {
        local $SIG{ALRM} = sub { die "ALRM\n" };
        alarm(10);
        my $res = $ua->get($url);
        alarm(0);
        $res;
    };
    $res = HTTP::Response->new(500, 'Timeout') unless $res;

And I recommend using L<Furl>. Furl can handle per-request timeouts
cleanly.

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>

=head1 SEE ALSO

L<LWPx::ParanoidAgent> has the same feature as this module. But it's
not currently maintained, and it's too hack-ish. LWPx::ParanoidHandler
uses the handler protocol provided by LWP::UserAgent, which is safer.

This module uses a lot of code taken from LWPx::ParanoidAgent, thanks.

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
