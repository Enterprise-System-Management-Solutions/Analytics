--
-- BIN12TOTALDATAVOLUME  (View) 
--
CREATE OR REPLACE FORCE VIEW DWH_USER.BIN12TOTALDATAVOLUME
(X, VOLUME3G, VOLUME2G, VOLUME4G)
BEQUEATH DEFINER
AS 
select "X","VOLUME3G","VOLUME2G","VOLUME4G" from
(select X, VOLUME3G, VOLUME2G, VOLUME4G
from BIN12JOINDATAVOLUME2G3G4G

UNION 

select Z, VOLUME3G, VOLUME2G, VOLUME4G
from BIN12JOINDATAVOLUME2G3G4G)
where x is not null;


