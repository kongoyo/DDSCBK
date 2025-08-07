**FREE
// *******************************************************************************
// * Program: TAPINFR                                                            *
// * Description: Reads TAPINF data and displays in a subfile                    *
// *******************************************************************************
CTL-OPT OPTION(*SRCSTMT : *NODEBUGIO);

DCLF TAPINFSF;

DCL-S PageNbr PACKED(5:0);
DCL-S RRNZ PACKED(5:0) INZ(0);

// Define a data structure for your TAPINF fields
DCL-DS TapInf_DS QUALIFIED;
  RDSYSN CHAR(8);
  RDDTTM CHAR(13);
  RDMID CHAR(6);
  RDVOL CHAR(6);
  RDLIB CHAR(10);
  RDCGY CHAR(10);
  RDSYS CHAR(8);
  RDDEN CHAR(10);
  RDCD CHAR(7);
  RDCT CHAR(6);
  RDRD CHAR(7);
  RDRT CHAR(6);
  RDLOC CHAR(10);
  RDLOCI CHAR(1);
  RDVSTS CHAR(2);
  RDOWN CHAR(17);
  RDWPR CHAR(1);
  RDCODE CHAR(1);
  RDMGEN CHAR(1);
  RDMIE CHAR(1);
  RDMTYP CHAR(2);
  RDRSV CHAR(2);
END-DS;

/FREE

  // Initialize subfile
  EXFMT SFLCTL;
  SFLCLR = '1';
  WRITE SFLCTL;
  SFLCLR = '0';

  // Clear message line
  MSGSFL = *BLANKS;

  PageNbr = 1;
  RRNZ = 0;

  // Declare cursor for fetching TAPINF data
  EXEC SQL
    DECLARE C1 CURSOR FOR
      SELECT RDSYSN, RDDTTM, RDMID, RDVOL, RDLIB, RDCGY, RDSYS,
             RDDEN, RDCD, RDCT, RDRD, RDRT, RDLOC, RDLOCI,
             RDVSTS, RDOWN, RDWPR, RDCODE, RDMGEN, RDMIE, RDMTYP, RDRSV
        FROM YOURLIB/YOURTABLE_TAPINF; // **Replace with your actual library/table name**

  EXEC SQL
    OPEN C1;

  DOU (*IN03 = *ON); // Loop until F3 (Exit) is pressed

    // Read subfile data
    READC SFLRCD;

    // Check for function keys
    SELECT;
      WHEN *IN03 = *ON; // F3 Exit
        LEAVE;

      WHEN *IN12 = *ON; // F12 Scroll Down
        IF (RRNZ >= PageNbr * SFLPAG) AND (NOT %EOF());
          PageNbr += 1;
        ENDIF;
        SFLDSP = '0'; // Clear and redisplay
        SFLDSPCTL = '0';
        WRITE SFLCTL;
        SFLDSP = '1';
        SFLDSPCTL = '1';
        ITER; // Go back to start of loop

      WHEN *IN07 = *ON; // F7 Scroll Up
        IF PageNbr > 1;
          PageNbr -= 1;
        ENDIF;
        SFLDSP = '0'; // Clear and redisplay
        SFLDSPCTL = '0';
        WRITE SFLCTL;
        SFLDSP = '1';
        SFLDSPCTL = '1';
        ITER; // Go back to start of loop

      WHEN *IN05 = *ON; // F5 Refresh
        SFLDSP = '0';
        SFLDSPCTL = '0';
        WRITE SFLCTL;
        SFLCLR = '1';
        WRITE SFLCTL;
        SFLCLR = '0';
        RRNZ = 0;
        PageNbr = 1;
        MSGSFL = *BLANKS;
        EXEC SQL CLOSE C1;
        EXEC SQL OPEN C1;
        ITER;

    ENDSL;

    // Load subfile records
    RRNZ = 0;
    DOU (%EOF(C1) OR RRNZ >= (PageNbr * 100)); // Load up to a certain number of records per page for efficiency

      EXEC SQL
        FETCH C1 INTO :TapInf_DS.RDSYSN, :TapInf_DS.RDDTTM, :TapInf_DS.RDMID, :TapInf_DS.RDVOL,
                      :TapInf_DS.RDLIB, :TapInf_DS.RDCGY, :TapInf_DS.RDSYS, :TapInf_DS.RDDEN,
                      :TapInf_DS.RDCD, :TapInf_DS.RDCT, :TapInf_DS.RDRD, :TapInf_DS.RDRT,
                      :TapInf_DS.RDLOC, :TapInf_DS.RDLOCI, :TapInf_DS.RDVSTS, :TapInf_DS.RDOWN,
                      :TapInf_DS.RDWPR, :TapInf_DS.RDCODE, :TapInf_DS.RDMGEN, :TapInf_DS.RDMIE,
                      :TapInf_DS.RDMTYP, :TapInf_DS.RDRSV;

      IF NOT %EOF(C1);
        RRNZ += 1;
        SFLRRN = RRNZ;

        // Move data from data structure to subfile record format
        RDSYSN = TapInf_DS.RDSYSN;
        RDDTTM = TapInf_DS.RDDTTM;
        RDMID = TapInf_DS.RDMID;
        RDVOL = TapInf_DS.RDVOL;
        RDLIB = TapInf_DS.RDLIB;
        RDCGY = TapInf_DS.RDCGY;
        RDSYS = TapInf_DS.RDSYS;
        // Map other fields as needed

        WRITE SFLRCD;
      ELSE;
        LEAVE; // End of file
      ENDIF;
    ENDOU;

    IF RRNZ = 0;
      MSGSFL = 'No records found.';
    ENDIF;

    PAGENO = PageNbr;
    EXFMT SFLCTL;

  ENDOU;

  EXEC SQL
    CLOSE C1;

  *INLR = *ON;

