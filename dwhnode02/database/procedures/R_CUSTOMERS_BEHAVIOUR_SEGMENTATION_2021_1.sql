--
-- R_CUSTOMERS_BEHAVIOUR_SEGMENTATION_2021_1  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.R_CUSTOMERS_BEHAVIOUR_SEGMENTATION_2021_1 IS
    VDATE_KEY       NUMBER;
BEGIN


    
INSERT INTO CUSTOMERS_BEHAVIOUR_SEGMENTATION


SELECT /*+PARALLEL(A,15)*/A.DATE_KEY,MSISDN,ROUND(NVL(OUTGOING_CALL_COUNT,0),4)OUTGOING_CALL_COUNT,ROUND(NVL(OUTGOING_CALL_DUR_MIN,0),4)OUTGOING_CALL_DUR_MIN,
       ROUND(NVL(OUTGOING_ACD_MIN,0),4)OUTGOING_ACD_MIN,ROUND(NVL(COMBO_VOICE_MIN,0),4)COMBO_VOICE_MIN,
       ROUND(NVL(VAS_IVR_MIN,0),4)VAS_IVR_MIN,ROUND(NVL(INCOMING_CALL_COUNT,0),4)INCOMING_CALL_COUNT,
       ROUND(NVL(INCOMING_CALL_DUR_MIN,0),4)INCOMING_CALL_DUR_MIN,ROUND(NVL(INCOMING_ACD_MIN,0),4)INCOMING_ACD_MIN,
       ROUND(NVL(RECHARGE_COUNT,0),4)RECHARGE_COUNT,ROUND(NVL(RECHARGE_AMOUNT,0),4)RECHARGE_AMOUNT,
       ROUND(NVL(RECHARGE_VALUE,0),4)RECHARGE_VALUE,ROUND(NVL(CARD_COUNT,0),4)CARD_COUNT,
       ROUND(NVL(CARD_AMOUNT,0),4)CARD_AMOUNT,ROUND(NVL(CARD_VALUE,0),4)CARD_VALUE,
       ROUND(NVL(OUTGOING_SMS_COUNT,0),4)OUTGOING_SMS_COUNT,ROUND(NVL(INCOMING_SMS_COUNT,0),4)INCOMING_SMS_COUNT,
       ROUND(NVL(COMBO_SMS_COUNT,0),4)COMBO_SMS_COUNT,ROUND(NVL(DATA_USAGE_MB,0),4)DATA_USAGE_MB,
       ROUND(NVL(COMBO_DATA_USAGE_MB,0),4)COMBO_DATA_USAGE_MB,ROUND(NVL(PAY_PER_DATA_USAGES,0),4)PAY_PER_DATA_USAGES,
       ROUND(NVL(DATA_PACK_COUNT,0),4)DATA_PACK_COUNT,ROUND(NVL(VAS_SMS_COUNT,0),4)VAS_SMS_COUNT,
       ROUND(NVL(VAS_USSD_COUNT,0),4)VAS_USSD_COUNT,ROUND(NVL(MINUTE_BUNDLE_AMOUNT,0),4)MINUTE_BUNDLE_AMOUNT,
       ROUND(NVL(SMS_BUNDLE_COUNT,0),4)SMS_BUNDLE_COUNT,DATE_VALUE
       FROM  DATE_DIM B,
