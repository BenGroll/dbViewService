package DBView::DB;

use strict;
use warnings;

use Data::Dumper;
use DBI;
use DBView::TableIndex;

sub new {
    my $class = shift;
    
    my @driver_names = DBI->available_drivers;
    my $driver = "mysql";
    my $database = "cs_bens_database";
    my $dsn = "DBI:$driver:database=$database";
    my $db = DBI->connect($dsn, 'root', 'admin') or die $DBI::errstr;
    my $self = {controller => $db};

    bless ($self, $class);
}

sub tablelist {
    my $self = shift;

    my $db = $self->{controller};
    my @rows = $db->tables();

    my @tables = ();
    foreach my $row (@rows) {
        my @split = split(/\./, $row);
        my $last = pop(@split);
        $last =~ s/`//g;
        push(@tables, $last);
    }
    return \@tables;
}

sub indexlist {
    my $self = shift;
    my $tablename = shift;

    my $db = $self->{controller};

    my $query = "SHOW COLUMNS IN $tablename;";
    my $sth = $db->prepare($query);
    $sth->execute();

    my @indexes = ();
    while (my @array = $sth->fetchrow_array) {
        my $index = DBView::TableIndex->new(@array);
        push (@indexes, $index);
    }
    return \@indexes;
}

sub rows {
    my $self = shift;
    my $tablename = shift;
    
    my $db = $self->{controller};
    my $query = "SELECT * FROM $tablename;";
    my $sth = $db->prepare($query);
    $sth->execute();

    my @rows = ();
    while (my @row = $sth->fetchrow_array) {
        push(@rows, \@row);
    }
    return \@rows;
}

1;