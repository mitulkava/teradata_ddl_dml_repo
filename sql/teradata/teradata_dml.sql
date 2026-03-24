SELECT
    s.region,
    c.customer_id,
    c.first_name || ' ' || c.last_name          AS customer_name,
    c.segment,
    COUNT(DISTINCT o.order_id)                   AS total_orders,
    SUM(oi.quantity * oi.unit_price
        * (1 - COALESCE(oi.discount_pct, 0) / 100))  AS gross_revenue,
    COALESCE(SUM(r.refund_amount), 0)            AS total_refunds,
    SUM(oi.quantity * oi.unit_price
        * (1 - COALESCE(oi.discount_pct, 0) / 100))
        - COALESCE(SUM(r.refund_amount), 0)      AS net_revenue,
    RANK() OVER (
        PARTITION BY s.region
        ORDER BY
            SUM(oi.quantity * oi.unit_price
                * (1 - COALESCE(oi.discount_pct, 0) / 100))
            - COALESCE(SUM(r.refund_amount), 0) DESC
    )                                            AS revenue_rank
FROM
    retail_db.customers        c
    INNER JOIN retail_db.orders      o   ON c.customer_id = o.customer_id
    INNER JOIN retail_db.order_items oi  ON o.order_id    = oi.order_id
    INNER JOIN retail_db.stores      s   ON o.store_id    = s.store_id
    LEFT  JOIN retail_db.returns     r   ON o.order_id    = r.order_id
                                        AND oi.product_id  = r.product_id
WHERE
    o.status        = 'COMPLETED'
    AND o.order_date BETWEEN DATE '2024-01-01' AND DATE '2024-12-31'
    AND c.segment   = 'PREMIUM'
QUALIFY
    RANK() OVER (
        PARTITION BY s.region
        ORDER BY
            SUM(oi.quantity * oi.unit_price
                * (1 - COALESCE(oi.discount_pct, 0) / 100))
            - COALESCE(SUM(r.refund_amount), 0) DESC
    ) <= 5
GROUP BY
    s.region,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.segment
ORDER BY
    s.region,
    revenue_rank;
	
	
SELECT
    s.store_name,
    s.region,
    p.category,
    CAST(EXTRACT(YEAR  FROM o.order_date) AS CHAR(4))
        || '-'
        || TRIM(CAST(EXTRACT(MONTH FROM o.order_date) AS CHAR(2)))  AS order_month,

    SUM(oi.quantity * oi.unit_price
        * (1 - COALESCE(oi.discount_pct, 0) / 100))                AS total_revenue,

    SUM(oi.quantity * p.cost_price)                                 AS total_cost,

    SUM(oi.quantity * oi.unit_price
        * (1 - COALESCE(oi.discount_pct, 0) / 100))
        - SUM(oi.quantity * p.cost_price)                           AS gross_profit,

    ROUND(
        (SUM(oi.quantity * oi.unit_price
             * (1 - COALESCE(oi.discount_pct, 0) / 100))
         - SUM(oi.quantity * p.cost_price))
        / NULLIFZERO(SUM(oi.quantity * oi.unit_price
                         * (1 - COALESCE(oi.discount_pct, 0) / 100)))
        * 100,
    2)                                                              AS gross_margin_pct,

    -- Previous month gross profit using LAG
    LAG(
        SUM(oi.quantity * oi.unit_price
            * (1 - COALESCE(oi.discount_pct, 0) / 100))
        - SUM(oi.quantity * p.cost_price),
        1
    ) OVER (
        PARTITION BY s.store_id, p.category
        ORDER BY
            EXTRACT(YEAR  FROM o.order_date),
            EXTRACT(MONTH FROM o.order_date)
    )                                                               AS prev_month_profit,

    -- Month-over-Month growth %
    ROUND(
        (
            (SUM(oi.quantity * oi.unit_price
                 * (1 - COALESCE(oi.discount_pct, 0) / 100))
             - SUM(oi.quantity * p.cost_price))
            -
            LAG(
                SUM(oi.quantity * oi.unit_price
                    * (1 - COALESCE(oi.discount_pct, 0) / 100))
                - SUM(oi.quantity * p.cost_price),
                1
            ) OVER (
                PARTITION BY s.store_id, p.category
                ORDER BY
                    EXTRACT(YEAR  FROM o.order_date),
                    EXTRACT(MONTH FROM o.order_date)
            )
        )
        / NULLIFZERO(
            ABS(
                LAG(
                    SUM(oi.quantity * oi.unit_price
                        * (1 - COALESCE(oi.discount_pct, 0) / 100))
                    - SUM(oi.quantity * p.cost_price),
                    1
                ) OVER (
                    PARTITION BY s.store_id, p.category
                    ORDER BY
                        EXTRACT(YEAR  FROM o.order_date),
                        EXTRACT(MONTH FROM o.order_date)
                )
            )
        )
        * 100,
    2)                                                              AS mom_growth_pct

FROM
    retail_db.orders       o
    INNER JOIN retail_db.order_items oi  ON o.order_id   = oi.order_id
    INNER JOIN retail_db.products    p   ON oi.product_id = p.product_id
    INNER JOIN retail_db.stores      s   ON o.store_id    = s.store_id

WHERE
    o.status     = 'COMPLETED'
    AND o.order_date BETWEEN DATE '2023-01-01' AND DATE '2024-12-31'

GROUP BY
    s.store_id,
    s.store_name,
    s.region,
    p.category,
    EXTRACT(YEAR  FROM o.order_date),
    EXTRACT(MONTH FROM o.order_date)

ORDER BY
    s.store_name,
    p.category,
    EXTRACT(YEAR  FROM o.order_date),
    EXTRACT(MONTH FROM o.order_date);