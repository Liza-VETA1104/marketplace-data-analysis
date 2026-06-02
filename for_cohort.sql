SELECT 
    s.client_id,
    MIN(s.purchase_date) AS first_purchase_ever,
    MAX(CASE WHEN s.purchase_date < '2025-01-01' THEN s.purchase_date END) AS last_purchase_pre_2025,
    MIN(CASE WHEN s.purchase_date >= '2025-01-01' THEN s.purchase_date END) AS first_purchase_2025
FROM sales s
WHERE s.client_id IN (
    -- Подзапрос находит только тех, кто покупал в 2025 году
    SELECT DISTINCT client_id 
    FROM sales 
    WHERE purchase_date BETWEEN '2025-01-01' AND '2025-12-31'
)
