#!/usr/bin/perl

#Library definitions mimic'd from the original script for testing purposes:
use strict;
use warnings;
use Net::FTP;

#Hard code some variables for our Testing:
my $HOME = "Toscana 3.0/Outbound";
my $USER_ID = "billfireadm";
my $CLIENT = "sfac"; 

#Must declare variables when using "strict":
my ($FILELIST, $BASENAME, $TRANSFER_PHRASE, $TRANSFER_HOST, $TRANSFER_USER, $TRANSFER_PW, $SFTP, $FTP);

#Set the PW and PP directory paths as per the original script:
my $PWFILE = "/home/$USER_ID/.ssh/.transfer_pw.enc";
my $PPFILE = "/home/$USER_ID/.ssh/.transfer_pp";

#Grab the Transfer Phrase via the same way the script does for our testing:
chomp($TRANSFER_PHRASE = `cat $PPFILE`);

#Grab variables needed for FTP Connection string, these can be found at /home/billfireadm/.ssh
chomp($TRANSFER_HOST = `openssl enc -aes-256-cbc -d -in $PWFILE -pass pass:$TRANSFER_PHRASE|grep -i "$CLIENT-FTP"|awk -F, '{print \$2}'`);
chomp($TRANSFER_USER = `openssl enc -aes-256-cbc -d -in $PWFILE -pass pass:$TRANSFER_PHRASE|grep -i "$CLIENT-FTP"|awk -F, '{print \$3}'`);
chomp($TRANSFER_PW = `openssl enc -aes-256-cbc -d -in $PWFILE -pass pass:$TRANSFER_PHRASE|grep -i "$CLIENT-FTP"|awk -F, '{print \$4}'`);

#Setup FTP connection string:
$FTP = Net::FTP->new ( $TRANSFER_HOST ) or die "Could not connect to FTP host";
$FTP->login("$TRANSFER_USER","$TRANSFER_PW") or die "FTP username or password incorrect";
$FTP->binary();

#Set some more variables we need for the FTP call to list the contents of the directory ($HOME):
my $TYPE = "CM";
my $TYPE_ABR = "U";

#Show contents of $HOME direcory (Toscana 3.0/Outbound) on FTP server:
print "\nBefore-->\n";  
my $LS = $FTP->dir("Toscana 3.0/Outbound");
 foreach $FILELIST (@$LS) {
    if ($FILELIST =~ /BF.*$TYPE_ABR.*_2.*\.csv/i) {
      chomp($BASENAME = `echo $FILELIST|awk '{print \$NF}'`);
      print "$BASENAME\n";
    }
  }

#Pick the BASENAME (ie: the file you want deleted) via parameter passing:
#$BASENAME = "BF107U3P_20181227_204300.csv";
$BASENAME = "$ARGV[0]";

#Delete the file via FTP command (perl):
# (remove comment from below when ready to test)
# WARNING: this command is the DELETE command, your decision will be permanent when you run this.
#$FTP->delete($HOME/$BASENAME);

#Show contents of directory after the delete to confirm it worked:
print "\nAfter-->\n";
my $LS = $FTP->dir("Toscana 3.0/Outbound");
 foreach $FILELIST (@$LS) {
    if ($FILELIST =~ /BF.*$TYPE_ABR.*_2.*\.csv/i) {
      chomp($BASENAME = `echo $FILELIST|awk '{print \$NF}'`);
      print "$BASENAME\n";
    }
  }
