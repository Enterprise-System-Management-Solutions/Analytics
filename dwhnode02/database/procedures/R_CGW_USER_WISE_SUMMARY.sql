--
-- R_CGW_USER_WISE_SUMMARY  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R_CGW_USER_WISE_SUMMARY IS
    VDATE_KEY       VARCHAR2(64 BYTE);
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE-1,'RRRRMMDD');



    --EXECUTE IMMEDIATE  'TRUNCATE TABLE PKPI DROP STORAGE';
    --EXECUTE IMMEDIATE 'ALTER TABLE PKPI TRUNCATE PARTITION PKPI_||VDATE_KEY DROP STORAGE';
    
DELETE CGW_USER_WISE_SUMMARY WHERE DATE_KEY=VDATE_KEY;
COMMIT;
    
INSERT INTO CGW_USER_WISE_SUMMARY




SELECT A.CGW5_USERNAME,SUCCESSFUL_COUNT,SUCCESSFUL_AMOUNT,FAILED_COUNT, FAILEDL_AMOUNT ,VDATE_KEY
FROM 
(SELECT /*+PARALLEL(P,15)*/ CGW5_USERNAME FROM  L3_CGW P
WHERE CGW15_TRANSACTION_TIME_KEY=(SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
GROUP BY  CGW5_USERNAME
)A

LEFT OUTER JOIN

(SELECT /*+PARALLEL(P,15)*/ CGW5_USERNAME ,COUNT(*) SUCCESSFUL_COUNT,SUM(CGW14_AMOUNT) SUCCESSFUL_AMOUNT
FROM  L3_CGW P
WHERE CGW15_TRANSACTION_TIME_KEY=(SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
AND  CGW10_RESULT_CODE=0
GROUP BY  CGW5_USERNAME
)B ON A.CGW5_USERNAME=B.CGW5_USERNAME

LEFT OUTER JOIN


(SELECT /*+PARALLEL(P,15)*/ CGW5_USERNAME ,COUNT(*) FAILED_COUNT,SUM(CGW14_AMOUNT) FAILEDL_AMOUNT
FROM  L3_CGW P
WHERE CGW15_TRANSACTION_TIME_KEY=(SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
AND  CGW10_RESULT_CODE !=0
GROUP BY  CGW5_USERNAME
)C on A.CGW5_USERNAME=C.CGW5_USERNAME;
      COMMIT;
END;
/

