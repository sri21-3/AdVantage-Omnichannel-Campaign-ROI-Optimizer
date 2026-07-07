USE EcoStyle_Marketing;

-- Create the master aggregation summary
SELECT 
    c.channel AS marketing_platform,
    
    -- 1. Grab the exact platform spend from our dedicated dimensions
    spend_lookup.total_platform_spend,
    
    -- 2. Financial Metrics from our transaction fact data
    ROUND(SUM(t.gross_revenue), 2) AS total_revenue_generated,
    COUNT(DISTINCT t.transaction_id) AS total_completed_orders,
    
    -- 3. Performance Aggregations (ROAS & AOV)
    ROUND(SUM(t.gross_revenue) / spend_lookup.total_platform_spend, 2) AS calculated_roas,
    ROUND(SUM(t.gross_revenue) / COUNT(DISTINCT t.transaction_id), 2) AS average_order_value_aov
FROM transactions t
JOIN campaigns c 
    ON t.campaign_id = c.campaign_id
-- This subquery locks down the exact calibrated spend per channel ($200k, $150k, $150k)
JOIN (
    SELECT channel, SUM(budget_spend) AS total_platform_spend 
    FROM campaigns 
    GROUP BY channel
) spend_lookup 
    ON c.channel = spend_lookup.channel
-- Filter out any active or processed refunds to keep revenue projections accurate
WHERE t.refund_flag = 0 OR t.refund_flag IS NULL
GROUP BY c.channel, spend_lookup.total_platform_spend
ORDER BY calculated_roas DESC;


USE EcoStyle_Marketing;

-- =========================================================================
-- SPOT CHECK SUITE: MANUAL METRICS FOR DOUBLE-CHECKING VERIFICATION
-- =========================================================================

-- 1. Spot checking Google Ads explicitly
SELECT 
    'Google Ads' AS platform_check,
    (SELECT SUM(budget_spend) FROM campaigns WHERE channel = 'Google Ads') AS manual_spend,
    SUM(t.gross_revenue) AS manual_revenue,
    COUNT(DISTINCT t.transaction_id) AS manual_orders,
    ROUND(SUM(t.gross_revenue) / (SELECT SUM(budget_spend) FROM campaigns WHERE channel = 'Google Ads'), 2) AS manual_roas
FROM transactions t
JOIN campaigns c ON t.campaign_id = c.campaign_id
WHERE c.channel = 'Google Ads' AND (t.refund_flag = 0 OR t.refund_flag IS NULL)

UNION ALL

-- 2. Spot checking Facebook explicitly
SELECT 
    'Facebook' AS platform_check,
    (SELECT SUM(budget_spend) FROM campaigns WHERE channel = 'Facebook') AS manual_spend,
    SUM(t.gross_revenue) AS manual_revenue,
    COUNT(DISTINCT t.transaction_id) AS manual_orders,
    ROUND(SUM(t.gross_revenue) / (SELECT SUM(budget_spend) FROM campaigns WHERE channel = 'Facebook'), 2) AS manual_roas
FROM transactions t
JOIN campaigns c ON t.campaign_id = c.campaign_id
WHERE c.channel = 'Facebook' AND (t.refund_flag = 0 OR t.refund_flag IS NULL)

UNION ALL

-- 3. Spot checking TikTok explicitly
SELECT 
    'TikTok' AS platform_check,
    (SELECT SUM(budget_spend) FROM campaigns WHERE channel = 'TikTok') AS manual_spend,
    SUM(t.gross_revenue) AS manual_revenue,
    COUNT(DISTINCT t.transaction_id) AS manual_orders,
    ROUND(SUM(t.gross_revenue) / (SELECT SUM(budget_spend) FROM campaigns WHERE channel = 'TikTok'), 2) AS manual_roas
FROM transactions t
JOIN campaigns c ON t.campaign_id = c.campaign_id
WHERE c.channel = 'TikTok' AND (t.refund_flag = 0 OR t.refund_flag IS NULL);