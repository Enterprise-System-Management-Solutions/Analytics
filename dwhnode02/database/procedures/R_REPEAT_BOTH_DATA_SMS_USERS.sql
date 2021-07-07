--
-- R_REPEAT_BOTH_DATA_SMS_USERS  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R_REPEAT_BOTH_DATA_SMS_USERS IS
    VDATE_KEY       NUMBER;
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE,'RRRRMMDD');

    
INSERT INTO REPEAT_BOTH_DATA_SMS_USERS


SELECT /*+parallel(P,16)*/S372_CALLINGPARTYNUMBER MSISDN ,VDATE_KEY FROM 
(SELECT  /*+parallel(P,16)*/S372_CALLINGPARTYNUMBER FROM 
(SELECT /*+parallel(P,16)*/ DISTINCT S372_CALLINGPARTYNUMBER
FROM L3_SMS P
WHERE (S387_CHARGINGTIME_KEY between (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-30,'dd/mm/rrrr'))
                             and  (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-1,'dd/mm/rrrr')))
AND S378_SERVICEFLOW=1
GROUP BY S372_CALLINGPARTYNUMBER) P 

INNER JOIN

(
SELECT /*+parallel(P,16)*/ DISTINCT G372_CALLINGPARTYNUMBER
FROM L3_DATA P
WHERE  (G383_CHARGINGTIME_KEY between (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-30,'dd/mm/rrrr'))
                             and  (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-1,'dd/mm/rrrr')))
GROUP BY G372_CALLINGPARTYNUMBER) Q ON G372_CALLINGPARTYNUMBER=S372_CALLINGPARTYNUMBER 

)P
WHERE 
EXISTS
(
select S372_CALLINGPARTYNUMBER1 from
(SELECT S372_CALLINGPARTYNUMBER S372_CALLINGPARTYNUMBER1,TOTAL,DISTINCT_CALLEDPARTY FROM (
SELECT /*+parallel(P,16)*/ DISTINCT S372_CALLINGPARTYNUMBER, COUNT(S373_CALLEDPARTYNUMBER) AS TOTAL, COUNT(DISTINCT S373_CALLEDPARTYNUMBER) AS DISTINCT_CALLEDPARTY 
FROM L3_SMS P
WHERE (S387_CHARGINGTIME_KEY between (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-30,'dd/mm/rrrr'))
                             and  (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-1,'dd/mm/rrrr')))
AND S378_SERVICEFLOW=1
GROUP BY S372_CALLINGPARTYNUMBER)
WHERE (TOTAL/DISTINCT_CALLEDPARTY)>1
)Q
WHERE S372_CALLINGPARTYNUMBER1=S372_CALLINGPARTYNUMBER
)
;
    COMMIT;
END;
/
