#!/bin/bash
echo "=== Démarrage WORKER $(hostname) ==="
service ssh start
ssh-keyscan -H spark-master >> ~/.ssh/known_hosts 2>/dev/null
while ! nc -z spark-master 9000; do sleep 2; done
echo "=== Worker prêt ==="
tail -f /dev/null
