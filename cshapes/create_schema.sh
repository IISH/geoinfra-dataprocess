#!/bin/bash

psql -d geo -c 'create schema geoinfra;'

echo "created schema" 2>&1 | tee -a $logfile;
