CREATE TABLE orders (
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR,
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
    order_id VARCHAR,
    order_item_id INT,
    product_id VARCHAR,
    seller_id VARCHAR,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC
);

CREATE TABLE order_payments (
    order_id VARCHAR,
    payment_sequential INT,
    payment_type VARCHAR,
    payment_installments INT,
    payment_value NUMERIC
);

CREATE TABLE order_reviews (
    review_id VARCHAR,
    order_id VARCHAR,
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE products (
    product_id VARCHAR PRIMARY KEY,
    product_category_name VARCHAR,
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g NUMERIC,
    product_length_cm NUMERIC,
    product_height_cm NUMERIC,
    product_width_cm NUMERIC
);

CREATE TABLE customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    customer_zip_code_prefix INT,
    customer_city VARCHAR,
    customer_state VARCHAR
);


CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC, 
	geolocation_city VARCHAR,
    geolocation_state VARCHAR
);


CREATE TABLE sellers (
    seller_id VARCHAR PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR,
    seller_state VARCHAR
);

-- =====================================
-- PRIMARY KEYS
-- =====================================

-- Customers
ALTER TABLE customers
ADD CONSTRAINT customers_pk 
PRIMARY KEY (customer_id);

-- Orders
ALTER TABLE orders
ADD CONSTRAINT orders_pk 
PRIMARY KEY (order_id);

-- Products
ALTER TABLE products
ADD CONSTRAINT products_pk 
PRIMARY KEY (product_id);

-- Sellers
ALTER TABLE sellers
ADD CONSTRAINT sellers_pk 
PRIMARY KEY (seller_id);

-- Order Items (FACT TABLE)
-- One order can contain multiple items
ALTER TABLE order_items
ADD CONSTRAINT order_items_pk 
PRIMARY KEY (order_id, order_item_id);

-- Payments
-- One order can have multiple payments
ALTER TABLE order_payments
ADD CONSTRAINT order_payments_pk
PRIMARY KEY (order_id, payment_sequential);

-- Reviews
ALTER TABLE order_reviews
ADD CONSTRAINT order_reviews_pk
PRIMARY KEY (review_id, order_id);


-- =====================================
-- FOREIGN KEYS
-- =====================================

--Orders → Customers 
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
ON DELETE RESTRICT;


--Order Items → Orders 
ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id)
ON DELETE CASCADE;

--Order Items → Products 
ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_products
FOREIGN KEY (product_id)
REFERENCES products(product_id)
ON DELETE RESTRICT;

--Order Items → Sellers 
ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_sellers
FOREIGN KEY (seller_id)
REFERENCES sellers(seller_id)
ON DELETE RESTRICT;

--Payments → Orders 
ALTER TABLE order_payments
ADD CONSTRAINT fk_payments_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id)
ON DELETE CASCADE;

--Reviews → Orders 
ALTER TABLE order_reviews
ADD CONSTRAINT fk_reviews_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id)
ON DELETE CASCADE;

--Geolocation
ALTER TABLE dim_geolocation
ADD CONSTRAINT dim_geo_pk
PRIMARY KEY (geolocation_zip_code_prefix);

--Auto index foreign keys
CREATE INDEX idx_orders_customer_id 
ON orders(customer_id);

CREATE INDEX idx_orderitems_product_id 
ON order_items(product_id);

CREATE INDEX idx_orderitems_seller_id 
ON order_items(seller_id);

CREATE INDEX idx_payments_order_id 
ON order_payments(order_id);

CREATE INDEX idx_reviews_order_id 
ON order_reviews(order_id);


--Orders

COPY orders(
    order_id, customer_id, order_status,
    order_purchase_timestamp, order_approved_at,
    order_delivered_carrier_date, order_delivered_customer_date,
    order_estimated_delivery_date
)
FROM 'E:\PostgreSQL\orders.csv'
DELIMITER ','
CSV
HEADER
NULL '\N';

--Products

copy products(
    product_id, product_category_name, product_name_length,
    product_description_length, product_photos_qty,
    product_weight_g, product_length_cm, product_height_cm, product_width_cm
)
FROM 'E:\PostgreSQL\products.csv'
DELIMITER ','
CSV
HEADER
QUOTE '"';

--Sellers

COPY sellers(seller_id, seller_zip_code_prefix, seller_city, seller_state)
FROM 'E:\PostgreSQL\sellers.csv'
DELIMITER ','
CSV HEADER
QUOTE '"';

--Order_reviews

copy order_reviews(
    review_id, order_id, review_score, review_comment_title, 
    review_comment_message, review_creation_date, review_answer_timestamp
)
FROM 'E:\PostgreSQL\order_reviews.csv'
DELIMITER ','
CSV
HEADER
QUOTE '"';

