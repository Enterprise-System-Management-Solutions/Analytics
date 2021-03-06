export ORACLE_UNQNAME=DWH05
export ORACLE_BASE=/data01/app/oracle
export ORACLE_HOME=/data01/app/oracle/product/12.2.0/db_1
export ORACLE_SID=DWH05

PATH=/usr/sbin:$PATH:$ORACLE_HOME/bin

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib;


get_partition()
{
sqlplus  -s <<EOF
dwh_user/dwh_user_123
SET echo off
SET head off
SET feedback off
REM "WHENEVER SQLERROR EXIT SQL.SQLCODE"
SELECT EPART||','||SPART||','||DPART||','||RPART||','||DATE_KEY
FROM
(SELECT 'ETL_DATE_KEY_'||A.DATE_KEY EPART,'SMS_'||A.DATE_KEY SPART,'DATA_'||A.DATE_KEY DPART, 'RECHARGE_'||A.DATE_KEY RPART,B.DATE_KEY
FROM DATE_DIM A, DATE_DIM B
WHERE A.DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = TO_DATE (SYSDATE,'dd/mm/rrrr'))
AND B.DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = TO_DATE (SYSDATE-1,'dd/mm/rrrr'))
);
EXIT
EOF
}



insert_script()
{
sqlplus  -s <<EOF
dwh_user/dwh_user_123
SET echo on
SET head off
SET feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE

DECLARE
    VDATE_KEY       NUMBER;
    ACTIVATION      NUMBER;
    ONE_DAY         NUMBER;
    THIRTY_DAY      NUMBER;
    DAILY_CALLERS   number;
    VDATE           DATE := TO_DATE(TO_DATE(SYSDATE-1,'YYYYMMDD'),'DD/MM/RRRR');
    ------KPI_LOG STATUS------
    VSTATUS599      NUMBER;
    VSTATUS614      NUMBER;
    VSTATUS664      NUMBER;
    VSTATUS520      number;

BEGIN
    SELECT DATE_KEY INTO VDATE_KEY 
    FROM DATE_DIM
    WHERE DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = VDATE);
    
    -------------599    Activation---------
    SELECT COUNT(STATUS) AS STATUS INTO  VSTATUS599
    FROM LIFECYCLE_LOG
    WHERE DATE_KEY = VDATE_KEY
    AND  KPI_KEY = 599;
    
    IF VSTATUS599 = 0 THEN
        INSERT INTO LIFECYCLE_LOG (PROCEDURE_NAME, KPI_KEY, SOURCE, DATE_KEY, STATUS, INSERT_TIME, REMARKS)
        VALUES                    ('SP_LIFECYCLE_ACTIVE_BASE',599,'LAST_ACTIVITY_FCT',VDATE_KEY,30,SYSDATE,'A');
        COMMIT;
       
        SELECT COUNT(MSISDN) INTO ACTIVATION
        FROM LAST_ACTIVITY_FCT PARTITION($1)
        WHERE ETL_DATE_KEY=VDATE_KEY
        AND SNAPSHOT_DATE_KEY=VDATE_KEY;

        INSERT INTO LIFECYCLE_KPI_FCT(DATE_KEY, KPI_KEY,KPI_VALUE)
        VALUES (VDATE_KEY, 599,ACTIVATION);        
        COMMIT;
        
        UPDATE LIFECYCLE_LOG SET 
        STATUS = 96,
        UPDATE_TIME=SYSDATE
        WHERE DATE_KEY = VDATE_KEY
        AND KPI_KEY = 599;        
        COMMIT;
    ELSE
        INSERT INTO LIFECYCLE_LOG (PROCEDURE_NAME, KPI_KEY, SOURCE, DATE_KEY, STATUS, INSERT_TIME, REMARKS)
        VALUES                    ('SP_LIFECYCLE_ACTIVE_BASE',566,'LAST_ACTIVITY_FCT',VDATE_KEY,34,SYSDATE,'A');
        COMMIT;
    END IF; 
    
    -------614    1 day Active Base-----
    SELECT COUNT(STATUS) AS STATUS INTO  VSTATUS614
    FROM LIFECYCLE_LOG
    WHERE DATE_KEY = VDATE_KEY
    AND  KPI_KEY = 614;
    
    IF VSTATUS614 = 0 THEN
        INSERT INTO LIFECYCLE_LOG (PROCEDURE_NAME, KPI_KEY, SOURCE, DATE_KEY, STATUS, INSERT_TIME, REMARKS)
        VALUES                    ('SP_LIFECYCLE_ACTIVE_BASE',614,'LAST_ACTIVITY_FCT',VDATE_KEY,30,SYSDATE,'A');
        COMMIT; 
        SELECT COUNT(*) INTO ONE_DAY 
        FROM 
        (SELECT MSISDN, SNAPSHOT_DATE_KEY, ETL_DATE_KEY - LU_DATE_KEY AS DATE_DIFF  
        FROM LAST_ACTIVITY_FCT PARTITION($1)
        WHERE ETL_DATE_KEY =VDATE_KEY
        AND ETL_DATE_KEY - LU_DATE_KEY = 0);
		
        INSERT INTO LIFECYCLE_KPI_FCT(DATE_KEY, KPI_KEY,KPI_VALUE)
        VALUES (VDATE_KEY, 614,ONE_DAY);
        COMMIT;
        
        UPDATE LIFECYCLE_LOG SET 
        STATUS = 96,
        UPDATE_TIME=SYSDATE
        WHERE DATE_KEY = VDATE_KEY
        AND KPI_KEY = 614;        
        COMMIT;
    ELSE
        INSERT INTO LIFECYCLE_LOG (PROCEDURE_NAME, KPI_KEY, SOURCE, DATE_KEY, STATUS, INSERT_TIME, REMARKS)
        VALUES                    ('SP_LIFECYCLE_ACTIVE_BASE',614,'LAST_ACTIVITY_FCT',VDATE_KEY,34,SYSDATE,'A');
        COMMIT;
    END IF;
    
    -----664    30 days active sub base
    SELECT COUNT(STATUS) AS STATUS INTO  VSTATUS664
    FROM LIFECYCLE_LOG
    WHERE DATE_KEY = VDATE_KEY
    AND  KPI_KEY = 664;
    
    IF VSTATUS664 = 0 THEN
        INSERT INTO LIFECYCLE_LOG (PROCEDURE_NAME, KPI_KEY, SOURCE, DATE_KEY, STATUS, INSERT_TIME, REMARKS)
        VALUES                    ('SP_LIFECYCLE_ACTIVE_BASE',664,'LAST_ACTIVITY_FCT',VDATE_KEY,30,SYSDATE,'A');
        COMMIT;

        SELECT COUNT(*) INTO THIRTY_DAY 
        FROM(
        SELECT MSISDN  
        FROM 
        (SELECT MSISDN, SNAPSHOT_DATE_KEY, ETL_DATE_KEY - LU_DATE_KEY AS DATE_DIFF  
        FROM LAST_ACTIVITY_FCT PARTITION($1)
        WHERE ETL_DATE_KEY =VDATE_KEY
        AND ETL_DATE_KEY - LU_DATE_KEY >= 30)
        GROUP BY MSISDN);

        INSERT INTO LIFECYCLE_KPI_FCT(DATE_KEY, KPI_KEY,KPI_VALUE)
        VALUES (VDATE_KEY, 664,THIRTY_DAY);
        COMMIT;
        UPDATE LIFECYCLE_LOG SET 
        STATUS = 96,
        UPDATE_TIME=SYSDATE
        WHERE DATE_KEY = VDATE_KEY
        AND KPI_KEY = 664;        
        COMMIT;
    ELSE
        INSERT INTO LIFECYCLE_LOG (PROCEDURE_NAME, KPI_KEY, SOURCE, DATE_KEY, STATUS, INSERT_TIME, REMARKS)
        VALUES                    ('SP_LIFECYCLE_ACTIVE_BASE',664,'LAST_ACTIVITY_FCT',VDATE_KEY,34,SYSDATE,'A');
        COMMIT;
    END IF;
    
        ---------520 Daily callers--------
    SELECT COUNT(STATUS) AS STATUS INTO  VSTATUS520
    FROM LIFECYCLE_LOG
    WHERE DATE_KEY = VDATE_KEY
    AND  KPI_KEY = 520;
    
    IF VSTATUS520 = 0 THEN
        INSERT INTO LIFECYCLE_LOG (PROCEDURE_NAME, KPI_KEY, SOURCE, DATE_KEY, STATUS, INSERT_TIME, REMARKS)
        VALUES                    ('SP_LIFECYCLE_VOICE',520,'LAST_ACTIVITY_FCT_LD',VDATE_KEY,30,SYSDATE,'A');
        COMMIT;
        
        SELECT COUNT(MSISDN) INTO DAILY_CALLERS
        FROM LAST_ACTIVITY_FCT_LD 
        WHERE LU_DATE_KEY=VDATE_KEY;

        INSERT INTO LIFECYCLE_KPI_FCT(DATE_KEY, KPI_KEY,KPI_VALUE)
        VALUES (VDATE_KEY, 520,DAILY_CALLERS);
        COMMIT;
                
        UPDATE LIFECYCLE_LOG SET 
        STATUS = 96
        WHERE DATE_KEY = VDATE_KEY
        AND KPI_KEY = 520;        
        COMMIT;
    ELSE
        INSERT INTO LIFECYCLE_LOG (PROCEDURE_NAME, KPI_KEY, SOURCE, DATE_KEY, STATUS, INSERT_TIME, REMARKS)
        VALUES                    ('SP_LIFECYCLE_ACTIVE_BASE',520,'LAST_ACTIVITY_FCT_LD',VDATE_KEY,34,SYSDATE,'A');
        COMMIT;
    END IF;
END;
EXIT
EOF
}

# ======= SMSC SECTION =====.

lock=/data02/scripts/process/bin/sp_lifecycle_active_base  export lock

if [ -f $lock ] ; then
exit 2

else
touch $lock

fileList=`get_partition`

for fil in $fileList
do

v1=`echo ${fil}|sed s/,/\ /g|awk '{print $1}'`   ###partition
v5=`echo ${fil}|sed s/,/\ /g|awk '{print $5}'`   ###date_key

insert_script $v1

done

rm -f $lock

fi

