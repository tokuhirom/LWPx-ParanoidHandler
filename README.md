# NAME

LWPx::ParanoidHandler - Handler for LWP::UserAgent that protects you from harm

# SYNOPSIS

    use LWPx::ParanoidHandler;
    use LWP::UserAgent;

    my $ua = LWP::UserAgent->new();
    make_paranoid($ua);

    my $res = $ua->request(GET 'http://127.0.0.1/');
    # my $res = $ua->request(GET 'http://google.com/');
    use Data::Dumper; warn Dumper($res);
    warn $res->status_line;

# DESCRIPTION

LWPx::ParanoidHandler is a clever firewall for [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent).

This module provides a handler to prevent a request from reaching or
being (re)directed to internal servers, loopbacks, or multicast
addresses.

It is useful when implementing OpenID servers, crawlers, etc.

# FUNCTIONS

- make\_paranoid($ua\[, $dns\]);

    Make your LWP::UserAgent instance paranoid.

    The optional $dns argument is an instance of [Net::DNS::Paranoid](https://metacpan.org/pod/Net::DNS::Paranoid).
    Useful if you want to add your own blocked\_hosts or whitelisted\_hosts,
    or adjust the timeout on DNS lookups.

# FAQ

- How can I set a timeout for the whole request?

    [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent) does not provide a timeout over the whole request
    (its timeout is only on inactivity on the server connection). Since
    LWPx::ParanoidHandler uses LWP::UserAgent's handler protocol, it
    cannot change this.

    You may want to protect your whole request with a timeout to stop it
    getting stuck in a malicious tar-pit (as provided by the timeout in
    [LWPx::ParanoidAgent](https://metacpan.org/pod/LWPx::ParanoidAgent)).

    You can do this as follows by using alarm():

        my $res = eval {
            local $SIG{ALRM} = sub { die "ALRM\n" };
            alarm(10);
            my $res = $ua->get($url);
            alarm(0);
            $res;
        };
        $res = HTTP::Response->new(500, 'Timeout') unless $res;

    And I recommend using [Furl](https://metacpan.org/pod/Furl). Furl can handle per-request timeouts
    cleanly.

# AUTHOR

Tokuhiro Matsuno <tokuhirom AAJKLFJEF@ GMAIL COM>

# SEE ALSO

[LWPx::ParanoidAgent](https://metacpan.org/pod/LWPx::ParanoidAgent) has the same feature as this module. But it's
not currently maintained, and it's too hack-ish. LWPx::ParanoidHandler
uses the handler protocol provided by LWP::UserAgent, which is safer.

This module uses a lot of code taken from LWPx::ParanoidAgent, thanks.

# LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
