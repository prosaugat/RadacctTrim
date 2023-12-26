#!/usr/bin/perl

use strict;
use warnings;
use POSIX qw(strftime);

# DB Details
my $date = strftime "%Y-%m-%d %H:%M:%S", localtime;
my $logger_cmd = "logger radacct_trim script started $date";
system($logger_cmd);

my $sql_user   = "prosaugat";
my $sql_pass   = "my-password";
my $db         = "radius";
my $tbl_arch   = "radacct_archive";
my $months     = 6;
my $mysql_pwd  = "--password=$sql_pass";

my $cmd = "mysql -u$sql_user $mysql_pwd --skip-column-names -s -e";

# Checking for DB and TABLE
print "
Script Started \@ $date
";
print "- Step 1: Checking for DB: $db / TABLE: $tbl_arch ...\n";

my $dbchk_cmd = "mysqlshow --user=$sql_user $db | grep -v Wildcard | grep -o $db";
my $dbchk     = qx($dbchk_cmd);

if ($dbchk eq "$db\n") {
    print " > $db DB found\n";
} else {
    print " > $db not found. Creating now ...\n";
    system("$cmd \"create database if not exists $db;\"");
}

my $tbl_arch_exists_cmd = sprintf 'SHOW TABLES LIKE "%s"', $tbl_arch;
if (`$cmd \"$tbl_arch_exists_cmd\" $db`) {
    print " > $tbl_arch TABLE found IN DB: $db\n";
} else {
    print " > $tbl_arch TABLE not found IN DB: $db / Creating now ...\n";
    system("$cmd \"use $db; create table if not exists $tbl_arch LIKE radacct;\"");
}

# Copy data from radacct to new db/archive table
my $notnull_count_cmd = "$cmd \"use $db; select count(*) from radacct WHERE acctstoptime is not null;\"";
my $notnull_count     = qx($notnull_count_cmd);
chomp($notnull_count);

print "- Step 2: Found $notnull_count records in radacct table, Now copying $notnull_count records to $tbl_arch table ...\n";
system("$cmd \"use $db; INSERT IGNORE INTO $tbl_arch SELECT * FROM radacct WHERE acctstoptime is not null;\"");

# Deleting old data from radacct table
print "- Step 3: Deleting $notnull_count records old data from radacct table (which have acctstoptime NOT NULL) ...\n";
system("$cmd \"use $db; DELETE FROM radacct WHERE acctstoptime is not null;\"");

# Copying old data from $tbl_arch older than $months months
print "- Step 4: Copying old data from $tbl_arch older than $months months ...\n";
system("$cmd \"use $db; DELETE FROM $tbl_arch WHERE date(acctstarttime) < (CURDATE() - INTERVAL $months MONTH);\"");

$date = strftime "%Y-%m-%d %H:%M:%S", localtime;
$logger_cmd = "logger radacct_trim script ended with $notnull_count records processed for trimming \@ $date";
system($logger_cmd);

print "
radacct_trim script ended with $notnull_count records processed for trimming \@ $date\n";
