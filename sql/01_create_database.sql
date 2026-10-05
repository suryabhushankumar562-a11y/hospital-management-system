-- 01_create_database.sql
-- Creates an isolated project schema. No separate database is required.

CREATE SCHEMA IF NOT EXISTS hospital;

SET search_path TO hospital, public;

COMMENT ON SCHEMA hospital IS
'Portfolio Hospital Management & Analytics System schema';
