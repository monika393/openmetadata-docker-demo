#!/bin/bash

# Script to manually create lineage relationships using OpenMetadata API
# This creates lineage between tables based on foreign key relationships

TOKEN="eyJraWQiOiJHYjM4OWEtOWY3Ni1nZGpzLWE5MmotMDI0MmJrOTQzNTYiLCJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJvcGVuLW1ldGFkYXRhLm9yZyIsInN1YiI6ImluZ2VzdGlvbi1ib3QiLCJyb2xlcyI6WyJJbmdlc3Rpb25Cb3RSb2xlIl0sImVtYWlsIjoiaW5nZXN0aW9uLWJvdEBvcGVuLW1ldGFkYXRhLm9yZyIsImlzQm90Ijp0cnVlLCJ0b2tlblR5cGUiOiJCT1QiLCJpYXQiOjE3NTU2NjMyOTQsImV4cCI6bnVsbH0.Rhj1bjZq1hfi1fT1n5FCohQ7u_OlVr6GuexNh6E7ME2OSLGl4qFzk1Dz-aeWrLDSMn9hKfZHHz1iIeaS2yf6LLoQIaiTgo2xlEbLtRRVIMUcg9LB1KtBrXwBHbt6-PctSYmpTb7RoYeTjxyk7H_h5OdFHfupOmUFr5BTWZL30p5Fpvdf8fkjkBjnOIYlOzuYmzMHscl0Ym_eRrUIBdiolWaUw_iVDBAt37y8j1HzebtwP2zF0b_wlcTmRmjRNG_F9Fvod1N7MHL_ZF6bd6eeQnEpyIizQs2Wb7OfEa_8M20IJBOBSXAxiwuzUTiV_G4taGvFyj8a6jz6aziRe86jKw"

echo "Creating lineage relationships manually..."

# Get the table IDs first
echo "Fetching table information..."

# Get customers table ID
CUSTOMERS_RESPONSE=$(curl -s -X GET "http://localhost:8585/api/v1/tables/name/retail_mysql.default.retail_demo.customers" \
  -H "Authorization: Bearer $TOKEN")
CUSTOMERS_ID=$(echo "$CUSTOMERS_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

# Get products table ID
PRODUCTS_RESPONSE=$(curl -s -X GET "http://localhost:8585/api/v1/tables/name/retail_mysql.default.retail_demo.products" \
  -H "Authorization: Bearer $TOKEN")
PRODUCTS_ID=$(echo "$PRODUCTS_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

# Get sales table ID
SALES_RESPONSE=$(curl -s -X GET "http://localhost:8585/api/v1/tables/name/retail_mysql.default.retail_demo.sales" \
  -H "Authorization: Bearer $TOKEN")
SALES_ID=$(echo "$SALES_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

# Get sales_report_daily_customer table ID
REPORT_RESPONSE=$(curl -s -X GET "http://localhost:8585/api/v1/tables/name/retail_mysql.default.retail_demo.sales_report_daily_customer" \
  -H "Authorization: Bearer $TOKEN")
REPORT_ID=$(echo "$REPORT_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

echo "Table IDs:"
echo "  Customers: $CUSTOMERS_ID"
echo "  Products: $PRODUCTS_ID"
echo "  Sales: $SALES_ID"
echo "  Sales Report: $REPORT_ID"

# Create lineage from customers to sales
if [ ! -z "$CUSTOMERS_ID" ] && [ ! -z "$SALES_ID" ]; then
    echo "Creating lineage: customers -> sales"
    curl -s -X POST "http://localhost:8585/api/v1/lineage" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"edge\": {
          \"fromEntity\": {
            \"id\": \"$CUSTOMERS_ID\",
            \"type\": \"table\"
          },
          \"toEntity\": {
            \"id\": \"$SALES_ID\",
            \"type\": \"table\"
          },
          \"lineageDetails\": {
            \"pipeline\": {
              \"name\": \"retail_data_pipeline\",
              \"displayName\": \"Retail Data Pipeline\"
            },
            \"description\": \"Customer data flows to sales transactions\"
          }
        }
      }"
    echo ""
fi

# Create lineage from products to sales
if [ ! -z "$PRODUCTS_ID" ] && [ ! -z "$SALES_ID" ]; then
    echo "Creating lineage: products -> sales"
    curl -s -X POST "http://localhost:8585/api/v1/lineage" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"edge\": {
          \"fromEntity\": {
            \"id\": \"$PRODUCTS_ID\",
            \"type\": \"table\"
          },
          \"toEntity\": {
            \"id\": \"$SALES_ID\",
            \"type\": \"table\"
          },
          \"lineageDetails\": {
            \"pipeline\": {
              \"name\": \"retail_data_pipeline\",
              \"displayName\": \"Retail Data Pipeline\"
            },
            \"description\": \"Product data flows to sales transactions\"
          }
        }
      }"
    echo ""
fi

# Create lineage from sales to sales_report_daily_customer
if [ ! -z "$SALES_ID" ] && [ ! -z "$REPORT_ID" ]; then
    echo "Creating lineage: sales -> sales_report_daily_customer"
    curl -s -X POST "http://localhost:8585/api/v1/lineage" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"edge\": {
          \"fromEntity\": {
            \"id\": \"$SALES_ID\",
            \"type\": \"table\"
          },
          \"toEntity\": {
            \"id\": \"$REPORT_ID\",
            \"type\": \"table\"
          },
          \"lineageDetails\": {
            \"pipeline\": {
              \"name\": \"retail_aggregation_pipeline\",
              \"displayName\": \"Retail Aggregation Pipeline\"
            },
            \"description\": \"Sales data is aggregated into daily customer reports\"
          }
        }
      }"
    echo ""
fi

echo "Lineage relationships created successfully!"
echo "You can now view the lineage in the OpenMetadata UI at http://localhost:8585" 