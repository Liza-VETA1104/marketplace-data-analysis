--Для ABC 
SELECT 	
	product_id,
	SUM(total_price) as revenue,
	SUM(quantity) as total_quantity
FROM sales s 
WHERE s.purchase_date >= '2025-01-01' and s.purchase_date < '2026-01-01'
GROUP BY product_id; 

--XYZ
WITH calendar AS (
    SELECT generate_series(
        '2025-01-01'::date,
        '2025-12-31'::date,
        '1 day'
    )::date AS dt
),
products AS (
    SELECT DISTINCT product_id FROM sales
),
daily AS (
    SELECT 
        p.product_id,
        c.dt AS purchase_date,
        COALESCE(SUM(s.total_price), 0) AS daily_revenue
    FROM products p
    CROSS JOIN calendar c
    LEFT JOIN sales s ON s.product_id = p.product_id AND s.purchase_date = c.dt
    GROUP BY p.product_id, c.dt
),
stats AS (
    SELECT 
        product_id,
        AVG(daily_revenue) AS avg_daily,
        STDDEV(daily_revenue) AS std_daily
    FROM daily
    GROUP BY product_id
)
SELECT 
    product_id,
    avg_daily,
    std_daily,
    std_daily / NULLIF(avg_daily, 0) AS cv,
    CASE 
        WHEN std_daily / NULLIF(avg_daily, 0) < 0.1 THEN 'X'
        WHEN std_daily / NULLIF(avg_daily, 0) < 0.25 THEN 'Y'
        ELSE 'Z'
    END AS xyz
FROM stats
ORDER BY product_id;
