#!/usr/bin/perl

use strict;

use Client;
use Getopt::Long;
use JSON::PP;

my $config_name = "config.json";
my $body_name;

GetOptions(
  "config=s" => \$config_name,
) or die "$0 --config=foo.json --body=Bar\n";

my $client = Client->new(config => $config_name);
my $planets = $client->empire_status->{planets};

my %foods = (
  "Planetary Command Center",  "algae",
  "Malcud Fungus Farm",        "fungus",
  "Malcud Burger Packer",      "burger",
  "Algae Cropper",             "algae",
  "Algae Syrup Bottler",       "syrup",
  "Amalgus Bean Plantation",   "bean",
  "Amalgus Bean Soup Cannery", "soup",
  "Potato Patch",              "potato",
  "Potato Pancake Factory",    "pancake",
  "Denton Root Patch",         "root",
  "Denton Root Chip Frier",    "chip",
  "Corn Plantation",           "corn",
  "Corn Meal Grinder",         "meal",
  "Wheat Farm",                "wheat",
  "Bread Bakery",              "bread",
  "Beeldeban Herder",          "beetle",
  "Beeldeban Protein Shake Factory", "shake",
  "Apple Orchard",             "apple",
  "Apple Cider Bottler",       "cider",
  "Lapis Orchard",             "lapis",
  "Lapis Pie Bakery",          "pie",
  "Dairy Farm",                "milk",
  "Cheese Maker",              "cheese",
  "Algae Pond",                "algae",
  "Malcud Field",              "fungus",
  "Beeldeban Nest",            "beetle",
  "Lapis Forest",              "lapis",
  "Denton Brambles",           "root",
  "Amalgus Meadow",            "bean",
);

my %stats;
my %total = reverse %foods;
$total{$_} = 0 for keys %total;
for my $body_id (sort { $planets->{$a} cmp $planets->{$b} } keys(%$planets)) {
  my $buildings = $client->body_buildings($body_id);
  print "$planets->{$body_id}: orbit $buildings->{status}{body}{orbit}, net $buildings->{status}{body}{food_hour} food/hr\n";
  my @buildings = map { { %{$buildings->{buildings}{$_}}, id => $_ } } keys(%{$buildings->{buildings}});
  my @producers = grep { $foods{$_->{name}} } @buildings;
  my %produce;
  my %producers;
  for my $building (@producers) {
    $stats{$building->{name}}{$building->{level}} ||= 
      $client->building_stats_for_level($building->{url}, $building->{id}, $building->{level});
    my $rate = $stats{$building->{name}}{$building->{level}}{building}{food_hour};
    $producers{$foods{$building->{name}}}{$building->{name}}{$building->{level}}++;
    $produce{$foods{$building->{name}}} += $rate;
    $total{$foods{$building->{name}}} += $rate;
  }
  for my $food (sort keys %produce) {
    printf("  %-10s%8d/hour ", $food, $produce{$food});
    my @seq;
    for my $gen (sort keys %{$producers{$food}}) {
      my @list;
      for my $level (sort keys %{$producers{$food}{$gen}}) {
        push @list, "$producers{$food}{$gen}{$level}x$level"
      }
      push @seq, sprintf("%-32s ", $gen).join(", ", @list);
    }
    print join("; ", @seq)."\n";
  }
}
print "\nTotal:\n";
for my $food (sort keys %total) {
  printf("  %-10s%8d/hour\n", $food, $total{$food});
}
