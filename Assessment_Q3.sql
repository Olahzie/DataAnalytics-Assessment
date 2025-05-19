
-- ===============================================
-- Summary Report: Account Inactivity Alert
-- Scenario: The ops team wants to flag accounts with no inflow transactions for over one year.
-- Task:  Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days)
-- Description:
--   - CTE to get the last successful transaction date per savings account
--   - Join with plans table to get account type and filter by inactivity
--   - Join to with the plan to get the plans type & Only include accounts with no inflow in the last 365 days
--   - Outputs: plan_id, owner_id, type, last_transaction_date, inactivity_days
-- ===============================================

-- Step 1: CTE to get the last successful transaction date per savings account
WITH latest_tx AS (
    SELECT
        plan_id,
        owner_id,
        MAX(transaction_date) AS last_transaction_date,
        DATEDIFF(CURDATE(), MAX(transaction_date)) AS inactivity_days
    FROM savings_savingsaccount
    WHERE transaction_status = 'success'
    GROUP BY plan_id, owner_id
)
-- Step 2: Join with plans table to get account type and filter by inactivity
SELECT
    tx.plan_id AS plan_id,
    tx.owner_id AS owner_id,
    CASE   -- Determine the type of plan based on flags
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investments'
        ELSE 'Other'
    END AS type,
    tx.last_transaction_date AS last_transaction_date,
    tx.inactivity_days AS inactivity_days
FROM latest_tx tx
INNER JOIN plans_plan p ON tx.plan_id = p.id     -- inner Join with the plan table to get only active customer
WHERE tx.inactivity_days > 365;      -- Filter: Only include accounts with no inflow in the last 365 days







