--- Task 1: Final Validation of SQL Outputs against Raw CSV Sums

USE EcoStyle_Marketing;

-- Final data verification ledger
SELECT 
    'Campaign Table Spend Summary' AS checklist_item,
    COUNT(DISTINCT campaign_id) AS total_count,
    SUM(budget_spend) AS financial_sum
FROM campaigns

UNION ALL

SELECT 
    'Raw Customers Row Volume',
    COUNT(DISTINCT customer_id),
    NULL
FROM customers

UNION ALL

SELECT 
    'Raw Transactions Financial Ledger',
    COUNT(DISTINCT t.transaction_id),
    SUM(t.gross_revenue)
FROM transactions t -- Added the missing table alias 't' here
WHERE t.refund_flag = 0 OR t.refund_flag IS NULL

UNION ALL

SELECT 
    'Master Attribution Connected View Analytics',
    COUNT(DISTINCT transaction_id),
    SUM(gross_revenue)
FROM Master_Attribution;

SELECT * FROM Master_Attribution;