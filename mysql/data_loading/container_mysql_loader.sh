#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Config (override via env vars)
# -----------------------------
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-password}"
MYSQL_DB="${MYSQL_DB:-retail_demo}"
CSV_DIR="${CSV_DIR:-csv}"      # expects csv/customers.csv, csv/products.csv, csv/sales.csv, csv/sales_report_daily_customer.csv

# -----------------------------
# Helpers
# -----------------------------
mysql_cli() {
  mysql --local-infile=1 -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$@"
}

abs_path() {
  # portable "realpath"
  local p="$1"; local d; d="$(cd "$(dirname "$p")" && pwd)"; echo "$d/$(basename "$p")"
}

require_file() {
  if [ ! -f "$1" ]; then
    echo "ERROR: Missing file: $1" >&2
    exit 1
  fi
}

# -----------------------------
# Check CSVs exist
# -----------------------------
require_file "$CSV_DIR/customers.csv"
require_file "$CSV_DIR/products.csv"
require_file "$CSV_DIR/sales.csv"
require_file "$CSV_DIR/sales_report_daily_customer.csv"

# -----------------------------
# Configure MySQL User for External Connections
# -----------------------------
echo ">> Configuring MySQL user for external connections..."
mysql_cli -e "
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
"

# -----------------------------
# Create DB & Tables
# -----------------------------
echo ">> Creating database \`$MYSQL_DB\` (if not exists)..."
mysql_cli -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo ">> Creating tables (if not exists)..."
mysql_cli "$MYSQL_DB" <<'SQL'
SET SESSION sql_mode='STRICT_ALL_TABLES';

CREATE TABLE IF NOT EXISTS customers (
  id            INT            NOT NULL PRIMARY KEY,
  name          VARCHAR(100)   NOT NULL,
  email         VARCHAR(255)   NOT NULL,
  country       VARCHAR(32)    NOT NULL,
  state         VARCHAR(32)    NULL,
  signup_date   DATE           NOT NULL,
  UNIQUE KEY uk_customers_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS products (
  id            INT            NOT NULL PRIMARY KEY,
  name          VARCHAR(150)   NOT NULL,
  category      VARCHAR(32)    NOT NULL,
  unit_price    DECIMAL(12,2)  NOT NULL,
  currency      CHAR(3)        NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sales (
  sale_id       BIGINT         NOT NULL PRIMARY KEY,
  sale_date     DATE           NOT NULL,
  customer_id   INT            NOT NULL,
  product_id    INT            NOT NULL,
  quantity      INT            NOT NULL,
  unit_price    DECIMAL(12,2)  NOT NULL,
  amount        DECIMAL(14,2)  NOT NULL,
  CONSTRAINT fk_sales_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_sales_product  FOREIGN KEY (product_id)  REFERENCES products(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- This table holds the pre-aggregated report from CSV.
CREATE TABLE IF NOT EXISTS sales_report_daily_customer (
  sale_date       DATE           NOT NULL,
  customer_id     INT            NOT NULL,
  purchases_count INT            NOT NULL,
  total_amount    DECIMAL(14,2)  NOT NULL,
  PRIMARY KEY (sale_date, customer_id),
  CONSTRAINT fk_report_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Optional: also provide a live view that recomputes the same aggregation from `sales`.
CREATE OR REPLACE VIEW sales_report_daily_customer_v AS
SELECT
  s.sale_date,
  s.customer_id,
  COUNT(*)                       AS purchases_count,
  SUM(s.amount)                  AS total_amount
FROM sales s
GROUP BY s.sale_date, s.customer_id;
SQL

# -----------------------------
# Enable local infile & load CSVs
# -----------------------------
echo ">> Enabling LOCAL INFILE for this session (best-effort)..."
mysql_cli -e "SET GLOBAL local_infile = 1;" || true

echo ">> Loading customers.csv ..."
mysql_cli "$MYSQL_DB" --execute "
LOAD DATA LOCAL INFILE '$(abs_path "$CSV_DIR/customers.csv")'
INTO TABLE customers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, email, country, state, signup_date);
"

echo ">> Loading products.csv ..."
mysql_cli "$MYSQL_DB" --execute "
LOAD DATA LOCAL INFILE '$(abs_path "$CSV_DIR/products.csv")'
INTO TABLE products
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, category, unit_price, currency);
"

echo ">> Loading sales.csv ..."
mysql_cli "$MYSQL_DB" --execute "
SET FOREIGN_KEY_CHECKS=0;
LOAD DATA LOCAL INFILE '$(abs_path "$CSV_DIR/sales.csv")'
INTO TABLE sales
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(sale_id, sale_date, customer_id, product_id, quantity, unit_price, amount);
SET FOREIGN_KEY_CHECKS=1;
"

echo ">> Loading sales_report_daily_customer.csv ..."
mysql_cli "$MYSQL_DB" --execute "
LOAD DATA LOCAL INFILE '$(abs_path "$CSV_DIR/sales_report_daily_customer.csv")'
INTO TABLE sales_report_daily_customer
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(sale_date, customer_id, purchases_count, total_amount);
"

# -----------------------------
# Row counts
# -----------------------------
echo ">> Row counts:"
mysql_cli "$MYSQL_DB" -N -e "SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sales', COUNT(*) FROM sales
UNION ALL SELECT 'sales_report_daily_customer', COUNT(*) FROM sales_report_daily_customer;"

echo "✅ Done."
