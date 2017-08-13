$#listOfArrays=-1;
$#arrayWithinArray=-1;

for $i (1..10) {
  push @arrayWithinArray, $i;
  for($j=0;$j<=$#arrayWithinArray;$j++) {
    print "$arrayWithinArray[$j]\t";
  }
  print "\n";
  my @tempArray = @arrayWithinArray;
  push @listOfArrays, \@tempArray;
}

for($i=$#listOfArrays;$i>=0;$i--) {
  @rowOfArrays=@{$listOfArrays[$i]};
  #print "$#rowOfArrays, ";
  for($j=0;$j<=$#rowOfArrays;$j++) {
    print "$rowOfArrays[$j]\t";
  }
  print "\n";
}
<>;