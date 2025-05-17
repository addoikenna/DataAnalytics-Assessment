/*
--------------------------------------------------------------------------------
Question_2: Transaction Frequency Analysis (Customer Segmentation)

Objective:
Segment customers based on how frequently they transact using the savings system.
This helps the finance team distinguish between highly active users and occasional ones.

Frequency Buckets:
- High Frequency: ≥ 10 transactions per month
- Medium Frequency: 3 to 9 transactions per month
- Low Frequency: ≤ 2 transactions per month

Approach:
1. Aggregate transaction counts by customer and month from `savings_savingsaccount`.
2. Compute each customer's average monthly transaction volume.
3. Join with `users_customuser` to ensure even customers with no transactions are included.
4. Categorize customers based on their transaction frequency.
5. Report the number of customers and average monthly transactions per segment.

Notes:
- Only inflow transactions with a valid `transaction_date` are considered.
- The segmentation logic uses standard SQL CASE expressions.
--------------------------------------------------------------------------------
*/

WITH transactions_per_month AS (
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS month,
        COUNT(*) AS transactions_count
    FROM
        adashi_staging.savings_savingsaccount
    WHERE
        transaction_date IS NOT NULL
    GROUP BY
        owner_id,
        month
),
avg_transactions_per_customer AS (
    SELECT
        owner_id,
        AVG(transactions_count) AS avg_transactions_per_month
    FROM
        transactions_per_month
    GROUP BY
        owner_id
),
customer_transactions AS (
    SELECT
        u.id AS owner_id,
        COALESCE(a.avg_transactions_per_month, 0) AS avg_transactions_per_month
    FROM
        adashi_staging.users_customuser u
    LEFT JOIN
        avg_transactions_per_customer a ON u.id = a.owner_id
),
customers_categories AS (
    SELECT
        owner_id,
        avg_transactions_per_month,
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM
        customer_transactions
)
SELECT
    frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM
    customers_categories
GROUP BY
    frequency_category
ORDER BY
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;
