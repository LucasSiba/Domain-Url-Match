#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

use constant DEBUG => 1;
use constant MAX_DEBUG => 0;

use URI::URL;
URI::URL::strict(0);

if (@ARGV != 2) {
    print "USAGE:\n  $0 <domain-list> <url-list>\n";
    exit 1;
}

my $DOMAINS_FILE_NAME = $ARGV[0];
my $URLS_FILE_NAME    = $ARGV[1];

open my $DOMAINS_FD, "<$DOMAINS_FILE_NAME" or die "$DOMAINS_FILE_NAME: $!\n";
open my $URLS_FD,    "<$URLS_FILE_NAME"    or die "$URLS_FILE_NAME: $!\n";

my $counter = 0;

# Read the domains list and store in sorted list (with the domain names reversed)
my @DOMAINS = ();
for (<$DOMAINS_FD>) {
    chomp;
    my $orig_dom = $_;
    next unless $orig_dom;
    next if ($orig_dom =~ m/^#/);
    $orig_dom = reverse $orig_dom;
    $orig_dom = lc $orig_dom;
    push @DOMAINS, $orig_dom;
    print STDERR localtime()." - $counter domains loaded\n" if ++$counter % 500000 == 0 && DEBUG;
}

print STDERR localtime()." - domain file loaded (".@DOMAINS." entries)\n" if DEBUG;
@DOMAINS = sort @DOMAINS;
print STDERR localtime()." - domain list sorted\n" if DEBUG;

$counter = 0;

# Read the URL list and store as a list of hashes (hash include the original URL
# as read, and the domain name reversed)
my @URLS = ();
for (<$URLS_FD>) {
    chomp;
    my $url_orig = $_;
    next unless $url_orig;
    next if ($url_orig =~ m/^#/);
    my $url_obj;
    if ($url_orig =~ /^https?:\/\//) {
       $url_obj = new URI::URL $url_orig;
    } else {
       $url_obj = new URI::URL 'http://'.$url_orig;
    }
    if (!$url_obj->can("host")) {
        print STDERR localtime()." - failed to parse $url_orig\n" if DEBUG;
        next;
    }
    my $dom = reverse $url_obj->host;
    $dom = lc $dom;
    push @URLS, {'url' => $url_orig, 'dom' => $dom};
    print STDERR localtime()." - $counter urls loaded\n" if ++$counter % 250000 == 0 && DEBUG;
}

print STDERR localtime()." - url file loaded (".@URLS." entries)\n" if DEBUG;
@URLS = sort {$a->{dom} cmp $b->{dom}} @URLS;
print STDERR localtime()." - url list sorted\n" if DEBUG;

$counter = @URLS + @DOMAINS;

my $url = shift(@URLS);
my $dom = shift(@DOMAINS);

while (1) {
    print STDERR "comparing '$dom' <=> '$url->{dom}'\n" if MAX_DEBUG;

    # exact match, or URL is a sub-domain of the domain
    if ($url->{dom} eq $dom || $url->{dom} =~ m/^\Q$dom\E\./) {
        print "$url->{url}\n";
        $url = shift(@URLS);
    } else {
        if (($dom cmp $url->{dom}) > 0) {
            $url = shift(@URLS);
        } else {
            $dom = shift(@DOMAINS);
        }
    }
   
    print STDERR localtime()." - $counter comparisons remaining\n" if --$counter % 500000 == 0 && DEBUG;
    last if (!defined $url || !defined $dom); 
}

