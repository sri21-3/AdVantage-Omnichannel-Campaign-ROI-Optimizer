-- 1. Create and select the database
CREATE DATABASE IF NOT EXISTS EcoStyle_Marketing;
USE EcoStyle_Marketing;

-- 2. Create Campaigns Table
CREATE TABLE campaigns (
    campaign_id INT PRIMARY KEY,
    channel VARCHAR(50),
    objective VARCHAR(100),
    start_date DATE,
    end_date DATE,
    target_segment VARCHAR(100),
    expected_uplift DECIMAL(5, 4)
);

-- 3. Create Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    signup_date DATE,
    country VARCHAR(100),
    age INT,
    gender VARCHAR(20),
    loyalty_tier VARCHAR(50),
    acquisition_channel VARCHAR(50)
);

-- 4. Create Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    category VARCHAR(100),
    brand VARCHAR(100),
    base_price DECIMAL(10, 2),
    launch_date DATE,
    is_premium BOOLEAN
);

-- 5. Create Events Table (Web Clicks / Interactions)
CREATE TABLE events (
    event_id INT PRIMARY KEY,
    timestamp DATETIME,
    customer_id INT,
    session_id VARCHAR(100),
    event_type VARCHAR(50),
    product_id INT,
    device_type VARCHAR(50),
    traffic_source VARCHAR(50),
    campaign_id INT,
    page_category VARCHAR(100),
    session_duration_sec INT,
    experiment_group VARCHAR(50)
);

-- 6. Create Transactions Table
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    timestamp DATETIME,
    customer_id INT,
    product_id INT,
    quantity INT,
    discount_applied DECIMAL(10, 2),
    gross_revenue DECIMAL(10, 2),
    campaign_id INT,
    refund_flag BOOLEAN
);

## all the tables data is imported from csv files

-- Check if any transaction points to a Customer ID that does not exist
SELECT COUNT(*) AS orphaned_transactions_customer 
FROM transactions t
LEFT JOIN customers c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL AND t.customer_id IS NOT NULL;

-- Check if any transaction points to a Campaign ID that does not exist
SELECT COUNT(*) AS orphaned_transactions_campaign
FROM transactions t
LEFT JOIN campaigns cp ON t.campaign_id = cp.campaign_id
WHERE cp.campaign_id IS NULL AND t.campaign_id IS NOT NULL;

-- Check if any web click/event points to a missing Customer ID
SELECT COUNT(*) AS orphaned_events_customer
FROM events e
LEFT JOIN customers c ON e.customer_id = c.customer_id
WHERE c.customer_id IS NULL AND e.customer_id IS NOT NULL;