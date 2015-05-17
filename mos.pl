#!/usr/bin/perl -w
use strict;
use DBI;

my $db = DBI->connect(
     "dbi:mysql:dbname=fusionpbx",
     "root",
     "",
     { RaiseError => 1 },
) or die $DBI::errstr;

#Query MOS Score
my $query = $db->prepare("SELECT MIN(rtp_audio_in_mos) as min,  MAX(rtp_audio_in_mos) as max, AVG(rtp_audio_in_mos) as avg FROM v_xml_cdr WHERE rtp_audio_in_mos IS NOT NULL AND answer_stamp > DATE_SUB(now(), INTERVAL 5 MINUTE)");
$query->execute() or die "Couldn't execute statement!\n";

my $datetime = localtime;

my ($min,$max,$avg) = $query->fetchrow_array();

$query->finish();
$db->disconnect();

my $message;
my ($status, $statustxt) = (0, "OK");

if(defined $min) {

    if($min < 3.1 || $avg < 3.1) {
        $status = 2;
        $statustxt = "CRITICAL";
    } elsif(($min >= 3.1 && $min <= 3.6) || ($avg >= 3.1 && $avg <= 3.6)) {
        $status = 1;
        $statustxt = "WARNING";

    }

    $min = sprintf("%.1f", $min);
    $max = sprintf("%.1f", $max);
    $avg = sprintf("%.1f", $avg);
    $message = "MOS=$min;$max;$avg";

} else {

    ($min, $max, $avg) = ("-nan","-nan","-nan");

}

print "$status Voice_Quality MIN=$min|MAX=$max|AVERAGE=$avg Server is $statustxt $message $datetime \n";
