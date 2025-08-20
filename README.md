# OpenMetadata Docker Setup

## What is OpenMetadata?

OpenMetadata is a unified platform for discovery, observability, and governance powered by a central metadata repository, in-depth lineage, and seamless team collaboration. It is one of the fastest-growing open-source projects with a vibrant community and adoption by a diverse set of companies in a variety of industry verticals.

Based on Open Metadata Standards and APIs, supporting connectors to a wide range of data services, OpenMetadata enables end-to-end metadata management, giving you the freedom to unlock the value of your data assets.

### Key Features

- **Data Discovery**: Find and understand your data assets across multiple systems
- **Data Governance**: Implement policies, standards, and compliance requirements
- **Data Quality**: Monitor and validate data quality with automated testing
- **Data Lineage**: Track data flow and dependencies across your ecosystem
- **Team Collaboration**: Enable data teams to work together effectively
- **Observability**: Monitor data health and performance metrics

## Installation using Docker

### Prerequisites

#### System Requirements
- **Docker** (version 20.10.0 or greater)
- **Docker Compose** (version v2.1.1 or greater)
- **Memory**: At least 6 GiB allocated to Docker
- **CPU**: At least 4 vCPUs allocated to Docker

#### Verify Docker Installation
```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker compose version
```

### Installation Steps

1. **Create a directory for OpenMetadata**
   ```bash
   mkdir open-metadata-docker-setup
   cd open-metadata-docker-setup
   ```

2. **Download Docker Compose File**
   ```bash
   # For MySQL backend
   curl -O https://raw.githubusercontent.com/open-metadata/OpenMetadata/main/docker-compose.yml
   
   # For PostgreSQL backend (alternative)
   curl -O https://raw.githubusercontent.com/open-metadata/OpenMetadata/main/docker-compose-postgres.yml
   ```

3. **Start the Docker Compose Services**
   ```bash
   # For MySQL backend
   docker compose up -d
   
   # For PostgreSQL backend
   docker compose -f docker-compose-postgres.yml up -d
   ```

4. **Verify Installation**
   ```bash
   # Check if all containers are running
   docker ps
   ```

### Access OpenMetadata

- **OpenMetadata UI**: http://localhost:8585
  - Username: `admin@open-metadata.org`
  - Password: `admin`

- **Airflow UI**: http://localhost:8080
  - Username: `admin`
  - Password: `admin`

### Container Management

```bash
# Stop services
docker compose down

# Start services
docker compose up -d

# Stop and remove volumes (cleanup)
docker compose down --volumes
```

## Data Ingestion Setup

This project includes a comprehensive MySQL ingestion pipeline with organized scripts for different ingestion types.

### Project Structure

```
open-metadata-docker-setup/
├── csv/                          # Sample CSV data files
│   ├── customers.csv
│   ├── products.csv
│   ├── sales.csv
│   └── sales_report_daily_customer.csv
├── mysql/                        # MySQL ingestion components
│   ├── data_loading/             # CSV data loading and MySQL setup
│   │   ├── docker_csv_loader.sh
│   │   └── container_mysql_loader.sh
│   ├── metadata/                 # Metadata ingestion
│   │   ├── mysql_metadata_ingestion.yaml
│   │   └── run_metadata_ingestion.sh
│   ├── profiler/                 # Data profiling
│   │   ├── mysql_profiler.yaml
│   │   └── run_profiler.sh
│   ├── data_quality/             # Data quality tests
│   │   ├── mysql_data_quality.yaml
│   │   ├── mysql_data_quality_sales_simple.yaml
│   │   ├── mysql_data_quality_products.yaml
│   │   ├── mysql_data_quality_report.yaml
│   │   └── run_data_quality.sh
│   ├── lineage/                  # Data lineage
│   │   ├── mysql_lineage.yaml
│   │   ├── mysql_lineage_simple.yaml
│   │   ├── run_lineage.sh
│   │   └── create_lineage_manually.sh
│   ├── run_all_ingestions.sh     # Main orchestration script
│   └── README.md                 # Detailed ingestion documentation
└── README.md                     # This file
```

