package LWPx::ParanoidHandler;
use strict;
use warnings;
use 5.008008;
our $VERSION = '0.01';
use parent qw/Exporter/;
use Net::DNS::Paranoid;

our @EXPORT = qw/paranoid_handler/;

sub paranoid_handler {
    my ($paranoid) = @_;
    $paranoid ||= Net::DNS::Paranoid->new();

    sub {
        my ($request, $ua, $h) = @_;

        my $host = $request->uri->host;
        if ($paranoid->is_bad_host($host)) {
            my $err_res = HTTP::Response->new(403, "Unauthorized access to blocked host");
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
    $ua->add_handler(request_send => paranoid_handler());

    my $res = $ua->request(GET 'http://127.0.0.1/');
    # my $res = $ua->request(GET 'http://google.com/');
    use Data::Dumper; warn Dumper($res);
    warn $res->status_line;

=head1 DESCRIPTION

LWPx::ParanoidHandler is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
