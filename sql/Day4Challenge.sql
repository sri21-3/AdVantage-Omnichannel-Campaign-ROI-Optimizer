USE EcoStyle_Marketing;

CREATE OR REPLACE VIEW Master_Attribution AS
SELECT 
    t.transaction_id,
    t.timestamp AS transaction_time,
    t.customer_id,
    t.product_id,
    t.quantity,
    t.discount_applied,
    t.gross_revenue,
    t.refund_flag,
    c.campaign_id,
    c.channel AS marketing_platform,
    c.objective AS campaign_objective,
    e.event_id AS attribution_click_id,
    e.timestamp AS click_time,
    e.device_type,
    e.session_duration_sec
FROM transactions t
-- 1. Link to campaigns to pull clean standardized channel names
LEFT JOIN campaigns c 
    ON t.campaign_id = c.campaign_id
-- 2. Link to events to pull session context (matching the specific customer's interaction for that campaign)
LEFT JOIN events e 
    ON t.customer_id = e.customer_id 
    AND t.campaign_id = e.campaign_id
    AND e.event_type = 'purchase'; -- Isolates the specific checkout conversion event

SELECT * FROM Master_Attribution 


-- Test A: Check if any customer in your transactions table is completely missing from your master customers CRM directory
SELECT 
    COUNT(DISTINCT t.customer_id) AS transactional_customers,
    COUNT(DISTINCT CASE WHEN cust.customer_id IS NULL THEN t.customer_id END) AS unmapped_orphaned_customers
FROM transactions t
LEFT JOIN customers cust 
    ON t.customer_id = cust.customer_id;

-- Test B: Check your attribution join coverage rate inside the new view
SELECT 
    COUNT(*) AS total_sales_records,
    SUM(CASE WHEN attribution_click_id IS NULL THEN 1 ELSE 0 END) AS untracked_organic_sales,
    (SUM(CASE WHEN attribution_click_id IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS matching_attribution_rate
FROM Master_Attribution;
