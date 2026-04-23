#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DATA_DIR="$ROOT_DIR/data"
SOURCE_DATA_DIR="${1:-$PROJECT_DATA_DIR}"

required_files=(
  "olist_customers_dataset.csv"
  "olist_orders_dataset.csv"
  "olist_products_dataset.csv"
  "olist_order_items_dataset.csv"
  "olist_order_payments_dataset.csv"
)

missing=0
for file in "${required_files[@]}"; do
  if [[ ! -f "$SOURCE_DATA_DIR/$file" ]]; then
    echo "Missing file: $SOURCE_DATA_DIR/$file"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "Provide a folder that contains the required Olist CSV files, then run this script again."
  exit 1
fi

mkdir -p "$PROJECT_DATA_DIR"

if [[ "$SOURCE_DATA_DIR" != "$PROJECT_DATA_DIR" ]]; then
  echo "Syncing CSV files into $PROJECT_DATA_DIR"
  for file in "${required_files[@]}"; do
    cp -f "$SOURCE_DATA_DIR/$file" "$PROJECT_DATA_DIR/$file"
  done
fi

cd "$ROOT_DIR"

docker compose up -d db

until docker compose exec -T db pg_isready -U olist -d olist >/dev/null 2>&1; do
  sleep 1
done

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -f /workspace/sql/01_create_schema.sql

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c \
  "TRUNCATE TABLE order_items, order_payments, orders, customers, products CASCADE;"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c \
  "\copy customers(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state) FROM '/workspace/data/olist_customers_dataset.csv' CSV HEADER NULL ''"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c \
  "\copy orders(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date) FROM '/workspace/data/olist_orders_dataset.csv' CSV HEADER NULL ''"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c \
  "\copy products(product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm) FROM '/workspace/data/olist_products_dataset.csv' CSV HEADER NULL ''"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c \
  "\copy order_items(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value) FROM '/workspace/data/olist_order_items_dataset.csv' CSV HEADER NULL ''"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c \
  "\copy order_payments(order_id, payment_sequential, payment_type, payment_installments, payment_value) FROM '/workspace/data/olist_order_payments_dataset.csv' CSV HEADER NULL ''"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -f /workspace/sql/04_create_views.sql

echo "Olist CSV data loaded successfully."
