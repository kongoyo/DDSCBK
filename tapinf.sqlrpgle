**free
ctl-opt option(*NODEBUGIO:*SRCSTMT);
dcl-ds tapinf extname('DDSCBK/TAPINF') qualified;
end-ds;
dcl-f dspf workstn infds(tapdspf);

      *
     D CmdStr          S            200
     D CmdLen          S             15P 5
     D RRN#            S              4S 0
     D                 DS
     D MSG                           45A
     D SYSNAM          S              8A
      *
      //  Main Routine
        RRN# = 1;
        Exsr  $ClearSr;
        Exsr  $LoadSr;
        Dow *In03 = *Off;
          *In99 = *On;  // Enable Overlay
          RRN# = 1;
          Exfmt SFLCTL01;
          If *In03 = *On;
             *Inlr = *On;
             Return;
          Endif;
          Select;
          When *In05 = *On;
            Exsr $RFHSUB;
            MSG = 'Tape Information has been Refreshed!';
          Other;
          Readc(e) SFLDTA01;
            Dow Not %Eof();
              If OPT = 'I';
                Exsr  $INZSUB;
                OPT = ' ';
                MSG = ' ';
                Update SFLDTA01;
              Elseif OPT = 'M';
                MNTMSG = *Blanks;
                Exsr $MNTSUB;
                OPT = ' ';
                MSG = ' ';
              Elseif OPT = 'D';
                Exsr  $DSPSUB;
                OPT = ' ';
              Elseif OPT <> 'I' and OPT <> 'M' and OPT <> 'D';
                MSG = 'Option Not Valid ! Please Retry !';
              Else;
              Endif;
              Readc(e) SFLDTA01;
              If %Error;
                Leave;
              Endif;
            Enddo;
          Endsl;
          Exsr  $ClearSr;
          Exsr  $LoadSr;
        Enddo;
        *Inlr = *On;
      *
      //  SubRoutine to Initialize Tape
        BegSr  $INZSUB;
          Dow *In12 = *Off;
            Exfmt INZREC;
            If *In12 = *On;
               *In12 = *Off;
            Leavesr;
            Endif;
            Chain (SRDMID) TAPINF;
            If %Found;
              CmdStr = 'INZTAP DEV(' + %trim(SRDLIB) + ') +
                NEWVOL(' + %trim(SRDMID) + ') VOL(' + %trim(SRDMID) + ') +
                CHECK(*NO) DENSITY(*CTGTYPE)';
              CmdLen = %len(%trimr(CmdStr));
            Exec SQL
              Call QSYS2.QCMDEXC(:CmdStr, :CmdLen);
              If SQLSTATE = '00000';
              INZMSG = 'Tape Initialize Successfully...!';
              Else;
              INZMSG = 'Tape Initialize Failed...!';
              Endif;
            Endif;
            Read TAPINF;
            If %Eof(TAPINFLF);
                *In50 = *Off;
                *In51 = *On;
            Endif;
          Enddo;
        EndSr;
      *
      //  SubRoutine to Mount Tape
        Begsr     $MNTSUB;
          MNTMSG  = *Blanks;
          Dow *In12 = *Off;
            Exfmt MNTREC;
            If  *In12 = *On;
                *In12 = *Off;
                Leavesr;
            Endif;
            Chain (SRDMID) TAPINF;
            If %Found;
              CmdStr = 'CHKTAP DEV(' + %trim(SRDLIB) + ') +
                VOL(' + %trim(SRDMID) + ') ENDOPT(*LEAVE)';
              CmdLen = %len(%trimr(CmdStr));
            Exec SQL
              Call QSYS2.QCMDEXC(:CmdStr, :CmdLen);
              If SQLSTATE = '00000';
              MNTMSG = 'Tape Mounted Successfully...!';
              Else;
              MNTMSG = 'Tape Mounted Failed...!';
              Endif;
            Endif;
          Enddo;
        Endsr;
      *
      //  SubRoutine to Display Tape
        BegSr  $DSPSUB;
          Dow *In12 = *Off;
            Exfmt DSPREC;
            If *In12 = *On;
               *In12 = *Off;
            Leavesr;
            Endif;
            Chain (SRDMID) TAPINF;
            If %Found;
              CmdStr = 'DSPTAP DEV(' + %trim(SRDLIB) + ') +
                VOL(' + %trim(SRDMID) + ') OUTPUT(*PRINT)';
              CmdLen = %len(%trimr(CmdStr));
            Exec SQL
              Call QSYS2.QCMDEXC(:CmdStr, :CmdLen);
              If SQLSTATE = '00000';
              DSPMSG = 'Tape Displayed Successfully...!';
              Else;
              DSPMSG = 'Tape Displayed Failed...!';
              Endif;
            Endif;
          Enddo;
        EndSr;
      *
      //  SubRoutine to Refresh Aping Result
        BegSr  $RFHSUB;
          CmdStr = 'DSPTAPCTG DEV(TAPMLB01) OUTPUT(*OUTFILE) +
                OUTFILE(DDSCEE/TAPINF)';
          CmdLen = %len(%trimr(CmdStr));
          Exec SQL
          Call QSYS2.QCMDEXC(:CmdStr, :CmdLen);
        EndSr;
      *
      //  SubRoutine to Clear SubFile
        BegSr  $ClearSr;
          *In50 = *Off;   //SFLDSP
          *In51 = *Off;   //SFLDSPCTL
          *In52 = *On;    //SFLCLR
          *In53 = *Off;
          Write SFLCTL01;
          *In50 = *On;    //SFLDSP
          *In51 = *On;    //SFLDSPCTL
          *In52 = *Off;   //SFLCLR
          *In53 = *On;
          RRN# = 0;
        EndSr;
      *
      //  SubRoutine to Load SubFile
        BegSr  $LoadSr;
          Setll *Start   TAPINFLF;
          Read  TAPINF;
          If %Eof(TAPINFLF);
            *In50 = *Off;
            *In51 = *On;
            *In99 = *Off;  // Disable Overlay
            Write Footer;
          Else;
            *In50 = *On;
            *In51 = *On;
            *In99 = *On;   // Enable Overlay
          CmdStr = 'DSPTAPCTG DEV(TAPMLB01) OUTPUT(*OUTFILE) +
                OUTFILE(DDSCEE/TAPINF)';
          CmdLen = %len(%trimr(CmdStr));
          Exec SQL
          Call QSYS2.QCMDEXC(:CmdStr, :CmdLen);
            Dow Not %Eof(TAPINFLF);
              RRN# = RRN# + 1;
              SRDMID  = RDMID ;
              SRDVOL  = RDVOL;
              RDMTYP  = RDMTYP;
              SRDLIB  = RDLIB ;
              SRDLOC  = RDLOC;
              RDLOCI  = RDLOCI;
              SRDWPR  = RDWPR;
              Write SFLDTA01;
              Write Footer;
              Read  TAPINF;
            Enddo;
          Endif;
        EndSr;
