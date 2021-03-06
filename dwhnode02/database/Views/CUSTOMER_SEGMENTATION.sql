--
-- CUSTOMER_SEGMENTATION  (View) 
--
CREATE OR REPLACE FORCE VIEW DWH_USER.CUSTOMER_SEGMENTATION
(DATE1, MSISDN, DURATION)
BEQUEATH DEFINER
AS 
SELECT V387_CHARGINGTIME_KEY DATE1,V372_CALLINGPARTYNUMBER MSISDN, SUM (V35_RATE_USAGE) / 60 DURATION
       FROM L3_voice
       where V387_CHARGINGTIME_KEY in (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE >= TO_DATE(SYSDATE-20,'DD/MM/RRRR'))
       
   GROUP BY V372_CALLINGPARTYNUMBER,V387_CHARGINGTIME_KEY;


