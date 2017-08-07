# !/bin/bash

# The output of healthcheck script should be exactly "OK" to consider health check to be successful.

# Uncomment and provide valid port number and username:password (if base auth is used):
curl -s -X POST http://127.0.0.1:8080/api/health

