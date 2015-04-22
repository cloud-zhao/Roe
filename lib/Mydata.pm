package Mydata;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT=qw();

use DBI;

use constant SQLITE_SOURCE =>'DBI:SQLite:dbname=localdb.db';

sub new{
	my $class=shift;
	my $self;
	my %mysqlinfo=@_;
	if(!(defined %mysqlinfo){
		$self->{dbh}=DBI->connect(SQLITE_SOURCE,'','') or die "connect fail\n";
	}elsif(defined %mysqlinfo){
		my %mysqlinfo=@_;
		my $mysql_source="DBI:mysql:database=$mysqlinfo{database};host=$mysqlinfo{host}";
		$self->{dbh}=DBI->connect($mysql_source,$mysqlinfo{user},$mysqlinfo{password}) or
		die "connect $mysqlinfo{host} 3306 failed\n";
	}
	return bless $self,$class;
}

sub create_table{
	my $self=shift;
	my %tableinfo=@_;
	my $createinfo;
	for my $tablename (keys %tableinfo){
		$createinfo{$tablename}="create table $tablename(";
			for my $colname (keys %{$tableinfo{$tablename}}){
				$createinfo{$tablename}.="$colname $tableinfo{$tablename}->{$colname}[0],";
			}
	}
	for my $table (keys %$tableinfo){
		$self->{dbh}->do($table);
	}
	return 0;
}

sub insert_data{
	my $self=shift;
	my %tableinfo=@_;
	for my $tablename (keys %tableinfo){
		my $insert="insert into $tablename set";
		for keys $colname (keys %{$tableinfo{$tablename}}){
			$insert.=" $colname=$tableinfo{$tablename}->{$colname},";
		} 
		chop $insert;
		$self->{dbh}->do($insert);
	}
}

sub select_data{
	my $self=shift;
	my $sql=shift;
	my $select=$self->{dbh}->selectall_arrayref($sql);
	return $select;
}

sub disconnect{
	my $self=shift;
	$self->{dbh}->disconnect;
	$self=undef;
}