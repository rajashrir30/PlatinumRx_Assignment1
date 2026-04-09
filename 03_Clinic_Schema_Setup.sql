-- Clinic Management System schema setup
-- Assumption: PostgreSQL-compatible SQL.
-- Note: Only rows explicitly visible in the PDF are inserted below.

DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS clinic_sales;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS clinics;

CREATE TABLE clinics (
    cid VARCHAR(50) PRIMARY KEY,
    clinic_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE customer (
    uid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    mobile VARCHAR(20)
);

CREATE TABLE clinic_sales (
    oid VARCHAR(50) PRIMARY KEY,
    uid VARCHAR(50) NOT NULL REFERENCES customer(uid),
    cid VARCHAR(50) NOT NULL REFERENCES clinics(cid),
    amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    datetime TIMESTAMP NOT NULL,
    sales_channel VARCHAR(50) NOT NULL
);

CREATE TABLE expenses (
    eid VARCHAR(50) PRIMARY KEY,
    cid VARCHAR(50) NOT NULL REFERENCES clinics(cid),
    description VARCHAR(255),
    amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    datetime TIMESTAMP NOT NULL
);

INSERT INTO clinics (cid, clinic_name, city, state, country) VALUES
('cnc-0100001', 'XYZ clinic', 'lorem', 'ipsum', 'dolor');

INSERT INTO customer (uid, name, mobile) VALUES
('bk-09f3e-95hj', 'Jon Doe', '97XXXXXXXX');

INSERT INTO clinic_sales (oid, uid, cid, amount, datetime, sales_channel) VALUES
('ord-00100-00100', 'bk-09f3e-95hj', 'cnc-0100001', 24999, '2021-09-23 12:03:22', 'sodat');

INSERT INTO expenses (eid, cid, description, amount, datetime) VALUES
('exp-0100-00100', 'cnc-0100001', 'first-aid supplies', 557, '2021-09-23 07:36:48');
