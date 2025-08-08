**free
ctl-opt option(*nodebugio:*srcstmt) dftactgrp(*no) ;  
dcl-f tapinfd workstn indds(Dspf) sfile(SFL01:SFLRRN) ;
dcl-ds Dspf qualified ;
  Exit ind pos(3) ;
  Refresh ind pos(5) ;
  SubfileDisplay ind pos(30) ;
  SubfileClear ind pos(50) ;
  SubfileEnd ind pos(51) ;
end-ds;
dcl-f tapinf extfile('DDSCBK/TAPINF') keyed ;
dcl-s SubfileMaximum int(10) ;

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
  write SFL01;
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
  return;
enddo ;
*inlr = *on;


dcl-proc LoadSubfile;
  read tapinf;
  if (%eof) ;
    dsply 'No records found in TAPINF file.' ;
    *inlr = *on;
    return;
  endif ;
  dow not %eof(tapinf);
    read tapinf;
    if (%eof) ;
      leave ;
    endif ;
    SFLRRN += 1 ;
    write SFL01;
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
  //   write SFL01 ;
  // enddo ;
  SubfileMaximum = SFLRRN ;
  ChainSubfile();
  Dspf.SubfileEnd = *on ;
  Dspf.SubfileClear = *on ;
  Dspf.SubfileDisplay = *off ;
  *inlr = *on;
  return;
end-proc ;

dcl-proc ChainSubfile ;
  dcl-s Number int(10) ;
  for Number = 1 to SubfileMaximum ;
    chain Number SFL01 ;
    // dsply (%char(SFLRRN) + ' ' + NAME) ;
  endfor ;
  return;
end-proc ;