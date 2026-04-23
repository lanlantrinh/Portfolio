$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$projectDataDir = Join-Path $root "data"
$sourceDataDir = if ($args.Count -gt 0) { $args[0] } else { $projectDataDir }

$requiredFiles = @(
    "olist_customers_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_products_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv"
)

$missing = $false
foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $sourceDataDir $file
    if (-not (Test-Path $fullPath)) {
        Write-Host "Missing file: $fullPath"
        $missing = $true
    }
}

if ($missing) {
    throw "Provide a folder that contains the required Olist CSV files, then run this script again."
}

New-Item -ItemType Directory -Force -Path $projectDataDir | Out-Null

if ((Resolve-Path $sourceDataDir).Path -ne (Resolve-Path $projectDataDir).Path) {
    Write-Host "Syncing CSV files into $projectDataDir"
    foreach ($file in $requiredFiles) {
        Copy-Item -Force (Join-Path $sourceDataDir $file) (Join-Path $projectDataDir $file)
    }
}

Set-Location $root

docker compose up -d db

do {
    Start-Sleep -Seconds 1
    $ready = docker compose exec -T db pg_isready -U olist -d olist
} until ($LASTEXITCODE -eq 0)

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -f /workspace/sql/01_create_schema.sql

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c `
  "TRUNCATE TABLE order_items, order_payments, orders, customers, products CASCADE;"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c `
  "\copy customers(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state) FROM '/workspace/data/olist_customers_dataset.csv' CSV HEADER NULL ''"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c `
  "\copy orders(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date) FROM '/workspace/data/olist_orders_dataset.csv' CSV HEADER NULL ''"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c `
  "\copy products(product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm) FROM '/workspace/data/olist_products_dataset.csv' CSV HEADER NULL ''"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c `
  "\copy order_items(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value) FROM '/workspace/data/olist_order_items_dataset.csv' CSV HEADER NULL ''"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -c `
  "\copy order_payments(order_id, payment_sequential, payment_type, payment_installments, payment_value) FROM '/workspace/data/olist_order_payments_dataset.csv' CSV HEADER NULL ''"

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -f /workspace/sql/04_create_views.sql

Write-Host "Olist CSV data loaded successfully."
