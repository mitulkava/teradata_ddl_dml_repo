-- 1. Customers
CREATE TABLE newtpcds.customers (
    customer_id     INTEGER NOT NULL,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    email           VARCHAR(100),
    city            VARCHAR(50),
    state           VARCHAR(30),
    signup_date     DATE FORMAT 'YYYY-MM-DD',
    segment         VARCHAR(20)   -- e.g. 'PREMIUM', 'STANDARD', 'BASIC'
) PRIMARY INDEX (customer_id);


-- 2. Orders
CREATE TABLE newtpcds.orders (
    order_id        INTEGER NOT NULL,
    customer_id     INTEGER,
    order_date      DATE FORMAT 'YYYY-MM-DD',
    store_id        INTEGER,
    status          VARCHAR(20),  -- e.g. 'COMPLETED', 'RETURNED', 'PENDING'
    total_amount    DECIMAL(12,2)
) PRIMARY INDEX (order_id);


-- 3. Order Items
CREATE TABLE newtpcds.order_items (
    item_id         INTEGER NOT NULL,
    order_id        INTEGER,
    product_id      INTEGER,
    quantity        INTEGER,
    unit_price      DECIMAL(10,2),
    discount_pct    DECIMAL(5,2)
) PRIMARY INDEX (item_id);


-- 4. Products
CREATE TABLE newtpcds.products (
    product_id      INTEGER NOT NULL,
    product_name    VARCHAR(100),
    category        VARCHAR(50),
    brand           VARCHAR(50),
    cost_price      DECIMAL(10,2),
    list_price      DECIMAL(10,2)
) PRIMARY INDEX (product_id);


-- 5. Stores
CREATE TABLE newtpcds.stores (
    store_id        INTEGER NOT NULL,
    store_name      VARCHAR(100),
    city            VARCHAR(50),
    state           VARCHAR(30),
    region          VARCHAR(20),  -- e.g. 'NORTH', 'SOUTH', 'EAST', 'WEST'
    open_date       DATE FORMAT 'YYYY-MM-DD'
) PRIMARY INDEX (store_id);


-- 6. Returns
CREATE TABLE newtpcds.returns (
    return_id       INTEGER NOT NULL,
    order_id        INTEGER,
    product_id      INTEGER,
    return_date     DATE FORMAT 'YYYY-MM-DD',
    return_reason   VARCHAR(200),
    refund_amount   DECIMAL(10,2)
) PRIMARY INDEX (return_id);