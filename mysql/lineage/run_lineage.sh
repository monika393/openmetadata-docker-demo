#!/bin/bash

# Script to run MySQL lineage ingestion for OpenMetadata
# This script extracts data lineage information from MySQL

echo "Starting MySQL lineage ingestion..."

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
    echo "This might cause issues with lineage ingestion"
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

# Copy the YAML configuration to the ingestion container
echo "Copying configuration to ingestion container..."
docker cp mysql_lineage_simple.yaml openmetadata_ingestion:/opt/airflow/dags/

# Run the lineage ingestion using the container
echo "Running lineage ingestion..."
docker exec openmetadata_ingestion metadata lineage -c /opt/airflow/dags/mysql_lineage_simple.yaml

echo "MySQL lineage ingestion completed!"
echo "You can now view the lineage information in the OpenMetadata UI at http://localhost:8585" 