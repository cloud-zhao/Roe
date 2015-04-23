package Mydata;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT=qw();

use DBI;
use Myconf;

#use constant SQLITE_SOURCE =>"DBI:SQLite:dbname=../data/mydata.db";

my $database=$roe_conf{database};
my $datatype=$roe_conf{datatype};

sub new{
	my $class=shift;
	my $self;
	if((! $datatype) || ($datatype eq "sqlite")){
		my $sqlite_source="DBI:SQLite:dbname=$database";
		$self->{dbh}=DBI->connect($sqlite_source,'','') or die "$DBI::errstr\n";
	}elsif($datatype eq "mysql"){
		my ($datahost,$dataname)=split '::',$database;
		my $datauser=$roe_conf{datauser};
		my $datapass=$roe_conf{datapass};
		my $mysql_source="DBI:mysql:database=$dataname;host=$datahost";
		$self->{dbh}=DBI->connect($mysql_source,$datauser,$datapass) or
		die "$DBI::errstr\n";
	}
	return bless $self,$class;
}

#create_table()
sub create_table{
	my $self=shift;
	my $table_name=shift;
	my %columns=@_;
	my $sql="create table $table_name (";

	for my $col (keys %columns){
		$sql.="$col $columns{$col},";
	}
	chop $sql;
	$sql.=");";
	print "$sql\n";

	$self->{dbh}->do($sql);
	die "$DBI::errstr\n" if $self->{dbh}->err;

	return 0;
}

sub insert_data{
	my $self=shift;
	my $table_name=shift;
	my %values=@_;
	my $sql="insert into $table_name ";
	my ($sql_col,$sql_val);
	for(keys %values){
		$sql_col.="$_,";
		$sql_val.=qq/"$values{$_}",/;
	}
	chop $sql_col;
	chop $sql_val;
	$sql.="($sql_col) ($sql_val);";
	print "$sql\n";

	$self->{dbh}->do($sql);
	die "$DBI::err\n" if $self->{dbh}->err;
	return 0;
}

sub select_data{
	my $self=shift;
	my $table_name=shift;
	my $where_val=pop;
	my $where_id=pop;
	my $sql="select ".join ','."from $table_name where $where_id=$where_val;";
	my $select=$self->{dbh}->selectall_arrayref($sql);
	return $select;
}

sub disconnect{
	my $self=shift;
	$self->{dbh}->disconnect;
	return 0;
}
