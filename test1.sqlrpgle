**free
ctl-opt option(*nodebugio:*srcstmt) debug(*yes) dftactgrp(*no);
dcl-f tapinfp usage(*input) extfile('STEVE/TAPINFP');
dcl-f tapinfd workstn extfile('STEVE/TAPINFD') indds(dspf) sfile(tapi01:rrn);
dcl-s rrn packed(4:0);
dcl-s msg char(45);
dcl-ds dspf qualified;
  exit ind pos(3);
  refresh ind pos(5);
  cancel ind pos(12);
  sfldsp ind pos(60);
  sfldspctl ind pos(61);
  sflclr ind pos(62);
end-ds;

dou (dspf.exit = *on or dspf.cancel = *on);
  clearsfl();
  loadsfl();
  write tapi03;
  displaysfl();
  readcsfl();
  if (dspf.refresh = *on);
    close tapinfp;
    refreshsfl();
    open tapinfp;
  endif;
enddo;

*inlr = *on;
return;

dcl-proc clearsfl;
  rrn = 0;
  opt = *blank;
  dspf.sflclr = *on;
  write tapi02;
  dspf.sflclr = *off;
end-proc;

dcl-proc loadsfl;
  exec sql declare tapinfc cursor for
    select RDMID, RDVOL, RDMTYP, RDLIB, RDLOC, RDLOCI, RDWPR
    from steve.tapinfp order by RDLOCI desc;
  exec sql open tapinfc;
  dou sqlcod <> 0;
    exec sql fetch next from tapinfc 
                        into :rdmid, :rdvol, :rdmtyp, :rdlib, :rdloc, :rdloci, :rdwpr;
    if (sqlcod = 100);
      leave;
    endif;
    rrn += 1;
    write tapi01;
  enddo;
  exec sql close tapinfc;
end-proc;

dcl-proc displaysfl;
  dspf.sfldsp = *on;
  dspf.sfldspctl = *on;
  exfmt tapi02;
  dspf.sfldsp = *off;
  dspf.sfldspctl = *off;
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
end-proc;

dcl-proc readcsfl;
  dcl-pr syscmd int(10) ExtProc('system');
    *n Pointer Value Options(*String);
  end-pr;
  dcl-s cmdstr char(1500);
  dcl-s returnCode int(10);
  readc tapi01;
  dow not %eof();
    select;
      when (opt='I');
        cmdstr = '';
        returnCode = syscmd(cmdstr);
        if returnCode = 0;
          snd-msg 'Tape initialized successfully.';
        else;
          snd-msg 'Tape initialized failed.';
        endif;
      when (opt='M');
        cmdstr = '';
        returnCode = syscmd(cmdstr);
        if returnCode = 0;
          snd-msg 'Tape mounted successfully.';
        else;
          snd-msg 'Tape mounted failed.';
        endif;    
      other;
    endsl;
    opt = ' ';
    update tapi01;
  enddo;
end-proc;
