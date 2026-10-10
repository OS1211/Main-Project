USE FraudDetectionDB;

SHOW VARIABLES LIKE 'local_infile';

USE FraudDetectionDB;

TRUNCATE TABLE raw_transactions_staging;

LOAD DATA LOCAL INFILE
'C:/Users/OMAIR/Downloads/fraud detection in onlione transactions.csv'
INTO TABLE raw_transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

USE FraudDetectionDB;

TRUNCATE TABLE raw_transactions_staging;

USE FraudDetectionDB;

SELECT COUNT(*) AS Total_Rows
FROM raw_transactions_staging;


USE FraudDetectionDB;

SELECT COUNT(*) AS Total_Rows
FROM raw_transactions_staging;

SELECT COUNT(DISTINCT Transaction_ID) AS Unique_Transaction_IDs
FROM raw_transactions_staging;


SELECT COUNT(*) AS Duplicate_Transaction_IDs
FROM (
    SELECT Transaction_ID
    FROM raw_transactions_staging
    GROUP BY Transaction_ID
    HAVING COUNT(*) > 1
) AS duplicates;

USE FraudDetectionDB;
SELECT 
    Transaction_ID,
    COUNT(*) AS Occurrences
FROM raw_transactions_staging
GROUP BY Transaction_ID
HAVING COUNT(*) > 1
ORDER BY Occurrences DESC;


SELECT 
    SUM(Occurrences - 1) AS Duplicate_Rows
FROM (
    SELECT 
        Transaction_ID,
        COUNT(*) AS Occurrences
    FROM raw_transactions_staging
    GROUP BY Transaction_ID
    HAVING COUNT(*) > 1
) AS d;


SELECT
    SUM(Transaction_ID IS NULL OR TRIM(Transaction_ID) = '') AS Missing_Transaction_ID,
    SUM(Customer_ID IS NULL OR TRIM(Customer_ID) = '') AS Missing_Customer_ID,
    SUM(Transaction_DateTime IS NULL OR TRIM(Transaction_DateTime) = '') AS Missing_DateTime,
    SUM(Amount IS NULL) AS Missing_Amount,
    SUM(Currency IS NULL OR TRIM(Currency) = '') AS Missing_Currency,
    SUM(Payment_Method IS NULL OR TRIM(Payment_Method) = '') AS Missing_Payment_Method,
    SUM(Merchant_Category IS NULL OR TRIM(Merchant_Category) = '') AS Missing_Merchant_Category,
    SUM(Transaction_Type IS NULL OR TRIM(Transaction_Type) = '') AS Missing_Transaction_Type,
    SUM(Customer_Segment IS NULL OR TRIM(Customer_Segment) = '') AS Missing_Customer_Segment,
    SUM(Is_Fraud IS NULL) AS Missing_Is_Fraud
FROM raw_transactions_staging;


SELECT
    SUM(City IS NULL OR TRIM(City) = '') AS Missing_City,
    SUM(Country IS NULL OR TRIM(Country) = '') AS Missing_Country,
    SUM(Device_Type IS NULL OR TRIM(Device_Type) = '') AS Missing_Device_Type,
    SUM(Browser IS NULL OR TRIM(Browser) = '') AS Missing_Browser,
    SUM(Transactions_Last_24H IS NULL) AS Missing_Transactions_Last_24H,
    SUM(Distance_From_Home IS NULL) AS Missing_Distance_From_Home,
    SUM(Failed_Login_Attempts IS NULL) AS Missing_Failed_Login_Attempts,
    SUM(Account_Age_Years IS NULL) AS Missing_Account_Age_Years,
    SUM(Customer_Segment IS NULL OR TRIM(Customer_Segment) = '') AS Missing_Customer_Segment,
    SUM(Customer_Email IS NULL OR TRIM(Customer_Email) = '') AS Missing_Customer_Email,
    SUM(Customer_Phone IS NULL OR TRIM(Customer_Phone) = '') AS Missing_Customer_Phone,
    SUM(Is_Fraud IS NULL) AS Missing_Is_Fraud
FROM raw_transactions_staging;


USE FraudDetectionDB;

SHOW COLUMNS FROM raw_transactions_staging;


USE FraudDetectionDB;

SELECT 
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'frauddetectiondb'
  AND TABLE_NAME = 'raw_transactions_staging'
ORDER BY ORDINAL_POSITION;



USE FraudDetectionDB;

SELECT GROUP_CONCAT(
    COLUMN_NAME
    ORDER BY ORDINAL_POSITION
    SEPARATOR ', '
) AS All_Columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'frauddetectiondb'
  AND TABLE_NAME = 'raw_transactions_staging';
  
  
  USE FraudDetectionDB;

SELECT
    SUM(City IS NULL OR TRIM(City) = '') AS Missing_City,
    SUM(Country IS NULL OR TRIM(Country) = '') AS Missing_Country,
    SUM(Device_Type IS NULL OR TRIM(Device_Type) = '') AS Missing_Device_Type,
    SUM(Browser IS NULL OR TRIM(Browser) = '') AS Missing_Browser,
    SUM(Transactions_Last_24H IS NULL) AS Missing_Transactions_Last_24H,
    SUM(Distance_From_Home_KM IS NULL) AS Missing_Distance_From_Home_KM,
    SUM(Failed_Login_Attempts IS NULL) AS Missing_Failed_Login_Attempts,
    SUM(Account_Age_Years IS NULL) AS Missing_Account_Age_Years,
    SUM(Customer_Segment IS NULL OR TRIM(Customer_Segment) = '') AS Missing_Customer_Segment,
    SUM(Customer_Email IS NULL OR TRIM(Customer_Email) = '') AS Missing_Customer_Email,
    SUM(Customer_Phone IS NULL OR TRIM(Customer_Phone) = '') AS Missing_Customer_Phone,
    SUM(Is_Fraud IS NULL) AS Missing_Is_Fraud
FROM raw_transactions_staging;





USE FraudDetectionDB;

SET SESSION group_concat_max_len = 100000;

