SELECT * 
FROM [bank transaction_data];


-- KPIs
-- Total Transaction
SELECT 
    COUNT (Transaction_ID) AS total_transaction
FROM [bank transaction_data]

-- Total Transaction Value
SELECT 
    SUM (Transaction_Amount) AS total_transaction_value
FROM [bank transaction_data]

-- Average transaction amount 
SELECT 
    ROUND(AVG(transaction_amount), 2) AS AVG_transaction_amount
FROM [bank transaction_data]

-- Transaction Success Rate(%)
SELECT 
    SUM(CASE 
        WHEN transaction_status = 'success'  THEN 1 
        ELSE 0 
    END) * CAST(100.0 AS FLOAT) / (SELECT 
        COUNT(*) 
        FROM [bank transaction_data]) 
    AS success_rate
FROM [bank transaction_data];

-- Fraud Analysis
-- Fraud Rate (%)
SELECT 
    SUM(CASE 
        WHEN fraud_flag = 1 THEN 1 
        ELSE 0 
    END ) * CAST(100.0 AS FLOAT) / (SELECT 
        COUNT (*) 
        FROM [bank transaction_data])
    AS total_fraud_rate
FROM [bank transaction_data]

-- Fraud Rate by Transaction Type
-- Fraud Rate by Transaction Type in a table
SELECT 
    transaction_type,
    SUM(transaction_amount) AS transaction_value,
    SUM(CASE
            WHEN fraud_flag = 1 THEN 1 
            ELSE 0 
        END) * CAST(100.0 AS FLOAT) / (SELECT 
            COUNT (*) 
        FROM [bank transaction_data]) AS fraud_rate
FROM [bank transaction_data]
GROUP BY Transaction_Type;

-- Transfer
SELECT 
    SUM(CASE 
        WHEN fraud_flag = 1 AND Transaction_Type = 'transfer'  THEN 1 
        ELSE 0 
    END ) * CAST(100.0 AS FLOAT) / (SELECT 
        COUNT (*) 
        FROM [bank transaction_data])
    AS fraud_rate_by_transfer
FROM [bank transaction_data];

-- Withdrawal
SELECT 
    SUM(CASE 
        WHEN fraud_flag = 1 AND Transaction_Type = 'withdrawal'  THEN 1 
        ELSE 0 
    END ) * CAST(100.0 AS FLOAT) / (SELECT 
        COUNT (*) 
        FROM [bank transaction_data])
    AS fraud_rate_bt_withdrawal
FROM [bank transaction_data];

-- Deposit
SELECT 
    SUM(CASE 
        WHEN fraud_flag = 1 AND Transaction_Type = 'deposit'  THEN 1 
        ELSE 0 
    END ) * CAST(100.0 AS FLOAT) / (SELECT 
        COUNT (*) 
        FROM [bank transaction_data])
    AS fraud_rate_by_deposit
FROM [bank transaction_data];

-- Fraud trend over time
SELECT
    DATEPART(HOUR, Timestamp) AS transaction_hour,
    COUNT(*) AS total_transactions,
    SUM(CASE 
        WHEN Fraud_Flag = 1 
        THEN 1 
        ELSE 0 
    END) AS fraud_transactions
FROM [bank transaction_data]
GROUP BY DATEPART(HOUR, Timestamp)
ORDER BY transaction_hour;


-- NETWORK PERFORMANCE 
-- Average latency by network slice
SELECT 
    DISTINCT Network_Slice_ID,
    AVG(CAST(Latency_ms AS FLOAT)) AS avg_latency_ms
FROM [bank transaction_data]
WHERE Latency_ms IS NOT NULL
GROUP BY Network_Slice_ID
ORDER BY Network_Slice_ID;

-- Bandwidth vs transaction success
SELECT 
    Transaction_status,
    AVG(CAST(Slice_Bandwidth_Mbps AS FLOAT)) AS avg_bandwidth
FROM [bank transaction_data]
GROUP BY Transaction_Status;

--Latency Bucket
SELECT
    CASE
        WHEN Latency_ms BETWEEN 0 AND 5 THEN '0–5 ms'
        WHEN latency_ms BETWEEN 6 AND 10 THEN '6–10 ms'
        WHEN latency_ms BETWEEN 11 AND 15 THEN '11–15 ms'
        WHEN latency_ms BETWEEN 16 AND 20 THEN '16–20 ms'
        ELSE '20+ ms'
    END AS latency_bucket,
    COUNT(*) AS failed_transactions
FROM [bank transaction_data]
WHERE transaction_status = 'Failed'
GROUP BY Latency_ms
ORDER BY failed_transactions DESC;

-- Device & Behavior Analysis
-- Transaction count by device
SELECT 
    Device_used,
    COUNT(transaction_id) AS device_used
FROM [bank transaction_data]
GROUP BY Device_Used;

-- Failure rate by device (%)
-- Percentage of the total failed transactions by Mobile
SELECT 
    SUM(CASE 
            WHEN transaction_status = 'failed' AND device_used = 'mobile' 
            THEN 1 ELSE 0 
        END) * CAST(100.0 AS FLOAT) / (SELECT 
        SUM(CASE 
                WHEN transaction_status = 'failed' 
                THEN 1 
                ELSE 0 
            END)
        FROM [bank transaction_data]) AS failure_rate_by_mobile
FROM [bank transaction_data];


-- Percentage of the total failed transactions by Desktop
SELECT 
    SUM(CASE 
            WHEN transaction_status = 'failed' AND device_used = 'desktop' 
            THEN 1 ELSE 0 
        END) * CAST(100.0 AS FLOAT) / (SELECT 
        SUM(CASE 
                WHEN transaction_status = 'failed' 
                THEN 1 
                ELSE 0 
            END)
        FROM [bank transaction_data]) AS failure_rate_by_mobile
FROM [bank transaction_data];

-- Failure rate by device (%) in a table
-- Last Column indicate percentage of the total transactions that failed
SELECT 
    Device_Used,
    COUNT (*) AS total_transactions,
    SUM (CASE 
            WHEN transaction_status = 'failed' 
            THEN 1 
            ELSE 0 
        END) AS failed_transactions,
    ROUND(SUM (CASE 
            WHEN transaction_status = 'failed' 
            THEN 1 
            ELSE 0 
        END) * CAST(100.0 AS FLOAT) / COUNT (*), 2) AS failure_rate_percent
FROM [bank transaction_data]
GROUP BY device_used;

-- Top 10 Senders
SELECT TOP 10
    Sender_Account_ID, 
    SUM(CAST(transaction_amount AS FLOAT)) AS total_transactions
FROM [bank transaction_data]
GROUP BY Sender_Account_ID
ORDER BY total_transactions desc


-- Top 5 Receivers
SELECT TOP 5
    Receiver_Account_ID, 
    SUM(CAST(transaction_amount AS FLOAT)) AS total_transactions
FROM [bank transaction_data]
GROUP BY Receiver_Account_ID
ORDER BY total_transactions desc

