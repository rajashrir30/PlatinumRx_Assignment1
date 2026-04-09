-- Hotel Management System query solutions

-- Q1. For every user in the system, get the user_id and last booked room_no.
WITH ranked_bookings AS (
    SELECT
        b.user_id,
        b.room_no,
        b.booking_date,
        ROW_NUMBER() OVER (
            PARTITION BY b.user_id
            ORDER BY b.booking_date DESC, b.booking_id DESC
        ) AS rn
    FROM bookings b
)
SELECT
    u.user_id,
    rb.room_no AS last_booked_room_no
FROM users u
LEFT JOIN ranked_bookings rb
    ON u.user_id = rb.user_id
   AND rb.rn = 1
ORDER BY u.user_id;

-- Q2. Get booking_id and total billing amount of every booking created in November, 2021.
SELECT
    b.booking_id,
    SUM(bc.item_quantity * i.item_rate) AS total_billing_amount
FROM bookings b
JOIN booking_commercials bc
    ON b.booking_id = bc.booking_id
JOIN items i
    ON bc.item_id = i.item_id
WHERE b.booking_date >= '2021-11-01'
  AND b.booking_date < '2021-12-01'
GROUP BY b.booking_id
ORDER BY b.booking_id;

-- Q3. Get bill_id and bill amount of all the bills raised in October, 2021 having bill amount > 1000.
SELECT
    bc.bill_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i
    ON bc.item_id = i.item_id
WHERE bc.bill_date >= '2021-10-01'
  AND bc.bill_date < '2021-11-01'
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000
ORDER BY bill_amount DESC, bc.bill_id;

-- Q4. Determine the most ordered and least ordered item of each month of year 2021.
WITH monthly_item_totals AS (
    SELECT
        DATE_FORMAT(bc.bill_date, '%Y-%m-01') AS month_start,
        i.item_id,
        i.item_name,
        SUM(bc.item_quantity) AS total_quantity
    FROM booking_commercials bc
    JOIN items i
        ON bc.item_id = i.item_id
    WHERE bc.bill_date >= '2021-01-01'
      AND bc.bill_date < '2022-01-01'
    GROUP BY DATE_FORMAT(bc.bill_date, '%Y-%m-01'), i.item_id, i.item_name
),
ranked AS (
    SELECT
        month_start,
        item_id,
        item_name,
        total_quantity,
        RANK() OVER (
            PARTITION BY month_start
            ORDER BY total_quantity DESC, item_name ASC
        ) AS most_rank,
        RANK() OVER (
            PARTITION BY month_start
            ORDER BY total_quantity ASC, item_name ASC
        ) AS least_rank
    FROM monthly_item_totals
)
SELECT
    month_start,
    'most_ordered' AS order_type,
    item_id,
    item_name,
    total_quantity
FROM ranked
WHERE most_rank = 1

UNION ALL

SELECT
    month_start,
    'least_ordered' AS order_type,
    item_id,
    item_name,
    total_quantity
FROM ranked
WHERE least_rank = 1
ORDER BY month_start, order_type DESC, item_name;

-- Q5. Find the customers with the second highest bill value of each month of year 2021.
WITH monthly_bills AS (
    SELECT
        DATE_FORMAT(bc.bill_date, '%Y-%m-01') AS month_start,
        bc.bill_id,
        b.user_id,
        SUM(bc.item_quantity * i.item_rate) AS bill_amount
    FROM booking_commercials bc
    JOIN bookings b
        ON bc.booking_id = b.booking_id
    JOIN items i
        ON bc.item_id = i.item_id
    WHERE bc.bill_date >= '2021-01-01'
      AND bc.bill_date < '2022-01-01'
    GROUP BY DATE_FORMAT(bc.bill_date, '%Y-%m-01'), bc.bill_id, b.user_id
),
ranked_bills AS (
    SELECT
        month_start,
        bill_id,
        user_id,
        bill_amount,
        DENSE_RANK() OVER (
            PARTITION BY month_start
            ORDER BY bill_amount DESC
        ) AS bill_rank
    FROM monthly_bills
)
SELECT
    rb.month_start,
    rb.bill_id,
    rb.user_id,
    u.name,
    rb.bill_amount
FROM ranked_bills rb
JOIN users u
    ON rb.user_id = u.user_id
WHERE rb.bill_rank = 2
ORDER BY rb.month_start, rb.user_id;
