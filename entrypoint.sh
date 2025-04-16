#!/bin/sh

# Start the main application in the background
/usr/bin/dumb-init node server/index.mjs &

# Get the PID of the background process
APP_PID=$!

# Wait for the WireGuard interface to be up
until ip link show wg0 > /dev/null 2>&1; do
  echo "Waiting for wg0 interface..."
  sleep 2
done

echo "wg0 interface is up."

# Apply bandwidth limit if the environment variable is set
if [ -n "$BANDWIDTH_LIMIT" ]; then
  # Example: BANDWIDTH_LIMIT=1mbit
  tc qdisc add dev wg0 root tbf rate $BANDWIDTH_LIMIT limit 150kb burst 15kb
  echo "Bandwidth limited to $BANDWIDTH_LIMIT on wg0"
fi

# Now wait for the background app to finish (keeps the script running)
wait $APP_PID