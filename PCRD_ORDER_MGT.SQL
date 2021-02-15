create or replace NONEDITIONABLE PACKAGE BODY PCRD_ORDER_MGT IS

FUNCTION ORDER_REPORT 

(
    P_BUSINESS_DATE  IN VARCHAR2
) RETURN PLS_INTEGER IS

V_FILE_NAME                 VARCHAR2 (32767);
F_XML_FILE                  UTL_FILE.FILE_TYPE;
V_RECORD_DATA_HEADER        VARCHAR2 (32767);
V_RECORD_DATA_DETAILS       VARCHAR2 (32767);
INVOICE_STATUS              VARCHAR2 (2000);

CURSOR CUR_ORD_REP_1

IS
/*ORDER*/

SELECT 

TO_NUMBER(replace(LTRIM(ORDER_REF,'PO0'),'-','.')) As Order_Reference, 
SUBSTR(ORDER_DATE,4,6) AS Order_Period, 
INITCAP(SUPPLIER_NAME) AS Supplier_Name,
--order_total_amount,
TO_CHAR(REPLACE(ORDER_TOTAL_AMOUNT,',',''),'FM999G999G999G999D00') AS Order_Total_Amount, 
ORDER_STATUS, 
INVOICE_REFERENCE,
INVOICE_AMOUNT,
DECODE(INVOICE_STATUS,'Paid','OK','Pending','To follow up','Verify') AS Action 
FROM XXBCM_ORDER_MGT
ORDER BY ORDER_DATE DESC
;

BEGIN

    BEGIN

        V_FILE_NAME := 'ORDER REPORT '|| TO_CHAR(SYSDATE, 'DDMMYYYY')||'.csv';

        F_XML_FILE  := UTL_FILE.FOPEN ('XMLDIR',V_FILE_NAME,'w',32767);

        V_RECORD_DATA_HEADER := 'Order_Reference, Order_Period, Supplier_Name, Order_Total_Amount, Order_Status, Invoice_Reference,Invoice_Amount,Action';
        --V_RECORD_DATA_DETAILS := 'Identifier, old_account_number, new_account_number, old_expiration_date, new_expiration_date, Reason_Code, error_codes_1,error_codes_2, error_codes_3, error_codes_4, error_codes_5 ';

        /* Text */
        UTL_FILE.PUT_LINE (F_XML_FILE, 'ORDER REPORT FOR ' || TO_CHAR(SYSDATE, 'DDth FMMON YYYY'));

        UTL_FILE.PUT_LINE (F_XML_FILE, V_RECORD_DATA_HEADER);

        V_RECORD_DATA_HEADER := NULL ;


        FOR R IN CUR_ORD_REP_1
            LOOP

                V_RECORD_DATA_HEADER :=             R.Order_Reference                       ||','||
                                                    R.Order_Period                          ||','||
                                                    R.Supplier_Name                         ||','||
                                                    R.Order_Total_Amount                    ||','||
                                                    R.Order_Status                          ||','||
                                                    R.Invoice_Reference                     ||','||
                                                    R.Invoice_Amount                        ||','||
                                                    R.Action                                ;

                                        UTL_FILE.PUT_LINE (F_XML_FILE, V_RECORD_DATA_HEADER);
                                        UTL_FILE.PUT_LINE (F_XML_FILE, NULL);
                                        --UTL_FILE.PUT_LINE (F_XML_FILE, V_RECORD_DATA_DETAILS);

        END LOOP;

        UTL_FILE.FCLOSE   (F_XML_FILE);

     END;
    END ORDER_REPORT;

FUNCTION NUMBER_OF_ORDER_REPORT

(
    P_BUSINESS_DATE  IN VARCHAR2
) RETURN PLS_INTEGER IS

V_FILE_NAME                 VARCHAR2 (32767);
F_XML_FILE                  UTL_FILE.FILE_TYPE;
V_RECORD_DATA_HEADER        VARCHAR2 (32767);
V_RECORD_DATA_DETAILS       VARCHAR2 (32767);
INVOICE_STATUS              VARCHAR2 (2000);


CURSOR CUR_NUM_ORD_REP_1

IS

/*NUMBER OF ORDER*/

SELECT TRIM(SUPPLIER_NAME) AS SUPPLIER_NAME, 
SUPP_CONTACT_NAME,
REPLACE(TO_CHAR(SUBSTR(REPLACE(REPLACE(REPLACE(SUPP_CONTACT_NUMBER,' ',''),'.',''),',',''), 0,8),'999,9999,9999'),',','-') as Supplier_Contact_No_1,
REPLACE(TO_CHAR(SUBSTR(REPLACE(REPLACE(REPLACE(SUPP_CONTACT_NUMBER,' ',''),'.',''),',',''), 9,8),'999,9999,9999'),',','-') as Supplier_Contact_No_2,
TO_CHAR(SUM(REPLACE(NVL(ORDER_TOTAL_AMOUNT,0),',','')),'FM999G999G999G999D00') AS Order_Total_Amount,
--SUM(REPLACE(NVL(ORDER_TOTAL_AMOUNT,0),',','')) AS Order_Total_Amount,
COUNT(*) AS TOTAL

FROM XXBCM_ORDER_MGT
WHERE ORDER_DATE BETWEEN '01-JAN-2017' AND '31-AUG-2017'
GROUP BY SUPPLIER_NAME,SUPP_CONTACT_NAME,REPLACE(TO_CHAR(SUBSTR(REPLACE(REPLACE(REPLACE(SUPP_CONTACT_NUMBER,' ',''),'.',''),',',''), 0,8),'999,9999,9999'),',','-'),REPLACE(TO_CHAR(SUBSTR(REPLACE(REPLACE(REPLACE(SUPP_CONTACT_NUMBER,' ',''),'.',''),',',''), 9,8),'999,9999,9999'),',','-')
ORDER BY SUPPLIER_NAME,SUPP_CONTACT_NAME asc;

