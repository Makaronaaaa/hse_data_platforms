#!/bin/bash


echo "=== Setting up Hadoop web interfaces access ==="

PASSWORD=$(grep 'ansible_ssh_pass' inventory.ini | head -1 | cut -d'=' -f2)

echo "Stopping old tunnels..."
pkill -f "ssh.*-L.*:9870" 2>/dev/null || true
pkill -f "ssh.*-L.*:8088" 2>/dev/null || true
pkill -f "ssh.*-L.*:19888" 2>/dev/null || true

echo "Starting SSH tunnels..."

sshpass -p "$PASSWORD" ssh -fN -o StrictHostKeyChecking=no \
  -L 9870:192.168.1.91:9870 team@176.109.91.43

sshpass -p "$PASSWORD" ssh -fN -o StrictHostKeyChecking=no \
  -L 8088:192.168.1.91:8088 team@176.109.91.43

sshpass -p "$PASSWORD" ssh -fN -o StrictHostKeyChecking=no \
  -L 19888:192.168.1.91:19888 team@176.109.91.43

echo ""
echo "=== Web interfaces are now available ==="
echo "HDFS NameNode:    http://localhost:9870"
echo "YARN ResourceManager: http://localhost:8088"
echo "MapReduce JobHistory: http://localhost:19888"
echo ""
echo "To stop tunnels: pkill -f 'ssh.*-L'"
