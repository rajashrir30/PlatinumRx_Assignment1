-- Clinic Management System query solutions
-- MySQL 8 compatible version
-- Fixed values are used so the file can run directly in VS Code:
-- target year = 2021
-- target month = September 2021

-- Q1. Find the revenue we got from each sales channel in a given year.
SELECT
    sales_channel,
    SUM(amount) AS total_revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel
ORDER BY total_revenue DESC, sales_channel;

-- Q2. Find top 10 the most valuable customers for a given year.
SELECT
    c.uid,
    c.name,
    SUM(cs.amount) AS total_revenue
FROM clinic_sales cs
JOIN customer c
    ON cs.uid = c.uid
WHERE YEAR(cs.datetime) = 2021
GROUP BY c.uid, c.name
ORDER BY total_revenue DESC, c.uid
LIMIT 10;

-- Q3. Find month wise revenue, expense, profit, status (profitable / not-profitable) for a given year.
WITH revenue_by_month AS (
    SELECT
        MONTH(datetime) AS month_no,
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
    GROUP BY MONTH(datetime)
),
expense_by_month AS (
    SELECT
        MONTH(datetime) AS month_no,
        SUM(amount) AS expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY MONTH(datetime)
),
all_months AS (
    SELECT month_no FROM revenue_by_month
    UNION
    SELECT month_no FROM expense_by_month
)
SELECT
    m.month_no,
    COALESCE(r.revenue, 0) AS revenue,
    COALESCE(e.expense, 0) AS expense,
    COALESCE(r.revenue, 0) - COALESCE(e.expense, 0) AS profit,
    CASE
        WHEN COALESCE(r.revenue, 0) - COALESCE(e.expense, 0) > 0 THEN 'profitable'
        ELSE 'not-profitable'
    END AS status
FROM all_months m
LEFT JOIN revenue_by_month r
    ON m.month_no = r.month_no
LEFT JOIN expense_by_month e
    ON m.month_no = e.month_no
ORDER BY m.month_no;

-- Q4. For each city find the most profitable clinic for a given month.
WITH sales_in_month AS (
    SELECT
        cid,
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
      AND MONTH(datetime) = 9
    GROUP BY cid
),
expenses_in_month AS (
    SELECT
        cid,
        SUM(amount) AS expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
      AND MONTH(datetime) = 9
    GROUP BY cid
),
clinic_profit AS (
    SELECT
        cl.city,
        cl.cid,
        cl.clinic_name,
        COALESCE(s.revenue, 0) - COALESCE(e.expense, 0) AS profit
    FROM clinics cl
    LEFT JOIN sales_in_month s
        ON cl.cid = s.cid
    LEFT JOIN expenses_in_month e
        ON cl.cid = e.cid
),
ranked AS (
    SELECT
        city,
        cid,
        clinic_name,
        profit,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY profit DESC, clinic_name ASC
        ) AS rn
    FROM clinic_profit
)
SELECT
    city,
    cid,
    clinic_name,
    profit
FROM ranked
WHERE rn = 1
ORDER BY city;

-- Q5. For each state find the second least profitable clinic for a given month.
WITH sales_in_month AS (
    SELECT
        cid,
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
      AND MONTH(datetime) = 9
    GROUP BY cid
),
expenses_in_month AS (
    SELECT
        cid,
        SUM(amount) AS expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
      AND MONTH(datetime) = 9
    GROUP BY cid
),
clinic_profit AS (
    SELECT
        cl.state,
        cl.cid,
        cl.clinic_name,
        COALESCE(s.revenue, 0) - COALESCE(e.expense, 0) AS profit
    FROM clinics cl
    LEFT JOIN sales_in_month s
        ON cl.cid = s.cid
    LEFT JOIN expenses_in_month e
        ON cl.cid = e.cid
),
ranked AS (
    SELECT
        state,
        cid,
        clinic_name,
        profit,
        DENSE_RANK() OVER (
            PARTITION BY state
            ORDER BY profit ASC
        ) AS profit_rank
    FROM clinic_profit
)
SELECT
    state,
    cid,
    clinic_name,
    profit
FROM ranked
WHERE profit_rank = 2
ORDER BY state, clinic_name;