BEGIN

    BEGIN

        V_FILE_NAME := 'NUMBER OF ORDERS REPORT '|| TO_CHAR(SYSDATE, 'DDMMYYYY')||'.csv';

        F_XML_FILE  := UTL_FILE.FOPEN ('XMLDIR',V_FILE_NAME,'w',32767);

        V_RECORD_DATA_HEADER := 'SUPPLIER_NAME, SUPP_CONTACT_NAME, Supplier_Contact_No_1, Supplier_Contact_No_2,Order_Total_Amount, TOTAL';
        --V_RECORD_DATA_DETAILS := 'Identifier, old_account_number, new_account_number, old_expiration_date, new_expiration_date, Reason_Code, error_codes_1,error_codes_2, error_codes_3, error_codes_4, error_codes_5 ';

        /* Text */
        UTL_FILE.PUT_LINE (F_XML_FILE, 'ORDER REPORT FOR ' || TO_CHAR(SYSDATE, 'DDth FMMON YYYY'));

        UTL_FILE.PUT_LINE (F_XML_FILE, V_RECORD_DATA_HEADER);

        V_RECORD_DATA_HEADER := NULL ;


        FOR S IN CUR_NUM_ORD_REP_1
            LOOP

                V_RECORD_DATA_HEADER :=             S.SUPPLIER_NAME                            ||','||
                                                    S.SUPP_CONTACT_NAME                        ||','||
                                                    S.Supplier_Contact_No_1                    ||','||
                                                    S.Supplier_Contact_No_2                    ||','||
                                                    S.Order_Total_Amount                       ||','||
                                                    S.TOTAL                     ;

                                        UTL_FILE.PUT_LINE (F_XML_FILE, V_RECORD_DATA_HEADER);
                                        UTL_FILE.PUT_LINE (F_XML_FILE, NULL);
                                        --UTL_FILE.PUT_LINE (F_XML_FILE, V_RECORD_DATA_DETAILS);

        END LOOP;

        UTL_FILE.FCLOSE   (F_XML_FILE);

     END;
     END NUMBER_OF_ORDER_REPORT;

FUNCTION HIGHEST_ORDER

(
    P_BUSINESS_DATE  IN VARCHAR2
) RETURN PLS_INTEGER IS

V_FILE_NAME                 VARCHAR2 (32767);
F_XML_FILE                  UTL_FILE.FILE_TYPE;
V_RECORD_DATA_HEADER        VARCHAR2 (32767);
V_RECORD_DATA_DETAILS       VARCHAR2 (32767);
INVOICE_STATUS              VARCHAR2 (2000);
V_COUNT                     INTEGER;


CURSOR CUR_HIG_ORD_REP_1

IS

/*HIGHEST NUMBER OF ORDER*/

SELECT
TO_NUMBER(replace(LTRIM(ORDER_REF,'PO0'),'-','.')) As Order_Reference,
TO_CHAR(TO_DATE(ORDER_DATE,'DD-MON-RRRR'),'MonthDD, RRRR') AS ORDER_DATE,--ORDER_DATE,
UPPER(SUPPLIER_NAME) AS SUPPLIER_NAME,
TO_CHAR(REPLACE(ORDER_TOTAL_AMOUNT,',',''),'FM999G999G999G999D00') AS Order_Total_Amount,
ORDER_STATUS,
INVOICE_REFERENCE
FROM XXBCM_ORDER_MGT
ORDER BY TO_NUMBER(REPLACE(NVL(ORDER_TOTAL_AMOUNT,0),',','')) DESC;


BEGIN

    BEGIN

        V_FILE_NAME := 'HIGHEST NUMBER OF ORDERS REPORT '|| TO_CHAR(SYSDATE, 'DDMMYYYY')||'.csv';

        F_XML_FILE  := UTL_FILE.FOPEN ('XMLDIR',V_FILE_NAME,'w',32767);

        V_RECORD_DATA_HEADER := 'Order_Reference, ORDER_DATE, SUPPLIER_NAME, Order_Total_Amount,ORDER_STATUS,INVOICE_REFERENCE';

        /* Text */
        UTL_FILE.PUT_LINE (F_XML_FILE, 'HIGHEST NUMBER OF ORDER REPORT FOR ' || TO_CHAR(SYSDATE, 'DDth FMMON YYYY'));

        UTL_FILE.PUT_LINE (F_XML_FILE, V_RECORD_DATA_HEADER);

        V_RECORD_DATA_HEADER := NULL ;


        V_COUNT:=0;

        FOR T IN CUR_HIG_ORD_REP_1
            LOOP

                V_COUNT:=V_COUNT+1;

                IF V_COUNT=3 THEN

                    V_RECORD_DATA_HEADER :=             T.Order_Reference                   ||','||
                                                        T.ORDER_DATE                        ||','||
                                                        T.SUPPLIER_NAME                     ||','||
                                                        T.Order_Total_Amount                ||','||
                                                        T.ORDER_STATUS                      ||','||
                                                        T.INVOICE_REFERENCE                  ;

                                            UTL_FILE.PUT_LINE (F_XML_FILE, V_RECORD_DATA_HEADER);
                                            UTL_FILE.PUT_LINE (F_XML_FILE, NULL);
                                            --UTL_FILE.PUT_LINE (F_XML_FILE, V_RECORD_DATA_DETAILS);
                    EXIT;
                END IF;

        END LOOP;

        UTL_FILE.FCLOSE   (F_XML_FILE);

     END;
     END HIGHEST_ORDER;


END PCRD_ORDER_MGT;
