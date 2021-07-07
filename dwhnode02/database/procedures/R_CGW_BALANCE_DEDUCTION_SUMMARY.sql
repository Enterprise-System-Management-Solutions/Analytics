--
-- R_CGW_BALANCE_DEDUCTION_SUMMARY  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R_CGW_BALANCE_DEDUCTION_SUMMARY IS
    VDATE_KEY       VARCHAR2(64 BYTE);
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE-1,'RRRRMMDD');



    --EXECUTE IMMEDIATE  'TRUNCATE TABLE PKPI DROP STORAGE';
    --EXECUTE IMMEDIATE 'ALTER TABLE PKPI TRUNCATE PARTITION PKPI_||VDATE_KEY DROP STORAGE';
    
DELETE CGW_BALANCE_DEDUCTION_SUMMARY WHERE DATE_KEY=VDATE_KEY;
COMMIT;
    
INSERT INTO CGW_BALANCE_DEDUCTION_SUMMARY


SELECT /*+PARALLEL(P,10)*/ CGW5_USERNAME , COALESCE (TRANSACTION_COUNT, 0)TRANSACTION_COUNT, COALESCE (AMOUNT_BDT, 0) AMOUNT_BDT ,VDATE_KEY
FROM 
(SELECT  /*+PARALLEL(P,10)*/  CGW5_USERNAME, COUNT(*) TRANSACTION_COUNT , SUM(CGW14_AMOUNT) AMOUNT_BDT 
FROM L3_CGW P
WHERE CGW15_TRANSACTION_TIME_KEY=(SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
AND CGW10_RESULT_CODE=0
GROUP BY CGW5_USERNAME
)P;
      COMMIT;
END;
/
