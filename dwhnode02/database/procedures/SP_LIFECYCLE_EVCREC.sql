--
-- SP_LIFECYCLE_EVCREC  (Procedure) 
--
CREATE OR REPLACE PROCEDURE DWH_USER.SP_LIFECYCLE_EVCREC (P_PROCESS_DATE VARCHAR2) IS
    VDATE_KEY               VARCHAR2(4);
    MAIN_ACCOUNT_BALANCE    NUMBER;
    VDATE                   DATE := TO_DATE(TO_DATE(P_PROCESS_DATE,'YYYYMMDD'),'DD/MM/RRRR');
    ---------KPI_LOG STATUS----------
    VSTATUS659          NUMBER;
BEGIN
   
    SELECT DATE_KEY INTO VDATE_KEY 
    FROM DATE_DIM
    WHERE DATE_KEY = (SELECT A.DATE_KEY FROM DATE_DIM A WHERE A.DATE_VALUE = VDATE);
                     
    ---------------659  EV SIM Main Account Balance-----------------
    SELECT COUNT(STATUS) AS STATUS INTO  VSTATUS659
    FROM LIFECYCLE_LOG
    WHERE DATE_KEY = VDATE_KEY
    AND  KPI_KEY = 659;

    IF VSTATUS659 = 0 THEN
        INSERT INTO LIFECYCLE_LOG (PROCEDURE_NAME, KPI_KEY, SOURCE, DATE_KEY, STATUS, INSERT_TIME, REMARKS)
        VALUES                    ('SP_LIFECYCLE_EVCREC',659,'L3_EVCREC',VDATE_KEY,30,SYSDATE,'A');
        COMMIT;

        SELECT SUM(ER34_NEW_BALANCE) INTO MAIN_ACCOUNT_BALANCE
        FROM L3_EVCREC
        where ER12_RECHARGE_DATE_KEY = VDATE_KEY; 
               
        INSERT INTO LIFECYCLE_KPI_FCT(DATE_KEY, KPI_KEY,KPI_VALUE)
        VALUES (VDATE_KEY, 659,MAIN_ACCOUNT_BALANCE);
        COMMIT;
        UPDATE LIFECYCLE_LOG SET 
        STATUS = 96
        WHERE DATE_KEY = VDATE_KEY
        AND KPI_KEY = 659;        
        COMMIT;
    ELSE
        INSERT INTO LIFECYCLE_LOG (PROCEDURE_NAME, KPI_KEY, SOURCE, DATE_KEY, STATUS, INSERT_TIME, REMARKS)
        VALUES                    ('SP_LIFECYCLE_EVCREC',659,'L3_EVCREC',VDATE_KEY,34,SYSDATE,'A');
        COMMIT;
    END IF;
END;
/
