#!/usr/bin/perl

use strict;

use Client;
use Getopt::Long;
use JSON::PP;

my $config_name = "config.json";
my $body_name;
my $name = "Trade|Subspace|Mission|Port";

GetOptions(
  "config=s" => \$config_name,
  "name=s"   => \$name,
) or die "$0 --config=foo.json --body=Bar\n";

my $client = Client->new(config => $config_name);
my $planets = $client->empire_status->{planets};

my %plans;
for my $body_id (sort { $planets->{$a} cmp $planets->{$b} } keys(%$planets)) {
  print "$planets->{$body_id}:\n";
  my $buildings = $client->body_buildings($body_id);
  my @buildings = map { { %{$buildings->{buildings}{$_}}, id => $_ } } keys(%{$buildings->{buildings}});
  my %buildings = map { $_->{name}, $_->{id} } @buildings;
  my %levels    = map { $_->{name}, $_->{level} } sort { $a->{level} <=> $b->{level} } @buildings;
  printf("  %-22slevel %2d, id %d\n", "$_:", $levels{$_}, $buildings{$_}) for (sort grep { /$name/ } keys %buildings);
}