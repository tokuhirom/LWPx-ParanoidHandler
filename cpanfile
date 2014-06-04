requires 'Exporter';
requires 'LWP', '6';
requires 'Net::DNS::Paranoid', '0.07';
requires 'parent';
requires 'perl', '5.010001';

on build => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Requires';
};
