#!/bin/bash

# Script to run MySQL data profiler for OpenMetadata
# This script uses the OpenMetadata ingestion framework to profile MySQL data

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting MySQL data profiler..."

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
    echo "This might cause issues with data profiling"
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
docker cp "$SCRIPT_DIR/mysql_profiler.yaml" openmetadata_ingestion:/opt/airflow/dags/

# Run the profiler using the container
echo "Running data profiler..."
docker exec openmetadata_ingestion metadata profile -c /opt/airflow/dags/mysql_profiler.yaml

echo "MySQL data profiler completed!"
echo "You can now view the profiling results in the OpenMetadata UI at http://localhost:8585" 