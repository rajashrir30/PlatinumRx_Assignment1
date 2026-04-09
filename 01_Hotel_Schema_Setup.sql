-- Hotel Management System schema setup
-- Assumption: PostgreSQL-compatible SQL. Data types are chosen to stay simple and portable.
-- Note: Only rows explicitly visible in the PDF are inserted below.

DROP TABLE IF EXISTS booking_commercials;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    mail_id VARCHAR(150),
    billing_address TEXT
);

CREATE TABLE items (
    item_id VARCHAR(50) PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    item_rate NUMERIC(10, 2) NOT NULL CHECK (item_rate >= 0)
);

CREATE TABLE bookings (
    booking_id VARCHAR(50) PRIMARY KEY,
    booking_date TIMESTAMP NOT NULL,
    room_no VARCHAR(50) NOT NULL,
    user_id VARCHAR(50) NOT NULL REFERENCES users(user_id)
);

CREATE TABLE booking_commercials (
    id VARCHAR(50) PRIMARY KEY,
    booking_id VARCHAR(50) NOT NULL REFERENCES bookings(booking_id),
    bill_id VARCHAR(50) NOT NULL,
    bill_date TIMESTAMP NOT NULL,
    item_id VARCHAR(50) NOT NULL REFERENCES items(item_id),
    item_quantity NUMERIC(10, 2) NOT NULL CHECK (item_quantity >= 0)
);

INSERT INTO users (user_id, name, phone_number, mail_id, billing_address) VALUES
('21wrcxuy-67erfn', 'John Doe', '97XXXXXXXX', 'john.doe@example.com', 'XX, Street Y, ABC City');

INSERT INTO items (item_id, item_name, item_rate) VALUES
('itm-a9e8-q8fu', 'Tawa Paratha', 18.00),
('itm-a07vh-aer8', 'Mix Veg', 89.00);

INSERT INTO bookings (booking_id, booking_date, room_no, user_id) VALUES
('bk-09f3e-95hj', '2021-09-23 07:36:48', 'rm-bhf9-aerjn', '21wrcxuy-67erfn');

INSERT INTO booking_commercials (id, booking_id, bill_id, bill_date, item_id, item_quantity) VALUES
('q34r-3q4o8-q34u', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a9e8-q8fu', 3),
('q3o4-ahf32-o2u4', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a07vh-aer8', 1),
('134lr-oyfo8-3qk4', 'bk-09f3e-95hj', 'bl-34qhd-r7h8', '2021-09-23 12:05:37', 'itm-a9e8-q8fu', 0.5);
