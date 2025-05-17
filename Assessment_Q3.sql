/*
--------------------------------------------------------------------------------
Question_3: Account Inactivity Alert (Savings & Investment)

Objective:
Identify all savings and investment plans that have received no inflow transactions
(i.e., confirmed_amount > 0) in the last 365 days. This helps the operations team flag dormant plans
for intervention or follow-up.

Approach:
1. Focus only on Savings and Investment plans (`is_regular_savings = 1` or `is_a_fund = 1`).
2. Join with `savings_savingsaccount` using only inflow transactions (`confirmed_amount > 0`).
3. Group by plan and calculate the most recent transaction date.
4. Flag plans with no transactions in the last 1 year, or no transactions at all.

Optimizations:
- Early filter on plan type and transaction amount to reduce rows joined.
- Used CTE to avoid recalculating `MAX(transaction_date)` in both `SELECT` and `HAVING`.
- Avoided unnecessary casting and improved function efficiency.

Note:
- Only plans with at least one of `is_regular_savings` or `is_a_fund` flagged are considered.
- `confirmed_amount` is assumed to be in kobo (as per schema context).
--------------------------------------------------------------------------------
*/

WITH last_transactions AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
        END AS type,
        MAX(s.transaction_date) AS last_transaction_date
    FROM
        adashi_staging.plans_plan p
    LEFT JOIN
        adashi_staging.savings_savingsaccount s
        ON p.id = s.plan_id
        AND s.confirmed_amount > 0
    WHERE
        p.is_regular_savings = 1 OR p.is_a_fund = 1
    GROUP BY
        p.id, p.owner_id, p.is_regular_savings, p.is_a_fund
)
SELECT
    plan_id,
    owner_id,
    type,
    DATE(last_transaction_date) AS last_transaction_date,
    DATEDIFF(CURRENT_DATE, last_transaction_date) AS inactivity_days
FROM
    last_transactions
WHERE
    last_transaction_date IS NULL 
    OR last_transaction_date <= DATE_SUB(CURRENT_DATE, INTERVAL 365 DAY)
ORDER BY
    inactivity_days DESC;
