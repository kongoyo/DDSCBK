**free
ctl-opt option(*nodebugio:*srcstmt) debug(*yes) dftactgrp(*no);
dcl-f tapinfd workstn indds(dspf) sfile(sfldta:SFLRRN);
dcl-c MaxSfl 9999;
dcl-ds dspf qualified;
  exit ind pos(3);
  refresh ind pos(5);
  sfldsp ind pos(50);
  sfldspctl ind pos(51);
  sflclr ind pos(52);
  sflend ind pos(53);
end-ds;
dcl-s SFLRRN packed(4:0);
dcl-f tapinfl usage(*update) keyed;

setll *start tapinfl;
loadsfl();
dspf.sfldsp = *on;
dspf.sfldspctl = *on;
dow *in03 = *off;
  exfmt SFLCTL;
  if *in03 = *on;
    leave;
  elseif *in05 = *on;
    refreshsfl();
    SFLRRN = 0;
    setll *start tapinfl;
    loadsfl();
    iter;
  endif;
  if dspf.sfldsp = *on;
    readsfl();
  endif;
enddo;

*inlr = *on;
return;

dcl-proc clearsfl;
end-proc;

dcl-proc loadsfl;
  Setll *Start TAPINFL;
  Read  TAPINFL;
  If %Eof(TAPINFL);
    *In50 = *Off;
    *In51 = *On;
    *In52 = *Off;
    *In53 = *On;
    *In99 = *Off;  // Disable Overlay
    Write Footer;
  Else;
    *In50 = *On;
    *In51 = *On;
    *In52 = *Off;
    *In53 = *Off;
    *In99 = *On;   // Enable Overlay
    Dow Not %Eof(TAPINFL);
      SFLRRN = SFLRRN + 1;
      Write SFLDTA;
      Read  TAPINFL;
    Enddo;
  Endif;
        // EndSr;
end-proc;

dcl-proc refreshsfl;
  dcl-pr syscmd int(10) ExtProc('system');
    *n Pointer Value Options(*String);
  end-pr;
  dcl-s cmdstr char(1500);
  dcl-s returnCode int(10);
  cmdstr = 'DSPTAPCTG DEV(TAPMLB01) OUTPUT(*OUTFILE) OUTFILE(STEVE/TAPINFP)';
  returnCode = syscmd(cmdstr);
  if returnCode = 0;
    snd-msg 'Outfile recreated successfully.';
  else;
    snd-msg 'Outfile recreation failed.';
  endif;
  return;
end-proc;

dcl-proc readsfl;
end-proc;

