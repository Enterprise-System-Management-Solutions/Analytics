--
-- R_MKT_TOT_MIN_USAGE_REVENUE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R_MKT_TOT_MIN_USAGE_REVENUE IS
    VDATE_KEY       NUMBER;
BEGIN

SELECT DATE_KEY INTO VDATE_KEY
FROM DATE_DIM WHERE TO_CHAR(DATE_VALUE,'RRRRMMDD')=TO_CHAR(SYSDATE-1,'RRRRMMDD');



    --EXECUTE IMMEDIATE  'TRUNCATE TABLE PKPI DROP STORAGE';
    --EXECUTE IMMEDIATE 'ALTER TABLE PKPI TRUNCATE PARTITION PKPI_||VDATE_KEY DROP STORAGE';
    
DELETE MKT_TOT_MIN_USAGE_REVENUE WHERE DATE_KEY=VDATE_KEY;
COMMIT;
    
INSERT INTO MKT_TOT_MIN_USAGE_REVENUE





SELECT PRODUCT_NAME,COALESCE (TOTAL_BASE_TARIFF_MIN, 0)TOTAL_BASE_TARIFF_MIN,
       COALESCE (MINUTES_BUNDLE_MIN, 0)MINUTES_BUNDLE_MIN,
       COALESCE (COMBO_BUNDLE_MIN, 0)COMBO_BUNDLE_MIN,COALESCE (TOTAL_ONNET_MINUTES, 0)TOTAL_ONNET_MINUTES,
       COALESCE (TOTAL_OFFNET_MINUTES, 0)TOTAL_OFFNET_MINUTES,COALESCE (TOTAL_PAID_MINUTES, 0)TOTAL_PAID_MINUTES,
       COALESCE (TOTAL_VOICE_REVNUE, 0)TOTAL_VOICE_REVNUE,  VDATE_KEY,     COALESCE (OTHER_MINUTES, 0)OTHER_MINUTES

FROM PRODUCT_DIM M,

