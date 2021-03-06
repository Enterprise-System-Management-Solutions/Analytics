--
-- PRO_NEW_MGMT_DBOARD7_MAP_VOICE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.PRO_NEW_MGMT_DBOARD7_MAP_VOICE IS
    VDATE_KEY       NUMBER;
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE-1,'RRRRMMDD');

    
DELETE NEW_MGMT_DBOARD7_MAP_VOICE WHERE PDR_DATE_KEY=VDATE_KEY;
COMMIT;
    
INSERT INTO NEW_MGMT_DBOARD7_MAP_VOICE


SELECT COUNTRY,INITCAP(DIVISION) DIVISION ,SUM(VOICE_DURATION)/(3600*1000) VOICE_DURATION_HR,SUM(VOICE_REVRNUE)/100000 VOICE_REVRNUE_THOUSANDS,VDATE_KEY FROM ZONE_DIM_OLD,
(SELECT /*+PARALLEL(P,8)*/ V381_CALLINGCELLID ,SUM(V35_RATE_USAGE) VOICE_DURATION, SUM (V41_DEBIT_AMOUNT) VOICE_REVRNUE
FROM  L3_VOICE P
WHERE V378_SERVICEFLOW =1 AND V387_CHARGINGTIME_KEY = (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
GROUP BY  V381_CALLINGCELLID 
)
WHERE CGI=V381_CALLINGCELLID
GROUP BY COUNTRY,INITCAP(DIVISION);

    COMMIT;
END;
/

