#!/bin/sh
set -euo pipefail
rabbitmq-server &
TEMP_PID=$!

echo "Waiting for RabbitMQ to become fully responsive..."

until rabbitmqctl await_startup >/dev/null 2>&1
do
    sleep 2
done

rabbitmqctl add_user $RABBITMQ_USER $RABBITMQ_PASS || true
rabbitmqctl set_permissions -p / $RABBITMQ_USER ".*" ".*" ".*" || true

service rabbitmq-server stop
wait $TEMP_PID

exec rabbitmq-server