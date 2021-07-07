--
-- R_SHAHIN_DEMO02  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R_SHAHIN_DEMO02 IS
    
BEGIN

    
INSERT INTO SHAHIN_DEMO02

SELECT /*+PARALLEL(P,8)*/ V387_CHARGINGTIME_KEY DATE_KEY,SUM (V41_DEBIT_AMOUNT) VOICE_REVENUE FROM L3_VOICE PARTITION(VOICE_2370) P
WHERE V387_CHARGINGTIME_KEY  = (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(sysdate-1,'DD/MM/RRRR')))
GROUP BY V387_CHARGINGTIME_KEY
;
    COMMIT;
END;
/
