package Myconf;
use strict;
use warnings;
use base qw(Exporter);

our @EXPORT=qw(%roe_conf write_conf);
our %roe_conf;

my $conf_file="../conf/roe.conf";
$conf_file="../conf/roe.conf.default" unless -f $conf_file ;


%roe_conf=(
	database=>"../data/mydata.db",
	datatype=>"sqlite",
	datauser=>"root",
	datapass=>"ccindex",
	hostfile=>"../conf/host.conf",
	monitor_cpu=>1,
	monitor_disk=>1,
	monitor_load=>1,
	monitor_mem=>1,
	monitor_net=>1
);
my $golable_conf=\%roe_conf;

=pod
sub new{
	my $class=shift;
	my $self={};
	$self->{conf}={};
	return bless $self,$class;
}
=cut

sub _read_conf{
	#my $self=shift;

	open(my $cfp,"<$conf_file") or die "Cannot open file $conf_file\n";

	while(<$cfp>){
		chomp;
		next if /^\s+$/;
		next if /^#/;
		$_=~s/\s+//g;
		my ($key,$value)=split '=';
		next unless $key;
		_check_conf($key);
		$roe_conf{$key}=$value;
	}
	close $cfp;
	return 0;
}

sub write_conf{
	#my $self=shift;
	my @local_conf=@_;
	return 0 unless @local_conf;
	if(@local_conf%2 != 0){
		print "Parameter error\n";
		return 1;
	}
	
	open(my $cfp,">$conf_file") or die "Cannot open file $conf_file\n";
	for(my $c=0;$c<@local_conf;$c++){
		_check_conf($local_conf[$c]);
		$roe_conf{$local_conf[$c]}=$local_conf[++$c];
	}
	print $cfp "$_=$roe_conf{$_}\n" for keys %roe_conf;

	close $cfp;
	return 0;
}

sub _check_conf{
	my $golable_key=shift;
	unless(exists $golable_conf->{$golable_key}){
		print "Configure file ".'"'.$conf_file.'"';
		print " unrecognized option ".'"'.$golable_key.'"'."\n";
		exit 1;
	}
	return 0;
}

_read_conf;

1;