SELECT GROUP_CONCAT(
    CONCAT(
        'SUM(`', COLUMN_NAME, '` IS NULL OR TRIM(`',
        COLUMN_NAME,
        '`) = '''') AS `Missing_', COLUMN_NAME, '`'
    )
    ORDER BY ORDINAL_POSITION
    SEPARATOR ', '
) INTO @missing_check
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'frauddetectiondb'
  AND TABLE_NAME = 'raw_transactions_staging';

SET @sql = CONCAT(
    'SELECT ',
    @missing_check,
    ' FROM raw_transactions_staging'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;



USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(Transaction_Hour IS NULL OR TRIM(Transaction_Hour) = '') AS Missing_Hour,
    SUM(Day_of_Week IS NULL OR TRIM(Day_of_Week) = '') AS Missing_Day,
    SUM(Transaction_DateTime IS NULL OR TRIM(Transaction_DateTime) = '') AS Missing_DateTime
FROM raw_transactions_staging;




SELECT
    Transaction_ID,
    Transaction_DateTime,
    Transaction_Hour,
    Day_of_Week
FROM raw_transactions_staging
WHERE Transaction_Hour IS NULL
   OR TRIM(Transaction_Hour) = ''
   OR Day_of_Week IS NULL
   OR TRIM(Day_of_Week) = ''
LIMIT 20;




USE FraudDetectionDB;

SELECT
    Transaction_DateTime,
    Transaction_Hour,
    Day_of_Week
FROM raw_transactions_staging
WHERE Transaction_Hour IS NOT NULL
  AND TRIM(Transaction_Hour) <> ''
LIMIT 10;




USE FraudDetectionDB;

SELECT
    Transaction_ID,
    Transaction_DateTime,
    Transaction_Hour AS Current_Hour,
    HOUR(
        CASE
            WHEN Transaction_DateTime LIKE '%/%/%'
            THEN STR_TO_DATE(Transaction_DateTime, '%d/%m/%Y %H:%i')
            ELSE STR_TO_DATE(Transaction_DateTime, '%Y-%m-%d %H:%i:%s')
        END
    ) AS New_Hour,
    Day_of_Week AS Current_Day,
    DAYNAME(
        CASE
            WHEN Transaction_DateTime LIKE '%/%/%'
            THEN STR_TO_DATE(Transaction_DateTime, '%d/%m/%Y %H:%i')
            ELSE STR_TO_DATE(Transaction_DateTime, '%Y-%m-%d %H:%i:%s')
        END
    ) AS New_Day
FROM raw_transactions_staging
WHERE Transaction_Hour IS NULL
   OR TRIM(Transaction_Hour) = ''
   OR Day_of_Week IS NULL
   OR TRIM(Day_of_Week) = ''
LIMIT 20;






USE FraudDetectionDB;

UPDATE raw_transactions_staging
SET
    Transaction_Hour =
        HOUR(
            CASE
                WHEN Transaction_DateTime LIKE '%/%/%'
                THEN STR_TO_DATE(Transaction_DateTime, '%d/%m/%Y %H:%i')
                ELSE STR_TO_DATE(Transaction_DateTime, '%Y-%m-%d %H:%i:%s')
            END
        ),
    Day_of_Week =
        DAYNAME(
            CASE
                WHEN Transaction_DateTime LIKE '%/%/%'
                THEN STR_TO_DATE(Transaction_DateTime, '%d/%m/%Y %H:%i')
                ELSE STR_TO_DATE(Transaction_DateTime, '%Y-%m-%d %H:%i:%s')
            END
        )
WHERE
    (Transaction_Hour IS NULL OR TRIM(Transaction_Hour) = '')
    OR
    (Day_of_Week IS NULL OR TRIM(Day_of_Week) = '');
    
    
    
    
    SELECT
    COUNT(*) AS Total_Rows,
    SUM(Transaction_Hour IS NULL OR TRIM(Transaction_Hour) = '') AS Missing_Hour,
    SUM(Day_of_Week IS NULL OR TRIM(Day_of_Week) = '') AS Missing_Day
FROM raw_transactions_staging;





USE FraudDetectionDB;

SELECT
    Transaction_ID,
    COUNT(*) AS Duplicate_Count
FROM raw_transactions_staging
GROUP BY Transaction_ID
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;





SELECT
    COUNT(*) AS Total_Duplicate_Rows
FROM (
    SELECT Transaction_ID
    FROM raw_transactions_staging
    GROUP BY Transaction_ID
    HAVING COUNT(*) > 1
) AS d;





USE FraudDetectionDB;

SELECT
    SUM(Duplicate_Count - 1) AS Excess_Duplicate_Rows
FROM (
    SELECT
        Transaction_ID,
        COUNT(*) AS Duplicate_Count
    FROM raw_transactions_staging
    GROUP BY Transaction_ID
    HAVING COUNT(*) > 1
) AS d;




SELECT
    Duplicate_Count,
    COUNT(*) AS Number_of_Transaction_IDs
FROM (
    SELECT
        Transaction_ID,
        COUNT(*) AS Duplicate_Count
    FROM raw_transactions_staging
    GROUP BY Transaction_ID
    HAVING COUNT(*) > 1
) AS d
GROUP BY Duplicate_Count
ORDER BY Duplicate_Count;




SELECT *
FROM raw_transactions_staging
WHERE Transaction_ID IN (
    SELECT Transaction_ID
    FROM raw_transactions_staging
    GROUP BY Transaction_ID
    HAVING COUNT(*) > 1
)
ORDER BY Transaction_ID
LIMIT 20;







SELECT
    Transaction_ID,
    Customer_ID,
    Transaction_DateTime,
    Amount,
    Payment_Method,
    Merchant_Category,
    Is_Fraud
FROM raw_transactions_staging
WHERE Transaction_ID IN (
    SELECT Transaction_ID
    FROM (
        SELECT Transaction_ID
        FROM raw_transactions_staging
        GROUP BY Transaction_ID
        HAVING COUNT(*) > 1
        LIMIT 5
    ) AS dup
)
ORDER BY Transaction_ID;





USE FraudDetectionDB;

DROP TABLE IF EXISTS raw_transactions_dedup;

CREATE TABLE raw_transactions_dedup
LIKE raw_transactions_staging;

INSERT INTO raw_transactions_dedup
SELECT DISTINCT *
FROM raw_transactions_staging;




SELECT COUNT(*) AS Deduplicated_Rows
FROM raw_transactions_dedup;



USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Transaction_ID) AS Unique_Transaction_IDs,
    SUM(Transaction_ID IS NULL OR TRIM(Transaction_ID) = '') AS Missing_Transaction_ID
FROM raw_transactions_dedup;




USE FraudDetectionDB;

UPDATE raw_transactions_dedup
SET Customer_ID = 'UNKNOWN_CUSTOMER'
WHERE Customer_ID IS NULL
   OR TRIM(Customer_ID) = '';
   
   
   
   
   SELECT
    COUNT(*) AS Total_Rows,
    SUM(Customer_ID IS NULL OR TRIM(Customer_ID) = '') AS Missing_Customer_ID,
    SUM(Customer_ID = 'UNKNOWN_CUSTOMER') AS Replaced_Customer_ID
FROM raw_transactions_dedup;





USE FraudDetectionDB;

UPDATE raw_transactions_dedup
SET Currency = 'UNKNOWN'
WHERE Currency IS NULL
   OR TRIM(Currency) = '';
   
   
   
   
   SELECT
    COUNT(*) AS Total_Rows,
    SUM(Currency IS NULL OR TRIM(Currency) = '') AS Missing_Currency,
    SUM(Currency = 'UNKNOWN') AS Replaced_Currency
FROM raw_transactions_dedup;



USE FraudDetectionDB;

UPDATE raw_transactions_dedup
SET Payment_Method = 'UNKNOWN'
WHERE Payment_Method IS NULL
   OR TRIM(Payment_Method) = '';
   
   
   
   SELECT
    COUNT(*) AS Total_Rows,
    SUM(Payment_Method IS NULL OR TRIM(Payment_Method) = '') AS Missing_Payment_Method,
    SUM(Payment_Method = 'UNKNOWN') AS Replaced_Payment_Method
FROM raw_transactions_dedup;




USE FraudDetectionDB;

UPDATE raw_transactions_dedup
SET Device_Type = 'UNKNOWN'
WHERE Device_Type IS NULL
   OR TRIM(Device_Type) = '';
   
   
   
   
   SELECT
    COUNT(*) AS Total_Rows,
    SUM(Device_Type IS NULL OR TRIM(Device_Type) = '') AS Missing_Device_Type,
    SUM(Device_Type = 'UNKNOWN') AS Replaced_Device_Type
FROM raw_transactions_dedup;




USE FraudDetectionDB;

UPDATE raw_transactions_dedup
SET Browser = 'UNKNOWN'
WHERE Browser IS NULL
   OR TRIM(Browser) = '';
   
   
   
   SELECT
    COUNT(*) AS Total_Rows,
    SUM(Browser IS NULL OR TRIM(Browser) = '') AS Missing_Browser,
    SUM(Browser = 'UNKNOWN') AS Replaced_Browser
FROM raw_transactions_dedup;



USE FraudDetectionDB;

UPDATE raw_transactions_dedup
SET Customer_Phone = 'UNKNOWN_PHONE'
WHERE Customer_Phone IS NULL
   OR TRIM(Customer_Phone) = '';
   
   
   
   SELECT
    COUNT(*) AS Total_Rows,
    SUM(Customer_Phone IS NULL OR TRIM(Customer_Phone) = '') AS Missing_Customer_Phone,
    SUM(Customer_Phone = 'UNKNOWN_PHONE') AS Replaced_Customer_Phone
FROM raw_transactions_dedup;



USE FraudDetectionDB;

UPDATE raw_transactions_dedup
SET Login_Risk = 'UNKNOWN'
WHERE Login_Risk IS NULL
   OR TRIM(Login_Risk) = '';
   
   
   
   SELECT
    COUNT(*) AS Total_Rows,
    SUM(Login_Risk IS NULL OR TRIM(Login_Risk) = '') AS Missing_Login_Risk,
    SUM(Login_Risk = 'UNKNOWN') AS Replaced_Login_Risk
FROM raw_transactions_dedup;





USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(Transaction_ID IS NULL OR TRIM(Transaction_ID) = '') AS Missing_Transaction_ID,
    SUM(Customer_ID IS NULL OR TRIM(Customer_ID) = '') AS Missing_Customer_ID,
    SUM(Transaction_DateTime IS NULL OR TRIM(Transaction_DateTime) = '') AS Missing_DateTime,
    SUM(Amount IS NULL) AS Missing_Amount,
    SUM(Currency IS NULL OR TRIM(Currency) = '') AS Missing_Currency,
    SUM(Payment_Method IS NULL OR TRIM(Payment_Method) = '') AS Missing_Payment_Method,
    SUM(Merchant_Category IS NULL OR TRIM(Merchant_Category) = '') AS Missing_Merchant_Category,
    SUM(Transaction_Type IS NULL OR TRIM(Transaction_Type) = '') AS Missing_Transaction_Type,
    SUM(City IS NULL OR TRIM(City) = '') AS Missing_City,
    SUM(Country IS NULL OR TRIM(Country) = '') AS Missing_Country,
    SUM(Device_Type IS NULL OR TRIM(Device_Type) = '') AS Missing_Device_Type,
    SUM(Browser IS NULL OR TRIM(Browser) = '') AS Missing_Browser,
    SUM(Customer_Email IS NULL OR TRIM(Customer_Email) = '') AS Missing_Email,
    SUM(Customer_Phone IS NULL OR TRIM(Customer_Phone) = '') AS Missing_Phone,
    SUM(Is_Fraud IS NULL) AS Missing_Is_Fraud,
    SUM(Login_Risk IS NULL OR TRIM(Login_Risk) = '') AS Missing_Login_Risk
FROM raw_transactions_dedup;





USE FraudDetectionDB;

SELECT 'Currency' AS Column_Name, Currency AS Value, COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Currency

UNION ALL

SELECT 'Payment_Method', Payment_Method, COUNT(*)
FROM raw_transactions_dedup
GROUP BY Payment_Method

UNION ALL

SELECT 'Merchant_Category', Merchant_Category, COUNT(*)
FROM raw_transactions_dedup
GROUP BY Merchant_Category

UNION ALL

SELECT 'Transaction_Type', Transaction_Type, COUNT(*)
FROM raw_transactions_dedup
GROUP BY Transaction_Type

UNION ALL

SELECT 'Device_Type', Device_Type, COUNT(*)
FROM raw_transactions_dedup
GROUP BY Device_Type

UNION ALL

SELECT 'Browser', Browser, COUNT(*)
FROM raw_transactions_dedup
GROUP BY Browser

UNION ALL

SELECT 'Customer_Segment', Customer_Segment, COUNT(*)
FROM raw_transactions_dedup
GROUP BY Customer_Segment

UNION ALL

SELECT 'Risk_Category', Risk_Category, COUNT(*)
FROM raw_transactions_dedup
GROUP BY Risk_Category

UNION ALL

SELECT 'Velocity_Risk', Velocity_Risk, COUNT(*)
FROM raw_transactions_dedup
GROUP BY Velocity_Risk

UNION ALL

SELECT 'Location_Risk', Location_Risk, COUNT(*)
FROM raw_transactions_dedup
GROUP BY Location_Risk

UNION ALL

SELECT 'Login_Risk', Login_Risk, COUNT(*)
FROM raw_transactions_dedup
GROUP BY Login_Risk;






USE FraudDetectionDB;
UPDATE raw_transactions_dedup
SET Currency = 'INR'
WHERE Currency NOT IN ('INR', 'UNKNOWN');


UPDATE raw_transactions_dedup
SET Payment_Method =
    CASE
        WHEN LOWER(TRIM(Payment_Method)) = 'upi' THEN 'UPI'
        WHEN LOWER(TRIM(Payment_Method)) = 'debit card' THEN 'Debit Card'
        WHEN LOWER(TRIM(Payment_Method)) = 'credit card' THEN 'Credit Card'
        WHEN LOWER(TRIM(Payment_Method)) = 'net banking' THEN 'Net Banking'
        WHEN LOWER(TRIM(Payment_Method)) = 'wallet' THEN 'Wallet'
        WHEN LOWER(TRIM(Payment_Method)) = 'unknown' THEN 'UNKNOWN'
        ELSE TRIM(Payment_Method)
    END;
    
    
    
    UPDATE raw_transactions_dedup
SET Device_Type =
    CASE
        WHEN LOWER(TRIM(Device_Type)) = 'android' THEN 'Android'
        WHEN LOWER(TRIM(Device_Type)) = 'windows' THEN 'Windows'
        WHEN LOWER(TRIM(Device_Type)) = 'macos' THEN 'MacOS'
        WHEN LOWER(TRIM(Device_Type)) = 'ios' THEN 'iOS'
        WHEN LOWER(TRIM(Device_Type)) = 'unknown' THEN 'UNKNOWN'
        ELSE TRIM(Device_Type)
    END;
    
    
    
    
    
    
    
    UPDATE raw_transactions_dedup
SET Browser =
    CASE
        WHEN LOWER(TRIM(Browser)) = 'chrome' THEN 'Chrome'
        WHEN LOWER(TRIM(Browser)) = 'edge' THEN 'Edge'
        WHEN LOWER(TRIM(Browser)) = 'safari' THEN 'Safari'
        WHEN LOWER(TRIM(Browser)) = 'firefox' THEN 'Firefox'
        WHEN LOWER(TRIM(Browser)) = 'unknown' THEN 'UNKNOWN'
        ELSE TRIM(Browser)
    END;
    
    
    
    
    
    
    UPDATE raw_transactions_dedup
SET Customer_Segment =
    CASE
        WHEN LOWER(TRIM(Customer_Segment)) = 'new' THEN 'New'
        WHEN LOWER(TRIM(Customer_Segment)) = 'premium' THEN 'Premium'
        WHEN LOWER(TRIM(Customer_Segment)) = 'regular' THEN 'Regular'
        ELSE TRIM(Customer_Segment)
    END;
    
    
    
    
    
    
    
    UPDATE raw_transactions_dedup
SET Risk_Category =
    CASE
        WHEN LOWER(TRIM(Risk_Category)) = 'critical' THEN 'Critical'
        WHEN LOWER(TRIM(Risk_Category)) = 'high' THEN 'High'
        WHEN LOWER(TRIM(Risk_Category)) = 'medium' THEN 'Medium'
        WHEN LOWER(TRIM(Risk_Category)) = 'low' THEN 'Low'
        ELSE TRIM(Risk_Category)
    END;
    
    
    
    
    UPDATE raw_transactions_dedup
SET Velocity_Risk =
    CASE
        WHEN LOWER(TRIM(Velocity_Risk)) = 'very low' THEN 'Very Low'
        WHEN LOWER(TRIM(Velocity_Risk)) = 'low' THEN 'Low'
        WHEN LOWER(TRIM(Velocity_Risk)) = 'medium' THEN 'Medium'
        WHEN LOWER(TRIM(Velocity_Risk)) = 'high' THEN 'High'
        WHEN LOWER(TRIM(Velocity_Risk)) = 'unknown' THEN 'UNKNOWN'
        ELSE TRIM(Velocity_Risk)
    END;
    
    
    
    
    UPDATE raw_transactions_dedup
SET Location_Risk =
    CASE
        WHEN LOWER(TRIM(Location_Risk)) = 'very low' THEN 'Very Low'
        WHEN LOWER(TRIM(Location_Risk)) = 'low' THEN 'Low'
        WHEN LOWER(TRIM(Location_Risk)) = 'medium' THEN 'Medium'
        WHEN LOWER(TRIM(Location_Risk)) = 'high' THEN 'High'
        WHEN LOWER(TRIM(Location_Risk)) = 'unknown' THEN 'UNKNOWN'
        ELSE TRIM(Location_Risk)
    END;
    
    
    
    
    UPDATE raw_transactions_dedup
SET Login_Risk =
    CASE
        WHEN LOWER(TRIM(Login_Risk)) = 'very low' THEN 'Very Low'
        WHEN LOWER(TRIM(Login_Risk)) = 'low' THEN 'Low'
        WHEN LOWER(TRIM(Login_Risk)) = 'medium' THEN 'Medium'
        WHEN LOWER(TRIM(Login_Risk)) = 'high' THEN 'High'
        WHEN LOWER(TRIM(Login_Risk)) = 'unknown' THEN 'UNKNOWN'
        ELSE TRIM(Login_Risk)
    END;
    
    
    
    SELECT
    Currency,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Currency
ORDER BY Frequency DESC;



SELECT
    Payment_Method,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Payment_Method
ORDER BY Frequency DESC;




SELECT
    Device_Type,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Device_Type
ORDER BY Frequency DESC;



USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(Amount IS NULL) AS Missing_Amount,
    SUM(Amount <= 0) AS Zero_or_Negative_Amount,
    MIN(Amount) AS Minimum_Amount,
    MAX(Amount) AS Maximum_Amount,
    ROUND(AVG(Amount), 2) AS Average_Amount
FROM raw_transactions_dedup;




SELECT
    COUNT(*) AS Total_Rows,
    SUM(Transactions_Last_24H IS NULL) AS Missing_Values,
    SUM(Transactions_Last_24H < 0) AS Negative_Values,
    MIN(Transactions_Last_24H) AS Minimum_Value,
    MAX(Transactions_Last_24H) AS Maximum_Value
FROM raw_transactions_dedup;





SELECT
    COUNT(*) AS Total_Rows,
    SUM(Distance_From_Home IS NULL) AS Missing_Values,
    SUM(Distance_From_Home < 0) AS Negative_Values,
    MIN(Distance_From_Home) AS Minimum_Distance,
    MAX(Distance_From_Home) AS Maximum_Distance
FROM raw_transactions_dedup;




DESCRIBE raw_transactions_dedup;



USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(Distance_From_Home_KM IS NULL) AS Missing_Values,
    SUM(Distance_From_Home_KM < 0) AS Negative_Values,
    MIN(Distance_From_Home_KM) AS Minimum_Distance,
    MAX(Distance_From_Home_KM) AS Maximum_Distance
FROM raw_transactions_dedup;





USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(Failed_Login_Attempts IS NULL) AS Missing_Values,
    SUM(Failed_Login_Attempts < 0) AS Negative_Values,
    MIN(Failed_Login_Attempts) AS Minimum_Attempts,
    MAX(Failed_Login_Attempts) AS Maximum_Attempts
FROM raw_transactions_dedup;





USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(Account_Age_Years IS NULL) AS Missing_Values,
    SUM(Account_Age_Years < 0) AS Negative_Values,
    MIN(Account_Age_Years) AS Minimum_Age,
    MAX(Account_Age_Years) AS Maximum_Age
FROM raw_transactions_dedup;





USE FraudDetectionDB;

SELECT
    Customer_Segment,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Customer_Segment
ORDER BY Frequency DESC;




USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(Customer_Email IS NULL OR TRIM(Customer_Email) = '') AS Missing_Values,
    SUM(Customer_Email LIKE '%@%') AS Valid_Email_Format,
    SUM(Customer_Email NOT LIKE '%@%' AND TRIM(Customer_Email) <> '') AS Invalid_Email_Format
FROM raw_transactions_dedup;






USE FraudDetectionDB;

SELECT
    Customer_Email,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
WHERE Customer_Email NOT LIKE '%@%'
  AND TRIM(Customer_Email) <> ''
GROUP BY Customer_Email
ORDER BY Frequency DESC;





USE FraudDetectionDB;

UPDATE raw_transactions_dedup
SET Customer_Email = 'UNKNOWN_EMAIL'
WHERE Customer_Email = 'INVALID_EMAIL';




SELECT
    Customer_Email,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Customer_Email
ORDER BY Frequency DESC;




USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(Customer_Phone IS NULL OR TRIM(Customer_Phone) = '') AS Missing_Values,
    SUM(Customer_Phone LIKE '%UNKNOWN%'
        OR Customer_Phone LIKE '%INVALID%') AS Invalid_or_Unknown
FROM raw_transactions_dedup;





SELECT
    Customer_Phone,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Customer_Phone
ORDER BY Frequency DESC
LIMIT 20;




UPDATE raw_transactions_dedup
SET Customer_Phone = 'UNKNOWN_PHONE'
WHERE Customer_Phone IS NULL
   OR TRIM(Customer_Phone) = ''
   OR UPPER(TRIM(Customer_Phone)) IN ('UNKNOWN', 'INVALID', 'UNKNOWN_PHONE');
   
   
   
   
   SELECT
    Customer_Phone,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Customer_Phone
ORDER BY Frequency DESC
LIMIT 10;





SELECT
    Is_Fraud,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Is_Fraud
ORDER BY Frequency DESC;




SELECT
    Weekend_Flag,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Weekend_Flag
ORDER BY Frequency DESC;




SELECT
    COUNT(*) AS Total_Rows,
    SUM(Account_Age_Months IS NULL) AS Missing_Values,
    SUM(Account_Age_Months < 0) AS Negative_Values,
    MIN(Account_Age_Months) AS Minimum_Months,
    MAX(Account_Age_Months) AS Maximum_Months
FROM raw_transactions_dedup;





SELECT
    Transaction_Amount_Risk,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Transaction_Amount_Risk
ORDER BY Frequency DESC;


SHOW COLUMNS FROM raw_transactions_dedup
LIKE 'Transaction_Amount%';




SELECT
    Transaction_Amount_Band,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Transaction_Amount_Band
ORDER BY Frequency DESC;



SELECT
    Velocity_Risk,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Velocity_Risk
ORDER BY Frequency DESC;



SELECT
    Location_Risk,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Location_Risk
ORDER BY Frequency DESC;




SELECT
    Login_Risk,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Login_Risk
ORDER BY Frequency DESC;




UPDATE raw_transactions_dedup
SET Login_Risk = 'UNKNOWN_LOGIN_RISK'
WHERE Login_Risk = 'UNKNOWN';




SELECT
    Login_Risk,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Login_Risk
ORDER BY Frequency DESC;



SELECT
    Risk_Category,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Risk_Category
ORDER BY Frequency DESC;




SELECT
    Anomaly_Flag,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Anomaly_Flag
ORDER BY Frequency DESC;



SELECT
    Card_Transaction_Flag,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Card_Transaction_Flag
ORDER BY Frequency DESC;




SELECT
    Data_Quality_Flag,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Data_Quality_Flag
ORDER BY Frequency DESC;




USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Transaction_ID) AS Unique_Transaction_IDs,
    COUNT(*) - COUNT(DISTINCT Transaction_ID) AS Duplicate_Rows
FROM raw_transactions_dedup;






USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,

    SUM(Transaction_ID IS NULL OR TRIM(Transaction_ID) = '') AS Missing_Transaction_ID,
    SUM(Customer_ID IS NULL OR TRIM(Customer_ID) = '') AS Missing_Customer_ID,
    SUM(Transaction_DateTime IS NULL OR TRIM(Transaction_DateTime) = '') AS Missing_DateTime,

    SUM(Amount IS NULL) AS Missing_Amount,
    SUM(Amount < 0) AS Negative_Amount,

    SUM(Currency IS NULL OR TRIM(Currency) = '') AS Missing_Currency,
    SUM(Payment_Method IS NULL OR TRIM(Payment_Method) = '') AS Missing_Payment_Method,

    SUM(Is_Fraud IS NULL) AS Missing_Is_Fraud,
    SUM(Is_Fraud NOT IN (0,1)) AS Invalid_Is_Fraud

FROM raw_transactions_dedup;





SELECT
    Transaction_ID,
    Customer_ID,
    Transaction_DateTime,
    Amount,
    Currency,
    Payment_Method,
    Is_Fraud
FROM raw_transactions_dedup
WHERE Amount IS NULL;








USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(Amount IS NULL) AS Null_Amount,
    SUM(Amount = 0) AS Zero_Amount,
    SUM(Amount < 0) AS Negative_Amount
FROM raw_transactions_dedup;





SELECT
    Transaction_ID,
    Customer_ID,
    Transaction_DateTime,
    Amount,
    Currency,
    Payment_Method,
    Transaction_Type,
    Is_Fraud
FROM raw_transactions_dedup
WHERE Amount < 0;





SELECT
    Transaction_Type,
    COUNT(*) AS Negative_Amount_Count
FROM raw_transactions_dedup
WHERE Amount < 0
GROUP BY Transaction_Type
ORDER BY Negative_Amount_Count DESC;





DELETE FROM raw_transactions_dedup
WHERE Amount < 0
  AND Transaction_Type IN ('Purchase', 'Subscription');
  
  
  
  
  
  SELECT
    Transaction_Type,
    COUNT(*) AS Negative_Amount_Count
FROM raw_transactions_dedup
WHERE Amount < 0
GROUP BY Transaction_Type
ORDER BY Negative_Amount_Count DESC;





SELECT COUNT(*) AS Total_Rows
FROM raw_transactions_dedup;



SELECT
    COUNT(*) AS Total_Rows,
    SUM(Transaction_DateTime IS NULL) AS Missing_DateTime,
    MIN(Transaction_DateTime) AS Earliest_DateTime,
    MAX(Transaction_DateTime) AS Latest_DateTime
FROM raw_transactions_dedup;





SELECT
    Currency,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Currency
ORDER BY Frequency DESC;






SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Transaction_ID) AS Unique_Transaction_IDs,
    COUNT(*) - COUNT(DISTINCT Transaction_ID) AS Duplicate_Transaction_IDs,

    SUM(Transaction_ID IS NULL OR TRIM(Transaction_ID) = '') AS Missing_Transaction_ID,
    SUM(Customer_ID IS NULL OR TRIM(Customer_ID) = '') AS Missing_Customer_ID,
    SUM(Transaction_DateTime IS NULL) AS Missing_DateTime,
    SUM(Amount IS NULL) AS Missing_Amount,

    SUM(Is_Fraud IS NULL) AS Missing_Is_Fraud,
    SUM(Is_Fraud NOT IN (0,1)) AS Invalid_Is_Fraud
FROM raw_transactions_dedup;





DESCRIBE raw_transactions_dedup;




SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'FraudDetectionDB'
  AND TABLE_NAME = 'raw_transactions_dedup'
ORDER BY ORDINAL_POSITION;









USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Transaction_ID) AS Unique_Transaction_IDs,
    COUNT(*) - COUNT(DISTINCT Transaction_ID) AS Duplicate_Rows,

    SUM(Transaction_ID IS NULL OR TRIM(Transaction_ID) = '') AS Missing_Transaction_ID,
    SUM(Customer_ID IS NULL OR TRIM(Customer_ID) = '') AS Missing_Customer_ID,
    SUM(Transaction_DateTime IS NULL OR TRIM(Transaction_DateTime) = '') AS Missing_DateTime,
    SUM(Amount IS NULL OR TRIM(Amount) = '') AS Missing_Amount,
    SUM(Is_Fraud IS NULL OR TRIM(Is_Fraud) = '') AS Missing_Is_Fraud,

    SUM(CAST(Amount AS DECIMAL(15,2)) < 0) AS Negative_Amount,
    SUM(CAST(Amount AS DECIMAL(15,2)) = 0) AS Zero_Amount,

    SUM(TRIM(Is_Fraud) NOT IN ('0','1')) AS Invalid_Is_Fraud

FROM raw_transactions_dedup;










USE FraudDetectionDB;

SELECT
    Transaction_ID,
    Customer_ID,
    Transaction_DateTime,
    Amount,
    Currency,
    Payment_Method,
    Transaction_Type,
    Is_Fraud
FROM raw_transactions_dedup
WHERE CAST(Amount AS DECIMAL(15,2)) < 0;







USE FraudDetectionDB;

SELECT
    COUNT(*) AS Invalid_Negative_Amount_Rows
FROM raw_transactions_dedup
WHERE CAST(Amount AS DECIMAL(15,2)) < 0
  AND TRIM(Transaction_Type) <> 'Refund';
  
  
  
  
  
  
  SELECT
    TRIM(Currency) AS Currency,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY TRIM(Currency)
ORDER BY Frequency DESC;







USE FraudDetectionDB;

SELECT
    'Payment_Method' AS Column_Name,
    TRIM(Payment_Method) AS Value,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY TRIM(Payment_Method)

UNION ALL

SELECT
    'Transaction_Type',
    TRIM(Transaction_Type),
    COUNT(*)
FROM raw_transactions_dedup
GROUP BY TRIM(Transaction_Type)

UNION ALL

SELECT
    'Customer_Segment',
    TRIM(Customer_Segment),
    COUNT(*)
FROM raw_transactions_dedup
GROUP BY TRIM(Customer_Segment)

UNION ALL

SELECT
    'Device_Type',
    TRIM(Device_Type),
    COUNT(*)
FROM raw_transactions_dedup
GROUP BY TRIM(Device_Type)

UNION ALL

SELECT
    'Risk_Category',
    TRIM(Risk_Category),
    COUNT(*)
FROM raw_transactions_dedup
GROUP BY TRIM(Risk_Category);







USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,

    SUM(CAST(Amount AS DECIMAL(15,2)) <= 0) AS Invalid_Amount,
    
    SUM(CAST(Transactions_Last_24H AS UNSIGNED) < 0) AS Invalid_Transactions_Last_24H,
    
    SUM(CAST(Distance_From_Home_km AS DECIMAL(15,2)) < 0) AS Invalid_Distance,
    
    SUM(CAST(Failed_Login_Attempts AS UNSIGNED) < 0) AS Invalid_Login_Attempts,
    
    SUM(CAST(Account_Age_Years AS UNSIGNED) < 0) AS Invalid_Account_Age,

    SUM(CAST(Risk_Score AS DECIMAL(10,2)) < 0) AS Negative_Risk_Score

FROM raw_transactions_dedup;








SELECT
    Transaction_ID,
    Customer_ID,
    Transaction_DateTime,
    Amount,
    Transaction_Type,
    Currency,
    Payment_Method,
    Is_Fraud
FROM raw_transactions_dedup
WHERE CAST(Amount AS DECIMAL(15,2)) <= 0;




SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'FraudDetectionDB'
  AND TABLE_NAME = 'raw_transactions_dedup'
  AND COLUMN_NAME LIKE '%Distance%';
  
  
  
  
  
  
  
  
  
  
  USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,

    SUM(CAST(Amount AS DECIMAL(15,2)) = 0) AS Zero_Amount,

    SUM(CAST(Transactions_Last_24H AS UNSIGNED) < 0) 
        AS Invalid_Transactions_Last_24H,

    SUM(CAST(Distance_From_Home_KM AS DECIMAL(15,2)) < 0) 
        AS Invalid_Distance,

    SUM(CAST(Failed_Login_Attempts AS UNSIGNED) < 0) 
        AS Invalid_Login_Attempts,

    SUM(CAST(Account_Age_Years AS UNSIGNED) < 0) 
        AS Invalid_Account_Age,

    SUM(CAST(Risk_Score AS DECIMAL(10,2)) < 0) 
        AS Negative_Risk_Score

FROM raw_transactions_dedup;








SELECT
    COUNT(*) AS Total_Rows,

    SUM(
        TRIM(Is_Fraud) NOT IN ('0','1')
        OR Is_Fraud IS NULL
    ) AS Invalid_Is_Fraud,

    SUM(
        TRIM(Risk_Category) NOT IN ('Low','Medium','High','Critical')
        OR Risk_Category IS NULL
    ) AS Invalid_Risk_Category,

    SUM(
        CAST(Risk_Score AS DECIMAL(10,2)) < 0
        OR CAST(Risk_Score AS DECIMAL(10,2)) > 100
    ) AS Invalid_Risk_Score_Range

FROM raw_transactions_dedup;









USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,

    SUM(TRIM(Transaction_ID) = '' OR Transaction_ID IS NULL) AS Blank_Transaction_ID,
    SUM(TRIM(Customer_ID) = '' OR Customer_ID IS NULL) AS Blank_Customer_ID,
    SUM(TRIM(Transaction_DateTime) = '' OR Transaction_DateTime IS NULL) AS Blank_DateTime,
    SUM(TRIM(Amount) = '' OR Amount IS NULL) AS Blank_Amount,
    SUM(TRIM(Currency) = '' OR Currency IS NULL) AS Blank_Currency,
    SUM(TRIM(Payment_Method) = '' OR Payment_Method IS NULL) AS Blank_Payment_Method,
    SUM(TRIM(Transaction_Type) = '' OR Transaction_Type IS NULL) AS Blank_Transaction_Type,
    SUM(TRIM(Customer_Segment) = '' OR Customer_Segment IS NULL) AS Blank_Customer_Segment,
    SUM(TRIM(Is_Fraud) = '' OR Is_Fraud IS NULL) AS Blank_Is_Fraud

FROM raw_transactions_dedup;









USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,

    COUNT(DISTINCT Transaction_ID) AS Unique_Transaction_IDs,

    COUNT(*) - COUNT(DISTINCT Transaction_ID) AS Duplicate_Transaction_IDs,

    SUM(Transaction_ID IS NULL OR TRIM(Transaction_ID) = '') AS Missing_Transaction_ID,

    SUM(Customer_ID IS NULL OR TRIM(Customer_ID) = '') AS Missing_Customer_ID,

    SUM(Transaction_DateTime IS NULL OR TRIM(Transaction_DateTime) = '') AS Missing_DateTime,

    SUM(Amount IS NULL OR TRIM(Amount) = '') AS Missing_Amount,

    SUM(Is_Fraud IS NULL OR TRIM(Is_Fraud) = '') AS Missing_Is_Fraud,

    SUM(TRIM(Is_Fraud) NOT IN ('0','1')) AS Invalid_Is_Fraud,

    SUM(CAST(Risk_Score AS DECIMAL(10,2)) < 0
        OR CAST(Risk_Score AS DECIMAL(10,2)) > 100) AS Invalid_Risk_Score,

    SUM(CAST(Amount AS DECIMAL(15,2)) < 0
        AND TRIM(Transaction_Type) <> 'Refund') AS Invalid_Negative_Amount

FROM raw_transactions_dedup;







USE FraudDetectionDB;

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'FraudDetectionDB'
  AND TABLE_NAME = 'raw_transactions_dedup'
ORDER BY ORDINAL_POSITION;






USE FraudDetectionDB;

DESCRIBE raw_transactions_dedup;






USE FraudDetectionDB;

SELECT 
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'FraudDetectionDB'
  AND TABLE_NAME = 'raw_transactions_dedup'
ORDER BY ORDINAL_POSITION;






USE FraudDetectionDB;

SELECT 
    CONCAT(ORDINAL_POSITION, ' | ', COLUMN_NAME) AS Column_List
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'FraudDetectionDB'
  AND TABLE_NAME = 'raw_transactions_dedup'
ORDER BY ORDINAL_POSITION;





USE FraudDetectionDB;

SELECT
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'FraudDetectionDB'
  AND TABLE_NAME = 'raw_transactions_dedup'
  AND ORDINAL_POSITION IN (23, 28, 34);
  
  
  
  
  
  
  USE FraudDetectionDB;

SELECT
    'International_Transaction' AS Column_Name,
    GROUP_CONCAT(DISTINCT TRIM(International_Transaction)
                 ORDER BY TRIM(International_Transaction)
                 SEPARATOR ', ') AS Values_Found
FROM raw_transactions_dedup

UNION ALL

SELECT
    'Transaction_Amount_Band',
    GROUP_CONCAT(DISTINCT TRIM(Transaction_Amount_Band)
                 ORDER BY TRIM(Transaction_Amount_Band)
                 SEPARATOR ', ')
FROM raw_transactions_dedup

UNION ALL

SELECT
    'Card_Transaction_Flag',
    GROUP_CONCAT(DISTINCT TRIM(Card_Transaction_Flag)
                 ORDER BY TRIM(Card_Transaction_Flag)
                 SEPARATOR ', ')
FROM raw_transactions_dedup;






USE FraudDetectionDB;

SELECT
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'FraudDetectionDB'
  AND TABLE_NAME = 'raw_transactions_dedup'
  AND COLUMN_NAME IN (
      'Transaction_DateTime',
      'Amount',
      'Transactions_Last_24H',
      'Distance_From_Home_KM',
      'Failed_Login_Attempts',
      'Account_Age_Years',
      'Is_Fraud',
      'Risk_Score',
      'Transaction_Hour',
      'Account_Age_Months'
  )
ORDER BY ORDINAL_POSITION;







USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,
    SUM(Transaction_DateTime IS NULL OR TRIM(Transaction_DateTime) = '') AS Empty_DateTime,
    SUM(Amount IS NULL OR TRIM(Amount) = '') AS Empty_Amount,
    SUM(Transactions_Last_24H IS NULL OR TRIM(Transactions_Last_24H) = '') AS Empty_Transactions_24H,
    SUM(Distance_From_Home_KM IS NULL OR TRIM(Distance_From_Home_KM) = '') AS Empty_Distance,
    SUM(Failed_Login_Attempts IS NULL OR TRIM(Failed_Login_Attempts) = '') AS Empty_Login_Attempts,
    SUM(Account_Age_Years IS NULL OR TRIM(Account_Age_Years) = '') AS Empty_Account_Age,
    SUM(Is_Fraud IS NULL OR TRIM(Is_Fraud) = '') AS Empty_Is_Fraud,
    SUM(Risk_Score IS NULL OR TRIM(Risk_Score) = '') AS Empty_Risk_Score,
    SUM(Transaction_Hour IS NULL OR TRIM(Transaction_Hour) = '') AS Empty_Transaction_Hour,
    SUM(Account_Age_Months IS NULL OR TRIM(Account_Age_Months) = '') AS Empty_Account_Age_Months
FROM raw_transactions_dedup;








USE FraudDetectionDB;

SELECT
    COUNT(*) AS Total_Rows,

    SUM(
        Transaction_DateTime IS NULL
        OR STR_TO_DATE(TRIM(Transaction_DateTime), '%Y-%m-%d %H:%i:%s') IS NULL
    ) AS Invalid_DateTime,

    SUM(
        Amount IS NULL
        OR TRIM(Amount) NOT REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
    ) AS Invalid_Amount,

    SUM(
        Transactions_Last_24H IS NULL
        OR TRIM(Transactions_Last_24H) NOT REGEXP '^[0-9]+$'
    ) AS Invalid_Transactions_24H,

    SUM(
        Distance_From_Home_KM IS NULL
        OR TRIM(Distance_From_Home_KM) NOT REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
    ) AS Invalid_Distance,

    SUM(
        Failed_Login_Attempts IS NULL
        OR TRIM(Failed_Login_Attempts) NOT REGEXP '^[0-9]+$'
    ) AS Invalid_Login_Attempts,

    SUM(
        Account_Age_Years IS NULL
        OR TRIM(Account_Age_Years) NOT REGEXP '^[0-9]+$'
    ) AS Invalid_Account_Age,

    SUM(
        Is_Fraud IS NULL
        OR TRIM(Is_Fraud) NOT REGEXP '^[01]$'
    ) AS Invalid_Is_Fraud,

    SUM(
        Risk_Score IS NULL
        OR TRIM(Risk_Score) NOT REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
    ) AS Invalid_Risk_Score,

    SUM(
        Transaction_Hour IS NULL
        OR TRIM(Transaction_Hour) NOT REGEXP '^[0-9]+$'
    ) AS Invalid_Transaction_Hour,

    SUM(
        Account_Age_Months IS NULL
        OR TRIM(Account_Age_Months) NOT REGEXP '^[0-9]+$'
    ) AS Invalid_Account_Age_Months

FROM raw_transactions_dedup;







SELECT
    Risk_Score,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Risk_Score
ORDER BY Frequency DESC
LIMIT 20;








SELECT
    Transaction_DateTime,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
WHERE STR_TO_DATE(TRIM(Transaction_DateTime), '%Y-%m-%d %H:%i:%s') IS NULL
GROUP BY Transaction_DateTime
ORDER BY Frequency DESC
LIMIT 20;




SELECT
    Amount
FROM raw_transactions_dedup
WHERE TRIM(Amount) NOT REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
LIMIT 20;







SELECT
    COUNT(*) AS Total_Rows,
    SUM(
        Risk_Score IS NULL
        OR TRIM(Risk_Score) = ''
        OR TRIM(Risk_Score) NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
    ) AS Invalid_Risk_Score
FROM raw_transactions_dedup;






SELECT
    COUNT(*) AS Total_Rows,
    SUM(
        Transaction_DateTime IS NULL
        OR TRIM(Transaction_DateTime) = ''
        OR STR_TO_DATE(TRIM(Transaction_DateTime), '%d/%m/%Y %H:%i') IS NULL
    ) AS Invalid_DateTime
FROM raw_transactions_dedup;







SELECT
    COUNT(*) AS Total_Rows,
    SUM(
        Amount IS NULL
        OR TRIM(Amount) = ''
        OR REPLACE(TRIM(Amount), ',', '') NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
    ) AS Invalid_Amount
FROM raw_transactions_dedup;






SELECT 
    Transaction_DateTime,
    LENGTH(TRIM(Transaction_DateTime)) AS Length
FROM raw_transactions_dedup
LIMIT 20;





SELECT 
    Amount
FROM raw_transactions_dedup
WHERE Amount IS NULL
   OR TRIM(Amount) = ''
   OR REPLACE(TRIM(Amount), ',', '') NOT REGEXP '^[0-9]+(\\.[0-9]+)?$';
   
   
   
   
   
   SELECT
    Transaction_ID,
    Transaction_Type,
    Amount,
    Payment_Method,
    Is_Fraud
FROM raw_transactions_dedup
WHERE Amount = -150;





SELECT
    COUNT(*) AS Total_Rows,
    SUM(
        Transaction_DateTime IS NULL
        OR TRIM(Transaction_DateTime) = ''
        OR STR_TO_DATE(
            TRIM(Transaction_DateTime),
            '%Y-%m-%d %H:%i:%s'
        ) IS NULL
    ) AS Invalid_DateTime
FROM raw_transactions_dedup;





SELECT
    Transaction_ID,
    Transaction_DateTime
FROM raw_transactions_dedup
WHERE STR_TO_DATE(
          TRIM(Transaction_DateTime),
          '%Y-%m-%d %H:%i:%s'
      ) IS NULL
LIMIT 30;





SELECT
    Transaction_ID,
    Transaction_DateTime AS Old_DateTime,
    STR_TO_DATE(
        TRIM(Transaction_DateTime),
        '%d/%m/%Y %H:%i'
    ) AS New_DateTime
FROM raw_transactions_dedup
WHERE STR_TO_DATE(
          TRIM(Transaction_DateTime),
          '%Y-%m-%d %H:%i:%s'
      ) IS NULL
LIMIT 30;




UPDATE raw_transactions_dedup
SET Transaction_DateTime = DATE_FORMAT(
    STR_TO_DATE(
        TRIM(Transaction_DateTime),
        '%d/%m/%Y %H:%i'
    ),
    '%Y-%m-%d %H:%i:%s'
)
WHERE STR_TO_DATE(
          TRIM(Transaction_DateTime),
          '%Y-%m-%d %H:%i:%s'
      ) IS NULL;
      
      
      
      
      
      
      
      UPDATE raw_transactions_dedup
SET Transaction_DateTime = DATE_FORMAT(
    STR_TO_DATE(
        TRIM(Transaction_DateTime),
        '%d/%m/%Y %H:%i'
    ),
    '%Y-%m-%d %H:%i:%s'
)
WHERE TRIM(Transaction_DateTime) LIKE '%/%';










SELECT
    COUNT(*) AS Total_Rows,
    SUM(
        Transaction_DateTime IS NULL
        OR TRIM(Transaction_DateTime) = ''
        OR STR_TO_DATE(
            TRIM(Transaction_DateTime),
            '%Y-%m-%d %H:%i:%s'
        ) IS NULL
    ) AS Invalid_DateTime
FROM raw_transactions_dedup;






SELECT
    Transaction_ID,
    Transaction_DateTime
FROM raw_transactions_dedup
WHERE Transaction_ID IN (
    'TXN-046076',
    'TXN-012708',
    'TXN-029489',
    'TXN-015909',
    'TXN-035988'
);








SELECT
    Transaction_ID,
    Transaction_Type,
    Amount,
    Payment_Method,
    Is_Fraud
FROM raw_transactions_dedup
WHERE Amount = -150;







SELECT
    MIN(Amount) AS Minimum_Amount,
    MAX(Amount) AS Maximum_Amount,
    AVG(Amount) AS Average_Amount,
    COUNT(*) AS Total_Transactions
FROM raw_transactions_dedup;







SELECT
    Transaction_ID,
    Transaction_Type,
    Amount,
    Currency,
    Payment_Method,
    Is_Fraud
FROM raw_transactions_dedup
ORDER BY Amount DESC
LIMIT 10;







SELECT
    Amount,
    COUNT(*) AS Frequency,
    SUM(Is_Fraud = 1) AS Fraud_Count,
    SUM(Is_Fraud = 0) AS Non_Fraud_Count
FROM raw_transactions_dedup
WHERE Amount = 999999.99
GROUP BY Amount;







SELECT
    Payment_Method,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Payment_Method
ORDER BY Frequency DESC;







SELECT
    Currency,
    COUNT(*) AS Frequency
FROM raw_transactions_dedup
GROUP BY Currency
ORDER BY Frequency DESC;





SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Transaction_ID) AS Unique_Transaction_IDs,
    COUNT(*) - COUNT(DISTINCT Transaction_ID) AS Duplicate_IDs
FROM raw_transactions_dedup;





SELECT
    SUM(Transaction_ID IS NULL OR TRIM(Transaction_ID) = '') AS Missing_Transaction_ID,
    SUM(Customer_ID IS NULL OR TRIM(Customer_ID) = '') AS Missing_Customer_ID,
    SUM(Transaction_DateTime IS NULL OR TRIM(Transaction_DateTime) = '') AS Missing_DateTime,
    SUM(Amount IS NULL) AS Missing_Amount,
    SUM(Is_Fraud IS NULL) AS Missing_Is_Fraud
FROM raw_transactions_dedup;







SELECT
    COUNT(*) AS Total_Rows,
    MIN(Transaction_DateTime) AS Earliest_Transaction,
    MAX(Transaction_DateTime) AS Latest_Transaction,
    MIN(Amount) AS Minimum_Amount,
    MAX(Amount) AS Maximum_Amount,
    SUM(Is_Fraud = 1) AS Fraud_Transactions,
    SUM(Is_Fraud = 0) AS Non_Fraud_Transactions
FROM raw_transactions_dedup;








DROP TABLE IF EXISTS transactions_cleaned;

CREATE TABLE transactions_cleaned AS
SELECT *
FROM raw_transactions_dedup;



SELECT COUNT(*) AS Final_Cleaned_Rows
FROM transactions_cleaned;





DESCRIBE raw_transactions_dedup;






USE frauddetectiondb;

ALTER TABLE raw_transactions_dedup

MODIFY COLUMN Transaction_ID VARCHAR(20),

MODIFY COLUMN Customer_ID VARCHAR(20),

MODIFY COLUMN Transaction_DateTime DATETIME,

MODIFY COLUMN Amount DECIMAL(12,2),

MODIFY COLUMN Transactions_Last_24H INT,

MODIFY COLUMN Distance_From_Home_KM DECIMAL(10,2),

MODIFY COLUMN Failed_Login_Attempts INT,

MODIFY COLUMN Account_Age_Years INT,

MODIFY COLUMN Is_Fraud TINYINT,

MODIFY COLUMN Risk_Score DECIMAL(10,2),

MODIFY COLUMN Transaction_Hour INT,

MODIFY COLUMN Account_Age_Months INT;



DESCRIBE raw_transactions_dedup;






DROP TABLE IF EXISTS transactions_cleaned;

CREATE TABLE transactions_cleaned AS
SELECT *
FROM raw_transactions_dedup;


DESCRIBE transactions_cleaned;



SELECT COUNT(*) AS Final_Cleaned_Rows
FROM transactions_cleaned;




SELECT COUNT(*) AS Final_Rows
FROM transactions_cleaned;



SELECT Transaction_ID, COUNT(*) AS Duplicate_Count
FROM transactions_cleaned
GROUP BY Transaction_ID
HAVING COUNT(*) > 1;




SELECT
    SUM(Transaction_ID IS NULL OR TRIM(Transaction_ID) = '') AS Missing_Transaction_ID,
    SUM(Customer_ID IS NULL OR TRIM(Customer_ID) = '') AS Missing_Customer_ID,
    SUM(Transaction_DateTime IS NULL) AS Missing_DateTime,
    SUM(Amount IS NULL) AS Missing_Amount,
    SUM(Is_Fraud IS NULL) AS Missing_Fraud_Flag
FROM transactions_cleaned;




DESCRIBE transactions_cleaned;





SELECT
    COUNT(*) AS Total_Rows,
    MIN(Transaction_DateTime) AS Earliest_Transaction,
    MAX(Transaction_DateTime) AS Latest_Transaction,
    MIN(Amount) AS Minimum_Amount,
    MAX(Amount) AS Maximum_Amount,
    SUM(Is_Fraud = 1) AS Fraud_Count,
    SUM(Is_Fraud = 0) AS Non_Fraud_Count
FROM transactions_cleaned;








