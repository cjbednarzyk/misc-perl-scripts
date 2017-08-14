#!/usr/local/bin/perl

$old;
$new;
$file;

print "The available commands are\:\n";
print "quit\n";
print "replace\n";
print "\> ";
while(<>) {
# Waiting for a command
  chomp $_;
  if($_ eq replace) {
    print "  old word/phrase\?\n  \> ";
    while(<>) {
    # Waiting for the old word/phrase
      chomp $_;
      $old=$_;
      print "    new word/phrase\?\n    \> ";
      while(<>) {
	# Waiting for the new word/phrase
	chomp $_;
	$new=$_;
        print "      name of file to edit\?\n";
        print "      type * to edit all files in the current directory\n";
        print "      \> ";
        while(<>) {
          # Waiting for the filename
	  chomp $_;
	  $file=$_;
	  &changeWord;
	  last;
        }
	last;
      }
      last;
    }
  }
  elsif($_ eq 'quit') {
    last;
  }
  else {
  }
  print "The available commands are\:\n";
  print "quit\n";
  print "replace\n";
  print "\> ";
}

##########################################
# A method to change one word to another #
##########################################
sub changeWord() {
  print "Changing all occurrences of $old to $new...\n";
  $tempstring="";
  opendir(MYDIR, ".");
  foreach $line (readdir(MYDIR)) {
    if (-f "$line") {
      $tempstring.="$line"."\n";
    }
  }
  close(MYDIR);
  @dir=split(/\n/,$tempstring);
  if($file eq "*") {
    foreach $dirline (@dir) {
      $tempstring="";
      open(FILE,"<$dirline");
      while(<FILE>) {
        $tempstring.=$_;
      }
      close(FILE);
      $_="$tempstring";
      s/$old/$new/g;
      $tempstring=$_;
      open(FILE,">$dirline");
      print FILE "$tempstring";
      close(FILE);
    }
    print "Done!\n";
  }
  else {
    foreach $dirline (@dir) {
      if($dirline eq $file) {
        $tempstring="";
	open(FILE,"<$dirline");
	while(<FILE>) {
          $tempstring.=$_;
        }
	close(FILE);
	$_="$tempstring";
	s/$old/$new/g;
	$tempstring=$_;
	open(FILE,">$dirline");
	print FILE "$tempstring";    
	close(FILE);
      }
    }
    print "Done with changing the words in $file!\n";
  }
}
