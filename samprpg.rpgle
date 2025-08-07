**free
ctl-opt option(*nodebugio:*srcstmt) dftactgrp(*no) ;  
dcl-f SAMP workstn indds(Dspf) sfile(SFL01:SFLRRN) ;
dcl-ds Dspf qualified ;
  Exit ind pos(3) ;
  SubfileDisplay ind pos(30) ;
end-ds ;
dcl-f TESTFILEP keyed ;
dcl-s SubfileMaximum int(10) ;

LoadSubfile() ;
dow (*on) ;
  exfmt CTL01 ;
  if (Dspf.Exit) ;
    leave ;
  else ;
    ChainSubfile() ;
  endif ;
enddo ;
*inlr = *on ;
return;

dcl-proc LoadSubfile ;
  Dspf.SubfileDisplay = *on ;
  SFLRRN = 0 ;
  dow (*on) ;
    read TESTFILER ;
    if (%eof) ;
      leave ;
    endif ;
    SFLRRN += 1 ;
    write SFL01 ;
  enddo ;
  SubfileMaximum = SFLRRN ;
end-proc ;

dcl-proc ChainSubfile ;
  dcl-s Number int(10) ;
  for Number = 1 to SubfileMaximum ;
    chain Number SFL01 ;
    dsply (%char(SFLRRN) + ' ' + NAME) ;
  endfor ;
end-proc ;