# Polyglot Data Export Engine: Streaming 10M Rows to CSV, JSON, XML, and Parquet Formats

## Overview

This is a high-performance, memory-efficient data export engine that streams large datasets (10 million+ rows) to multiple formats: CSV, JSON, XML, and Apache Parquet. The application is designed to handle massive datasets with a strict memory limit of 256MB using streaming techniques.

## Features

- **Multi-Format Export**: Export data to CSV, JSON, XML, and Parquet formats
- **Streaming Architecture**: Uses streaming to maintain constant, low memory usage regardless of dataset size
- **Compression Support**: Optional gzip compression for text-based formats
- **Nested Data Handling**: Properly serializes JSONB data in all export formats
- **Performance Benchmarking**: Built-in endpoint to measure export performance metrics
- **Docker Containerization**: Fully containerized with docker-compose for one-command setup
- **PostgreSQL Integration**: Uses PostgreSQL as the data source with 10M pre-seeded rows

## Architecture

### Technology Stack
- **Runtime**: Node.js with Express.js
- **Database**: PostgreSQL 13
- **Serialization Libraries**:
  - CSV: csv-writer, fast-csv
  - JSON: stream-json or JSONStream
  - XML: xml for streaming
  - Parquet: parquetjs
- **Compression**: Node.js zlib (built-in)

### Key Components
1. **Export Job Manager**: Manages export job creation and tracking
2. **Streaming Exporters**: Format-specific exporters with streaming implementations
3. **Database Connection Pool**: Efficient querying of large datasets
4. **Memory Management**: Chunk-based processing to keep memory usage constant

## Quick Start

### Prerequisites
- Docker
- Docker Compose

### Setup

1. Clone the repository:
```bash
git clone https://github.com/sarayu1201/Polyglot-Data-Export-Engine-Streaming-10M-Rows-to-CSV-JSON-XML-and-Parquet-Formats.git
cd Polyglot-Data-Export-Engine-Streaming-10M-Rows-to-CSV-JSON-XML-and-Parquet-Formats
```

2. Start the application:
```bash
docker-compose up --build
```

The application will be available at `http://localhost:8080`.

## API Documentation

### 1. Create Export Job

**Endpoint:** `POST /exports`

**Request Body:**
```json
{
  "format": "csv",
  "columns": [
    {
      "source": "id",
      "target": "ID"
    },
    {
      "source": "name",
      "target": "Name"
    },
    {
      "source": "value",
      "target": "Value"
    },
    {
      "source": "metadata",
      "target": "Metadata"
    }
  ],
  "compression": "gzip"
}
```

**Response (201 Created):**
```json
{
  "exportId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "pending"
}
```

### 2. Download Exported Data

**Endpoint:** `GET /exports/{exportId}/download`

**Response**: Streams the exported file in the requested format

**Supported Formats:**
- `csv`: Text CSV with Content-Type: text/csv
- `json`: JSON array with Content-Type: application/json
- `xml`: XML document with Content-Type: application/xml
- `parquet`: Binary Parquet file with Content-Type: application/octet-stream

### 3. Performance Benchmark

**Endpoint:** `GET /exports/benchmark`

**Response (200 OK):**
```json
{
  "datasetRowCount": 10000000,
  "results": [
    {
      "format": "csv",
      "durationSeconds": 45.23,
      "fileSizeBytes": 2500000000,
      "peakMemoryMB": 180
    },
    {
      "format": "json",
      "durationSeconds": 52.15,
      "fileSizeBytes": 3200000000,
      "peakMemoryMB": 185
    },
    {
      "format": "xml",
      "durationSeconds": 68.42,
      "fileSizeBytes": 4100000000,
      "peakMemoryMB": 190
    },
    {
      "format": "parquet",
      "durationSeconds": 35.67,
      "fileSizeBytes": 1800000000,
      "peakMemoryMB": 175
    }
  ]
}
```

## Database Schema

### records table

| Column | Type | Constraints |
|--------|------|-------------|
| id | BIGSERIAL | PRIMARY KEY |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL, DEFAULT NOW() |
| name | VARCHAR(255) | NOT NULL |
| value | DECIMAL(18, 4) | NOT NULL |
| metadata | JSONB | NOT NULL |

## Configuration

Environment variables (see `.env.example`):

```env
# Database
DATABASE_URL=postgresql://user:password@db:5432/exports_db
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=exports_db

# Server
PORT=8080
NODE_ENV=production

# Memory limits (container configured with 256m hard limit)
MAX_MEMORY_MB=220
```

## Implementation Details

### Streaming Strategy

Each format uses a streaming approach to avoid buffering entire datasets:

**CSV**: Uses stream-based CSV writer that writes rows incrementally
**JSON**: Uses event-based JSON parser to construct array without loading all data
**XML**: Uses SAX-based XML writer for streaming element generation
**Parquet**: Uses column-oriented streaming to write data in chunks

### Memory Efficiency

- Database queries use cursor-based pagination
- Data chunks are processed one at a time
- Response streams directly to HTTP client
- No intermediate buffering of full datasets
- Memory usage remains constant ~180-220MB regardless of export size

### JSONB Handling

**CSV**: Nested objects are serialized as JSON strings
**JSON**: Native JSON object representation
**XML**: Nested objects converted to XML element hierarchies
**Parquet**: Parquet struct/map types for nested structures

## Performance Benchmarks

Expected performance with 10M rows on standard hardware:

| Format | Duration | File Size | Memory Usage |
|--------|----------|-----------|---------------|
| CSV | ~45-50s | ~2.5GB | ~180MB |
| JSON | ~50-55s | ~3.2GB | ~185MB |
| XML | ~65-70s | ~4.1GB | ~190MB |
| Parquet | ~30-40s | ~1.8GB | ~175MB |

## Testing

Run the test suite:

```bash
npm test
```

Test coverage includes:
- CSV export with all data types
- JSON array streaming
- XML document generation
- Parquet file generation
- JSONB serialization across all formats
- Gzip compression
- Memory usage validation
- API endpoint contracts

## Development

### Project Structure

```
.
├── README.md
├── docker-compose.yml
├── Dockerfile
├── .env.example
├── package.json
├── source_code/
│   ├── server.js
│   ├── config/
│   │   └── database.js
│   ├── routes/
│   │   └── exports.js
│   ├── services/
│   │   ├── exportService.js
│   │   ├── exporters/
│   │   │   ├── csvExporter.js
│   │   │   ├── jsonExporter.js
│   │   │   ├── xmlExporter.js
│   │   │   └── parquetExporter.js
│   │   └── benchmarkService.js
│   └── utils/
│       └── helpers.js
├── seeds/
│   └── init-db.sh
└── tests/
    ├── exports.test.js
    └── exporters.test.js
```

## Contributing

Fork the repository, make your changes, and submit a pull request.

## License

MIT License - see LICENSE file for details

## Author

Vinaya Sarayu Allampalli

## Acknowledgments

Built as part of the Partnr Global Placement Program assignment on high-performance data export systems.
