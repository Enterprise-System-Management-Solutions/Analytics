--
-- BIN3JOINVOICEDATASMS  (View) 
--
CREATE OR REPLACE FORCE VIEW DWH_USER.BIN3JOINVOICEDATASMS
(DATA_ETL_DATE_KEY, G401_MAINOFFERINGID, ETL_DATE_KEY, S395_MAINOFFERINGID, VOICEDATASMSCOUNT)
BEQUEATH DEFINER
AS 
SELECT DATA_ETL_DATE_KEY,
          G401_MAINOFFERINGID,
          ETL_DATE_KEY,
          S395_MAINOFFERINGID,
          COALESCE (VOICEDATACOUNT, 0) + COALESCE (C.count_COL3, 0)
             VOICEDATASMSCOUNT
     FROM BIN3UNIONJOINVOICEDATA
          FULL JOIN
          (  SELECT ETL_DATE_KEY,
                    S395_MAINOFFERINGID,
                    COUNT (S22_PRI_IDENTITY) count_COL3
               FROM L3_SMS
              WHERE ETL_DATE_KEY =
                       (SELECT DATE_KEY
                          FROM DATE_DIM
                         WHERE DATE_VALUE =
                                  TRUNC (TO_DATE (SYSDATE - 1, 'DD/MM/RRRR')))
           GROUP BY ETL_DATE_KEY, S395_MAINOFFERINGID) C
             ON     (C.S395_MAINOFFERINGID = G401_MAINOFFERINGID)
                AND (C.ETL_DATE_KEY = DATA_ETL_DATE_KEY);


