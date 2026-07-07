USE EcoStyle_Marketing;

CREATE OR REPLACE VIEW View_CAC_By_Platform AS
SELECT 
    c.acquisition_channel AS marketing_platform,
    -- Pulls total spend by summing the campaigns mapped to that network
    spend_lookup.total_ad_spend,
    COUNT(DISTINCT c.customer_id) AS total_customers_acquired,
    -- CAC = Total Spend / Total Unique Acquired Customers
    ROUND(spend_lookup.total_ad_spend / COUNT(DISTINCT c.customer_id), 2) AS customer_acquisition_cost_cac
FROM customers c
JOIN (
    SELECT channel, SUM(budget_spend) AS total_ad_spend 
    FROM campaigns 
    GROUP BY channel
) spend_lookup 
    ON c.acquisition_channel = spend_lookup.channel
GROUP BY c.acquisition_channel, spend_lookup.total_ad_spend;

-- Preview the CAC View results
SELECT * FROM View_CAC_By_Platform;

--- Average Order Value (AOV) per channel
USE EcoStyle_Marketing;

CREATE OR REPLACE VIEW View_AOV_By_Platform AS
SELECT 
    c.channel AS marketing_platform,
    ROUND(SUM(t.gross_revenue), 2) AS total_net_revenue,
    COUNT(DISTINCT t.transaction_id) AS total_orders,
    -- AOV = Total Net Revenue / Total Completed Orders
    ROUND(SUM(t.gross_revenue) / COUNT(DISTINCT t.transaction_id), 2) AS average_order_value_aov
FROM transactions t
JOIN campaigns c ON t.campaign_id = c.campaign_id
WHERE t.refund_flag = 0 OR t.refund_flag IS NULL
GROUP BY c.channel;

-- Preview the AOV View results
SELECT * FROM View_AOV_By_Platform;

----Export aggregated SQL tables for Python environment

SELECT 
    aov.marketing_platform,
    cac.total_ad_spend,
    cac.total_customers_acquired,
    cac.customer_acquisition_cost_cac,
    aov.total_net_revenue,
    aov.total_orders,
    aov.average_order_value_aov,
    ROUND(aov.total_net_revenue / cac.total_ad_spend, 2) AS return_on_ad_spend_roas
FROM View_AOV_By_Platform aov
JOIN View_CAC_By_Platform cac 
    ON aov.marketing_platform = cac.marketing_platform;
    
    
SELECT USER();        -- shows user@host
SELECT CURRENT_USER(); -- shows authenticated user