(SELECT V387_CHARGINGTIME_KEY DATE_KEY, V372_CALLINGPARTYNUMBER MSISDN,SUM(OUTGOING_CALL_COUNT)OUTGOING_CALL_COUNT,SUM(OUTGOING_CALL_DUR_MIN)OUTGOING_CALL_DUR_MIN,
       SUM(OUTGOING_ACD_MIN)OUTGOING_ACD_MIN,SUM(COMBO_VOICE_MIN)COMBO_VOICE_MIN,SUM(VAS_IVR_MIN)VAS_IVR_MIN,SUM(INCOMING_CALL_COUNT)INCOMING_CALL_COUNT,
       SUM(INCOMING_CALL_DUR_MIN)INCOMING_CALL_DUR_MIN,SUM(INCOMING_ACD_MIN)INCOMING_ACD_MIN,SUM(RECHARGE_COUNT)RECHARGE_COUNT,SUM(RECHARGE_AMOUNT)RECHARGE_AMOUNT,
       SUM(RECHARGE_VALUE)RECHARGE_VALUE,SUM(CARD_COUNT)CARD_COUNT,SUM(CARD_AMOUNT)CARD_AMOUNT,SUM(CARD_VALUE)CARD_VALUE,
       SUM(OUTGOING_SMS_COUNT)OUTGOING_SMS_COUNT,SUM(INCOMING_SMS_COUNT)INCOMING_SMS_COUNT,SUM(COMBO_SMS_COUNT)COMBO_SMS_COUNT,SUM(DATA_USAGE_MB)DATA_USAGE_MB,
       SUM(COMBO_DATA_USAGE_MB)COMBO_DATA_USAGE_MB,SUM(PAY_PER_DATA_USAGES)PAY_PER_DATA_USAGES,SUM(DATA_PACK_COUNT)DATA_PACK_COUNT,SUM(VAS_SMS_COUNT)VAS_SMS_COUNT,
       CAST(NULL AS NUMBER(15)) VAS_USSD_COUNT,SUM(MINUTE_BUNDLE_AMOUNT)MINUTE_BUNDLE_AMOUNT ,CAST(NULL AS NUMBER(15)) SMS_BUNDLE_COUNT
       FROM
((SELECT /*+PARALLEL(P,15)*/ V387_CHARGINGTIME_KEY, V372_CALLINGPARTYNUMBER, OUTGOING_CALL_COUNT, OUTGOING_CALL_DUR_MIN, OUTGOING_ACD_MIN, 
       COMBO_VOICE_MIN, VAS_IVR_MIN, INCOMING_CALL_COUNT, INCOMING_CALL_DUR_MIN, INCOMING_ACD_MIN , 
       NULL AS RECHARGE_COUNT,NULL AS RECHARGE_AMOUNT, NULL AS RECHARGE_VALUE, NULL AS CARD_COUNT, NULL AS CARD_AMOUNT, NULL AS CARD_VALUE,
       NULL AS OUTGOING_SMS_COUNT, NULL AS INCOMING_SMS_COUNT, NULL  AS COMBO_SMS_COUNT,
       NULL AS DATA_USAGE_MB, NULL AS COMBO_DATA_USAGE_MB, NULL AS DATA_PACK_COUNT,
       NULL AS VAS_SMS_COUNT,MINUTE_BUNDLE_AMOUNT,NULL AS PAY_PER_DATA_USAGES
       
FROM --------------------------VOICE PART-------------------------------------

(SELECT /*+PARALLEL(P,15)*/V387_CHARGINGTIME_KEY,V372_CALLINGPARTYNUMBER,SUM(OUTGOING_CALL_COUNT) OUTGOING_CALL_COUNT,SUM(OUTGOING_CALL_DUR_MIN) OUTGOING_CALL_DUR_MIN,
       SUM(OUTGOING_ACD_MIN) OUTGOING_ACD_MIN,SUM(COMBO_VOICE_MIN) COMBO_VOICE_MIN,SUM(VAS_IVR_MIN) VAS_IVR_MIN,SUM(INCOMING_CALL_COUNT) INCOMING_CALL_COUNT,
       SUM(INCOMING_CALL_DUR_MIN) INCOMING_CALL_DUR_MIN,SUM(INCOMING_ACD_MIN) INCOMING_ACD_MIN,SUM(MINUTE_BUNDLE_AMOUNT)MINUTE_BUNDLE_AMOUNT
       FROM 
((SELECT /*+PARALLEL(P,15)*/ V387_CHARGINGTIME_KEY,V372_CALLINGPARTYNUMBER,  
        COUNT(V372_CALLINGPARTYNUMBER) OUTGOING_CALL_COUNT,
        SUM(V35_RATE_USAGE )/60 OUTGOING_CALL_DUR_MIN,
        (SUM(V35_RATE_USAGE)/COUNT(V372_CALLINGPARTYNUMBER))/60 OUTGOING_ACD_MIN,
        SUM( V50_PAY_FREE_UNIT_DURATION)/60 COMBO_VOICE_MIN,
        SUM(CASE WHEN V417_HOTLINEINDICATOR IN (1,2) THEN V35_RATE_USAGE END)/60 VAS_IVR_MIN, 
        CAST(NULL AS NUMBER(15,2)) INCOMING_CALL_COUNT,CAST(NULL AS NUMBER(15,2)) INCOMING_CALL_DUR_MIN,CAST(NULL AS NUMBER(15,2)) INCOMING_ACD_MIN,
        CAST(NULL AS NUMBER(15,2)) MINUTE_BUNDLE_AMOUNT
        
            
            
       
  
FROM DWH_USER.L3_VOICE P
WHERE (V387_CHARGINGTIME_KEY  BETWEEN (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             '21/06/2020',
                                                                             'DD/MM/RRRR')))
                                                        AND (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                            '30/06/2020',
                                                                             'DD/MM/RRRR'))))
      AND V378_SERVICEFLOW='1'

                            
GROUP BY V387_CHARGINGTIME_KEY,V372_CALLINGPARTYNUMBER
)
UNION ALL

(SELECT /*+PARALLEL(P,15)*/ V387_CHARGINGTIME_KEY,V373_CALLEDPARTYNUMBER, 
        CAST(NULL AS NUMBER(15,2)) OUTGOING_CALL_COUNT,CAST(NULL AS NUMBER(15,2)) OUTGOING_CALL_DUR_MIN,CAST(NULL AS NUMBER(15,2)) OUTGOING_ACD_MIN,
                SUM( V50_PAY_FREE_UNIT_DURATION)/60 COMBO_VOICE_MIN,
        SUM(CASE WHEN V417_HOTLINEINDICATOR IN (1,2) THEN V35_RATE_USAGE END)/60 VAS_IVR_MIN,
        COUNT(V373_CALLEDPARTYNUMBER) INCOMING_CALL_COUNT,
        SUM(V35_RATE_USAGE )/60 INCOMING_CALL_DUR_MIN,
        (SUM(V35_RATE_USAGE)/COUNT(V373_CALLEDPARTYNUMBER))/60 INCOMING_ACD_MIN,
         CAST(NULL AS NUMBER(15,2)) MINUTE_BUNDLE_AMOUNT

        
            
            
       
  
FROM DWH_USER.L3_VOICE P
WHERE (V387_CHARGINGTIME_KEY  BETWEEN (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             '21/06/2020',
                                                                             'DD/MM/RRRR')))
                                                        AND (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                            '30/06/2020',
                                                                             'DD/MM/RRRR'))))
      AND V378_SERVICEFLOW='2'

                            
