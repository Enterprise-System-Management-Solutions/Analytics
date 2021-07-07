--
-- R222_REPEAT_TOTAL_ACTIVE_SUBSCRIBERS  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R222_REPEAT_TOTAL_ACTIVE_SUBSCRIBERS IS
    VDATE_KEY       NUMBER;
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE-1,'RRRRMMDD');

    
INSERT INTO REPEAT_TOTAL_ACTIVE_SUBSCRIBERS


SELECT /*+parallel(P,16)*/MSISDN,VDATE_KEY FROM 
(

SELECT /*+parallel(P,16)*/DISTINCT MSISDN FROM
(
(SELECT /*+parallel(P,16)*/ DISTINCT V372_CALLINGPARTYNUMBER MSISDN
FROM L3_VOICE P
WHERE  (V387_CHARGINGTIME_KEY between (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-31,'dd/mm/rrrr'))
                             and  (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-2,'dd/mm/rrrr')))
AND V378_SERVICEFLOW=1
GROUP BY V372_CALLINGPARTYNUMBER)

UNION 

(
SELECT /*+parallel(P,16)*/ DISTINCT G372_CALLINGPARTYNUMBER
FROM L3_DATA P
WHERE (G383_CHARGINGTIME_KEY between (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-31,'dd/mm/rrrr'))
                             and  (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-2,'dd/mm/rrrr')))
GROUP BY G372_CALLINGPARTYNUMBER)


UNION

(SELECT /*+parallel(P,16)*/ DISTINCT S372_CALLINGPARTYNUMBER
FROM L3_SMS P
WHERE (S387_CHARGINGTIME_KEY between (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-31,'dd/mm/rrrr'))
                             and  (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-2,'dd/mm/rrrr')))
AND S378_SERVICEFLOW=1
GROUP BY S372_CALLINGPARTYNUMBER)


)P

)P
WHERE 
EXISTS
(
select V372_CALLINGPARTYNUMBER1  from
(SELECT V372_CALLINGPARTYNUMBER V372_CALLINGPARTYNUMBER1 ,TOTAL,DISTINCT_CALLEDPARTY FROM (
SELECT /*+parallel(P,16)*/ DISTINCT V372_CALLINGPARTYNUMBER, COUNT(V373_CALLEDPARTYNUMBER) AS TOTAL, COUNT(DISTINCT V373_CALLEDPARTYNUMBER) AS DISTINCT_CALLEDPARTY 
FROM L3_VOICE P
WHERE  (V387_CHARGINGTIME_KEY between (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-31,'dd/mm/rrrr'))
                             and  (SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE=TO_DATE(sysdate-2,'dd/mm/rrrr')))
AND V378_SERVICEFLOW=1
GROUP BY V372_CALLINGPARTYNUMBER)
WHERE (TOTAL/DISTINCT_CALLEDPARTY)>1
)Q
WHERE V372_CALLINGPARTYNUMBER1=MSISDN
)





;
    COMMIT;
END;
/
