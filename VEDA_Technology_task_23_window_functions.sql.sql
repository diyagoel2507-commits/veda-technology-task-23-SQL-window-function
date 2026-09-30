-- Q1. Assign a unique sequential row number to each order based on the order ID.
SELECT
    order_id,
    customer_id,
    order_date,
    ROW_NUMBER() OVER (
        ORDER BY order_id
    ) AS row_num
FROM orders
ORDER BY order_id
LIMIT 10;

-- Q2. Assign a unique sequential row number to each product based on its unit price in descending order.
SELECT
    product_id,
    product_name,
    unit_price,
    ROW_NUMBER() OVER (
        ORDER BY unit_price DESC NULLS LAST
    ) AS row_num
FROM products
ORDER BY unit_price DESC NULLS LAST
LIMIT 15;


-- Q3. Rank products based on their unit prices in descending order using the RANK() window function.
SELECT
    product_id,
    product_name,
    unit_price,
    RANK() OVER (
        ORDER BY unit_price DESC NULLS LAST
    ) AS price_rank
FROM products
ORDER BY unit_price DESC NULLS LAST
LIMIT 15;


-- Q4. Rank products based on their unit prices in descending order using the DENSE_RANK() window function.
SELECT
    product_id,
    product_name,
    unit_price,
    DENSE_RANK() OVER (
        ORDER BY unit_price DESC NULLS LAST
    ) AS dense_price_rank
FROM products
ORDER BY unit_price DESC NULLS LAST
LIMIT 15;


-- Q5. Find the previous order date for each customer using the LAG() window function and calculate the number of days between consecutive orders.
SELECT
    order_id,
    customer_id,
    order_date,
    LAG(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS previous_order_date,
    order_date - LAG(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS days_since_previous_order
FROM orders
ORDER BY order_id
LIMIT 20;


-- Q6. Find the next order date for each customer using the LEAD() window function and calculate the number of days between the current order and the next order.
SELECT order_id,customer_id, order_date,
    LEAD(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS next_order_date,
    LEAD(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) - order_date AS days_until_next_order
FROM orders
ORDER BY order_id
LIMIT 20;


-- Q7. Calculate the running total of sales for each order using the SUM() window function.
WITH order_totals AS (
    SELECT
        order_id,
        SUM(unit_price * quantity * (1 - discount)) AS order_total
    FROM order_details
    GROUP BY order_id
)
SELECT
    order_id,
    ROUND(order_total::numeric, 2) AS order_total,
    ROUND(
        SUM(order_total) OVER (
            ORDER BY order_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )::numeric,
        2
    ) AS running_total
FROM order_totals
ORDER BY order_id
LIMIT 20;


-- Q8. Calculate each order's value and the overall average order value using the AVG() window function.
WITH order_totals AS (
    SELECT
        order_id,
        SUM(unit_price * quantity * (1 - discount)) AS order_total
    FROM order_details
    GROUP BY order_id
)
SELECT
    order_id,
    ROUND(order_total::numeric, 2) AS order_total,
    ROUND(
        AVG(order_total) OVER ()::numeric,
        2
    ) AS average_order_value
FROM order_totals
ORDER BY order_id
LIMIT 20;


-- Q9. Calculate each customer's total sales using the SUM() window function by partitioning orders by customer.
WITH order_totals AS (
    SELECT
        order_id,
        SUM(unit_price * quantity * (1 - discount)) AS order_total
    FROM order_details
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.customer_id,
    ROUND(ot.order_total::numeric, 2) AS order_total,
    ROUND(
        SUM(ot.order_total) OVER (
            PARTITION BY o.customer_id
        )::numeric,
        2
    ) AS customer_total_sales
FROM orders o
JOIN order_totals ot
    ON o.order_id = ot.order_id
ORDER BY o.customer_id, o.order_id
LIMIT 20;


-- Q10. Assign a sequential row number to each customer's orders based on the order date using ROW_NUMBER() and PARTITION BY.
SELECT order_id,customer_id,order_date,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS customer_order_number
FROM orders
ORDER BY customer_id, order_date, order_id
LIMIT 20;


-- Q11. Rank each customer's orders by order date in descending order to identify their most recent order using RANK().
SELECT order_id,customer_id,order_date,
    RANK() OVER (
        PARTITION BY customer_id
        ORDER BY order_date DESC
    ) AS order_rank
FROM orders
ORDER BY customer_id, order_rank
LIMIT 20;


-- Q12. Compare each order's total value with the average order value of that customer using the AVG() window function.
WITH order_totals AS (
    SELECT
        order_id,
        SUM(unit_price * quantity * (1 - discount)) AS order_total
    FROM order_details
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.customer_id,
    ROUND(ot.order_total::numeric, 2) AS order_total,
    ROUND(
        AVG(ot.order_total) OVER (
            PARTITION BY o.customer_id
        )::numeric,
        2
    ) AS customer_average_order_value,
    ROUND(
        (
            ot.order_total
            - AVG(ot.order_total) OVER (
                PARTITION BY o.customer_id
            )
        )::numeric,
        2
    ) AS difference_from_average
FROM orders o
JOIN order_totals ot
    ON o.order_id = ot.order_id
ORDER BY o.customer_id, o.order_id
LIMIT 20;