GROUP BY V387_CHARGINGTIME_KEY,V373_CALLEDPARTYNUMBER
)

UNION ALL
(SELECT /*+PARALLEL(P,15)*/  R377_CYCLEBEGINTIME_KEY,R375_CHARGINGPARTYNUMBER,
        CAST(NULL AS NUMBER(15)) OUTGOING_CALL_COUNT,
        CAST(NULL AS NUMBER(15,2)) OUTGOING_CALL_DUR_MIN,
        CAST(NULL AS NUMBER(15,2)) OUTGOING_ACD_MIN,
        CAST(NULL AS NUMBER(15,2)) COMBO_VOICE_MIN,
        CAST(NULL AS NUMBER(15,2)) VAS_IVR_MIN, 
        CAST(NULL AS NUMBER(15,2)) INCOMING_CALL_COUNT,CAST(NULL AS NUMBER(15,2)) INCOMING_CALL_DUR_MIN,CAST(NULL AS NUMBER(15,2)) INCOMING_ACD_MIN,
        SUM(TO_NUMBER(SUBSTR(OFFERING_NAME,15,3))) MINUTE_BUNDLE_AMOUNT
FROM  DWH_USER.L3_RECURRING  P,DWH_USER.OFFER_DIM Q
WHERE  (R377_CYCLEBEGINTIME_KEY BETWEEN (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             '21/06/2020',
                                                                             'DD/MM/RRRR')))
                                                        AND (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                            '30/06/2020',
                                                                             'DD/MM/RRRR'))))
       AND R385_OFFERINGID IN ( SELECT OFFERING_ID FROM DWH_USER.OFFER_DIM WHERE OFFER_TYPE='Voice')
       AND R385_OFFERINGID=OFFERING_ID
