**free
ctl-opt option(*nodebugio:*srcstmt) debug(*yes) dftactgrp(*no);
dcl-f tapinfdspf workstn indds(dspf) sfile(sfldta01:rrn#);
dcl-c MaxSfl 9999;
dcl-ds dspf qualified;
  exit ind pos(3);
  refresh ind pos(5);
  overlay ind pos(99);
  sfldsp ind pos(50);
  sfldspctl ind pos(51);
  sflclr ind pos(52);
  sflend ind pos(53);
end-ds;
dcl-s #RRN packed(4:0);
dcl-f tapinf usage(*update) keyed;

setll *start tapinf;
load();
dow *in03 = *off;
    exfmt SFLCTL01;
    if *in03 = *on;
        leave;
    endif;
    elseif *in05 = *on;
        #RRN='';
        setll *start tapinf;
        load();
        iter;
    endif;
    if sfldsp = *on;
      readsfl();
    endif;
enddo;

*inlr = *on;
return;

dcl-proc clearsfl;
end-proc;

dcl-proc loadsfl;
  Setll *Start TAPINF;
  Read  TAPINF;
  If %Eof(TAPINF);
    *In50 = *Off;
    *In51 = *On;
    *In99 = *Off;  // Disable Overlay
    Write Footer;
  Else;
    *In50 = *On;
    *In51 = *On;
    *In99 = *On;   // Enable Overlay
    Dow Not %Eof(TAPINF);
      RRN# = RRN# + 1;
      Write SFLDTA01;
      Read  TAPINF;
    Enddo;
  Endif;
        // EndSr;
  return;
end-proc;

dcl-proc refreshsfl;
    dcl-pr syscmd int(10) ExtProc('system');
        *n Pointer Value Options(*String);
    end-pr;
    dcl-s cmdstr char(1500);
    dcl-s returnCode int(10);
    cmdstr = 'DSPTAPCTG DEV(TAPMLB01) OUTPUT(*OUTFILE) OUTFILE(STEVE/TAPINF)';
    returnCode = syscmd(cmdstr);
    return;
end-proc;

dcl-proc readsfl;
end-proc;

