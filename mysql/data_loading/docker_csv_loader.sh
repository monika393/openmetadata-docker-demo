#!/bin/bash

# Script to load CSV data into MySQL container
# This script copies CSV files and load script to the container, then executes it

echo "Starting CSV to MySQL load process..."

# Copy CSV files to the container
echo "Copying CSV files to container..."
docker cp csv openmetadata_mysql:/csv

# Copy the load script to the container
echo "Copying load script to container..."
docker cp container_mysql_loader.sh openmetadata_mysql:/root/load.sh

# Execute the load script inside the container
echo "Executing load script inside container..."
docker exec -it openmetadata_mysql bash -lc '
    chmod +x /root/load.sh
    MYSQL_HOST=localhost \
    MYSQL_USER=root \
    MYSQL_PASSWORD=password \
    MYSQL_DB=retail_demo \
    CSV_DIR=/csv \
    /root/load.sh
'

echo "CSV to MySQL load process completed!" 