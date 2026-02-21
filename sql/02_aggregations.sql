--Total Revenue
SELECT 
    SUM(price + freight_value) AS total_revenue
FROM order_items;

--Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders;

--Average Order Value(AOV)
SELECT 
    SUM(price + freight_value) / COUNT(DISTINCT order_id) AS avg_order_value
FROM order_items;

--Revenue By Month
SELECT 
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    SUM(oi.price + oi.freight_value) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY 1
ORDER BY 1;

--Revenue By State
SELECT 
    c.customer_state,
    SUM(oi.price + oi.freight_value) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

--Top 10 Products By Revenue
SELECT 
    oi.product_id,
    SUM(oi.price + oi.freight_value) AS revenue
FROM order_items oi
GROUP BY oi.product_id
ORDER BY revenue DESC
LIMIT 10;

--Orders By Status
SELECT 
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status;

--Average Delivery Time
SELECT 
    AVG(order_delivered_customer_date - order_purchase_timestamp) 
    AS avg_delivery_time
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

--Revenue View
CREATE OR REPLACE VIEW vw_revenue_monthly AS
SELECT 
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    SUM(oi.price + oi.freight_value) AS revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY 1;

--Customer Revenue View
CREATE OR REPLACE VIEW vw_customer_revenue AS
SELECT 
    c.customer_unique_id,
    SUM(oi.price + oi.freight_value) AS total_spent,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id;

--Seller Perfomance View
CREATE OR REPLACE VIEW vw_seller_performance AS
SELECT 
    s.seller_id,
    SUM(oi.price + oi.freight_value) AS revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id;

SELECT current_user;