GROUP BY R377_CYCLEBEGINTIME_KEY,R375_CHARGINGPARTYNUMBER
)
)P
GROUP BY V387_CHARGINGTIME_KEY,V372_CALLINGPARTYNUMBER
) P
)
UNION ALL
(SELECT /*+PARALLEL(P,15)*/ RE30_ENTRY_DATE_KEY, RE6_PRI_IDENTITY, NULL AS OUTGOING_CALL_COUNT,NULL AS OUTGOING_CALL_DUR_MIN, NULL AS OUTGOING_ACD_MIN, 
       NULL AS COMBO_VOICE_MIN, NULL AS VAS_IVR_MIN, NULL AS INCOMING_CALL_COUNT, NULL AS INCOMING_CALL_DUR_MIN, NULL AS NINCOMING_ACD_MIN , 
       RECHARGE_COUNT, RECHARGE_AMOUNT, RECHARGE_VALUE, CARD_COUNT, CARD_AMOUNT, CARD_VALUE,
       NULL AS OUTGOING_SMS_COUNT, NULL AS INCOMING_SMS_COUNT, NULL  AS COMBO_SMS_COUNT,
       NULL AS DATA_USAGE_MB, NULL AS COMBO_DATA_USAGE_MB, NULL AS DATA_PACK_COUNT,
       NULL AS VAS_SMS_COUNT,NULL AS MINUTE_BUNDLE_AMOUNT,NULL AS PAY_PER_DATA_USAGES
       
FROM -------------------------------------RECHATGE PART---------------------------
(SELECT RE30_ENTRY_DATE_KEY ,RE6_PRI_IDENTITY,SUM(RECHARGE_COUNT)RECHARGE_COUNT,SUM(RECHARGE_AMOUNT)RECHARGE_AMOUNT,
       SUM(RECHARGE_VALUE)RECHARGE_VALUE,SUM(CARD_COUNT)CARD_COUNT,SUM(CARD_AMOUNT)CARD_AMOUNT,SUM(CARD_VALUE)CARD_VALUE
FROM
(
(
SELECT /*+PARALLEL(P,15)*/ RE30_ENTRY_DATE_KEY ,RE6_PRI_IDENTITY,
COUNT(RE6_PRI_IDENTITY ) RECHARGE_COUNT, 
SUM(RE3_RECHARGE_AMT ) RECHARGE_AMOUNT,
SUM(RE3_RECHARGE_AMT )/COUNT(RE6_PRI_IDENTITY) RECHARGE_VALUE,
CAST(NULL AS NUMBER(15,2)) CARD_COUNT, CAST(NULL AS NUMBER(15,2)) CARD_AMOUNT, CAST(NULL AS NUMBER(15,2)) CARD_VALUE


FROM DWH_USER.L3_RECHARGE P
WHERE (RE30_ENTRY_DATE_KEY  BETWEEN (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             '21/06/2020',
                                                                             'DD/MM/RRRR')))
                                                        AND (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                            '30/06/2020',
                                                                             'DD/MM/RRRR'))))
                            
      AND RE18_PAYMENT_TYPE !='V'
