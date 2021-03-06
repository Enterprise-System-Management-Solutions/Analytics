--
-- PRO_NEW_MGMT_DBOARD5_DATA_USAGE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.PRO_NEW_MGMT_DBOARD5_DATA_USAGE IS
    VDATE_KEY       NUMBER;
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE-1,'RRRRMMDD');

    
DELETE NEW_MGMT_DBOARD5_DATA_USAGE WHERE PDR_DATE_KEY=VDATE_KEY;
COMMIT;
    
INSERT INTO NEW_MGMT_DBOARD5_DATA_USAGE


SELECT RATTYPE_NAME,DATA_VOLUME_TB,VDATE_KEY FROM RATTYPE_DIM,
(SELECT /*+PARALLEL(P,8)*/ G429_RATTYPE ,SUM(G384_TOTALFLUX)/1099511627776 DATA_VOLUME_TB  
FROM L3_DATA P
WHERE G383_CHARGINGTIME_KEY  = (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
GROUP BY G429_RATTYPE
)
WHERE G429_RATTYPE=RATTYPE_ID;

    COMMIT;
END;
/

