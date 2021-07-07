--
-- R_MKT_CHANNEL_PRO_PURCHASE_PART01  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R_MKT_CHANNEL_PRO_PURCHASE_PART01 IS
    VDATE_KEY       NUMBER;
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE-1,'RRRRMMDD');



    --EXECUTE IMMEDIATE  'TRUNCATE TABLE PKPI DROP STORAGE';
    --EXECUTE IMMEDIATE 'ALTER TABLE PKPI TRUNCATE PARTITION PKPI_||VDATE_KEY DROP STORAGE';
    
DELETE MKT_CHANNEL_PRO_PURCHASE_PART01 WHERE DATE_KEY=VDATE_KEY;
COMMIT;
    
INSERT INTO MKT_CHANNEL_PRO_PURCHASE_PART01

SELECT MSISDN,PRODUCT_NAME,OFFER_TYPE,COALESCE (PRODUCT_PURCHASE_PRICE, 0)PRODUCT_PURCHASE_PRICE,COALESCE (COUNT_AVAIL_SERVICE, 0)COUNT_AVAIL_SERVICE,VDATE_KEY
FROM
(SELECT MSISDN,PRODUCT_NAME,OFFER_TYPE,SUM(PRODUCT_PURCHASE_PRICE) PRODUCT_PURCHASE_PRICE,SUM(COUNT_AVAIL_SERVICE) COUNT_AVAIL_SERVICE 
FROM PRODUCT_DIM, OFFER_DIM,
(SELECT /*+PARALLEL(P,10)*/ R373_MAINOFFERINGID, R375_CHARGINGPARTYNUMBER MSISDN, R385_OFFERINGID,SUM (R41_DEBIT_AMOUNT) PRODUCT_PURCHASE_PRICE ,
                             COUNT(*) COUNT_AVAIL_SERVICE
FROM 
  L3_RECURRING 

WHERE R377_CYCLEBEGINTIME_KEY = (SELECT TO_CHAR(DATE_KEY) FROM DATE_DIM WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))

GROUP BY R373_MAINOFFERINGID, R375_CHARGINGPARTYNUMBER, R385_OFFERINGID
)
WHERE R373_MAINOFFERINGID=PRODUCT_ID AND R385_OFFERINGID=OFFERING_ID
GROUP BY MSISDN,PRODUCT_NAME,OFFER_TYPE
);
    COMMIT;
END;
/
