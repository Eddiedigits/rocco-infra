#!/bin/bash

# Normalize LOGLEVEL to lowercase and use "info" as default
LOGLEVEL_LOWER=$(echo "${LOGLEVEL:-info}" | tr '[:upper:]' '[:lower:]')

case "$LOGLEVEL_LOWER" in
  debug|info|warning|error|critical)
    LOGLEVEL="$LOGLEVEL_LOWER"
    ;;
  *)
    echo "Invalid LOGLEVEL: '$LOGLEVEL'. Falling back to 'info'."
    LOGLEVEL="info"
    ;;
esac

echo "Starting services inside the container..."

# Start Py4web in the foreground
echo "Starting Py4web with loglevel: $LOGLEVEL"
venv/bin/py4web run --password_file password.txt --host 0.0.0.0 --port 8080 apps
