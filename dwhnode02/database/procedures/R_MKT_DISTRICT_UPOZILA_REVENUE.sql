--
-- R_MKT_DISTRICT_UPOZILA_REVENUE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R_MKT_DISTRICT_UPOZILA_REVENUE IS
    VDATE_KEY       NUMBER;
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE-1,'RRRRMMDD');



    --EXECUTE IMMEDIATE  'TRUNCATE TABLE PKPI DROP STORAGE';
    --EXECUTE IMMEDIATE 'ALTER TABLE PKPI TRUNCATE PARTITION PKPI_||VDATE_KEY DROP STORAGE';
    
DELETE MKT_DISTRICT_UPOZILA_REVENUE WHERE DATE_KEY=VDATE_KEY;
COMMIT;
    
INSERT INTO MKT_DISTRICT_UPOZILA_REVENUE


SELECT INITCAP(DISTRICT) DISTRICT,INITCAP(UPAZILA) UPAZILA,INITCAP(SITE_NAME) SITE_NAME,SUM( PREPAID_VOICE_REVENUE) PREPAID_VOICE_REVENUE,
       SUM(POSTPAID_VOICE_REVENUE) POSTPAID_VOICE_REVENUE,SUM(DATA_PAYG_REVENUE ) DATA_PAYG_REVENUE,SUM(TOTAL_REVNUE) TOTAL_REVNUE,VDATE_KEY
FROM ZONE_DIM G,
(SELECT A.CGI,COALESCE (PREPAID_VOICE_REVENUE, 0)PREPAID_VOICE_REVENUE,COALESCE (POSTPAID_VOICE_REVENUE, 0)POSTPAID_VOICE_REVENUE,
        COALESCE (DATA_PAYG_REVENUE, 0)DATA_PAYG_REVENUE 
        ,COALESCE (PREPAID_VOICE_REVENUE, 0)+ COALESCE (POSTPAID_VOICE_REVENUE, 0)+ COALESCE (DATA_PAYG_REVENUE, 0) TOTAL_REVNUE
FROM
(
SELECT CGI FROM ZONE_DIM

)A

LEFT OUTER JOIN

(SELECT /*+PARALLEL(R,8)*/V381_CALLINGCELLID, SUM(V41_DEBIT_AMOUNT) PREPAID_VOICE_REVENUE FROM L3_VOICE R
WHERE V387_CHARGINGTIME_KEY = TO_CHAR((SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
    
AND  V400_PAYTYPE=0
GROUP BY V381_CALLINGCELLID
)B ON A.CGI=B.V381_CALLINGCELLID

LEFT OUTER JOIN

(SELECT /*+PARALLEL(R,8)*/V381_CALLINGCELLID, SUM(V41_DEBIT_AMOUNT) POSTPAID_VOICE_REVENUE FROM L3_VOICE R
WHERE V387_CHARGINGTIME_KEY = TO_CHAR((SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
     
AND  V400_PAYTYPE=1
GROUP BY V381_CALLINGCELLID
)C ON A.CGI=C.V381_CALLINGCELLID

LEFT OUTER JOIN

(SELECT /*+PARALLEL(R,8)*/G379_CALLINGCELLID, SUM(G41_DEBIT_AMOUNT) DATA_PAYG_REVENUE FROM L3_DATA R
WHERE G383_CHARGINGTIME_KEY = TO_CHAR((SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
   
GROUP BY G379_CALLINGCELLID
)D ON A.CGI=D.G379_CALLINGCELLID
)H

WHERE H.CGI=G.CGI

GROUP BY INITCAP(DISTRICT),INITCAP(UPAZILA),INITCAP(SITE_NAME)




;
    COMMIT;
END;
/

