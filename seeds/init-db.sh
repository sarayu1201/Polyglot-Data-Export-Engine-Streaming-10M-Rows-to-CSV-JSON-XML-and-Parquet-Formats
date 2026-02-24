#!/bin/bash

set -e

echo "Starting database initialization and seed..."

# Create the records table
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE TABLE IF NOT EXISTS records (
        id BIGSERIAL PRIMARY KEY,
        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
        name VARCHAR(255) NOT NULL,
        value DECIMAL(18, 4) NOT NULL,
        metadata JSONB NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_records_created_at ON records(created_at);
    CREATE INDEX IF NOT EXISTS idx_records_name ON records(name);
EOSQL

echo "Table created successfully."
echo "Seeding 10 million rows... This will take several minutes."

# Seed the database with 10 million rows
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    INSERT INTO records (name, value, metadata)
    SELECT
        'Record_' || generate_series AS name,
        (random() * 10000)::DECIMAL(18, 4) AS value,
        json_build_object(
            'category', CASE (generate_series % 5)
                WHEN 0 THEN 'A'
                WHEN 1 THEN 'B'
                WHEN 2 THEN 'C'
                WHEN 3 THEN 'D'
                ELSE 'E'
            END,
            'score', (random() * 100)::INT,
            'is_active', (generate_series % 2 = 0),
            'tags', ARRAY['tag' || (generate_series % 10), 'tag' || (generate_series % 20)],
            'details', json_build_object(
                'created_by', 'system',
                'version', (generate_series % 10) + 1,
                'priority', CASE (generate_series % 3)
                    WHEN 0 THEN 'high'
                    WHEN 1 THEN 'medium'
                    ELSE 'low'
                END
            )
        )::JSONB AS metadata
    FROM generate_series(1, 10000000);
EOSQL

echo "Database seeded successfully with 10,000,000 rows!"

# Verify row count
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT COUNT(*) as total_records FROM records;
EOSQL

echo "Database initialization complete!"
