# The output of healthcheck script should be exactly 'OK' to consider health check to be successful.

# Uncomment (provide valid username:password and port number):
# curl -s -u testonly:test -X POST http://127.0.0.1:8080/rest/health

# Dummy no-op healthcheck
echo 'OK'