GROUP BY RE30_ENTRY_DATE_KEY,RE6_PRI_IDENTITY
)
UNION ALL 
(
SELECT /*+PARALLEL(P,15)*/ RE30_ENTRY_DATE_KEY ,RE6_PRI_IDENTITY,
CAST(NULL AS NUMBER(15,2)) RECHARGE_COUNT, CAST(NULL AS NUMBER(15,2)) RECHARGE_AMOUNT, CAST(NULL AS NUMBER(15,2)) RECHARGE_VALUE,
COUNT(RE6_PRI_IDENTITY ) CARD_COUNT, 
SUM(RE3_RECHARGE_AMT ) CARD_AMOUNT,
SUM(RE3_RECHARGE_AMT )/COUNT(RE6_PRI_IDENTITY) CARD_VALUE

FROM DWH_USER.L3_RECHARGE P
WHERE (RE30_ENTRY_DATE_KEY  BETWEEN (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             '21/06/2020',
                                                                             'DD/MM/RRRR')))
                                                        AND (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                            '30/06/2020',
                                                                             'DD/MM/RRRR'))))
                            
      AND RE18_PAYMENT_TYPE ='V'
GROUP BY RE30_ENTRY_DATE_KEY,RE6_PRI_IDENTITY
)
)
GROUP BY RE30_ENTRY_DATE_KEY ,RE6_PRI_IDENTITY
) P
)
UNION ALL
(SELECT /*+PARALLEL(P,15)*/ S387_CHARGINGTIME_KEY, S22_PRI_IDENTITY, NULL AS OUTGOING_CALL_COUNT,NULL AS OUTGOING_CALL_DUR_MIN, NULL AS OUTGOING_ACD_MIN, 
       NULL AS COMBO_VOICE_MIN, NULL AS VAS_IVR_MIN, NULL AS INCOMING_CALL_COUNT, NULL AS INCOMING_CALL_DUR_MIN, NULL AS NINCOMING_ACD_MIN , 
       NULL AS RECHARGE_COUNT,NULL AS RECHARGE_AMOUNT, NULL AS RECHARGE_VALUE, NULL AS CARD_COUNT, NULL AS CARD_AMOUNT, NULL AS CARD_VALUE,
       OUTGOING_SMS_COUNT, INCOMING_SMS_COUNT,COMBO_SMS_COUNT,
       NULL AS DATA_USAGE_MB, NULL AS COMBO_DATA_USAGE_MB, NULL AS DATA_PACK_COUNT,
       NULL AS VAS_SMS_COUNT,NULL AS MINUTE_BUNDLE_AMOUNT,NULL AS PAY_PER_DATA_USAGES
       
FROM ------------------------SMS PART---------------------
(SELECT  S387_CHARGINGTIME_KEY,S22_PRI_IDENTITY,SUM(OUTGOING_SMS_COUNT)OUTGOING_SMS_COUNT,SUM(INCOMING_SMS_COUNT)INCOMING_SMS_COUNT,
        SUM(COMBO_SMS_COUNT)COMBO_SMS_COUNT
        FROM 
(
(SELECT /*+PARALLEL(P,15)*/ S387_CHARGINGTIME_KEY,S22_PRI_IDENTITY,
 COUNT(CASE WHEN S378_SERVICEFLOW='1' THEN S22_PRI_IDENTITY END) OUTGOING_SMS_COUNT,
 COUNT(CASE WHEN S378_SERVICEFLOW='2' THEN S22_PRI_IDENTITY END) INCOMING_SMS_COUNT, CAST(NULL AS NUMBER(15)) COMBO_SMS_COUNT
FROM  DWH_USER.L3_SMS P
WHERE (S387_CHARGINGTIME_KEY   BETWEEN (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             '21/06/2020',
                                                                             'DD/MM/RRRR')))
                                                        AND (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                            '30/06/2020',
                                                                             'DD/MM/RRRR'))))
