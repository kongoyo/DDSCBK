**free
ctl-opt option(*srcstmt) dftactgrp(*no) ;  
dcl-f tapinfd workstn indds(Dspf) sfile(SFLCTL:SFLRRN) ;
dcl-ds Dspf qualified ;
  Exit ind pos(3) ;
  Refresh ind pos(5) ;
  SubfileDisplay ind pos(50) ;
  SubfileClear ind pos(52) ;
  SubfileEnd ind pos(53) ;
end-ds;
dcl-f tapinfl extfile('STEVE/TAPINFL') keyed ;

LoadSubfile();
dow *inlr = *off;
  // Display the subfile
  dsply 'Displaying subfile...' ;
  // Wait for user input
  dsply 'Press Enter to continue...' ;
  // Clear the screen
  clear Dspf ;
  // Set the display attributes
  Dspf.SubfileDisplay = *on ;
  Dspf.SubfileClear = *off ;
  // Write the subfile header
  write SFLCTL;
  // Load the subfile with data
  LoadSubfile();
  // Display the subfile
  dsply 'Subfile loaded with data.' ;
  // Wait for user input
  dsply 'Press Enter to exit...' ;
  // Clear the screen
  clear Dspf ;
  // Set the display attributes
  Dspf.SubfileDisplay = *off ;
  Dspf.SubfileClear = *on ;
  // End the program
enddo ;
*inlr = *on;


dcl-proc LoadSubfile;
  read tapinflr;
  if (%eof) ;
    dsply 'No records found in TAPINF file.' ;
    *inlr = *on;
    return;
  endif ;
  dow not %eof(tapinfl);
    read tapinflr;
    if (%eof) ;
      leave ;
    endif ;
    SFLRRN += 1 ;
    write SFLCTL;
  enddo ;
  Dspf.SubfileEnd = *off ;
  Dspf.SubfileDisplay = *on ;
  SFLRRN = 0 ;
  // dow (*on) ;
  //   // read TESTFILER ;
  //   read tapinf;
  //   if (%eof) ;
  //     leave ;
  //   endif ;
  //   SFLRRN += 1 ;
  //   write SFLCTL ;
  // enddo ;
  SubfileMaximum = SFLRRN ;
  ChainSubfile(SubfileMaximum);
  Dspf.SubfileEnd = *on ;
  Dspf.SubfileClear = *on ;
  Dspf.SubfileDisplay = *off ;
end-proc ;

dcl-proc ChainSubfile ;
  dcl-pi *n;
    SubfileMaximum int(10);
  end-pi;
  dcl-s Number int(10) ;
  for Number = 1 to SubfileMaximum ;
    chain Number SFLCTL ;
    // dsply (%char(SFLRRN) + ' ' + NAME) ;
  endfor ;
end-proc ;