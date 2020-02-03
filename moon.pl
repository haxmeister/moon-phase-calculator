#!/usr/bin/env perl

use warnings;
use strict;
use Astro::MoonPhase;
use JSON;

my $json   = JSON->new->allow_nonref;

my $number_of_cycles = shift(@ARGV);
if (! $number_of_cycles){$number_of_cycles = 1;}

my %cycles;
my $next_time = time();
while ($number_of_cycles){
    add_cycle($next_time);
    $next_time = $next_time + 2551444; # number of seconds till next cycle
    $number_of_cycles--;
}

#my $json_pretty = $json->pretty->encode( \%cycles );
#print $json_pretty;
date_phase();

sub add_cycle{
    my $time = shift;
    my @phases  = phasehunt($time);
    my @phase_names = (
                    "New Moon", 
                    "First Quarter", 
                    "Full Moon", 
                    "Last Quarter", 
                    "New Moon",
                    );

    my $i = 0;
    foreach my $nexty (@phases){
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($nexty);
        $year = $year +1900;
        $mon = $mon + 1;
        $hour = $hour;
        
        my ($MoonPhase,
            $MoonIllum,
            $MoonAge,
            $MoonDist,
            $MoonAng,
            $SunDist,
            $SunAng,
            ) = phase($nexty);

        $cycles{"$mon/$mday/$year"}{'phase'} = $phase_names[$i] ;
        $cycles{"$mon/$mday/$year"}{'time'} = Fmt_Time($nexty);
        $cycles{"$mon/$mday/$year"}{'distance'} = $MoonDist;
        $cycles{"$mon/$mday/$year"}{'angle'} = $MoonAng;
        $cycles{"$mon/$mday/$year"}{'sunangle'} = $SunAng;
        push @{$cycles{'DateOrder'}}, "$mon/$mday/$year" unless $i == 4;
        $i++;
    }
}

sub Fmt_Time{
    my $time = shift;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);

    # Time Format - HH:MM
    return sprintf("%02d:%02d",$hour, $min);
}

sub date_phase{
    foreach my $item (@{$cycles{'DateOrder'}}){
        print $item.
            ",".
            $cycles{$item}{'phase'}.
            ",".
            $cycles{$item}{'time'}.
            "\n";

    }
}
