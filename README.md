# SQL Data Insights Project

## Overview

This project contains solutions to a series of SQL-based data analysis tasks performed on a customer savings and investment platform. The analysis was conducted using **MySQL Workbench**, based on a database snapshot provided in a `.SQL` file. The queries provide insights into customer behavior, transaction patterns, account inactivity, and estimated customer lifetime value.

---

## Environment

- **SQL Tool Used:** MySQL Workbench  
- **Database Source:** Provided `.SQL` file imported into MySQL

---

## Task-by-Task Explanations

### 1. High-Value Customers with Multiple Products

**Objective:**  
Identify customers who have both a funded savings plan and a funded investment plan, and rank them by total deposits.

**Approach:**

- Joined the `users_customuser`, `plans_plan`, and `savings_savingsaccount` tables.
- Filtered for records where `is_regular_savings = 1` (savings) and `is_a_fund = 1` (investment).
- Grouped by customer and counted each plan type, ensuring both were present.
- Summed confirmed inflows (`confirmed_amount`) and converted them from kobo to naira for readability.
- Sorted the results by total deposits in descending order.

---

### 2. Transaction Frequency Analysis

**Objective:**  
Classify customers into frequency buckets based on their average monthly transaction counts.

**Approach:**

- Counted the total number of transactions per user from the `savings_savingsaccount` table.
- Computed the date range from the first to the last transaction per user to estimate the months active.
- Divided the total transactions by active months to calculate the average monthly frequency.
- Categorized users into “High”, “Medium”, or “Low” frequency tiers.
- Aggregated and displayed average transaction frequency and customer count per tier.

---

### 3. Account Inactivity Alert

**Objective:**  
Flag active savings or investment plans with no transactions in over one year.

**Approach:**

- Joined `plans_plan` and `savings_savingsaccount`.
- Focused only on savings (`is_regular_savings = 1`) and investment (`is_a_fund = 1`) plans.
- Identified the most recent transaction per plan using `MAX()` on `transaction_date`.
- Filtered out any plan where the latest transaction is older than 365 days.
- Calculated inactivity duration in days.

---

### 4. Customer Lifetime Value (CLV) Estimation

**Objective:**  
Estimate customer lifetime value based on account tenure and total transaction volume.

**Assumptions:**

- Profit per transaction = 0.1% of transaction value.
- CLV formula =  
  `(total_transactions / tenure_months) * 12 * avg_profit_per_transaction`

**Approach:**

- Joined user and savings data to calculate total transaction inflow per customer.
- Estimated tenure from user signup date (`date_joined`) to the latest transaction.
- Applied the CLV formula after converting total inflows from kobo to naira.
- Ranked customers by their estimated CLV.

---

## Challenges Encountered

- **Reading the .SQL File:**  
  The provided SQL dump had to be carefully loaded into MySQL Workbench. For someone unfamiliar with database import processes, this step required technical setup and troubleshooting, especially around data types and relational integrity.

- **Missing `name` Field:**  
  The `name` field in `users_customuser` was consistently null. To handle this, the `first_name` and `last_name` columns were concatenated in all relevant outputs to form a usable full name.

- **Identifying Active Accounts:**  
  Determining what qualified as an “active” account required interpreting implicit business logic. We narrowed the scope to only savings and investment plans using `is_regular_savings` and `is_a_fund` flags, respectively and also where `confirmed_amount` is not "Null".

- **Data in Kobo:**  
  All monetary amounts were stored in kobo. For human readability, all calculations involving money were converted to naira (by dividing by 100), especially for metrics like total deposit and CLV.

---

## Conclusion

This project showcases the effective use of SQL to extract business insights from financial data. Each query was optimized for clarity and correctness, with attention paid to join logic, aggregation, and filtering to meet specific stakeholder objectives. The project also involved making thoughtful assumptions and dealing with common real-world data challenges such as missing fields and unit conversions.
