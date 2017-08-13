@fileList = split(/\\/, readpipe("dir *"));
if($fileList[$#fileList] =~ /(.*)\n.*/) {
  $dirName = $1;
}
@fileList = split(/\n/, readpipe('dir * /a-d /b /o:d'));
$countFiles=0;
$numDigits=length ($#fileList+1);
foreach $file(@fileList) {
  if($file ne 'RenameFilesToFolderName.pl') {
    if($file =~ /.*\.(.*)$/) {
      $fileExt = $1;
    }
    $countFiles++;
    $countFiles = &padDigits($countFiles,$numDigits);
    while(-f $dirName.' '.$countFiles.'.'.$fileExt) {
      $countFiles++;
      $countFiles = &padDigits($countFiles,$numDigits);
    }
    system('rename "'.$file.'" "'.$dirName.' '.$countFiles.'.'.$fileExt.'"');
  }
  else {
    print 'Skipping this file: '.$file."\n";
  }
}

sub padDigits {
  my $inNum = shift;
  my $inLen = shift;
  while(length $inNum < $inLen) {$inNum = "0$inNum";}
  return $inNum;
}