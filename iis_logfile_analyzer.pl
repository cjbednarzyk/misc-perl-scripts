#Comment out unwanted output fields with a pound sign

@outputIISColumnList = (
'date',
'time',
's-sitename',
's-computername',
's-ip',
'cs-method',
'cs-uri-stem',
'cs-uri-query',
's-port',
'cs-username',
'c-ip',
'cs-version',
'cs(User-Agent)',
'cs(Cookie)',
'cs(Referer)',
'cs-host',
'sc-status',
'sc-substatus',
'sc-win32-status',
'sc-bytes',
'cs-bytes',
'time-taken'
);

# Get the list of log files from the current directory
opendir(LOGFILES,".") or die("Can't open input directory.");
@filelist=readdir(LOGFILES);
closedir(LOGFILES);

# Determine which files are log files to be analyzed
foreach $inputfilename(@filelist) {
  if ($inputfilename =~ /.log$/) {
    $#infiletext = -1;
    $#resetDates = -1;
    open(INPUTLOGFILE,"<$inputfilename");
    while(<INPUTLOGFILE>) {
#######################################
# Header Rows start with a pound sign #
#######################################
      if($_ =~ /^\#/) {
        @headerRow=split /\s+/,$_;
        if($headerRow[0] eq '#Software:') {
          $softwareName='';
          for($i=1;$i<$#headerRow;$i++) {
            $softwareName.=$headerRow[$i].' ';
          }
          $softwareName.=$headerRow[$#headerRow];
        }
        elsif($headerRow[0] eq '#Version:') {
          $versionName=$headerRow[1];
        }
        elsif($headerRow[0] eq '#Date:') {
          push (@{$resetDates[scalar(@resetDates)]}, $headerRow[1]);
          push (@{$resetDates[scalar(@resetDates)-1]}, $headerRow[2]);
        }
        elsif($headerRow[0] eq '#Fields:') {
          $#iisColumnList = -1;
          $#outputColumnList = -1;
          for($i=1;$i<=$#headerRow;$i++) {
            push (@{$iisColumnList[scalar(@iisColumnList)]}, $i-1);
            push (@{$iisColumnList[scalar(@iisColumnList)-1]},$headerRow[$i]);
            for($j=0;$j<=$#outputIISColumnList;$j++) {
              if($headerRow[$i] eq $outputIISColumnList[$j]) {
                push (@{$outputColumnList[scalar(@outputColumnList)]},$i-1);
                push (@{$outputColumnList[scalar(@outputColumnList)-1]},$headerRow[$i]);
              }
            }
          }
        }
      }
#############################################################################
# Data Rows - store only the columns listed in the beginning of the program #
#############################################################################
      else {
        @dataRow = split /\s+/,$_;
        push(@{$infiletext[scalar(@infiletext)]},$dataRow[$outputColumnList[0][0]]);
        for($i=1;$i<=$#outputColumnList;$i++) {
          push(@{$infiletext[scalar(@infiletext) - 1]},$dataRow[$outputColumnList[$i][0]]);
        }
      }
    }
    close(INPUTLOGFILE);

###########################################################
# Done reading input - ready to output header information #
###########################################################

    $outputfilename = 'analysis log for '.$inputfilename;
    $outputfilename =~ s/.log$/.txt/;
    open(OUTPUTLOGFILE,">$outputfilename");
    print OUTPUTLOGFILE "Software:\t$softwareName\n";
    print OUTPUTLOGFILE "Version:\t$versionName\n";
    print OUTPUTLOGFILE "All IIS Resets on this file occurred on the following dates and times:\n";
    for($i=0;$i<=$#resetDates;$i++) {
      print OUTPUTLOGFILE "\t$resetDates[$i][0]\t$resetDates[$i][1]\n";
    }
    print OUTPUTLOGFILE "Input Fields:\n";
    for($i=0;$i<=$#iisColumnList;$i++) {
      print OUTPUTLOGFILE "\t$iisColumnList[$i][1]\n";
    }
    print OUTPUTLOGFILE "Output:\n\n";
    for($i=0;$i<$#outputColumnList;$i++) {
      print OUTPUTLOGFILE "$outputColumnList[$i][1]\t";
    }
    print OUTPUTLOGFILE "$outputColumnList[$#outputColumnList][1]\n";
###############################
# Output analysis information #
###############################

    for($rowIndex=0;$rowIndex<=$#infiletext;$rowIndex++) {

      for($i=0;$i<=$#outputColumnList;$i++) {
        if(($outputColumnList[$i][1] eq 'sc-status')&&($infiletext[$rowIndex][$i] ne '200')) {

          for($j=0;$j<=$#outputColumnList;$j++) {
            if(($outputColumnList[$j][1] eq 'c-ip')&&($infiletext[$rowIndex][$j] ne '192.168.167.2')&&($infiletext[$rowIndex][$j] ne '192.168.167.4')) {

              ##################################################
              # Print rows that match the criteria given above #
              ##################################################
              for($columnIndex=0;$columnIndex<$#outputColumnList;$columnIndex++) {
                print OUTPUTLOGFILE "$infiletext[$rowIndex][$columnIndex]\t";
              }
              print OUTPUTLOGFILE "$infiletext[$rowIndex][$#outputColumnList]\n";

            }
          }
        }
      }
    }
    close(OUTPUTLOGFILE);
  }
}