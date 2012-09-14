use strict;
use warnings;
use utf8;
use Test::More;
use lib 'lib';
use Net::DNS::Paranoid;
use t::MockResolver;

my $resolver = do {
    my $mock_resolver = t::MockResolver->new;

    # Record pointing to localhost:
    {
        my $packet = Net::DNS::Packet->new;
        $packet->push(answer => Net::DNS::RR->new("localhost-fortest.danga.com. 86400 A 127.0.0.1"));
        $mock_resolver->set_fake_record("localhost-fortest.danga.com", $packet);
    }

    # CNAME to blocked destination:
    {
        my $packet = Net::DNS::Packet->new;
        $packet->push(answer => Net::DNS::RR->new("bradlj-fortest.danga.com 300 IN CNAME brad.lj"));
        $mock_resolver->set_fake_record("bradlj-fortest.danga.com", $packet);
    }

    $mock_resolver;
};

my $dns = Net::DNS::Paranoid->new(resolver => $resolver);
$dns->blocked_hosts( [ qr/\.lj$/, "1.2.3.6", ] );

subtest 'random IP address forms' => sub {
    is_deeply( [ $dns->resolve('0x7f.1') ],
        [ undef, 'DNS lookup resulted in bad host.' ] );
};

subtest 'test the the blocked host above in decimal form is blocked by this non-decimal form' => sub {
    is_deeply( [ $dns->resolve('0x01.02.0x306') ],
        [ undef, 'DNS lookup resulted in bad host.' ] );
};

done_testing;

