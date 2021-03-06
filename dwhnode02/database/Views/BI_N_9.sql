--
-- BI_N_9  (View) 
--
CREATE OR REPLACE FORCE VIEW DWH_USER.BI_N_9
(V372_CALLINGPARTYNUMBER, V387_CHARGINGTIME_KEY, V397_MAINOFFERINGID, V400_PAYTYPE, G383_CHARGINGTIME_KEY, 
 G401_MAINOFFERINGID, G403_PAYTYPE, S387_CHARGINGTIME_KEY, S395_MAINOFFERINGID, S398_PAYTYPE, 
 R373_MAINOFFERINGID, R377_CYCLEBEGINTIME_KEY, R374_PAYTYPE)
BEQUEATH DEFINER
AS 
select A.V372_CALLINGPARTYNUMBER ,B.V387_CHARGINGTIME_KEY, B.V397_MAINOFFERINGID, B.V400_PAYTYPE ,C.G383_CHARGINGTIME_KEY, C.G401_MAINOFFERINGID, C.G403_PAYTYPE,
D.S387_CHARGINGTIME_KEY, D.S395_MAINOFFERINGID, D.S398_PAYTYPE,E.R373_MAINOFFERINGID, E.R377_CYCLEBEGINTIME_KEY, E.R374_PAYTYPE

from
(select V372_CALLINGPARTYNUMBER from l3_voice where V387_CHARGINGTIME_KEY = (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-7,'DD/MM/RRRR'))
union
select G372_CALLINGPARTYNUMBER from L3_DATA where G383_CHARGINGTIME_KEY= (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-7,'DD/MM/RRRR'))
union
select S22_PRI_IDENTITY from L3_SMS where S387_CHARGINGTIME_KEY= (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-7,'DD/MM/RRRR'))
union 
select R375_CHARGINGPARTYNUMBER from L3_RECURRING where R377_CYCLEBEGINTIME_KEY= (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-7,'DD/MM/RRRR'))
)A
left outer join 
(
select V372_CALLINGPARTYNUMBER, V387_CHARGINGTIME_KEY, V397_MAINOFFERINGID, V400_PAYTYPE from  L3_VOICE 
where V387_CHARGINGTIME_KEY = (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-7,'DD/MM/RRRR'))
group by V372_CALLINGPARTYNUMBER, V387_CHARGINGTIME_KEY, V397_MAINOFFERINGID, V400_PAYTYPE

)B on A.V372_CALLINGPARTYNUMBER=B.V372_CALLINGPARTYNUMBER

left outer join
(
select G372_CALLINGPARTYNUMBER, G383_CHARGINGTIME_KEY, G401_MAINOFFERINGID, G403_PAYTYPE from l3_DATA
where G383_CHARGINGTIME_KEY= (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-7,'DD/MM/RRRR'))
group by G372_CALLINGPARTYNUMBER, G383_CHARGINGTIME_KEY, G401_MAINOFFERINGID, G403_PAYTYPE

)C on A.V372_CALLINGPARTYNUMBER=C.G372_CALLINGPARTYNUMBER

left outer join

(
select S22_PRI_IDENTITY, S387_CHARGINGTIME_KEY, S395_MAINOFFERINGID, S398_PAYTYPE from L3_SMS 
where S387_CHARGINGTIME_KEY= (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-7,'DD/MM/RRRR'))
group by S22_PRI_IDENTITY, S387_CHARGINGTIME_KEY, S395_MAINOFFERINGID, S398_PAYTYPE 

)D on A.V372_CALLINGPARTYNUMBER=D.S22_PRI_IDENTITY
left outer join

(
select R373_MAINOFFERINGID, R375_CHARGINGPARTYNUMBER, R377_CYCLEBEGINTIME_KEY, R374_PAYTYPE from L3_RECURRING
where R377_CYCLEBEGINTIME_KEY= (SELECT DATE_KEY FROM DATE_DIM  WHERE DATE_VALUE = TO_DATE(SYSDATE-7,'DD/MM/RRRR'))
group by R373_MAINOFFERINGID, R375_CHARGINGPARTYNUMBER, R377_CYCLEBEGINTIME_KEY, R374_PAYTYPE
)E on A.V372_CALLINGPARTYNUMBER=E.R373_MAINOFFERINGID;


