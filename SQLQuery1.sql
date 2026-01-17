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
    COUNT (*) * 100.0 / (SELECT 
        COUNT(*) 
        FROM [bank transaction_data]) 
    AS success_rate
FROM [bank transaction_data]
WHERE Transaction_Status = 'success';

-- Fraud Analysis
-- Fraud Rate (%)
SELECT 
    COUNT (*) * 100.0 / (SELECT 
        COUNT (*) 
        FROM [bank transaction_data])
    AS total_fraud_rate
FROM [bank transaction_data]
WHERE Fraud_Flag = 1;

-- Fraud Rate by Transaction Type
-- Transfer
SELECT 
    COUNT (*) * 100.0 / (SELECT 
        COUNT (*) 
        FROM [bank transaction_data])
    AS fraud_rate_by_transfer
FROM [bank transaction_data]
WHERE Fraud_Flag = 1
AND Transaction_Type = 'transfer';

-- Withdrawal
SELECT 
    COUNT (*) * 100.0 / (SELECT 
        COUNT (*) 
        FROM [bank transaction_data])
    AS fraud_rate_bt_withdrawal
FROM [bank transaction_data]
WHERE Fraud_Flag = 1
AND Transaction_Type = 'withdrawal';

-- Deposit
SELECT 
    COUNT (*) * 100.0 / (SELECT 
        COUNT (*) 
        FROM [bank transaction_data])
    AS fraud_rate_by_deposit
FROM [bank transaction_data]
WHERE Fraud_Flag = 1
AND Transaction_Type = 'deposit';


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
-- Mobile
SELECT 
    COUNT (*) * 100.0 / (SELECT 
        COUNT (*)
        FROM [bank transaction_data]) AS failure_rate_by_mobile
FROM [bank transaction_data] 
WHERE  Transaction_Status = 'failed'
AND Device_Used = 'mobile';

-- Desktop
SELECT 
    COUNT (*) * 100.0 / (SELECT 
        COUNT (*)
        FROM [bank transaction_data]) AS failure_rate_by_desktop
FROM [bank transaction_data] 
WHERE  Transaction_Status = 'failed'
AND Device_Used = 'desktop';

-- Failure rate by device (%) in a table
SELECT 
    Device_Used,
    COUNT (*) AS total_transaction,
    SUM (CASE 
        WHEN transaction_status = 'failed' THEN 1 ELSE 0 END) AS failed_transaction,
    SUM (CASE 
        WHEN transaction_status = 'failed' THEN 1 ELSE 0 END) * 100.0 / COUNT (*) AS failure_rate_percent
FROM [bank transaction_data]
GROUP BY device_used;