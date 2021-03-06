--
-- R_USSD_TRANSACTION_TYPE_WISE_DETAILS  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R_USSD_TRANSACTION_TYPE_WISE_DETAILS IS
    VDATE_KEY       VARCHAR2(64 BYTE);
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE-1,'RRRRMMDD');



    --EXECUTE IMMEDIATE  'TRUNCATE TABLE PKPI DROP STORAGE';
    --EXECUTE IMMEDIATE 'ALTER TABLE PKPI TRUNCATE PARTITION PKPI_||VDATE_KEY DROP STORAGE';
    
DELETE USSD_TRANSACTION_TYPE_WISE_DETAILS WHERE DATE_KEY=VDATE_KEY;
COMMIT;
    
INSERT INTO USSD_TRANSACTION_TYPE_WISE_DETAILS

SELECT DATE_VALUE,USSD10_CALLBEGINTIME_KEY,TR_TYPE,UNIT_BILL,SUCCESSOUNT,VDATE_KEY
FROM DATE_DIM P,
(SELECT /*+PARALLEL(P,8)*/  /*+PARALLEL(Q,8)*/ P.USSD10_CALLBEGINTIME_KEY,P.USSD28_ACCOUNTNAME,Q.TR_TYPE,Q.UNIT_BILL, COUNT(*) SUCCESSOUNT FROM L3_USSD P, USSD_BKASH_DIM Q

WHERE USSD28_ACCOUNTNAME='bkashP'
AND 
USSD10_CALLBEGINTIME_KEY IN (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE >= TO_DATE(SYSDATE-7,'DD/MM/RRRR'))
AND 
P.USSD39_LASTSPCONTENT LIKE Q.MSG
GROUP BY P.USSD10_CALLBEGINTIME_KEY, P.USSD28_ACCOUNTNAME,Q.TR_TYPE,Q.UNIT_BILL
)Q
WHERE P.DATE_KEY=Q.USSD10_CALLBEGINTIME_KEY;
      COMMIT;
END;
/

