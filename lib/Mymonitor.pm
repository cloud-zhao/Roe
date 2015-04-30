package Mymonitor;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT=qw();

use Mydata;
use Myconf;
use Myssh;
use Mytools;

my $host_file=$roe_conf{hostfile};
my $data=Mydata->new();
my $now_time;
my $past_time;
my $ssh={};
my $hn=0;

sub host_connect{
	my $host={};
	my $col=["ip","user","password"];
	if(-f $host_file){
		open my $fp,"<$host_file" or die "Cannot open $host_file.\n";
		while(<$fp>){
			chomp;
			@{$host->{$_}}=$data->select_data("hostinfo",@$col,{hostname=>$_});
		}
		close $fp;
	}else{
		my @all_host=$data->select_data("hostinfo","hostname",@$col);
		for(my i=0;i<@all_host;i++){
			$host->{$all_host[$i++]}=[$all_host[$i++],$all_host[$i++],$all_host[$i]];
		}
	}

	for $hn (keys %$host){
		if(@{$host->{$hn}}){
			$ssh->{$hn}=Myssh->new($host->{$hn}[0],$host->{$hn}[1],$host->{$hn}[2]);
		}else{
			$ssh->{$hn}=0;
		}
	}
}

sub main{
	$now_time=now_time();
	$past_time=past_time($now_time,{m=>10});
	for $hn (keys %$ssh){
		cpu();
		io();
		network();
		mem();
		netlink();
		disk();
		load();
		server();
		process();
	}
	$ssh={};
	$hn=0;
}

sub cpu{
	return 0 if $conf{monitor_cpu} != 1;
	my $stat=$host->{$hn}->open("/proc/stat");
	_cpu_get($stat);
	close $stat;
	_cpu_analyse();
}

sub _cpu_get{
	my $file=shift;
	return 1 if ref($file) ne "GLOB";
	while(<$file>){
		last if ! /^cpu/;
		my ($cpu,$us,$nice,$sys,$id,$iowait,
			$irq,$softirq,$st,$guest)=split /\s+/;
		my $total_time=$us+$nice+$sys+$id+$iowait+
			$irq+$softirq+$st+$guest;
		@cpu_all=qq($cpu $total_time $us $nice $sys $id
			$iowait $irq $softirq $st $guest);
		$data->insert_data("cpu_stat",$hn,$now_time,@cpu_all);
	}
	return 0;
}

sub _cpu_analyse{
	my ($id,$us,$sy);
	my @time1=$data->select_data("cpu_stat","cpu_num","tt","us","sy","id",{up_time=>$past_time,hostname=>$hn});
	my @time2=$data->select_data("cpu_stat","cpu_num","tt","us","sy","id",{up_time=>$now_time,hostname=>$hn});

	if((! @time1) && ($time1[1]>$time2[1])){
		for(my $i=0;$i<@time2;$i++){
			$id=$time2[$i+4]/$time2[$i+1]*100;
			$us=$time2[$i+2]/$time2[$i+1]*100;
			$sy=$time2[$i+3]/$time2[$i+1]*100;
			$data->insert_data("cpu_rate",$hn,$t2,$time2[$i],$us,$sy,$id,0);
			$i+=4;
		}
		return 0;
	}
	
	for(my $i=0;$i<@time2;$i++){
		$id=($time2[$i+4]-$time1[$i+4])/($time2[$i+1]-$time1[$i+1])*100;
		$us=($time2[$i+2]-$time1[$i+2])/($time2[$i+1]-$time1[$i+1])*100;
		$sy=($time2[$i+3]-$time1[$i+3])/($time2[$i+1]-$time1[$i+1])*100;
		$data->insert_data("cpu_rate",$hn,$now_time,$time2[$i],$us,$sy,$id,0);
		$i+=4;
	}
	return 0;
}

sub mem{}

sub disk{}

sub load{}

sub process{}

sub io{}

sub server{}

sub netlink{}

sub network{}

1;
