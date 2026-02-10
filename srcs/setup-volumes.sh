#!/bin/sh
# Create data directories for named volumes (required by docker-compose driver_opts)
# DATA_PATH is set by Makefile (e.g. /home/aarustam/data); fallback if run manually
DATA_DIR="${DATA_PATH:-/home/aarustam/data}"
mkdir -p "$DATA_DIR/wordpress_data" "$DATA_DIR/mariadb_data"
echo "Data directories created at $DATA_DIR"
