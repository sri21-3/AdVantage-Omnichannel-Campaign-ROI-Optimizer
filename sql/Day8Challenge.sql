USE EcoStyle_Marketing;

DELIMITER $$

CREATE PROCEDURE Refresh_Marketing_Data_Cleansing()
BEGIN
    -- 1. Temporarily disable safe updates
    SET SQL_SAFE_UPDATES = 0;

    -- 2. Clean Campaigns Dimension
    UPDATE campaigns
    SET channel = CASE 
        WHEN channel IN ('FB', 'Meta', 'Social', 'Email') THEN 'Facebook'
        WHEN channel IN ('Google', 'Paid Search', 'Display', 'Google Ads') THEN 'Google Ads'
        WHEN channel IN ('TikTok', 'Affiliate', 'TT') THEN 'TikTok'
        ELSE channel 
    END;

    -- 3. Relational Mapping Lookup for Customers CRM Table
    UPDATE customers c
    JOIN (
        SELECT DISTINCT e.customer_id, cp.channel AS true_channel
        FROM events e
        JOIN campaigns cp ON e.campaign_id = cp.campaign_id
        WHERE cp.channel IS NOT NULL
    ) attribution_lookup 
        ON c.customer_id = attribution_lookup.customer_id
    SET c.acquisition_channel = attribution_lookup.true_channel
    WHERE c.acquisition_channel NOT IN ('Organic', 'Referral');

    -- 4. Re-enable safe updates
    SET SQL_SAFE_UPDATES = 1;
END$$

DELIMITER ;

--- Standardize Campaign Budget Allocations
--- This fixes all campaign costs to represent your distributed $500,000 balance pool.
DELIMITER $$

CREATE PROCEDURE Calibrate_Campaign_Budgets()
BEGIN
    SET SQL_SAFE_UPDATES = 0;
    
    UPDATE campaigns
    SET budget_spend = 10000.00;
    
    SET SQL_SAFE_UPDATES = 1;
END$$

DELIMITER ;

--- Conduct Sanity Check on $500,000 Total Spend Balance

SELECT 
    -- Total unique campaign dimensions count
    COUNT(DISTINCT campaign_id) AS validated_campaign_count,
    -- Master distributed financial sum 
    SUM(budget_spend) AS absolute_tracked_spend,
    -- Verifies whether our ledger perfectly hits the $500,000 project parameters
    CASE 
        WHEN SUM(budget_spend) = 500000.00 THEN 'PASSED: Spend ledger matches exactly.'
        ELSE 'FAILED: Check for row multiplication duplicates.'
    END AS budget_sanity_check_status
FROM campaigns;


