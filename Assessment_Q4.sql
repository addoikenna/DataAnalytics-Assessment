/*
--------------------------------------------------------------------------------
Question_4: Customer Lifetime Value (CLV) Estimation

Objective:
Estimate the lifetime value of each customer based on how long they've had an account
(account tenure) and their transaction volume, using a simplified profit model.

Assumptions:
- Profit per transaction is 0.1% of the transaction value.
- CLV formula used: 
    (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
- All transaction values are in kobo, so we divide by 100 to convert to naira.

Optimizations:
- Early filtering of transactions with `confirmed_amount > 0` inside the JOIN.
- Used `NULLIF` to avoid division by zero for customers who just signed up.

--------------------------------------------------------------------------------
*/


WITH valid_transactions AS (
    SELECT
        owner_id,
        confirmed_amount / 100.0 AS amount_naira  -- Convert once
    FROM
        adashi_staging.savings_savingsaccount
    WHERE
        confirmed_amount > 0
),
customer_summary AS (
    SELECT
        vt.owner_id,
        COUNT(*) AS total_transactions,
        AVG(vt.amount_naira) AS avg_transaction_naira
    FROM
        valid_transactions vt
    GROUP BY
        vt.owner_id
)
SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months,
    cs.total_transactions,
    ROUND(
        (cs.total_transactions / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE), 0)) 
        * 12 * cs.avg_transaction_naira * 0.001,
        2
    ) AS estimated_clv_naira
FROM
    adashi_staging.users_customuser u
INNER JOIN
    customer_summary cs ON u.id = cs.owner_id
ORDER BY
    estimated_clv_naira DESC;