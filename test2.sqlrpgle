     H DFTNAME(CUSTSFL) BNDDIR('QC2LE')

     Fcustdspl  CF   E             WORKSTN

     DSFLRCD_DS        DS
     Dcustid                          7S 0
     Dcustnam                        30A
     Dcustcty                        15A

     DWk_RRN          S               5U 0
     DWk_SrchName     S              30A

     /FREE

     // 主程式迴圈，直到按下 F3 (In03) 或 F12 (In12)
     DOU (In03 = *ON OR In12 = *ON);

     // Clear 程序: 每次載入前，先清空 Subfile
     // ----------------------------------------------------
     Wk_RRN = 0;
     *IN20 = *ON;
     WRITE SFLCTL;
     *IN20 = *OFF;

     // 顯示控制記錄，讓使用者輸入查詢條件
     // ----------------------------------------------------
     // 首次載入時，先顯示控制記錄，讓使用者輸入搜尋條件
     // SFLDSP和SFLDSPCTL標識在第一次顯示時會是OFF，
     // 程式會先顯示控制記錄上的靜態文字和輸入欄位。
     //
     // 程式邏輯會先進入Load程序，讀取資料，然後才EXFMT。
     // 由於SFLDSP是關閉的，畫面會先顯示標頭和腳註。
     // 如果使用者輸入了SRCHNAME，程式會在下一個迴圈中用它。

     // Load 程序: 根據搜尋條件，載入資料
     // ----------------------------------------------------
     EXEC SQL DECLARE CUST_CURS CURSOR FOR
       SELECT custid, custnam, custcty
       FROM custmast
       WHERE custnam LIKE :srchname || '%';

     EXEC SQL OPEN CUST_CURS;

     DOU (SQLCOD <> 0);
       EXEC SQL FETCH NEXT FROM CUST_CURS INTO :SFLRCD_DS;

       IF (SQLCOD = 100);
         LEAVE;
       ENDIF;

       Wk_RRN += 1;
       WRITE SFLRCD;
     ENDDO;

     EXEC SQL CLOSE CUST_CURS;

     // 顯示 Subfile
     // ----------------------------------------------------
     *IN21 = *ON; // 啟用SFLDSP和SFLDSPCTL，顯示Subfile和控制記錄
     EXFMT SFLCTL;
     *IN21 = *OFF; // 關閉SFLDSP，以便下次迴圈時可以重新載入

     // 如果按下了 F3 或 F12，則退出迴圈
     IF (In03 = *ON OR In12 = *ON);
       LEAVE;
     ENDIF;

     // Read 程序: 讀取被修改的資料
     // ----------------------------------------------------
     // 迴圈讀取所有被使用者修改過的 Subfile 記錄
     DOU (*IN50 = *ON);
       READC SFLRCD;

       IF (%EOF);
         *IN50 = *ON;
       ELSE;
         // 在這裡，你可以處理被修改的資料，例如更新資料庫
         // 以下是更新資料庫的範例
         EXEC SQL UPDATE custmast
           SET custnam = :custnam,
               custcty = :custcty
           WHERE custid = :custid;
       ENDIF;
     ENDDO;
     *IN50 = *OFF;

     ENDDO;

     *INLR = *ON; // 設定最後一個標識，程式結束
     /END-FREE