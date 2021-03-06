--
-- SP_ACTIVE_BASE_SEGMENT  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.SP_ACTIVE_BASE_SEGMENT(P_PROCESS_DATE VARCHAR2) IS
    VDATE_KEY    NUMBER;
    VDATE        DATE := TO_DATE(TO_DATE(P_PROCESS_DATE,'YYYYMMDD'),'DD/MM/RRRR');
BEGIN   
    SELECT DATE_KEY INTO VDATE_KEY 
    FROM DATE_DIM
    WHERE DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = VDATE);
        
    MERGE INTO ACTIVEBASEVOICE A
    USING (SELECT DISTINCT V372_CALLINGPARTYNUMBER,V387_CHARGINGTIME_KEY FROM L3_VOICE  WHERE  V387_CHARGINGTIME_KEY=VDATE_KEY) V 
    ON (A.MSISDIN_NO = V.V372_CALLINGPARTYNUMBER) 
    WHEN MATCHED THEN
    UPDATE SET A.LAST_ACTIVITY_DATE_KEY=V.V387_CHARGINGTIME_KEY 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, LAST_ACTIVITY_DATE_KEY,ETL_DATE_KEY)
    VALUES (V.V372_CALLINGPARTYNUMBER, V.V387_CHARGINGTIME_KEY,VDATE_KEY);
    COMMIT; 
    
    ------DATA-----        
    MERGE INTO ACTIVEBASEDATA A
    USING (SELECT DISTINCT G372_CALLINGPARTYNUMBER,G383_CHARGINGTIME_KEY FROM L3_DATA  WHERE  G383_CHARGINGTIME_KEY=VDATE_KEY) D 
    ON (A.MSISDIN_NO = D.G372_CALLINGPARTYNUMBER) 
    WHEN MATCHED THEN
    UPDATE SET A.LAST_ACTIVITY_DATE_KEY=D.G383_CHARGINGTIME_KEY  WHERE A.MSISDIN_NO = D.G372_CALLINGPARTYNUMBER
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, LAST_ACTIVITY_DATE_KEY,ETL_DATE_KEY)
    VALUES (D.G372_CALLINGPARTYNUMBER, D.G383_CHARGINGTIME_KEY,VDATE_KEY);        
    COMMIT;  
    
    -----RECHARGE-----
    MERGE INTO ACTIVEBASERECHARGE A
    USING (SELECT DISTINCT RE6_PRI_IDENTITY,RE30_ENTRY_DATE_KEY FROM L3_RECHARGE  WHERE  RE30_ENTRY_DATE_KEY=VDATE_KEY) R 
    ON (A.MSISDIN_NO = R.RE6_PRI_IDENTITY) 
    WHEN MATCHED THEN
    UPDATE SET A.LAST_ACTIVITY_DATE_KEY=R.RE30_ENTRY_DATE_KEY 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, LAST_ACTIVITY_DATE_KEY,ETL_DATE_KEY)
    VALUES (R.RE6_PRI_IDENTITY, R.RE30_ENTRY_DATE_KEY,VDATE_KEY);
    COMMIT;
      
    -----RECURRING----      
    MERGE INTO ACTIVEBASERECURRING A
    USING (SELECT DISTINCT R375_CHARGINGPARTYNUMBER,R377_CYCLEBEGINTIME_KEY FROM L3_RECURRING  WHERE  R377_CYCLEBEGINTIME_KEY=VDATE_KEY) VS 
    ON (A.MSISDIN_NO = VS.R375_CHARGINGPARTYNUMBER) 
    WHEN MATCHED THEN
    UPDATE SET A.LAST_ACTIVITY_DATE_KEY=VS.R377_CYCLEBEGINTIME_KEY 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, LAST_ACTIVITY_DATE_KEY,ETL_DATE_KEY)
    VALUES (VS.R375_CHARGINGPARTYNUMBER, VS.R377_CYCLEBEGINTIME_KEY,VDATE_KEY);
    COMMIT;
    
    
    -----SMS---
     MERGE INTO ACTIVEBASESMS A
    USING (SELECT DISTINCT S22_PRI_IDENTITY,S387_CHARGINGTIME_KEY FROM L3_SMS  WHERE  S387_CHARGINGTIME_KEY=VDATE_KEY) VM 
    ON (A.MSISDIN_NO = VM.S22_PRI_IDENTITY) 
    WHEN MATCHED THEN
    UPDATE SET A.LAST_ACTIVITY_DATE_KEY=VM.S387_CHARGINGTIME_KEY 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, LAST_ACTIVITY_DATE_KEY,ETL_DATE_KEY)
    VALUES (VM.S22_PRI_IDENTITY, VM.S387_CHARGINGTIME_KEY,VDATE_KEY);
    COMMIT;
   
END;
/

