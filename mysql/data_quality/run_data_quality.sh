#!/bin/bash

# Script to run MySQL data quality tests for OpenMetadata
# This script uses the OpenMetadata test suite framework to validate data quality

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting MySQL data quality tests..."

# Check if OpenMetadata server is running
echo "Checking if OpenMetadata server is accessible..."
if ! curl -s http://localhost:8585/api/v1/version > /dev/null; then
    echo "ERROR: OpenMetadata server is not accessible at http://localhost:8585"
    echo "Please make sure OpenMetadata is running and accessible"
    exit 1
fi

# Check if MySQL container is running
echo "Checking if MySQL container is running..."
if ! docker ps | grep -q openmetadata_mysql; then
    echo "ERROR: MySQL container 'openmetadata_mysql' is not running"
    echo "Please start the MySQL container first"
    exit 1
fi

# Test MySQL connection from ingestion container
echo "Testing MySQL connection from ingestion container..."
if ! docker exec openmetadata_ingestion mysql -h openmetadata_mysql -u root -ppassword -e "SELECT 1;" > /dev/null 2>&1; then
    echo "WARNING: MySQL connection test failed from ingestion container"
    echo "This might cause issues with data quality tests"
    echo "You may need to run the CSV loader script first to configure MySQL users"
fi

# Check if ingestion container is running, start it if not
echo "Checking if OpenMetadata ingestion container is running..."
if ! docker ps | grep -q openmetadata_ingestion; then
    echo "Starting OpenMetadata ingestion container..."
    docker start openmetadata_ingestion
    # Wait a moment for the container to fully start
    sleep 5
fi

# Function to run tests for a specific table
run_tests() {
    local yaml_file="$1"
    local table_name="$2"
    
    echo ""
    echo "Running data quality tests for $table_name..."
    
    # Copy the YAML configuration to the ingestion container
    docker cp "$SCRIPT_DIR/$yaml_file" openmetadata_ingestion:/opt/airflow/dags/
    
    # Run the data quality tests using the container
    docker exec openmetadata_ingestion metadata test -c "/opt/airflow/dags/$yaml_file"
    
    if [ $? -eq 0 ]; then
        echo "✅ Data quality tests for $table_name completed successfully"
    else
        echo "❌ Data quality tests for $table_name failed"
        return 1
    fi
}

# Run tests for each table
run_tests "mysql_data_quality.yaml" "customers"
run_tests "mysql_data_quality_sales_simple.yaml" "sales"

echo ""
echo "=========================================="
echo "Data quality tests completed!"
echo "=========================================="
echo "You can now view the test results in OpenMetadata at:"
echo "http://localhost:8585"
echo ""
echo "Navigate to each table to see:"
echo "- Data Quality tab for test results"
echo "- Test case status and history"
echo "- Data quality metrics and trends"
echo "==========================================" 