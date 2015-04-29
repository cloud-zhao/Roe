package Mytools;

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT=qw(taday_date date_diff now_time write_file);

use Date::Calc qw(Date_to_Time);

sub taday_date{
	my @time_t=localtime;
	my $day_date=($time_t[5]+1900)."-".($time_t[4]+1)."-".$time_t[3];
	return $day_date;
}

sub date_diff{
	my ($newdate,$olddate)=@_;
	$newdate=[split '-',$newdate];
	$olddate=[split '-',$olddate];
	my $newtime=Date_to_Time(@$newdate,0,0,0);
	my $oldtime=Date_to_Time(@$olddate,0,0,0);
	return int(($newtime-$oldtime)/86400);
}

sub now_time{
	my @time_t=localtime;
	return ($time_t[5]+1900)."-".($time_t[4]+1)."-".$time_t[3]." ".
			$time_t[2].":".$time_t[1].":".$time_t[0];
}

sub write_file{
	my ($buff,$filename)=@_;
	open my $file,">>$filename" or die "$filename write fail\n";
	print $file "$buff\n";
	close $file;
	return 0;
}
