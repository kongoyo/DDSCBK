     H*修改異動日說明                                      人員                              
     H* ==== ======== =========================================== ==========                 
     H* U.01 98.04.16新增程式                                   PERRY                        
     H*                                                                                      
     H*                                                                                      
     H*****************************************************************                      
     H* PGM: HCOTM21    - MTN HCOTM21                                                        
     H*  CALLING:                                                                            
     H*  CALLED :                                                                            
     H*****************************************************************                      
     H DATEDIT(*YMD)                                                                         
     F*****************************************************************                      
     FZBRANCH   IF   E           K DISK                                                      
     FHSTKM01P  IF   E           K DISK                                                      
     FHCOTM21P  UF A E           K DISK                                                      
     FHCOTM21S  CF   E             WORKSTN                                                   
     F                                     SFILE(COT21S01:RRN)                               
     D*****************************************************************                      
     D                 DS                                                                    
     D  MSGDTA                 1     20                                                      
     D  MSGPM1                 1     10                                                      
     D  MSGNU1                 1      5P 0                                                   
     D  MSGNU2                 6     10P 0                                                   
     D  MSGPM2                11     20                                                      
     D  MSGNU3                11     15P 0                                                   
     D  MSGNU4                16     20P 0                                                   
     D**                                                                                     
     D                UDS                                                                    
     D  #BRNCH                 1      4                                                      
     D  USRID                 35     44                                                      
     C*****************************************************************                      
     C**   M A I N     P R O G R A M                                                         
     C*****************************************************************                      
     C     TAG01         TAG                                                                 
     C**--                                                                                   
     C   39              SETON                                        60                     
     C                   SETON                                        61                     
     C                   WRITE     COT21S03                                                  
     C                   EXFMT     COT21S02                                                  
     C                   SETOFF                                       386061                 
     C                   SETOFF                                       99                     
     C*                                                                                      
     C                   MOVE      *BLANK        MSGID                                       
     C                   MOVE      *BLANK        MSGTXT                                      
     C                   WRITE     COT21S99                                                  
     C*                                                                                      
     C     *IN20         IFEQ      '1'                                                       
     C     *IN43         ANDEQ     '0'                                                       
     C     *IN44         ANDEQ     '0'                                                       
     C                   EXSR      RTN98                                                     
     C*                                                                                      
     C                   ELSE                                                                
     C     *IN39         IFEQ      '1'                                                       
     C     *IN55         DOUEQ     '1'                                                       
     C                   READC     COT21S01                               55                 
     C*                                                                                      
     C     *IN55         IFEQ      '0'                                                       
     C                   SETOFF                                       707172                 
     C                   SETOFF                                       9999                   
     C                   UPDATE    COT21S01                                                  
     C* 權限限制--- 95 96 97 98                                                              
     C   96#OPT          CASEQ     '2'           RTN20                                       
     C   95#OPT          CASEQ     '3'           RTN30                                       
     C   97#OPT          CASEQ     '4'           RTN40                                       
     C   98#OPT          CASEQ     '5'           RTN50                                       
     C                   ENDCS                                                               
     C*                                                                                      
     C*                                                                                      
     C   KC                                                                                  
     COR KL              SETON                                        55                     
     C*                                                                                      
     C                   ENDIF                                                               
     C                   ENDDO                                                               
     C*                                                                                      
     C   43              EXSR      RTN11                                                     
     C   44              EXSR      RTN12                                                     
     C*                                                                                      
     C     PS001         IFNE      *BLANK                                                    
     C     *IN38         OREQ      '1'                                                       
     C                   EXSR      RTN10                                                     
     C                   ENDIF                                                               
     C*                                                                                      
     C                   ENDIF                                                               
     C                   ENDIF                                                               
     C**                                                                                     
     C   KC                                                                                  
     COR KL              DO                                                                  
     C                   MOVE      *BLANK        MSGID                                       
     C                   MOVE      *BLANK        MSGTXT                                      
     C                   WRITE     COT21S99                                                  
     C                   ENDDO                                                               
     C*****************************************************************                      
     C**   RTN10  WRITE SFL FOR PF5 OR POSTION TO                                            
     C*****************************************************************                      
     C     RTN10         BEGSR                                                               
     C**--                                                                                   
     C                   SETON                                        62                     
     C                   WRITE     COT21S02                                                  
     C                   SETOFF                                       62                     
     C                   Z-ADD     0             RRN                                         
     C**                                                                                     
     C     PS001         IFEQ      *BLANK                                                    
     C                   MOVE      PGUP1         CT21010                                     
     C                   MOVE      PGUP2         CT21020                                     
     C                   ELSE                                                                
     C                   MOVE      PS001         CT21010                                     
     C                   MOVE      PS002         CT21020                                     
     C                   ENDIF                                                               
     C**                                                                                     
     C     KYPSTO        SETLL     HCOTM21R                                                  
     C                   READ(N)   HCOTM21R                               54                 
     C*                                                                                      
     C     *IN54         DOWEQ     '0'                                                       
     C     RRN           ANDLT     11                                                        
     C*                                                                                      
     C                   ADD       1             RRN                                         
     C                   MOVE      *BLANK        #OPT                                        
     C*                                                                                      
     C                   MOVE      CT21010       PGDN1                                       
     C                   MOVE      CT21020       PGDN2                                       
     C     RRN           IFEQ      1                                                         
     C                   MOVE      CT21010       PGUP1                                       
     C                   MOVE      CT21020       PGUP2                                       
     C                   ENDIF                                                               
     C*                                                                                      
     C                   WRITE     COT21S01                                                  
     C*                                                                                      
     C                   READ(N)   HCOTM21R                               54                 
     C                   ENDDO                                                               
     C**                                                                                     
     C   54              SETOFF                                       63                     
     C  N54              SETON                                        63                     
     C**                                                                                     
     C     RRN           IFEQ      0                                                         
     C     PGUP1         IFNE      *BLANK                                                    
     C     *HIVAL        SETLL     HCOTM21R                                                  
     C                   READP(N)  HCOTM21R                               54                 
     C  N54              READP(N)  HCOTM21R                               54                 
     C  N54              DO                                                                  
     C                   MOVE      CT21010       PGDN1                                       
     C                   MOVE      CT21020       PGDN2                                       
     C                   ENDDO                                                               
     C   54              DO                                                                  
     C                   MOVE      *BLANK        PGDN1                                       
     C                   MOVE      *BLANK        PGDN2                                       
     C                   ENDDO                                                               
     C                   EXSR      RTN11                                                     
     C                   ENDIF                                                               
     C                   ENDIF                                                               
     C**                                                                                     
     C     RRN           IFEQ      0                                                         
     C                   SETOFF                                       39                     
     C                   MOVE      'CMM0001'     MSGID                                       
     C                   EXSR      RTN99                                                     
     C                   ELSE                                                                
     C                   SETON                                        39                     
     C                   ENDIF                                                               
     C*                                                                                      
     C                   MOVE      *BLANK        PS001                                       
     C                   MOVE      *BLANK        PS002                                       
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN11  WRITE SFL FOR PAGEDOWN                                                     
     C*****************************************************************                      
     C     RTN11         BEGSR                                                               
     C**--                                                                                   
     C                   MOVE      PGDN1         CT21010                                     
     C                   MOVE      PGDN2         CT21020                                     
     C     KYPSTO        SETGT     HCOTM21R                                                  
     C                   READ(N)   HCOTM21R                               54                 
     C**--                                                                                   
     C  N54              DO                                                                  
     C                   SETON                                        62                     
     C                   WRITE     COT21S02                                                  
     C                   SETOFF                                       62                     
     C                   Z-ADD     0             RRN               4 0                       
     C                   ENDDO                                                               
     C**                                                                                     
     C     *IN54         DOWEQ     '0'                                                       
     C     RRN           ANDLT     11                                                        
     C*                                                                                      
     C                   ADD       1             RRN                                         
     C                   MOVE      *BLANK        #OPT                                        
     C                   MOVE      CT21010       PGDN1                                       
     C                   MOVE      CT21020       PGDN2                                       
     C     RRN           IFEQ      1                                                         
     C                   MOVE      CT21010       PGUP1                                       
     C                   MOVE      CT21020       PGUP2                                       
     C                   ENDIF                                                               
     C*                                                                                      
     C                   WRITE     COT21S01                                                  
     C                   READ(N)   HCOTM21R                               54                 
     C*                                                                                      
     C                   ENDDO                                                               
     C**                                                                                     
     C   54              SETOFF                                       63                     
     C  N54              SETON                                        63                     
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN12  WRITE SFL FOR PAGEUP                                                       
     C*****************************************************************                      
     C     RTN12         BEGSR                                                               
     C**--                                                                                   
     C                   MOVE      PGUP1         CT21010                                     
     C                   MOVE      PGUP2         CT21020                                     
     C     KYPSTO        SETLL     HCOTM21R                                                  
     C                   READP(N)  HCOTM21R                               54                 
     C*                                                                                      
     C                   Z-ADD     0             RRN                                         
     C                   MOVE      *BLANK        PGDN1                                       
     C                   MOVE      *BLANK        PGDN2                                       
     C**                                                                                     
     C     *IN54         DOWEQ     '0'                                                       
     C     RRN           ANDLT     11                                                        
     C*                                                                                      
     C                   ADD       1             RRN                                         
     C                   MOVE      CT21010       PGDN1                                       
     C                   MOVE      CT21020       PGDN2                                       
     C*                                                                                      
     C                   READP(N)  HCOTM21R                               54                 
     C*                                                                                      
     C                   ENDDO                                                               
     C**                                                                                     
     C                   MOVE      PGDN1         PS001                                       
     C                   MOVE      PGDN2         PS002                                       
     C*                                                                                      
     C                   EXSR      RTN10                                                     
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN20  CHG RECORD                     OPTION=2                                    
     C*****************************************************************                      
     C     RTN20         BEGSR                                                               
     C**--                                                                                   
     C     KYPSTO        CHAIN     HCOTM21R                           5959                   
     C**                                                                                     
     C  N59              DO                                                                  
     C*                                                                                      
     C                   MOVE      '更改'      FUNTXT                                        
     C                   SETON                                        30                     
     C                   SETOFF                                       4093                   
     C*                                                                                      
     C*                                                                                      
     C                   EXSR      RTN72                                                     
     C*                                                                                      
     C     *INKL         DOUEQ     '1'                                                       
     C     *INKC         OREQ      '1'                                                       
     C     *IN99         OREQ      '0'                                                       
     C                   EXFMT     COT21S10                                                  
     C**                                                                                     
     C                   SETOFF                                       707172                 
     C                   SETOFF                                       99                     
     C*                                                                                      
     C  NKL                                                                                  
     CANNKC              DO                                                                  
     C*                                                                                      
     C                   EXSR      RTN21                                                     
     C**                                                                                     
     C  N99              DO                                                                  
     C*                                                                                      
     C                   EXSR      RTN71                                                     
     C*                                                                                      
     C                   UPDATE    HCOTM21R                             52                   
     C   52              MOVE      'CMM0020'     MSGID                                       
     C   52              EXSR      RTN99                                                     
     C                   ENDDO                                                               
     C**                                                                                     
     C                   ENDDO                                                               
     C**                                                                                     
     C                   ENDDO                                                               
     C**                                                                                     
     C  N99                                                                                  
     CANNKL                                                                                  
     CANNKC              DO                                                                  
     C                   MOVE      'CMM0004'     MSGID                                       
     C                   EXSR      RTN99                                                     
     C                   SETON                                        38                     
     C                   ENDDO                                                               
     C   KC                                                                                  
     COR KL              UNLOCK    HCOTM21P                             52                   
     C                   ENDDO                                                               
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN21  CHECK DATA 非KEY值                                                         
     C*****************************************************************                      
     C     RTN21         BEGSR                                                               
     C*                                                                                      
     C  N99CT21030       IFEQ      *BLANK                                                    
     C                   SETON                                        72                     
     C                   MOVE      'ADM0007'     MSGID                                       
     C                   EXSR      RTN99                                                     
     C                   ENDIF                                                               
     C*                                                                                      
     C  N99              DO                                                                  
     C                   MOVE      *BLANK        WK$030                                      
     C     CT21030       CHAIN     HSTKM01R                           5151                   
     C* N51HT0050        IFNE      'W'                                                       
     C*                  SETON                                        51                     
     C*                  ENDIF                                                               
     C  N51              MOVE      HT0040        WK$030                                      
     C   51              SETON                                        72                     
     C   51              MOVE      'ADM0027'     MSGID                                       
     C   51              EXSR      RTN99                                                     
     C                   ENDDO                                                               
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN30  COPY RECORD                    OPTION=3                                    
     C*****************************************************************                      
     C     RTN30         BEGSR                                                               
     C**--                                                                                   
     C     KYPSTO        CHAIN(N)  HCOTM21R                           5959                   
     C**                                                                                     
     C  N59              DO                                                                  
     C                   MOVE      '複製'      FUNTXT                                        
     C                   SETOFF                                       304093                 
     C*                                                                                      
     C                   EXSR      RTN72                                                     
     C*                                                                                      
     C     *INKL         DOUEQ     '1'                                                       
     C     *INKC         OREQ      '1'                                                       
     C     *IN99         OREQ      '0'                                                       
     C                   EXFMT     COT21S10                                                  
     C**                                                                                     
     C                   SETOFF                                       707172                 
     C                   SETOFF                                       99                     
     C*                                                                                      
     C  NKL                                                                                  
     CANNKC              DO                                                                  
     C*                                                                                      
     C  N99              EXSR      RTN31                                                     
     C*                                                                                      
     C  N99              DO                                                                  
     C                   EXSR      RTN21                                                     
     C**                                                                                     
     C  N99              DO                                                                  
     C*                                                                                      
     C                   EXSR      RTN71                                                     
     C*                                                                                      
     C                   WRITE     HCOTM21R                             52                   
     C   52              MOVE      'CMM0030'     MSGID                                       
     C   52              EXSR      RTN99                                                     
     C                   ENDDO                                                               
     C**                                                                                     
     C                   ENDDO                                                               
     C**                                                                                     
     C                   ENDDO                                                               
     C**                                                                                     
     C                   ENDDO                                                               
     C**--                                                                                   
     C  N99                                                                                  
     CANNKL                                                                                  
     CANNKC              DO                                                                  
     C                   MOVE      'CMM0005'     MSGID                                       
     C                   EXSR      RTN99                                                     
     C                   SETON                                        38                     
     C                   ENDDO                                                               
     C                   ENDDO                                                               
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN31  CHECK DATA KEY值                                                           
     C*****************************************************************                      
     C     RTN31         BEGSR                                                               
     C*                                                                                      
     C     KYPSTO        CHAIN(N)  HCOTM21R                           5151                   
     C  N51              DO                                                                  
     C                   SETON                                        7071                   
     C                   MOVE      'CMM0090'     MSGID                                       
     C                   EXSR      RTN99                                                     
     C                   ENDDO                                                               
     C*                                                                                      
     C  N99CT21010       IFEQ      *BLANK                                                    
     C                   SETON                                        70                     
     C                   MOVE      'ADM0007'     MSGID                                       
     C                   EXSR      RTN99                                                     
     C                   ENDIF                                                               
     C*                                                                                      
     C  N99CT21020       IFEQ      *BLANK                                                    
     C                   SETON                                        71                     
     C                   MOVE      'ADM0007'     MSGID                                       
     C                   EXSR      RTN99                                                     
     C                   ENDIF                                                               
     C*                                                                                      
     C  N99              DO                                                                  
     C                   MOVE      *BLANK        WK$020                                      
     C     CT21020       CHAIN     HSTKM01R                           5151                   
     C   51              SETON                                        71                     
     C   51              MOVE      'ADM0027'     MSGID                                       
     C   51              EXSR      RTN99                                                     
     C  N51              MOVE      HT0040        WK$020                                      
     C                   ENDDO                                                               
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN40   DELETE RECORD                 OPTION=4                                    
     C*****************************************************************                      
     C     RTN40         BEGSR                                                               
     C**--                                                                                   
     C     KYPSTO        CHAIN     HCOTM21R                           5959                   
     C**                                                                                     
     C  N59              DO                                                                  
     C**                                                                                     
     C                   MOVE      '刪除'      FUNTXT                                        
     C                   SETON                                        304093                 
     C**                                                                                     
     C                   EXSR      RTN72                                                     
     C*                                                                                      
     C                   EXFMT     COT21S10                                                  
     C*                                                                                      
     C  NKL                                                                                  
     CANNKC              DO                                                                  
     C                   DELETE    HCOTM21R                             52                   
     C   52              MOVE      'CMM0040'     MSGID                                       
     C   52              EXSR      RTN99                                                     
     C                   ENDDO                                                               
     C**                                                                                     
     C  N99                                                                                  
     CANNKL                                                                                  
     CANNKC              DO                                                                  
     C                   MOVE      'CMM0006'     MSGID                                       
     C                   EXSR      RTN99                                                     
     C                   SETON                                        38                     
     C                   ENDDO                                                               
     C   KC                                                                                  
     COR KL              UNLOCK    HCOTM21P                             52                   
     C                   ENDDO                                                               
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN50   DISPLAY RECORD                OPTION=5                                    
     C*****************************************************************                      
     C     RTN50         BEGSR                                                               
     C**--                                                                                   
     C     KYPSTO        CHAIN(N)  HCOTM21R                           5959                   
     C**                                                                                     
     C  N59              DO                                                                  
     C**                                                                                     
     C                   MOVE      '查詢'      FUNTXT                                        
     C                   SETON                                        3040                   
     C                   SETOFF                                         93                   
     C**                                                                                     
     C                   EXSR      RTN72                                                     
     C*                                                                                      
     C                   EXFMT     COT21S10                                                  
     C**                                                                                     
     C                   ENDDO                                                               
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN60  ADD RECORD                     OPTION=CF06                                 
     C*****************************************************************                      
     C     RTN60         BEGSR                                                               
     C**--                                                                                   
     C                   MOVE      *BLANK        CT21010                                     
     C                   MOVE      *BLANK        CT21020                                     
     C                   MOVE      *BLANK        WK$020                                      
     C                   MOVE      *BLANK        WK$030                                      
     C                   MOVE      *BLANK        CT21030                                     
     C                   MOVE      *BLANK        CT21040                                     
     C                   Z-ADD     0             CT21050                                     
     C                   Z-ADD     0             CT21060                                     
     C                   MOVE      *BLANK        CT21070                                     
     C*                                                                                      
     C                   MOVE      '新增'      FUNTXT                                        
     C                   SETOFF                                       304093                 
     C*                                                                                      
     C     *INKL         DOUEQ     '1'                                                       
     C     *INKC         OREQ      '1'                                                       
     C     *IN99         OREQ      '0'                                                       
     C                   EXFMT     COT21S10                                                  
     C**                                                                                     
     C                   SETOFF                                       707172                 
     C                   SETOFF                                       99                     
     C*                                                                                      
     C  NKL                                                                                  
     CANNKC              DO                                                                  
     C**                                                                                     
     C  N99              EXSR      RTN31                                                     
     C**                                                                                     
     C  N99              DO                                                                  
     C                   EXSR      RTN21                                                     
     C**                                                                                     
     C  N99              DO                                                                  
     C*                                                                                      
     C                   EXSR      RTN71                                                     
     C*                                                                                      
     C                   WRITE     HCOTM21R                             52                   
     C   52              MOVE      'CMM0030'     MSGID                                       
     C   52              EXSR      RTN99                                                     
     C                   ENDDO                                                               
     C**                                                                                     
     C                   ENDDO                                                               
     C**                                                                                     
     C                   ENDDO                                                               
     C**                                                                                     
     C                   ENDDO                                                               
     C**-                                                                                    
     C  N99                                                                                  
     CANNKL                                                                                  
     CANNKC              DO                                                                  
     C                   MOVE      'CMM0007'     MSGID                                       
     C                   EXSR      RTN99                                                     
     C                   SETON                                        38                     
     C                   ENDDO                                                               
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN71  MOVE DATA TO FILE                                                          
     C*****************************************************************                      
     C     RTN71         BEGSR                                                               
     C**--                                                                                   
     C                   Z-ADD     ZTODAY        CT21050                                     
     C                   TIME                    CT21060                                     
     C                   MOVEL     USRID         CT21070                                     
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN72  CHAIN DATA & MOVE DATA TO SCREEN                                           
     C*****************************************************************                      
     C     RTN72         BEGSR                                                               
     C**--                                                                                   
     C     CT21020       CHAIN     HSTKM01R                           5151                   
     C   51              MOVE      *BLANK        WK$020                                      
     C  N51              MOVE      HT0040        WK$020                                      
     C**--                                                                                   
     C     CT21030       CHAIN     HSTKM01R                           5151                   
     C   51              MOVE      *BLANK        WK$030                                      
     C  N51              MOVE      HT0040        WK$030                                      
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN98  COMAND KEY                                                                 
     C*****************************************************************                      
     C     RTN98         BEGSR                                                               
     C**--                                                                                   
     C   KC              SETON                                        LR                     
     C   KC              RETURN                                                              
     C   KE              EXSR      RTN10                                                     
     C   KE              GOTO      TAG01                                                     
     C*                                                                                      
     C   KF              DO                                                                  
     C                   EXSR      RTN60                                                     
     C   38              EXSR      RTN10                                                     
     C   38              GOTO      TAG01                                                     
     C                   ENDDO                                                               
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   RTN99  ERROR MSG     到MSG FILE 讀錯誤訊息　                                      
     C*****************************************************************                      
     C     RTN99         BEGSR                                                               
     C**--                                                                                   
     C                   SETON                                        99                     
     C*                                                                                      
     C                   CALL      'CMX99'                                                   
     C                   PARM                    MSGID             7                         
     C                   PARM                    MSGTXT           60                         
     C                   PARM                    MSGPM1                                      
     C                   PARM                    MSGPM2                                      
     C*                                                                                      
     C                   WRITE     COT21S99                                                  
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   P S S R         程式當掉時自動跳出                                                
     C*****************************************************************                      
     C     *PSSR         BEGSR                                                               
     C**--                                                                                   
     C                   SETON                                          LR                   
     C                   RETURN                                                              
     C**--                                                                                   
     C                   ENDSR                                                               
     C*****************************************************************                      
     C**   *INZSR   INITIALIZE                                                               
     C*****************************************************************                      
     C     *INZSR        BEGSR                                                               
     C**--                                                                                   
     C                   CALL      'ZTODAY'                                                  
     C                   PARM                    ZTODAY            8 0                       
     C**                                                                                     
     C                   MOVEL     'HCOTM21'     PGMQ                                        
     C**                                                                                     
     C     #BRNCH        CHAIN     ZBRANCH                            51                     
     C  N51              MOVE      ABK030        CMPNAM                                      
     C**                                                                                     
     C     *DTAARA       DEFINE    ZMODE         MODE              1                         
     C                   IN        MODE                                                      
     C     MODE          COMP      'B'                                    49                 
     C*                                                                                      
     C                   CALL      'XRTVAUT'                                                 
     C                   PARM      USRID         $USRID           10                         
     C                   PARM      'HCOTM21'     $PGMNM            7                         
     C                   PARM                    $ADD              1                         
     C                   PARM                    $CHG              1                         
     C                   PARM                    $DEL              1                         
     C                   PARM                    $INQ              1                         
     C                   PARM                    $PRT              1                         
     C                   PARM                    $OPN              1                         
     C*                                                                                      
     C     $ADD          COMP      'Y'                                    95                 
     C     $CHG          COMP      'Y'                                    96                 
     C     $DEL          COMP      'Y'                                    97                 
     C     $INQ          COMP      'Y'                                    98                 
     C**                                                                                     
     C                   MOVE      *BLANK        MSGDTA                                      
     C**                                                                                     
     C     KYPSTO        KLIST                                                               
     C                   KFLD                    CT21010                                     
     C                   KFLD                    CT21020                                     
     C**                                                                                     
     C                   MOVE      *BLANK        PGUP1             3                         
     C                   MOVE      *BLANK        PGUP2             6                         
     C                   MOVE      *BLANK        PGDN1             3                         
     C                   MOVE      *BLANK        PGDN2             6                         
     C                   Z-ADD     0             RRN               4 0                       
     C**                                                                                     
     C                   EXSR      RTN10                                                     
     C**--                                                                                   
     C                   ENDSR   