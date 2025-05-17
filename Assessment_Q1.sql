/*
--------------------------------------------------------------------------------
Question_1: High-Value Customers with Multiple Products (Cross-Selling Opportunity)

Objective:
Identify customers who have at least one funded savings plan (is_regular_savings = 1)
and at least one funded investment plan (is_a_fund = 1). Results are sorted by 
total deposit value in Naira to highlight high-value customers for cross-sell targeting.

Enhancement:
Filtered out records where `confirmed_amount <= 0` at the JOIN stage to minimize noise
and improve performance, assuming only positive inflows are relevant.

Note:
- `confirmed_amount` is stored in kobo, so we divide by 100 to convert to naira.
- Only funded transactions are considered.
--------------------------------------------------------------------------------
*/

WITH customer_plans AS (
    SELECT 
        u.id AS owner_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        p.id AS plan_id,
        p.is_regular_savings,
        p.is_a_fund,
        s.confirmed_amount
    FROM
        adashi_staging.users_customuser u
    INNER JOIN 
        adashi_staging.plans_plan p ON u.id = p.owner_id
    INNER JOIN 
        adashi_staging.savings_savingsaccount s 
            ON p.id = s.plan_id AND s.confirmed_amount > 0
),
customers_category AS (
    SELECT 
        owner_id,
        name,
        SUM(CASE WHEN is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,
        SUM(CASE WHEN is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count,
        ROUND(SUM(confirmed_amount) / 100.0, 2) AS total_deposit_naira
    FROM customer_plans
    GROUP BY owner_id, name
)
SELECT 
    owner_id,
    name,
    savings_count,
    investment_count,
    total_deposit_naira
FROM 
    customers_category
WHERE 
    savings_count > 0 AND investment_count > 0
ORDER BY 
    total_deposit_naira DESC;
