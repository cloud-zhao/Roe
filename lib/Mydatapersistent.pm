package Mydata
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT=qw();

use Persistent::File;
use Persistent::MySQL;

#use constant 

sub new{
	my $class=shift;
	my $self;
	return bless $self,$class;
}

sub file_create{
	my $self=shift;
	my ($filename)=@_;
	eval {
		$self->{"data_file"}=new Persistent::File($filename);
	};
	if($@){
		die "create file fail\n";
		return -1;
	}
	return $self;
}

sub set_col{
	my $self=shift;
	my @col=@_;
	my $id=shift @col;
	my $cols={
			$id=>["ID","VarChar",undef,100];
	};
	$cols->{$_}=['Persistent','VarChar',undef,255] for @col;
	$self->{"col"}=$cols || return -1;
	return _add_att($self);
}

sub set_value{
	my $self=shift;
	my $values=$self->{col};
}

sub _add_att{
	my $self=shift;
	my $cols=$self->{"col"};
	my $file=$self->{"data_file"};
	eval {
		for(keys %$cols){
			$file->add_attribute($_,@{$cols->{$_}});
		}
	};
	if ($@) {
		die "add attribute fail\n";
		return -1;
	}
	$self->{"data_file"}=$file;
	return $self;
}