GROUP BY S387_CHARGINGTIME_KEY,S22_PRI_IDENTITY
)
UNION ALL
(SELECT /*+PARALLEL(P,15)*/ Q.DATE_KEY S387_CHARGINGTIME_KEY,S22_PRI_IDENTITY,
         CAST(NULL AS NUMBER(15)) OUTGOING_SMS_COUNT, CAST(NULL AS NUMBER(15)) INCOMING_SMS_COUNT,
         SUM(S49_PAY_FREE_UNIT_TIMES) COMBO_SMS_COUNT
FROM L1_SMS@DWH05TODWH01 P,DATE_DIM Q

WHERE (PROCESSED_DATE BETWEEN TO_DATE('21/JUNE/2020','DD/MONTH/RRRR') AND TO_DATE('30/JUNE/2020','DD/MONTH/RRRR'))
AND TO_DATE(SUBSTR(P.S387_CHARGINGTIME,1,8),'RRRRMMDD')=Q.DATE_VALUE
AND (Q.DATE_KEY  BETWEEN (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             '21/06/2020',
                                                                             'DD/MM/RRRR')))
                                                        AND (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                            '30/06/2020',
                                                                             'DD/MM/RRRR'))))
AND S378_SERVICEFLOW='1'
GROUP BY Q.DATE_KEY ,S22_PRI_IDENTITY
)
)
GROUP BY  S387_CHARGINGTIME_KEY,S22_PRI_IDENTITY
) P
)
UNION ALL
(SELECT /*+PARALLEL(P,15)*/ G383_CHARGINGTIME_KEY, G372_CALLINGPARTYNUMBER, NULL AS OUTGOING_CALL_COUNT,NULL AS OUTGOING_CALL_DUR_MIN, NULL AS OUTGOING_ACD_MIN, 
       NULL AS COMBO_VOICE_MIN, NULL AS VAS_IVR_MIN, NULL AS INCOMING_CALL_COUNT, NULL AS INCOMING_CALL_DUR_MIN, NULL AS NINCOMING_ACD_MIN , 
       NULL AS RECHARGE_COUNT,NULL AS RECHARGE_AMOUNT, NULL AS RECHARGE_VALUE, NULL AS CARD_COUNT, NULL AS CARD_AMOUNT, NULL AS CARD_VALUE,
       NULL AS OUTGOING_SMS_COUNT, NULL AS INCOMING_SMS_COUNT,NULL AS COMBO_SMS_COUNT,
       DATA_USAGE_MB,COMBO_DATA_USAGE_MB,DATA_PACK_COUNT,
       NULL AS VAS_SMS_COUNT,NULL AS MINUTE_BUNDLE_AMOUNT, PAY_PER_DATA_USAGES
       
FROM --------------------------------DATA PART-------------------
(SELECT G383_CHARGINGTIME_KEY,G372_CALLINGPARTYNUMBER,SUM(DATA_USAGE_MB)DATA_USAGE_MB,
       SUM(COMBO_DATA_USAGE_MB)COMBO_DATA_USAGE_MB,NVL(SUM(DATA_USAGE_MB),0)-NVL(SUM(COMBO_DATA_USAGE_MB),0)PAY_PER_DATA_USAGES ,SUM(DATA_PACK_COUNT)DATA_PACK_COUNT
       FROM
((SELECT /*+PARALLEL(P,15)*/ G383_CHARGINGTIME_KEY,G372_CALLINGPARTYNUMBER,SUM(G384_TOTALFLUX)/1048576 DATA_USAGE_MB,
                             SUM(G51_FREE_UNIT_AMOUNT_OF_FLUX)/1048576 COMBO_DATA_USAGE_MB,CAST(NULL AS NUMBER(15)) DATA_PACK_COUNT
FROM DWH_USER.L3_DATA  P
WHERE (G383_CHARGINGTIME_KEY   BETWEEN (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             '21/06/2020',
                                                                             'DD/MM/RRRR')))
                                                        AND (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                            '30/06/2020',
                                                                             'DD/MM/RRRR'))))
GROUP BY G383_CHARGINGTIME_KEY,G372_CALLINGPARTYNUMBER
)
UNION ALL

