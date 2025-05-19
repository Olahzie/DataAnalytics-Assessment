-- ===============================================
-- Summary Report: Transaction Frequency Analysis
-- Scenario: The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).
-- Task: Calculate the average number of transactions per customer per month and categorize them:
-- Description:
--   - Get monthly transaction counts per user
--   - Calculate average transactions per customer per month (including those with zeros txn)
--   - Categorize each customer
--   - Outputs: Frequency_category, customer_count, avg_txn_per_month
-- ===============================================


-- Step 1: Get monthly transaction counts per user
WITH monthly_txns AS (
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,
        COUNT(*) AS monthly_txn_count
    FROM savings_savingsaccount
    GROUP BY owner_id, txn_month
),

-- Step 2: Calculate average transactions per customer per month (including zeros)
avg_txns AS (
    SELECT
        u.id AS owner_id,
        ROUND(AVG(COALESCE(m.monthly_txn_count, 0)), 2) AS avg_transactions_per_month
    FROM users_customuser u
    LEFT JOIN monthly_txns m ON u.id = m.owner_id
    GROUP BY u.id
),

-- Step 3: Categorize each customer
categorized AS (
    SELECT
        owner_id,
        avg_transactions_per_month,
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM avg_txns
)

-- Step 4: Final summary
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM categorized
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');





