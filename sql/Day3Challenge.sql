USE ecostyle_marketing;

SET SQL_SAFE_UPDATES = 0;
-- Update Transactions: set null revenues or discounts to 0.00
UPDATE transactions
SET 
    gross_revenue = IFNULL(gross_revenue, 0.00),
    discount_applied = IFNULL(discount_applied, 0.00);

-- Verify the cleanup
SELECT 
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN gross_revenue IS NULL THEN 1 ELSE 0 END) AS null_revenues
FROM transactions;

SELECT distinct(channel) FROM campaigns;


SELECT event_id
FROM events
GROUP BY event_id
HAVING COUNT(*) > 1;

