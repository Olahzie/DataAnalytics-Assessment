
-- ===============================================
-- Summary Report: High-Value Customers with Multiple Products
-- Scenario: The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
-- Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.
-- Description:
--   - Aggregates total confirmed deposits from savings accounts
--   - Counts number of savings and investment plans per user
--   - Filters to users who have BOTH savings and investment plans and its funded
--   - Outputs: User ID, Name, Savings Count, Investment Count, Total Deposit
-- ===============================================

-- CTE 1: Summarize successful savings transactions per user
WITH savings_summary AS (
    SELECT 
        owner_id,
        SUM(confirmed_amount) AS total_deposit
    FROM savings_savingsaccount
    WHERE transaction_status = 'success'  -- Only include successful transactions
    GROUP BY owner_id
),

-- CTE 2: Summarize number of saving and investment plans per user
plans_summary AS (
    SELECT
        owner_id,
        COUNT(CASE WHEN is_a_fund = 1 AND amount > 0 THEN 1 END) AS investment_count,
        COUNT(CASE WHEN is_regular_savings = 1 AND amount > 0 THEN 1 END) AS saving_count
    FROM plans_plan
    WHERE amount > 0  -- Exclude user with unfunded plans
    GROUP BY owner_id
)

-- Final query: Join CTEs with user data and filter to users with both plan types
SELECT 
    u.id AS owner_id,
    CONCAT_WS(' ', u.first_name, u.last_name) AS name,
    p.saving_count,
    p.investment_count,
    s.total_deposit
FROM users_customuser u
INNER JOIN savings_summary s ON u.id = s.owner_id
INNER JOIN plans_summary p ON u.id = p.owner_id
WHERE p.saving_count > 0 AND p.investment_count > 0  -- Only users with both plan types
ORDER BY s.total_deposit DESC;  -- Sort by deposit amount (highest first)