(SELECT /*+PARALLEL(P,15)*/  R377_CYCLEBEGINTIME_KEY,R375_CHARGINGPARTYNUMBER,CAST(NULL AS NUMBER(20,5)) DATA_USAGE_MB,CAST(NULL AS NUMBER(20,5)) COMBO_DATA_USAGE_MB,
        COUNT(R375_CHARGINGPARTYNUMBER)DATA_PACK_COUNT
FROM  DWH_USER.L3_RECURRING  P
WHERE  (R377_CYCLEBEGINTIME_KEY  BETWEEN (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             '21/06/2020',
                                                                             'DD/MM/RRRR')))
                                                        AND (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                            '30/06/2020',
                                                                             'DD/MM/RRRR'))))
       AND R385_OFFERINGID IN ( SELECT OFFERING_ID FROM DWH_USER.OFFER_DIM WHERE OFFER_TYPE='Data')
GROUP BY R377_CYCLEBEGINTIME_KEY,R375_CHARGINGPARTYNUMBER
)
)
GROUP BY  G383_CHARGINGTIME_KEY,G372_CALLINGPARTYNUMBER
) P
)
UNION ALL
(SELECT /*+PARALLEL(P,15)*/ SMC1_TIME_SERIAL_NUMBER_KEY, MSISDN, NULL AS OUTGOING_CALL_COUNT,NULL AS OUTGOING_CALL_DUR_MIN, NULL AS OUTGOING_ACD_MIN, 
       NULL AS COMBO_VOICE_MIN, NULL AS VAS_IVR_MIN, NULL AS INCOMING_CALL_COUNT, NULL AS INCOMING_CALL_DUR_MIN, NULL AS NINCOMING_ACD_MIN , 
       NULL AS RECHARGE_COUNT,NULL AS RECHARGE_AMOUNT, NULL AS RECHARGE_VALUE, NULL AS CARD_COUNT, NULL AS CARD_AMOUNT, NULL AS CARD_VALUE,
       NULL AS OUTGOING_SMS_COUNT, NULL AS INCOMING_SMS_COUNT,NULL AS COMBO_SMS_COUNT,
       NULL AS DATA_USAGE_MB,NULL AS COMBO_DATA_USAGE_MB,NULL AS DATA_PACK_COUNT,
       VAS_SMS_COUNT,NULL AS MINUTE_BUNDLE_AMOUNT,NULL AS PAY_PER_DATA_USAGES
       
FROM -----------------SMSC PART------------------
(SELECT /*+PARALLEL(P,15)*/ SMC1_TIME_SERIAL_NUMBER_KEY,SMC3_ORIGINAL_DELIVERY_ADDR MSISDN ,COUNT(*)

  VAS_SMS_COUNT
FROM
(SELECT /*+PARALLEL(P,15)*/ DATE_KEY SMC1_TIME_SERIAL_NUMBER_KEY,SMC3_ORIGINAL_DELIVERY_ADDR
FROM L1_SMSC@DWH05TODWH03 P,DATE_DIM Q

WHERE (PROCESSED_DATE BETWEEN TO_DATE('21/JUNE/2020','DD/MONTH/RRRR') AND TO_DATE('30/JUNE/2020','DD/MONTH/RRRR'))
AND TO_DATE(SUBSTR(P.SMC1_TIME_SERIAL_NUMBER,1,8),'RRRRMMDD')=Q.DATE_VALUE
AND (Q.DATE_KEY  BETWEEN (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                             '21/06/2020',
                                                                             'DD/MM/RRRR')))
                                                        AND (SELECT DATE_KEY
                                                               FROM DATE_DIM
                                                              WHERE DATE_VALUE =
                                                                       TRUNC (
                                                                          TO_DATE (
                                                                            '30/06/2020',
                                                                             'DD/MM/RRRR'))))
AND LENGTH(SMC3_ORIGINAL_DELIVERY_ADDR)=13
AND SMC15_SMSTATUS='1'
)P
GROUP BY SMC1_TIME_SERIAL_NUMBER_KEY,SMC3_ORIGINAL_DELIVERY_ADDR
) P
)
)
GROUP BY V387_CHARGINGTIME_KEY, V372_CALLINGPARTYNUMBER
)A
WHERE B.DATE_KEY=A.DATE_KEY
;
             
             
             
      COMMIT;
END;
/
