-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS transaction_items CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS store_inventory CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS stores CASCADE;

-- Stores Table
CREATE TABLE stores (
    store_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    phone VARCHAR(20)
);

-- Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    loyalty_points INTEGER DEFAULT 0,
    is_member BOOLEAN DEFAULT FALSE
);

-- Employees Table
CREATE TABLE employees (
    employee_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    email VARCHAR(100),
    store_id VARCHAR(10),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- Products Table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_type VARCHAR(20) NOT NULL, -- 'flavor', 'cone', etc.
    name VARCHAR(100) NOT NULL,
    price DECIMAL(5,2) NOT NULL,
    quantity INTEGER DEFAULT 0,
    available BOOLEAN DEFAULT TRUE
);

-- Store Inventory Table
CREATE TABLE store_inventory (
    store_id VARCHAR(10),
    product_id INTEGER,
    quantity INTEGER DEFAULT 0,
    PRIMARY KEY (store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Transactions Table
CREATE TABLE transactions (
    transaction_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    employee_id VARCHAR(10),
    store_id VARCHAR(10),
    date DATE NOT NULL,
    total_amount DECIMAL(6,2) NOT NULL,
    payment_method VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- Transaction Items Table
CREATE TABLE transaction_items (
    transaction_id VARCHAR(10),
    product_id INTEGER,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Reset sequences dynamically (optional)
SELECT setval('products_product_id_seq', COALESCE(MAX(product_id), 0) + 1, false) FROM products;
SELECT setval('transaction_items_id_seq', COALESCE(MAX(id), 0) + 1, false) FROM transaction_items;


-- Import data from CSV files (if applicable)
-- COPY stores FROM './data/stores.csv' DELIMITER ',' CSV HEADER;
-- COPY customers FROM './data/customers.csv' DELIMITER ',' CSV HEADER;
-- COPY employees FROM './data/employees.csv' DELIMITER ',' CSV HEADER;
-- COPY products FROM './data/products.csv' DELIMITER ',' CSV HEADER;
-- COPY store_inventory FROM './data/store_inventory.csv' DELIMITER ',' CSV HEADER;
-- COPY transactions FROM './data/transactions.csv' DELIMITER ',' CSV HEADER;
-- COPY transaction_items FROM './data/transaction_items.csv' DELIMITER ',' CSV HEADER;


-- Add indexes for performance optimization
-- CREATE INDEX idx_store_inventory ON store_inventory(store_id, product_id);
-- CREATE INDEX idx_transaction_items_transaction_id ON transaction_items(transaction_id);
-- CREATE INDEX idx_transaction_items_product_id ON transaction_items(product_id);
-- CREATE INDEX idx_transactions_store_id ON transactions(store_id);
-- CREATE INDEX idx_products_name ON products(name);




-- 🧭 Relationships in Your Schema
-- 🏬 stores ↔ employees
-- 1:N: One store has many employees.
-- Each employee has a store_id foreign key.
-- ✅ One store → many employees

-- 🏬 stores ↔ transactions
-- 1:N: One store has many transactions.
-- Each transaction has a store_id.
-- ✅ One store → many transactions

-- 👤 customers ↔ transactions
-- 1:N: One customer can make many transactions.
-- Each transaction has a customer_id.
-- ✅ One customer → many transactions

-- 👔 employees ↔ transactions
-- 1:N: One employee can handle many transactions.
-- Each transaction has an employee_id.
-- ✅ One employee → many transactions

-- 📦 products ↔ store_inventory
-- N:N: Products are stocked in multiple stores, and stores carry multiple products.
-- store_inventory is a junction table with store_id and product_id.
-- ✅ Many stores ↔ many products

-- 💳 transactions ↔ transaction_items
-- 1:N: One transaction can include many items.
-- Each transaction_item has a transaction_id.
-- ✅ One transaction → many transaction items

-- 📦 products ↔ transaction_items
-- 1:N: One product can appear in many transaction items.
-- Each transaction_item has a product_id.
-- ✅ One product → many transaction items