(SELECT A.PRODUCT_ID,TOTAL_BASE_TARIFF_MIN,MINUTES_BUNDLE_MIN,COMBO_BUNDLE_MIN,TOTAL_ONNET_MINUTES,
          TOTAL_OFFNET_MINUTES,TOTAL_PAID_MINUTES,COALESCE (VOICE_PAYG_REVENUE, 0)+ COALESCE (VOICE_BUNDLE_REVENUE, 0) TOTAL_VOICE_REVNUE,OTHER_MINUTES
FROM
(SELECT PRODUCT_ID 
FROM PRODUCT_DIM
)A

LEFT OUTER JOIN

(SELECT /*+PARALLEL(R,10)*/V397_MAINOFFERINGID ,SUM(V35_RATE_USAGE)/60 TOTAL_BASE_TARIFF_MIN 
FROM  L3_VOICE  R
WHERE V387_CHARGINGTIME_KEY = (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
                                                       
AND V397_MAINOFFERINGID=V436_LASTEFFECTOFFERING
GROUP BY V397_MAINOFFERINGID
)B ON A.PRODUCT_ID=B.V397_MAINOFFERINGID
LEFT OUTER JOIN



(SELECT /*+PARALLEL(T,10)*/ V397_MAINOFFERINGID ,SUM(V35_RATE_USAGE)/60 MINUTES_BUNDLE_MIN 
FROM 
L3_VOICE   T
WHERE V387_CHARGINGTIME_KEY =(SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
                                                 
AND V436_LASTEFFECTOFFERING IN ( SELECT OFFERING_ID FROM OFFER_DIM WHERE OFFER_TYPE='Voice')
GROUP BY V397_MAINOFFERINGID
) C ON A.PRODUCT_ID=C.V397_MAINOFFERINGID

LEFT OUTER JOIN

(SELECT /*+PARALLEL(V,10)*/ V397_MAINOFFERINGID ,SUM(V35_RATE_USAGE)/60 COMBO_BUNDLE_MIN 
FROM  L3_VOICE   V
WHERE V387_CHARGINGTIME_KEY =(SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
                                                  
AND V436_LASTEFFECTOFFERING IN ( SELECT OFFERING_ID FROM OFFER_DIM WHERE OFFER_TYPE='Combo')
GROUP BY V397_MAINOFFERINGID
)D ON A.PRODUCT_ID=D.V397_MAINOFFERINGID

LEFT OUTER JOIN

(SELECT /*+PARALLEL(X,10)*/ V397_MAINOFFERINGID ,SUM(V35_RATE_USAGE)/60 TOTAL_ONNET_MINUTES 
FROM L3_VOICE   X
WHERE V387_CHARGINGTIME_KEY = (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
                                                      
AND V476_ONNETINDICATOR=0
GROUP BY V397_MAINOFFERINGID
)E ON A.PRODUCT_ID=E.V397_MAINOFFERINGID 

LEFT OUTER JOIN

(SELECT /*+PARALLEL(Z,10)*/V397_MAINOFFERINGID ,SUM(V35_RATE_USAGE)/60 TOTAL_OFFNET_MINUTES 
FROM L3_VOICE Z
WHERE V387_CHARGINGTIME_KEY =(SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
                                               
AND V476_ONNETINDICATOR=1
GROUP BY V397_MAINOFFERINGID
)F ON A.PRODUCT_ID=F.V397_MAINOFFERINGID 

LEFT OUTER JOIN

(SELECT /*+PARALLEL(QQ,10)*/V397_MAINOFFERINGID ,SUM(V35_RATE_USAGE)/60 TOTAL_PAID_MINUTES,SUM(V41_DEBIT_AMOUNT) VOICE_PAYG_REVENUE  
FROM L3_VOICE QQ
WHERE 
V387_CHARGINGTIME_KEY = (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
                                                  
GROUP BY  V397_MAINOFFERINGID
)G ON A.PRODUCT_ID=G.V397_MAINOFFERINGID 


LEFT OUTER JOIN

(SELECT /*+PARALLEL(TT,10)*/ R373_MAINOFFERINGID ,SUM(R41_DEBIT_AMOUNT) VOICE_BUNDLE_REVENUE 
FROM L3_RECURRING TT
WHERE R377_CYCLEBEGINTIME_KEY = (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
                                                    
                                                      
AND R385_OFFERINGID IN ( SELECT OFFERING_ID FROM OFFER_DIM WHERE OFFER_TYPE='Voice')
GROUP BY  R373_MAINOFFERINGID
) I ON A.PRODUCT_ID=I.R373_MAINOFFERINGID 
LEFT OUTER JOIN
(SELECT /*+PARALLEL(R,10)*/V397_MAINOFFERINGID ,SUM(V35_RATE_USAGE)/60 OTHER_MINUTES 
FROM  L3_VOICE  R
WHERE V387_CHARGINGTIME_KEY = (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-1,'DD/MM/RRRR'))
                                                       
AND ((V436_LASTEFFECTOFFERING IN ( SELECT OFFERING_ID FROM OFFER_DIM WHERE OFFER_TYPE='Tariff')) OR (V436_LASTEFFECTOFFERING in (598878,402326,585067 ))

    OR (V436_LASTEFFECTOFFERING NOT IN (SELECT PRODUCT_ID FROM PRODUCT_DIM UNION SELECT OFFERING_ID FROM OFFER_DIM))OR 
    (V436_LASTEFFECTOFFERING IN ( SELECT OFFERING_ID FROM OFFER_DIM WHERE OFFER_TYPE='FNF')) OR 
    (V436_LASTEFFECTOFFERING IN ( SELECT OFFERING_ID FROM OFFER_DIM WHERE OFFER_TYPE='Video')))
GROUP BY V397_MAINOFFERINGID
)J ON A.PRODUCT_ID=J.V397_MAINOFFERINGID 

)N
WHERE M.PRODUCT_ID=N.PRODUCT_ID



;
    COMMIT;
END;
/

