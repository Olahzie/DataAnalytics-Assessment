# DataAnalytics-Assessment

# SQL Query Solutions:

This repository contains SQL solutions to the Cowrywise DataAnalytics-Assessment, focusing on customer activity, account inactivity, transaction behavior, and customer lifetime value (CLV) estimation. Each query is written from  MySQL environment.

---

## Table of Contents

1. [Transaction Frequency Classification](https://github.com/Olahzie/DataAnalytics-Assessment/blob/main/Assessment_Q1.sql)
2. [Inactivity Flag for Savings and Investments](https://github.com/Olahzie/DataAnalytics-Assessment/blob/main/Assessment_Q2.sql)
3. [CLV Estimation Based on Tenure and Transactions](https://github.com/Olahzie/DataAnalytics-Assessment/blob/main/Assessment_Q3.sql)
4. [SQL Techniques Used](https://github.com/Olahzie/DataAnalytics-Assessment/blob/main/Assessment_Q4.sql)
5. Challenges and Resolution

---

## Entity Relationship Diagram (ERD)

![ERD Diagram](https://github.com/Olahzie/DataAnalytics-Assessment/blob/main/ERD%20Diagram.png)



## 1. Transaction Frequency Classification

**Task:**  
Calculate the average number of transactions per customer per month and categorize them into:
- High Frequency (≥10 transactions/month)
- Medium Frequency (3–9 transactions/month)
- Low Frequency (≤2 transactions/month)

**Approach:**  
- Use a subquery (or CTE) to calculate monthly transaction counts.
- Join with the `users_customuser` table using a `LEFT JOIN` to ensure all users are included—even those with zero transactions.
- Use `COALESCE` to treat `NULL` transaction counts as zero.
- Group customers based on frequency using `CASE WHEN`.

---

## 2. Inactivity Flag for Savings and Investments

**Task:**  
Identify active accounts (either savings or investments) that have had **no successful inflow transactions in the last 365 days**.

**Approach:**  
- Use a CTE to extract the latest transaction date per `plan_id` and `owner_id`.
- Calculate inactivity using `DATEDIFF(CURDATE(), MAX(transaction_date))`.
- Join with the `plans_plan` table using `INNER JOIN` on `plan_id` to access flags like `is_regular_savings` and `is_a_fund`.
- Use `CASE` to classify each plan as `Savings`, `Investments`, or `Other`.

---

## 3. CLV Estimation Based on Tenure and Transactions

**Task:**  
Estimate the **Customer Lifetime Value (CLV)** using the formula:

CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction

markdown
Copy
Edit

**Assumptions:**
- Profit per transaction is **0.1%** of `confirmed_amount`.
- Customers are evaluated even if they have not transacted.

**Approach:**  
- CTE #1 (`customer_tx`) aggregates total transactions and average profit per transaction.
- CTE #2 (`tenure_cte`) calculates tenure (in months) since account signup.
- `LEFT JOIN` ensures inclusion of customers with no transaction history.
- Use `COALESCE` to handle potential nulls and avoid division by zero.

---

## 4. SQL Techniques Used

- **CTEs** for clean logical separation of steps (`WITH` clause).
- **JOINs:**
  - `LEFT JOIN` to include all users or accounts.
  - `INNER JOIN` to fetch related plan metadata.
- **Date Functions:**
  - `DATEDIFF()` to compute inactivity in days.
  - `TIMESTAMPDIFF()` to compute tenure in months.
- **`CASE` Statements** to categorize data like frequency level or plan type.
- **`COALESCE()`** for null handling, particularly when users have no transactions.
- **`ROUND()`** for formatting estimated values like CLV.

---

## 5. Challenges and Resolutions

### a. Including Users with No Transactions
- **Challenge:** Using `INNER JOIN` excluded non-transacting users.
- **Resolution:** Switched to `LEFT JOIN` and applied `COALESCE` for null-safe calculations.

### b. Avoiding Division by Zero
- **Challenge:** Tenure could be 0 months for new users.
- **Resolution:** Used `COALESCE(tenure_months, 1)` to ensure minimum value of 1 month.

### c. Handling Inflow-Only Conditions
- **Challenge:** Only savings accounts had inflow values while investment accounts did not.
- **Resolution:** Focused inflow checks on `savings_savingsaccount` and joined using `plan_id`.

### d. Code Readability and Maintainability
- **Challenge:** Large queries were difficult to manage or debug.
- **Resolution:** Broke logic into CTEs, applied inline comments, and used clear aliasing.
