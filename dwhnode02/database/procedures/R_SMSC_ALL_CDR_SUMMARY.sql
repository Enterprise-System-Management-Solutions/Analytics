--
-- R_SMSC_ALL_CDR_SUMMARY  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R_SMSC_ALL_CDR_SUMMARY IS
    VDATE_KEY       VARCHAR2(64 BYTE);
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE-1,'RRRRMMDD');



    --EXECUTE IMMEDIATE  'TRUNCATE TABLE PKPI DROP STORAGE';
    --EXECUTE IMMEDIATE 'ALTER TABLE PKPI TRUNCATE PARTITION PKPI_||VDATE_KEY DROP STORAGE';
    
DELETE SMSC_ALL_CDR_SUMMARY WHERE DATE_KEY=VDATE_KEY;
COMMIT;
    
INSERT INTO SMSC_ALL_CDR_SUMMARY

SELECT A.SMC30_ORGACCOUNT,   COALESCE (ONNET_SUCCESS_1, 0)+ COALESCE (ONNET_SUCCESS_2, 0) ONNET_SUCCESS,COALESCE (OFFNET_SUCCESS_1, 0)+ COALESCE (OFFNET_SUCCESS_2, 0) OFFNET_SUCCESS,
         COALESCE (ONNET_FAILED_1, 0)+ COALESCE (ONNET_FAILED_2, 0) ONNNET_FAIL, COALESCE (OFFNET_FAILED_1, 0)+ COALESCE (OFFNET_FAILED_2, 0) OFFNET_FAIL,
         COALESCE (INT_SUCCESS,0)INT_SUCCESS, COALESCE (INT_FAILED,0)INT_FAILED, COALESCE( TOTAL_SUCCESS,0)TOTAL_SUCCESS, COALESCE( TOTAL_FAIL,0)TOTAL_FAIL,
         VDATE_KEY
FROM
(select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT 
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
GROUP BY SMC30_ORGACCOUNT
)A

LEFT OUTER JOIN

(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 ONNET_SUCCESS_1
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC27_MTMSCADDR IS NOT NULL
AND SMC15_SMSTATUS=1
AND SUBSTR(SMC27_MTMSCADDR,1,5) LIKE ('88015%')
GROUP BY SMC30_ORGACCOUNT

)B  ON A.SMC30_ORGACCOUNT=B.SMC30_ORGACCOUNT

LEFT OUTER JOIN

(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 ONNET_SUCCESS_2
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC27_MTMSCADDR IS NULL
AND SMC15_SMSTATUS=1
AND (SUBSTR(SMC6_DESTINATION_DELIVERY_A,1,5) LIKE ('88015%') OR LENGTH(SMC6_DESTINATION_DELIVERY_A)<=6)
GROUP BY SMC30_ORGACCOUNT

)C  ON A.SMC30_ORGACCOUNT=C.SMC30_ORGACCOUNT


LEFT OUTER JOIN


(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 ONNET_FAILED_1
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC27_MTMSCADDR IS NOT NULL
AND SMC15_SMSTATUS !=1
AND SUBSTR(SMC27_MTMSCADDR,1,5) LIKE ('88015%')
GROUP BY SMC30_ORGACCOUNT

)D  ON A.SMC30_ORGACCOUNT=D.SMC30_ORGACCOUNT


LEFT OUTER JOIN


(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 ONNET_FAILED_2
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC27_MTMSCADDR IS NULL
AND SMC15_SMSTATUS !=1
AND (SUBSTR(SMC6_DESTINATION_DELIVERY_A,1,5) LIKE ('88015%') OR LENGTH(SMC6_DESTINATION_DELIVERY_A)<=6)
GROUP BY SMC30_ORGACCOUNT

)E  ON A.SMC30_ORGACCOUNT=E.SMC30_ORGACCOUNT


LEFT OUTER JOIN


(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 OFFNET_SUCCESS_1
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC27_MTMSCADDR IS NOT NULL
AND SMC15_SMSTATUS=1
AND SUBSTR(SMC27_MTMSCADDR,1,5) NOT LIKE ('88015%') 
GROUP BY SMC30_ORGACCOUNT

)F  ON A.SMC30_ORGACCOUNT=F.SMC30_ORGACCOUNT


LEFT OUTER JOIN


(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 OFFNET_SUCCESS_2
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC27_MTMSCADDR IS NULL
AND SMC15_SMSTATUS=1
AND (SUBSTR(SMC6_DESTINATION_DELIVERY_A,1,5) NOT LIKE ('88015%') AND   LENGTH(SMC6_DESTINATION_DELIVERY_A) NOT IN(1,2,3,4,5,6))
GROUP BY SMC30_ORGACCOUNT

)G  ON A.SMC30_ORGACCOUNT=G.SMC30_ORGACCOUNT


LEFT OUTER JOIN


(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 OFFNET_FAILED_1
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC27_MTMSCADDR IS NOT NULL
AND SMC15_SMSTATUS !=1
AND SUBSTR(SMC27_MTMSCADDR,1,5) NOT LIKE ('88015%') 
GROUP BY SMC30_ORGACCOUNT

)H  ON A.SMC30_ORGACCOUNT=H.SMC30_ORGACCOUNT


LEFT OUTER JOIN


(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 OFFNET_FAILED_2
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC27_MTMSCADDR IS NULL
AND SMC15_SMSTATUS !=1
AND (SUBSTR(SMC6_DESTINATION_DELIVERY_A,1,5) NOT LIKE ('88015%') AND   LENGTH(SMC6_DESTINATION_DELIVERY_A) NOT IN(1,2,3,4,5,6))
GROUP BY SMC30_ORGACCOUNT
)I  ON A.SMC30_ORGACCOUNT=I.SMC30_ORGACCOUNT


LEFT OUTER JOIN 


(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 INT_SUCCESS
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC27_MTMSCADDR IS NOT NULL
AND SMC15_SMSTATUS=1
AND SUBSTR(SMC27_MTMSCADDR,1,5) NOT LIKE ('880%') 
GROUP BY SMC30_ORGACCOUNT

)J  ON A.SMC30_ORGACCOUNT=J.SMC30_ORGACCOUNT


LEFT OUTER JOIN


(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 INT_FAILED
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC27_MTMSCADDR IS NOT NULL
AND SMC15_SMSTATUS !=1
AND SUBSTR(SMC27_MTMSCADDR,1,5) NOT LIKE ('880%') 
GROUP BY SMC30_ORGACCOUNT

)K  ON A.SMC30_ORGACCOUNT=K.SMC30_ORGACCOUNT

LEFT OUTER JOIN


(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 TOTAL_SUCCESS
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC15_SMSTATUS =1
GROUP BY SMC30_ORGACCOUNT

)L  ON A.SMC30_ORGACCOUNT=L.SMC30_ORGACCOUNT

LEFT OUTER JOIN


(
select /*+PARALLEL(P,15)*/  SMC30_ORGACCOUNT , COUNT(*)

 TOTAL_FAIL
from L3_SMSC P
--where SMC1_TIME_SERIAL_NUMBER
WHERE SMC1_TIME_SERIAL_NUMBER_KEY=(SELECT DATE_KEY FROM DATE_DIM WHERE DATE_VALUE = TRUNC(TO_DATE(SYSDATE-1,'DD/MM/RRRR')))
AND SMC15_SMSTATUS !=1
GROUP BY SMC30_ORGACCOUNT

)M  ON A.SMC30_ORGACCOUNT=M.SMC30_ORGACCOUNT;
      COMMIT;
END;
/

