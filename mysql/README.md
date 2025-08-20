# MySQL OpenMetadata Integration

This directory contains organized scripts and configurations for integrating MySQL with OpenMetadata.

## 📁 Folder Structure

```
mysql/
├── data_loading/          # CSV data loading and MySQL setup
│   ├── docker_csv_loader.sh
│   └── container_mysql_loader.sh
├── metadata/              # Metadata ingestion
│   ├── mysql_metadata_ingestion.yaml
│   └── run_metadata_ingestion.sh
├── profiler/              # Data profiling
│   ├── mysql_profiler.yaml
│   └── run_profiler.sh
├── data_quality/          # Data quality tests
│   ├── mysql_data_quality.yaml
│   ├── mysql_data_quality_sales_simple.yaml
│   ├── mysql_data_quality_products.yaml
│   ├── mysql_data_quality_report.yaml
│   └── run_data_quality.sh
├── lineage/               # Data lineage
│   ├── mysql_lineage.yaml
│   ├── mysql_lineage_simple.yaml
│   ├── run_lineage.sh
│   └── create_lineage_manually.sh
├── run_all_ingestions.sh  # Main orchestration script
└── README.md             # This file
```

## 🚀 Quick Start

### Option 1: Run Everything at Once
```bash
./run_all_ingestions.sh
```

### Option 2: Run Individual Components

#### 1. Load CSV Data
```bash
./data_loading/docker_csv_loader.sh
```

#### 2. Ingest Metadata
```bash
./metadata/run_metadata_ingestion.sh
```

#### 3. Run Data Profiler
```bash
./profiler/run_profiler.sh
```

#### 4. Run Data Quality Tests
```bash
./data_quality/run_data_quality.sh
```

#### 5. Ingest Lineage
```bash
./lineage/run_lineage.sh
```

## 📊 What Each Component Does

### Data Loading (`data_loading/`)
- Loads CSV files into MySQL database
- Configures MySQL users for external connections
- Creates tables and views

### Metadata Ingestion (`metadata/`)
- Extracts table schemas, columns, and relationships
- Creates database service in OpenMetadata
- Ingests all table metadata

### Data Profiler (`profiler/`)
- Analyzes data quality and statistics
- Generates column-level metrics
- Provides data insights

### Data Quality (`data_quality/`)
- Runs automated data quality tests
- Validates business rules
- Monitors data integrity

### Lineage (`lineage/`)
- Captures data flow between tables
- Shows view relationships
- Tracks data dependencies

## 🔧 Prerequisites

1. **Docker Containers Running:**
   - `openmetadata_server`
   - `openmetadata_ingestion`
   - `openmetadata_mysql`

2. **CSV Files Available:**
   - `../csv/customers.csv`
   - `../csv/products.csv`
   - `../csv/sales.csv`
   - `../csv/sales_report_daily_customer.csv`

3. **OpenMetadata Access:**
   - Server running on `http://localhost:8585`
   - Valid JWT token configured

## 📈 Expected Results

After running all components, you'll have:

- ✅ **Complete Metadata**: All tables, columns, and relationships
- ✅ **Data Profiling**: Statistical analysis and quality metrics
- ✅ **Data Quality**: Automated validation and monitoring
- ✅ **Lineage**: Data flow visualization
- ✅ **Dashboard**: Full data catalog at `http://localhost:8585`

## 🛠️ Troubleshooting

### Common Issues:
1. **Container not running**: Check with `docker ps`
2. **Connection failed**: Verify MySQL user configuration
3. **Permission denied**: Ensure scripts are executable (`chmod +x *.sh`)

### Logs:
- Check OpenMetadata server logs: `docker logs openmetadata_server`
- Check ingestion logs: `docker logs openmetadata_ingestion`
- Check MySQL logs: `docker logs openmetadata_mysql` 