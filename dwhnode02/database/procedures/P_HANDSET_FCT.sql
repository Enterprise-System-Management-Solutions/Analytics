--
-- P_HANDSET_FCT  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.P_HANDSET_FCT IS
BEGIN
--EXECUTE IMMEDIATE 'TRUNCATE TABLE HANDSET_FCT DROP STORAGE';
INSERT INTO HANDSET_FCT
SELECT DATE_KEY,MSISDN,IMEI,SUBSTR(IMEI,1,8) AS TAC
FROM 
(
SELECT G383_CHARGINGTIME_KEY AS DATE_KEY,G372_CALLINGPARTYNUMBER AS MSISDN,G388_IMEI AS IMEI
FROM L2_DATA@DWH05TODWH01
WHERE G383_CHARGINGTIME_KEY= (SELECT DATE_KEY FROM DATE_DIM WHERE TRUNC(DATE_VALUE)=TRUNC(SYSDATE-1))
GROUP BY G383_CHARGINGTIME_KEY,G372_CALLINGPARTYNUMBER,G388_IMEI)
GROUP BY DATE_KEY,MSISDN,IMEI,SUBSTR(IMEI,1,8)
;
COMMIT;
END;
/

