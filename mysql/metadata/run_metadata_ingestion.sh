#!/bin/bash

# Script to run MySQL metadata ingestion for OpenMetadata
# This script uses the OpenMetadata ingestion framework to extract metadata from MySQL

echo "Starting MySQL metadata ingestion..."

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
    echo "This might cause issues with metadata ingestion"
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
docker cp mysql_metadata_ingestion.yaml openmetadata_ingestion:/opt/airflow/dags/

# Run the metadata ingestion using the container
echo "Running metadata ingestion..."
docker exec openmetadata_ingestion metadata ingest -c /opt/airflow/dags/mysql_metadata_ingestion.yaml

echo "MySQL metadata ingestion completed!"
echo "You can now view the ingested metadata in the OpenMetadata UI at http://localhost:8585" 