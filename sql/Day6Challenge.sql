USE EcoStyle_Marketing;

WITH WeeklyConversions AS (
    SELECT 
        -- Task 2: Truncate/group timestamps into clean Year-Week strings
        DATE_FORMAT(t.timestamp, '%Y-%u') AS transaction_year_week,
        c.channel AS marketing_platform,
        COUNT(DISTINCT t.transaction_id) AS weekly_conversions,
        SUM(t.gross_revenue) AS weekly_revenue
    FROM transactions t
    JOIN campaigns c ON t.campaign_id = c.campaign_id
    WHERE t.refund_flag = 0 OR t.refund_flag IS NULL
    GROUP BY DATE_FORMAT(t.timestamp, '%Y-%u'), c.channel
)
SELECT 
    transaction_year_week,
    marketing_platform,
    weekly_conversions,
    weekly_revenue,
    
    -- Task 1: Window Function to pull the previous week's conversions for trend analysis
    LAG(weekly_conversions, 1) OVER(
        PARTITION BY marketing_platform 
        ORDER BY transaction_year_week
    ) AS previous_week_conversions,
    
    -- Window Function to calculate dynamic running total revenue per platform
    ROUND(SUM(weekly_revenue) OVER(
        PARTITION BY marketing_platform 
        ORDER BY transaction_year_week
    ), 2) AS running_total_revenue
FROM WeeklyConversions
ORDER BY marketing_platform, transaction_year_week;


--------Peak perfomance 
USE EcoStyle_Marketing;

WITH MonthlyPerformance AS (
    SELECT 
        -- 1. Date Truncation: Forces every timestamp to the 1st day of its respective month
        STR_TO_DATE(DATE_FORMAT(t.timestamp, '%Y-%m-01'), '%Y-%m-%d') AS truncated_month,
        c.channel AS marketing_platform,
        COUNT(DISTINCT t.transaction_id) AS total_conversions,
        ROUND(SUM(t.gross_revenue), 2) AS total_revenue,
        
        -- Pulls the fixed platform monthly budget allocation for relative performance evaluation
        (SELECT SUM(budget_spend) FROM campaigns WHERE channel = c.channel) / 12 AS estimated_monthly_spend
    FROM transactions t
    JOIN campaigns c ON t.campaign_id = c.campaign_id
    WHERE t.refund_flag = 0 OR t.refund_flag IS NULL
    GROUP BY STR_TO_DATE(DATE_FORMAT(t.timestamp, '%Y-%m-01'), '%Y-%m-%d'), c.channel
),
RankedPeriods AS (
    SELECT 
        truncated_month,
        marketing_platform,
        total_conversions,
        total_revenue,
        -- Calculate a localized monthly efficiency rating
        ROUND(total_revenue / estimated_monthly_spend, 2) AS monthly_efficiency_score,
        
        -- 2. Window function to rank the peak revenue months for each platform individually
        DENSE_RANK() OVER (
            PARTITION BY marketing_platform 
            ORDER BY total_revenue DESC
        ) AS revenue_peak_rank
    FROM MonthlyPerformance
)
-- 3. Filter for the Top 3 Peak Performance Periods per platform
SELECT 
    revenue_peak_rank AS peak_rank,
    DATE_FORMAT(truncated_month, '%M %Y') AS peak_month_period,
    marketing_platform,
    total_conversions,
    total_revenue,
    monthly_efficiency_score AS estimated_roas_multiplier
FROM RankedPeriods
WHERE revenue_peak_rank <= 3
ORDER BY marketing_platform, revenue_peak_rank;


--- Anlaysing week end sales
USE EcoStyle_Marketing;

SELECT 
    c.channel AS marketing_platform,
    DAYNAME(t.timestamp) AS day_of_week,
    COUNT(DISTINCT t.transaction_id) AS total_weekend_orders,
    ROUND(SUM(t.gross_revenue), 2) AS total_weekend_revenue,
    ROUND(AVG(t.gross_revenue), 2) AS average_order_value_aov,
    
    -- Natively calculates statistical variance of sales value to track spikes/dips
    ROUND(VAR_SAMP(t.gross_revenue), 2) AS transaction_value_variance,
    ROUND(STDDEV_SAMP(t.gross_revenue), 2) AS transaction_value_standard_deviation
FROM transactions t
JOIN campaigns c ON t.campaign_id = c.campaign_id
-- 1 = Sunday, 6 = Friday, 7 = Saturday in MySQL standard DAYOFWEEK mapping
WHERE DAYOFWEEK(t.timestamp) IN (1, 6, 7)
  AND (t.refund_flag = 0 OR t.refund_flag IS NULL)
GROUP BY c.channel, DAYNAME(t.timestamp), DAYOFWEEK(t.timestamp)
ORDER BY c.channel, FIELD(day_of_week, 'Friday', 'Saturday', 'Sunday');