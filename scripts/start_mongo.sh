#!/bin/sh
echo "(Re)Starting mongo..."
mkdir -p backend/bin/mongod/db_data
./scripts/service.sh start mongod 27017 backend/bin/mongod -- mongod --dbpath db_data --nojournal --port 27017
