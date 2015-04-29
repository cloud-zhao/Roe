package Myssh;

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT=qw(new cmd);

use Net::OpenSSH;
use Mydata;
use Myconf;

sub new{
	my $class=shift;
	my $self={};
	my ($ip,$user,$pass,$key)=@_;
	unless(defined $ip){
		print "The host is not specified.\n";
		return 1;
	}
	$user ||= "root";
	$pass ||= "";
	$key ||= "/root/.ssh/id_rsa";

	$self->{ssh}=Net::OpenSSH->new($ip,user=>$user,password=>$pass,key_path=>$key);
	if($self->{ssh}->error){
		die "Connection SSH $ip failed. ".$self->{ssh}->error;
	}

	return bless $self,$class;
}

sub open_stat{
	my $self=shift;
	my $file=shift;
	my ($out,$pid)=$self->{ssh}->pipe_out("cat $file") or 
		die "pipe_out method failed: ". $self->{ssh}->error;
	return $out;
}

sub get_host{
	my $self=shift;
	my $hostname=$self->{ssh}->capture("hostname -s");
	chomp $hostname;
	if($self->{ssh}->error){
		die "Get host failed. ".$self->{ssh}->error;
	}
	return $hostname;
}

sub run_cmd{
	my $self=shift;
	my $cmd=shift;
	$cmd ||= return 1;
	my ($out,$err)=$self->{ssh}->capture2("$cmd");
	if($self->{ssh}->error){
		die "Remote find command failed: ".$self->{ssh}->error;
	}
	print $out;
	return 0;
}

1;
