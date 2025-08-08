     HDEBUG(*YES)
     HOPTION(*NODEBUGIO:*SRCSTMT)
      *
      * 檔案宣告
     FTAPINF    UF A E           K DISK
     FTAPINFDSPFCF   E             WORKSTN SFILE(SFLDTA01:RRN#)
      *
      * 變數宣告
     D CmdStr          S            200A
     D CmdLen          S             15P 5
     D RRN#            S              4S 0
     D                 DS
     D MSG                           45A
     D SYSNAM          S              8A
      // 新增一個變數來儲存副檔中選擇的RDMID
     D SelRDMID        S             10A
      *
      * 主程式
      /FREE
        // 初始化
        RRN# = 1;
        Exsr  $ClearSr;
        Exsr  $LoadSr;

        // 主迴圈
        Dow *In03 = *Off;
          *In99 = *On;  // 啟用覆蓋畫面
          RRN# = 1;
          Write Footer;
          Exfmt SFLCTL01;

          If *In03 = *On;
             *Inlr = *On;
             Return;
          Endif;

          Select;
          When *In05 = *On;
            // 按下 F5 鍵時執行刷新
            Exsr $RFHSUB;
            MSG = 'Tape Information has been Refreshed!';
          When *In06 = *On;
            MSG = '目前尚未實作新增功能。';
          When *In07 = *On;
            MSG = '目前尚未實作建立SPLF功能。';
          When *In08 = *On;
            CmdStr = 'WRKSPLF SELECT(*CURRENT *ALL *ALL *ALL *ALL QPTAPDSP)';
                  Exec SQL
                    Call QSYS2.QCMDEXC(:CmdStr, :CmdLen);
          Other;
            Readc(e) SFLDTA01;
            Dow Not %Eof();
              // 在處理副檔資料前，將OPT欄位的RDMID值存入新的變數
              If OPT = 'I' or OPT = 'M' or OPT = 'P';
                SelRDMID = RDMID;
              Endif;
              If OPT = 'I';
                Exsr  $INZSUB;
                OPT = ' ';
                MSG = ' ';
                INZMSG = ' ';
                Update SFLDTA01;
              Elseif OPT = 'M';
                MNTMSG = *Blanks;
                Exsr $MNTSUB;
                OPT = ' ';
                MSG = ' ';
                MNTMSG = ' ';
              Elseif OPT = 'P';
                Exsr  $PRTSUB;
                OPT = ' ';
                MSG = ' ';
                PRTMSG = ' ';
              Elseif OPT <> 'I' and OPT <> 'M' and OPT <> 'P' and OPT <> '';
                MSG = '選項無效! 請重試!';
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
      /END-FREE
      *
      //�  初始化磁帶子程序
        BegSr  $INZSUB;
          // 使用 Read 迴圈尋找指定紀錄
          Setll *Start TAPINF;
          Read  TAPINF;
          Dow Not %Eof(TAPINF);
             If RDMID = SelRDMID; // 使用新變數進行判斷
               Dow *In12 = *Off;
                  Exfmt INZREC;
                  If *In12 = *On;
                     *In12 = *Off;
                  Leavesr;
                  Endif;
                  // 執行 INZTAP 指令
                  CmdStr = 'INZTAP DEV(' + %trim(RDLIB) + ') +
                    NEWVOL(' + %trim(RDMID) + ') VOL(' + %trim(RDMID) + ') +
                    CHECK(*NO) DENSITY(*CTGTYPE)';
                  CmdLen = %len(%trimr(CmdStr));
                  Exec SQL
                    Call QSYS2.QCMDEXC(:CmdStr, :CmdLen);

                  If SQLSTATE = '00000';
                     INZMSG = '磁帶初始化成功...!';
                  Else;
                     INZMSG = '磁帶初始化失敗...!';
                  Endif;
              Enddo;
              Leavesr; // 找到紀錄後離開子程序
            Endif;
            Read TAPINF;
          Enddo;
          INZMSG = '找不到該磁帶紀錄!'; // 迴圈結束仍未找到紀錄
        EndSr;
      *
      //�  掛載磁帶子程序
        Begsr     $MNTSUB;
          MNTMSG  = *Blanks;
          // 使用 Read 迴圈尋找指定紀錄
          Setll *Start TAPINF;
          Read  TAPINF;
          Dow Not %Eof(TAPINF);
            If RDMID = SelRDMID; // 使用新變數進行判斷
              Dow *In12 = *Off;
                Exfmt MNTREC;
                If  *In12 = *On;
                    *In12 = *Off;
                    Leavesr;
                Endif;
                // 執行 CHKTAP 指令
                CmdStr = 'CHKTAP DEV(' + %trim(RDLIB) + ') +
                  VOL(' + %trim(RDMID) + ') ENDOPT(*LEAVE)';
                CmdLen = %len(%trimr(CmdStr));
                Exec SQL
                  Call QSYS2.QCMDEXC(:CmdStr, :CmdLen);
                If SQLSTATE = '00000';
                  MNTMSG = '磁帶掛載成功...!';
                Else;
                  MNTMSG = '磁帶掛載失敗...!';
                Endif;
              Enddo;
              Leavesr;
            Endif;
            Read TAPINF;
          Enddo;
          MNTMSG = '找不到該磁帶紀錄!';
        Endsr;
      *
      //�  顯示磁帶資訊子程序
        BegSr  $PRTSUB;
          // 使用 Read 迴圈尋找指定紀錄
          Setll *Start TAPINF;
          Read  TAPINF;
          Dow Not %Eof(TAPINF);
            If RDMID = SelRDMID; // 使用新變數進行判斷
              Dow *In12 = *Off;
                Exfmt PRTREC;
                If *In12 = *On;
                   *In12 = *Off;
                Leavesr;
                Endif;
                // 執行 DSPTAP 指令
                CmdStr = 'DSPTAP DEV(' + %trim(RDLIB) + ') +
                  VOL(' + %trim(RDMID) + ') OUTPUT(*PRINT)';
                CmdLen = %len(%trimr(CmdStr));
                Exec SQL
                  Call QSYS2.QCMDEXC(:CmdStr, :CmdLen);
                If SQLSTATE = '00000';
                  PRTMSG = '磁帶列印成功...!';
                Else;
                  PRTMSG = '磁帶列印失敗...!';
                Endif;
              Enddo;
              Leavesr;
            Endif;
            Read TAPINF;
          Enddo;
          PRTMSG = '找不到該磁帶紀錄!';
        EndSr;
      *
      //�  刷新磁帶資訊子程序
        BegSr  $RFHSUB;
          // 先關閉檔案,再執行指令
          Close TAPINF;
          CmdStr = 'DSPTAPCTG DEV(TAPMLB01) OUTPUT(*OUTFILE) +
                OUTFILE(DDSCBK/TAPINF)';
          CmdLen = %len(%trimr(CmdStr));
          Exec SQL
          Call QSYS2.QCMDEXC(:CmdStr, :CmdLen);
          // 指令執行後重新開啟檔案
          Open TAPINF;
        EndSr;
      *
      //�  清除副檔子程序
        BegSr  $ClearSr;
          *In50 = *Off;   //�SFLDSP
          *In51 = *Off;   //�SFLDSPCTL
          *In52 = *On;    //�SFLCLR
          *In53 = *Off;
          Write SFLCTL01;
          *In50 = *On;    //�SFLDSP
          *In51 = *On;    //�SFLDSPCTL
          *In52 = *Off;   //�SFLCLR
          *In53 = *On;
          RRN# = 0;
        EndSr;
      *
      //�  載入副檔子程序
        BegSr  $LoadSr;
          // 在讀取檔案前先刷新資料
          Exsr $RFHSUB;

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
        EndSr;
