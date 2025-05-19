
-- ===============================================
-- Summary Report: Customer Lifetime Value (CLV) Estimation
-- Scenario: Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).
-- Task:  For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
	   -- Account tenure (months since signup)
       -- Total transactions
       -- Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
	   -- Order by estimated CLV from highest to lowest

-- Description:
--   - CTE to aggregate transaction data per customer
--   - CTE to calculate account tenure in months since signup
--   - Join transaction and tenure data, calculate estimated CLV
--   - Outputs: customer_id, name, tenure_months, total_transactions, estimated_clv
-- ===============================================

-- Step 1: CTE to aggregate transaction data per customer
WITH customer_tx AS (
    SELECT
        owner_id AS customer_id,
        COUNT(*) AS total_transactions,
        SUM(confirmed_amount) AS total_value,
        -- 0.1% profit margin per transaction
        AVG(confirmed_amount * 0.001) AS avg_profit_per_transaction
    FROM savings_savingsaccount
    WHERE transaction_status = 'success'
    GROUP BY owner_id
),

-- Step 2: CTE to calculate account tenure in months since signup
tenure_cte AS (
    SELECT
        id AS customer_id,
        CONCAT_WS(' ', first_name, last_name) AS name,
        TIMESTAMPDIFF(MONTH, date_joined, CURDATE()) AS tenure_months
    FROM users_customuser
)
-- Step 3: Join transaction and tenure data, calculate estimated CLV
SELECT
    u.customer_id,
    u.name,
    COALESCE(u.tenure_months, 1) AS tenure_months, -- Ensure tenure is at least 1 to avoid division by zero
    COALESCE(tx.total_transactions, 0) AS total_transactions, -- Handle customers with no transactions
    ROUND(
        (COALESCE(tx.total_transactions, 0) / COALESCE(u.tenure_months, 1)) -- CLV formula: (transactions/month) * 12 * avg_profit_per_transaction
        * 12 
        * COALESCE(tx.avg_profit_per_transaction, 0),
        2
    ) AS estimated_clv
FROM tenure_cte u
LEFT JOIN customer_tx tx ON u.customer_id = tx.customer_id -- Use LEFT JOIN to include customers who have never transacted
ORDER BY estimated_clv DESC; -- Order by highest estimated CLV
