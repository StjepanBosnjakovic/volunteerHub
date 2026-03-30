-- Create additional databases for Rails multi-database setup.
-- The primary database (volunteer_hub_production) is created by POSTGRES_DB env var.
CREATE DATABASE volunteer_hub_production_cache;
CREATE DATABASE volunteer_hub_production_queue;
CREATE DATABASE volunteer_hub_production_cable;
