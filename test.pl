#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;
use lib 'lib';

use LWP::UserAgent;
use LWPx::ParanoidHandler;

my $ua = LWP::UserAgent->new();
$ua->add_handler(request_send => paranoid_handler());

{
    my $res = $ua->get('http://127.0.0.1/');
    say $res->status_line;
}

{
    my $res = $ua->get('http://google.com/');
    say $res->status_line;
}

