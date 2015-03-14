package Myssh;

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT=qw(new cmd);

use Net::SSH2;

sub new{
	my $class=shift;
	my $self;
	my ($ip,$port,$user,$password)=@_;
	$self->{"host"}{"ip"}=$ip || return -1;
	$self->{"host"}{"$port"}=$port || 22;
	$self->{"host"}{"$user"}=$user || root;
	$self->{"host"}{"password"}=$password || "0x0000";
	$self->{"ssh2"}=Net::SSH2->new();
	bless $self,$class;
}

sub cmd{
	my $self=shift;
	my $command=shift || 'echo "unkonw command"';
	my $host=$self->{"host"};
	my $ssh2=$self->{"ssh2"};
	$ssh2->connect($host,Timeout=>60) or die "connect fail\n";
	if($host->{"password"} != "0x0000"){
		my $chan=_auth_password($host,$ssh2);
		$chan->exec("$command");
	}else{
		my $keyputh= $host->{"user"} == "root" ? "/root/.ssh" : "/home/".$host->{"user"}."/.ssh";
		my $chan=_auth_key($host,$ssh2,$keyputh);
		$chan->exec("$command");
	}
}

sub _auth_key{
	my $host=shift;
	my ($ssh2,$keyputh)=@_;
	if($ssh2->auth_publickey($host->{"user"},$keyputh."/id_rsa.pub",$keyputh."/id_rsa")){
		my $chan=$ssh2->channel();
		return \$chan;
	}else{
		return -1
	}
}

sub _auth_password{
	my $host=shift;
	my ($ssh2)=@_;
	if($ssh2->auth_password($host->{"user"},$host->{"password"})){
		my $chan=$ssh2->channel();
		return \$chan;
	}else{return -1}
}



=POD
    my ($stdout, $stderr, $exitcode) = cmd($ssh, $cmd, sub {
            my ($stderr, $chan) = @_;
            if ($stderr =~ /Password for '(.+)':/i) {
                print $chan "$passwd\n";
            }
        });



sub cmd {
    my ($ssh, $cmd, $callback) = @_;
    my $timeout = 250;
    my $bufsize = 4096;
    
    $ssh->blocking(1);
    my $chan=$ssh->channel();
    $chan->exec($cmd);
    
    my $poll = [{ handle => $chan, events => ['in','ext'] }];
    
    my %std=();
    $ssh->blocking( 0 );
    while(!$chan->eof) {
        $ssh->poll($timeout, $poll);
        
        my( $n, $buf );
        foreach my $ev (qw(in ext)) {
            next unless $poll->[0]{revents}{$ev};
            
            
            if( $n = $chan->read($buf, $bufsize, $ev eq 'ext') ) {
                $std{$ev} .= $buf;
            }
            if (ref($callback) eq 'CODE' && $std{$ev}) {
                $callback->($std{$ev}, $chan, $ev eq 'ext' ?
                                                  'stderr' : 'stdout');
            }
        }
    }
    $chan->wait_closed(); #not really needed but cleaner
    my $exit = $chan->exit_status();
    $chan->close(); #not really needed but cleaner
    $ssh->blocking(1); # set it back for sanity (future calls)
    return ($std{in}, $std{ext}, $exit);
}

=cut

