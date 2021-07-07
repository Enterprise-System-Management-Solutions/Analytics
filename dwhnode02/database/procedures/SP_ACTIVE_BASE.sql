--
-- SP_ACTIVE_BASE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.SP_ACTIVE_BASE (P_PROCESS_DATE VARCHAR2) IS
    VDATE_KEY               NUMBER;
    VDATE DATE := TO_DATE(TO_DATE(P_PROCESS_DATE,'YYYYMMDD'),'DD/MM/RRRR');
BEGIN
    SELECT DATE_KEY INTO VDATE_KEY 
    FROM DATE_DIM
    WHERE DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = VDATE);
    
       --------voice-------    
    MERGE INTO ACTIVEBASE A
    USING (SELECT DISTINCT V372_CALLINGPARTYNUMBER,V387_CHARGINGTIME_KEY FROM L3_VOICE  WHERE V378_SERVICEFLOW=1 AND  V387_CHARGINGTIME_KEY=VDATE_KEY) V 
    ON (A.MSISDIN_NO = V.V372_CALLINGPARTYNUMBER) 
    WHEN MATCHED THEN
    UPDATE SET A.LAST_ACTIVITY_DATE_KEY=V.V387_CHARGINGTIME_KEY 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, LAST_ACTIVITY_DATE_KEY,ETL_DATE_KEY)
    VALUES (V.V372_CALLINGPARTYNUMBER, V.V387_CHARGINGTIME_KEY,VDATE_KEY);
    COMMIT;
    
    --------data-------        
    MERGE INTO ACTIVEBASE A
    USING (SELECT DISTINCT G372_CALLINGPARTYNUMBER,G383_CHARGINGTIME_KEY FROM L3_DATA  WHERE  G383_CHARGINGTIME_KEY=VDATE_KEY) D 
    ON (A.MSISDIN_NO = D.G372_CALLINGPARTYNUMBER) 
    WHEN MATCHED THEN
    UPDATE SET A.LAST_ACTIVITY_DATE_KEY=D.G383_CHARGINGTIME_KEY  WHERE A.MSISDIN_NO = D.G372_CALLINGPARTYNUMBER
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, LAST_ACTIVITY_DATE_KEY,ETL_DATE_KEY)
    VALUES (D.G372_CALLINGPARTYNUMBER, D.G383_CHARGINGTIME_KEY,VDATE_KEY);        
    COMMIT;  
    
    -------Recharge-----
    MERGE INTO ACTIVEBASE A
    USING (SELECT DISTINCT RE6_PRI_IDENTITY,RE30_ENTRY_DATE_KEY FROM L3_RECHARGE  WHERE  RE30_ENTRY_DATE_KEY=VDATE_KEY) R 
    ON (A.MSISDIN_NO = R.RE6_PRI_IDENTITY) 
    WHEN MATCHED THEN
    UPDATE SET A.LAST_ACTIVITY_DATE_KEY=R.RE30_ENTRY_DATE_KEY 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, LAST_ACTIVITY_DATE_KEY,ETL_DATE_KEY)
    VALUES (R.RE6_PRI_IDENTITY, R.RE30_ENTRY_DATE_KEY,VDATE_KEY);
    COMMIT;
      
    ------RECURRING-----      
    MERGE INTO ACTIVEBASE A
    USING (SELECT DISTINCT R375_CHARGINGPARTYNUMBER,R377_CYCLEBEGINTIME_KEY FROM L3_RECURRING  WHERE  R377_CYCLEBEGINTIME_KEY=VDATE_KEY) VS 
    ON (A.MSISDIN_NO = VS.R375_CHARGINGPARTYNUMBER) 
    WHEN MATCHED THEN
    UPDATE SET A.LAST_ACTIVITY_DATE_KEY=VS.R377_CYCLEBEGINTIME_KEY 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, LAST_ACTIVITY_DATE_KEY,ETL_DATE_KEY)
    VALUES (VS.R375_CHARGINGPARTYNUMBER, VS.R377_CYCLEBEGINTIME_KEY,VDATE_KEY);
    COMMIT;
      
        ------sms-----      
    MERGE INTO ACTIVEBASE A
    USING (SELECT DISTINCT S372_CALLINGPARTYNUMBER,S387_CHARGINGTIME_KEY FROM L3_SMS  WHERE  S387_CHARGINGTIME_KEY=VDATE_KEY) VL
    ON (A.MSISDIN_NO = VL.S372_CALLINGPARTYNUMBER) 
    WHEN MATCHED THEN
    UPDATE SET A.LAST_ACTIVITY_DATE_KEY=VL.S387_CHARGINGTIME_KEY 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, LAST_ACTIVITY_DATE_KEY,ETL_DATE_KEY)
    VALUES (VL.S372_CALLINGPARTYNUMBER, VL.S387_CHARGINGTIME_KEY,VDATE_KEY);
    COMMIT;
    -------Age on network----
    MERGE INTO AGEONNETWROK A
    USING (SELECT DISTINCT V372_CALLINGPARTYNUMBER,V387_CHARGINGTIME_KEY FROM L3_VOICE  WHERE  V387_CHARGINGTIME_KEY=VDATE_KEY) V 
    ON (A.MSISDIN_NO = V.V372_CALLINGPARTYNUMBER) 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, FIRST_ACTIVE_DATE,ETL_DATE_KEY)
    VALUES (V.V372_CALLINGPARTYNUMBER, V.V387_CHARGINGTIME_KEY,VDATE_KEY);        
    COMMIT;  
        
    ----------data----------        
    MERGE INTO AGEONNETWROK A
    USING (SELECT DISTINCT G372_CALLINGPARTYNUMBER,G383_CHARGINGTIME_KEY FROM L3_DATA  WHERE  G383_CHARGINGTIME_KEY=VDATE_KEY) DN 
    ON (A.MSISDIN_NO = DN.G372_CALLINGPARTYNUMBER) 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, FIRST_ACTIVE_DATE,ETL_DATE_KEY)
    VALUES (DN.G372_CALLINGPARTYNUMBER, DN.G383_CHARGINGTIME_KEY,VDATE_KEY);        
    COMMIT;  
      
    --------recharge--------
    MERGE INTO AGEONNETWROK A
    USING (SELECT DISTINCT RE6_PRI_IDENTITY,RE30_ENTRY_DATE_KEY FROM L3_RECHARGE  WHERE  RE30_ENTRY_DATE_KEY=VDATE_KEY) RN 
    ON (A.MSISDIN_NO = RN.RE6_PRI_IDENTITY)  
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, FIRST_ACTIVE_DATE,ETL_DATE_KEY)
    VALUES (RN.RE6_PRI_IDENTITY, RN.RE30_ENTRY_DATE_KEY,VDATE_KEY);
    COMMIT;
    
    -------recurring--------     
    MERGE INTO AGEONNETWROK A
    USING (SELECT DISTINCT R375_CHARGINGPARTYNUMBER,R377_CYCLEBEGINTIME_KEY FROM L3_RECURRING  WHERE  R377_CYCLEBEGINTIME_KEY=VDATE_KEY) VN 
    ON (A.MSISDIN_NO = VN.R375_CHARGINGPARTYNUMBER) 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, FIRST_ACTIVE_DATE,ETL_DATE_KEY)
    VALUES (VN.R375_CHARGINGPARTYNUMBER, VN.R377_CYCLEBEGINTIME_KEY,VDATE_KEY);
    COMMIT;   
    
        -------sms--------     
    MERGE INTO AGEONNETWROK A
    USING (SELECT DISTINCT S372_CALLINGPARTYNUMBER,S387_CHARGINGTIME_KEY FROM l3_sms  WHERE  S387_CHARGINGTIME_KEY=VDATE_KEY) VM
    ON (A.MSISDIN_NO = VM.S372_CALLINGPARTYNUMBER) 
    WHEN NOT MATCHED THEN
    INSERT (MSISDIN_NO, FIRST_ACTIVE_DATE,ETL_DATE_KEY)
    VALUES (VM.S372_CALLINGPARTYNUMBER, VM.S387_CHARGINGTIME_KEY,VDATE_KEY);
    COMMIT;
END;
/
