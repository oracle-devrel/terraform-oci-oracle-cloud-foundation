-- =============================================================================
-- Oracle Database 26ai - DDL Creation Script
-- Tables: PRODUCT_CATALOG,
--         CUSTOMER_ANALYTICS_KPI
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Table: PRODUCT_CATALOG
-- Auxiliary table
-- -----------------------------------------------------------------------------
CREATE TABLE product_catalog (
    sku                VARCHAR2(64),
    product_name       VARCHAR2(64),
    brand              VARCHAR2(64),
    gender             VARCHAR2(64),
    category           VARCHAR2(64),
    subcategory        VARCHAR2(64),
    color              VARCHAR2(64),
    pattern            VARCHAR2(64),
    material           VARCHAR2(64),
    sizes_available    VARCHAR2(64),
    fit                VARCHAR2(64),
    price_usd          NUMBER,
    discount_percent   NUMBER,
    country_of_origin  VARCHAR2(64),
    in_stock           VARCHAR2(64),
    stock_quantity     NUMBER,
    fashion_trend_2025 VARCHAR2(256)
);


-- -----------------------------------------------------------------------------
-- Table: CUSTOMER_ANALYTICS_KPI
-- Table created to be uploaded in Databricks
-- -----------------------------------------------------------------------------
CREATE TABLE customer_analytics_kpi (
    customer_id                NUMBER(38),
    full_name                  VARCHAR2(255 CHAR),
    email                      VARCHAR2(255 CHAR),
    gender                     VARCHAR2(64 CHAR),
    date_of_birth              DATE,
    age                        NUMBER(38),
    phone_number               VARCHAR2(50 CHAR),
    account_created_date       TIMESTAMP(6),
    customer_tenure_days       NUMBER(38),
    loyalty_tier               VARCHAR2(50 CHAR),
    loyalty_points             NUMBER(38),
    email_verified             NUMBER(1),
    sms_opt_in                 NUMBER(1),
    total_orders               NUMBER(38),
    lifetime_value             NUMBER,
    average_order_value        NUMBER,
    last_order_date            DATE,
    days_since_last_order      NUMBER(38),
    preferred_store            VARCHAR2(255 CHAR),
    order_frequency            NUMBER,
    is_active_customer         NUMBER(1),
    customer_segment           VARCHAR2(100 CHAR),
    newsletter_subscribed      NUMBER(1),
    promotional_emails         NUMBER(1),
    marketing_categories_count NUMBER(38),
    preferred_style            VARCHAR2(100 CHAR),
    favorite_colors_count      NUMBER(38),
    favorite_brands_count      NUMBER(38),
    city                       VARCHAR2(100 CHAR),
    state                      VARCHAR2(100 CHAR),
    country                    VARCHAR2(100 CHAR),
    CONSTRAINT pk_customer_analytics_kpi PRIMARY KEY (customer_id)
);


exit;
/
