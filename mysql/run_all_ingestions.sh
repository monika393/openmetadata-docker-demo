#!/bin/bash

# Comprehensive script to run all OpenMetadata ingestions
# This script runs metadata, profiler, and lineage ingestion in sequence

echo "=========================================="
echo "OpenMetadata Complete Ingestion Pipeline"
echo "=========================================="

# Step 1: Run metadata ingestion
echo ""
echo "Step 1: Running metadata ingestion..."
./metadata/run_metadata_ingestion.sh

if [ $? -ne 0 ]; then
    echo "❌ Metadata ingestion failed"
    exit 1
fi
echo "✅ Metadata ingestion completed"

# Step 2: Run data profiler
echo ""
echo "Step 2: Running data profiler..."
./profiler/run_profiler.sh

if [ $? -ne 0 ]; then
    echo "❌ Data profiler failed"
    exit 1
fi
echo "✅ Data profiler completed"

# Step 3: Run data quality tests
echo ""
echo "Step 3: Running data quality tests..."
./data_quality/run_data_quality.sh

if [ $? -ne 0 ]; then
    echo "❌ Data quality tests failed"
    exit 1
fi
echo "✅ Data quality tests completed"

# Step 4: Run lineage ingestion
echo ""
echo "Step 4: Running lineage ingestion..."
./lineage/run_lineage.sh

if [ $? -ne 0 ]; then
    echo "❌ Lineage ingestion failed"
    exit 1
fi
echo "✅ Lineage ingestion completed"

echo ""
echo "=========================================="
echo "All ingestions completed successfully!"
echo "=========================================="
echo "You can now view your complete data catalog at:"
echo "http://localhost:8585"
echo ""
echo "Available features:"
echo "- 📊 Metadata: Table schemas, columns, and relationships"
echo "- 📈 Profiling: Data quality metrics and statistics"
echo "- 🧪 Data Quality: Test cases and validation rules"
echo "- 🔗 Lineage: Data flow between tables"
echo "==========================================" 