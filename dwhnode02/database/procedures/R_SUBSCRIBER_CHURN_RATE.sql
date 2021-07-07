--
-- R_SUBSCRIBER_CHURN_RATE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R_SUBSCRIBER_CHURN_RATE IS
    VDATE_KEY       NUMBER;
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE,'RRRRMMDD');
   
DELETE SUBSCRIBER_CHURN_RATE WHERE MONTH_KEY=(SELECT  MONTH_KEY-1 FROM DATE_DIM P WHERE  DATE_VALUE= TRUNC(TO_DATE(SYSDATE,'DD/MM/RRRR')));
COMMIT;
    
INSERT INTO SUBSCRIBER_CHURN_RATE


SELECT MONTH_KEY, MSISDN,PRODUCT_ID,PRODUCT_NAME,MRR,STOPPED_MRR,ROUND((STOPPED_MRR)/(MRR),2) CHURN_SCORE FROM
(SELECT A.MONTH_KEY, A.R375_CHARGINGPARTYNUMBER MSISDN,A.PRODUCT_ID,A.PRODUCT_NAME,A.MRR,NVL(B.STOPPED_MRR,0)STOPPED_MRR FROM
(SELECT /*+PARALLEL(P,15)*/ TO_CHAR(TO_NUMBER(MONTH_KEY)+1) MONTH_KEY, R375_CHARGINGPARTYNUMBER,PRODUCT_ID,PRODUCT_NAME,SUM (R41_DEBIT_AMOUNT) MRR
FROM L3_RECURRING P,PRODUCT_DIM Q,DATE_DIM R
WHERE (R377_CYCLEBEGINTIME_KEY IN (SELECT DATE_KEY FROM DATE_DIM WHERE MONTH_KEY = (SELECT TO_CHAR(TO_NUMBER(MONTH_KEY)-2) MONTH_KEY
FROM DATE_DIM
WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE,'DD/MM/RRRR')))))
AND P.R373_MAINOFFERINGID=Q.PRODUCT_ID
AND P.R377_CYCLEBEGINTIME_KEY=R.DATE_KEY 

GROUP BY MONTH_KEY, R375_CHARGINGPARTYNUMBER,PRODUCT_ID,PRODUCT_NAME)A

LEFT OUTER JOIN

(SELECT /*+PARALLEL(P,15)*/ R375_CHARGINGPARTYNUMBER,PRODUCT_ID,PRODUCT_NAME,SUM (R41_DEBIT_AMOUNT) STOPPED_MRR
FROM L3_RECURRING P,PRODUCT_DIM Q
WHERE (R377_CYCLEBEGINTIME_KEY IN (SELECT DATE_KEY FROM DATE_DIM WHERE MONTH_KEY = (SELECT TO_CHAR(TO_NUMBER(MONTH_KEY)-2) MONTH_KEY
FROM DATE_DIM
WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE,'DD/MM/RRRR')))))
AND P.R373_MAINOFFERINGID=Q.PRODUCT_ID
AND
NOT EXISTS
(SELECT *
FROM
(SELECT /*+PARALLEL(P,15)*/ R375_CHARGINGPARTYNUMBER,PRODUCT_ID,PRODUCT_NAME,R385_OFFERINGID
FROM L3_RECURRING P,PRODUCT_DIM Q
WHERE (R377_CYCLEBEGINTIME_KEY IN (SELECT DATE_KEY FROM DATE_DIM WHERE MONTH_KEY = (SELECT TO_CHAR(TO_NUMBER(MONTH_KEY)-1) MONTH_KEY
FROM DATE_DIM
WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE,'DD/MM/RRRR')))))
AND P.R373_MAINOFFERINGID=Q.PRODUCT_ID

GROUP BY R375_CHARGINGPARTYNUMBER,PRODUCT_ID,PRODUCT_NAME,R385_OFFERINGID
)S
WHERE P.R375_CHARGINGPARTYNUMBER=S.R375_CHARGINGPARTYNUMBER AND Q.PRODUCT_ID=S.PRODUCT_ID AND Q.PRODUCT_NAME=S.PRODUCT_NAME AND P.R385_OFFERINGID=S.R385_OFFERINGID
)


GROUP BY R375_CHARGINGPARTYNUMBER,PRODUCT_ID,PRODUCT_NAME)B ON A.R375_CHARGINGPARTYNUMBER=B.R375_CHARGINGPARTYNUMBER AND A.PRODUCT_NAME=B.PRODUCT_NAME AND A.PRODUCT_ID=B.PRODUCT_ID
ORDER BY A.R375_CHARGINGPARTYNUMBER
)
WHERE MRR !=0
ORDER BY MSISDN
;
             
             
             
      COMMIT;
END;
/