### Quick Start - Complete Ingestion Pipeline

1. **Navigate to MySQL directory**
   ```bash
   cd mysql
   ```

2. **Run complete ingestion pipeline**
   ```bash
   ./run_all_ingestions.sh
   ```

This script will execute all ingestion components in sequence:
- Load CSV data into MySQL
- Ingest metadata (tables, columns, relationships)
- Run data profiling (statistics and quality metrics)
- Execute data quality tests
- Capture data lineage

### Individual Component Execution

#### 1. Data Loading
```bash
./data_loading/docker_csv_loader.sh
```
Loads CSV files into MySQL database and configures users for external connections.

#### 2. Metadata Ingestion
```bash
./metadata/run_metadata_ingestion.sh
```
Extracts table schemas, columns, and relationships from MySQL into OpenMetadata.

#### 3. Data Profiling
```bash
./profiler/run_profiler.sh
```
Analyzes data quality and generates statistical metrics for all tables.

#### 4. Data Quality Tests
```bash
./data_quality/run_data_quality.sh
```
Runs automated data quality tests to validate business rules and data integrity.

#### 5. Lineage Ingestion
```bash
./lineage/run_lineage.sh
```
Captures data flow and dependencies between tables and views.

### What Each Component Provides

#### Data Loading
- Creates MySQL database and tables
- Loads sample retail data from CSV files
- Configures MySQL users for external connections
- Sets up database views for reporting

#### Metadata Ingestion
- Extracts complete table schemas
- Captures column definitions and data types
- Identifies primary keys and foreign keys
- Creates database service in OpenMetadata

#### Data Profiler
- Generates row counts and uniqueness metrics
- Analyzes data distributions and patterns
- Provides column-level statistics
- Identifies data quality issues

#### Data Quality
- Validates business rules (e.g., positive amounts, valid emails)
- Checks data completeness and accuracy
- Monitors referential integrity
- Provides test execution history

#### Lineage
- Maps data flow between tables
- Shows view dependencies
- Tracks data transformations
- Enables impact analysis

### Expected Results

After running the complete pipeline, you'll have access to:

- **Complete Data Catalog**: All tables, columns, and relationships at http://localhost:8585
- **Data Quality Dashboard**: Test results and quality metrics
- **Lineage Visualization**: Data flow diagrams and dependency graphs
- **Profiling Insights**: Statistical analysis and data patterns
- **Search and Discovery**: Find data assets across your ecosystem

### Troubleshooting

#### Common Issues

1. **Container not running**
   ```bash
   docker ps
   docker compose up -d
   ```

2. **Permission denied errors**
   ```bash
   chmod +x *.sh
   chmod +x */*.sh
   ```

3. **Connection failures**
   - Verify MySQL container is running
   - Check user permissions in MySQL
   - Ensure proper network connectivity

#### Logs and Debugging

```bash
# OpenMetadata server logs
docker logs openmetadata_server

# Ingestion container logs
docker logs openmetadata_ingestion

# MySQL container logs
docker logs openmetadata_mysql
```

### Next Steps

1. **Explore the UI**: Navigate to http://localhost:8585 to explore your data catalog
2. **Add More Data Sources**: Integrate additional databases, warehouses, or services
3. **Customize Tests**: Create data quality tests specific to your business rules
4. **Set Up Monitoring**: Configure alerts and notifications for data quality issues
5. **Team Collaboration**: Invite team members and set up access controls

### Resources

- [OpenMetadata Documentation](https://docs.open-metadata.org/latest)
- [Connectors Guide](https://docs.open-metadata.org/latest/connectors)
- [API Documentation](https://docs.open-metadata.org/latest/apis)
- [Community Slack](https://slack.open-metadata.org/)







