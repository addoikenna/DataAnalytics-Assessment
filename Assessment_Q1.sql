/*
--------------------------------------------------------------------------------
Question_1: High-Value Customers with Multiple Products (Cross-Selling Opportunity)

Objective:
Identify customers who have at least one funded savings plan (is_regular_savings = 1)
and at least one funded investment plan (is_a_fund = 1). Results are sorted by 
total deposit value in Naira to highlight high-value customers for cross-sell targeting.

Enhancement:
Counts distinct funded plans (not transactions) to prevent duplication.
Early filtering on confirmed_amount > 0 improves performance.

Note:
- confirmed_amount is stored in kobo, so we divide by 100 to convert to naira.
- Only funded plans (those with at least one positive transaction) are considered.
--------------------------------------------------------------------------------
*/


WITH funded_plans AS (
    SELECT 
        p.owner_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        p.id AS plan_id,
        p.is_regular_savings,
        p.is_a_fund,
        s.confirmed_amount
    FROM 
        adashi_staging.plans_plan p
    INNER JOIN 
        adashi_staging.users_customuser u ON u.id = p.owner_id
    INNER JOIN 
        adashi_staging.savings_savingsaccount s ON p.id = s.plan_id
    WHERE 
        s.confirmed_amount > 0
),
categorized_customers AS (
    SELECT 
        owner_id,
        name,
        COUNT(DISTINCT CASE WHEN is_regular_savings = 1 THEN plan_id END) AS savings_count,
        COUNT(DISTINCT CASE WHEN is_a_fund = 1 THEN plan_id END) AS investment_count
    FROM 
	funded_plans
    GROUP BY 
	owner_id, name
),
total_deposit AS (
    SELECT 
        owner_id,
        ROUND(SUM(confirmed_amount) / 100.0, 2) AS total_deposits -- divide by 100 to convert from kobo to naira
    FROM 
	funded_plans
    GROUP BY 
	owner_id
)
SELECT 
    c.owner_id,
    c.name,
    c.savings_count,
    c.investment_count,
    t.total_deposits
FROM 
    categorized_customers c
JOIN 
    total_deposit t ON c.owner_id = t.owner_id
WHERE 
    c.savings_count > 0 AND c.investment_count > 0
ORDER BY 
    t.total_deposits DESC;
