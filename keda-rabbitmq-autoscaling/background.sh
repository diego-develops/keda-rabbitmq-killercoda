#!/bin/bash
set -e

cd /root

if [ ! -d "keda-rabbitmq-killercoda" ]; then
  git clone https://github.com/diego-develops/keda-rabbitmq-killercoda.git
fi

cd /root/keda-rabbitmq-killercoda
git checkout main