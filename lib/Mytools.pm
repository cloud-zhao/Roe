package Mytools;

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT=qw(taday_date date_diff now_time past_time write_file);

use Date::Calc qw(Date_to_Time Time_to_Date);

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
	my $time=shift || time;
	my @time_t=localtime($time);
	return ($time_t[5]+1900)."-".($time_t[4]+1)."-".$time_t[3]." ".
			$time_t[2].":".$time_t[1].":".$time_t[0];
}

sub past_time{
	return 1 if @_<2;
	my ($ny,$nm,$nd,$nh,$mm,$ns)=split /-|:|\s+/,shift;
	my $time=Date_to_Time($ny,$nm,$nd,$nh,$mm,$ns);
	my $pd=shift;
	for(keys %$pd){
		$time-=$pd->{$_}*86400 if $_ eq 'd';
		$time-=$pd->{$_}*3600 if $_ eq 'h';
		$time-=$pd->{$_}*60 if $_ eq 'm';
		$time-=$pd->{$_} if $_ eq 's';
	}
	($ny,$nm,$nd,$nh,$mm,$ns)=Time_to_Date($time);
	return join('-',($ny,$nm,$nd))." ".join(':',($nh,$mm,$ns));
}

sub write_file{
	my ($buff,$filename)=@_;
	open my $file,">>$filename" or die "$filename write fail\n";
	print $file "$buff\n";
	close $file;
	return 0;
}

1;
