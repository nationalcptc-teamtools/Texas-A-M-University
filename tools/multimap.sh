#!/usr/bin/env bash
# multimap.sh
# Usage:
#   multimap.sh <ip1> [ip2 ...] [-T1|-T2|-T3|-T4|-T5]
# Examples:
#   ./multimap.sh 192.168.254.1 192.168.254.2
#   ./multimap.sh 192.168.254.1 192.168.254.2 -T4
#
# Requirements: nmap, sudo
# Behavior:
# - Creates ./scans and ./scans/<IP>
# - For each IP runs (in-order): initial, all-ports, udp (with -T#)
# - Runs up to 4 IP sequences concurrently.

set -u

# concurrency limit (max IPs simultaneously scanning)
MAX_CONCURRENCY=4

BASE_DIR="./scans"

# parse optional trailing timeout flag (-T1..-T5)
TIMEOUT_FLAG="-T3"  # default
ARGS=( "$@" )
NUM_ARGS=${#ARGS[@]}

if [ $NUM_ARGS -eq 0 ]; then
  echo "Usage: $0 <ip1> [ip2 ...] [-T1|-T2|-T3|-T4|-T5]"
  exit 1
fi

# check if last argument is a timeout flag
last_arg="${ARGS[$NUM_ARGS-1]}"
if [[ "$last_arg" =~ ^-T[1-5]$ ]]; then
  TIMEOUT_FLAG="$last_arg"
  # remove last arg from ARGS (IPs only)
  unset 'ARGS[$NUM_ARGS-1]'
  # rebuild array without last element
  IPS=( "${ARGS[@]}" )
  echo "using timeout $TIMEOUT_FLAG"
else
  IPS=( "${ARGS[@]}" )
  echo "defaulting to -T3"
fi

if [ ${#IPS[@]} -eq 0 ]; then
  echo "No IPs given."
  exit 1
fi

# Create base directory
if [ ! -d "$BASE_DIR" ]; then
  mkdir -p "$BASE_DIR"
  echo "Created $BASE_DIR"
else
  echo "$BASE_DIR already exists"
fi

# Function: run three scans sequentially for an IP
scan_ip() {
  local ip="$1"
  local ipdir="$BASE_DIR/$ip"

  mkdir -p "$ipdir"

  # initial scan
  sudo nmap "$TIMEOUT_FLAG" -sC -sV "$ip" -oN "$ipdir/initial.txt"
  if [ $? -eq 0 ]; then
    echo "$ip finished initial scan!"
  else
    echo "$ip initial scan FAILED (see $ipdir/initial.txt)"
  fi

  # all-ports scan
  sudo nmap "$TIMEOUT_FLAG" -sC -sV -p- "$ip" -oN "$ipdir/all-ports.txt"
  if [ $? -eq 0 ]; then
    echo "$ip finished all-ports scan!"
  else
    echo "$ip all-ports scan FAILED (see $ipdir/all-ports.txt)"
  fi

  # udp scan
  sudo nmap "$TIMEOUT_FLAG" -sU "$ip" -oN "$ipdir/udp.txt"
  if [ $? -eq 0 ]; then
    echo "$ip finished udp scan!"
  else
    echo "$ip udp scan FAILED (see $ipdir/udp.txt)"
  fi
}

# Trap to kill background scans on Ctrl-C
trap 'echo "Interrupt received, killing background scans..."; \
      pids=$(jobs -p); \
      if [ -n "$pids" ]; then kill $pids 2>/dev/null || true; fi; \
      wait; exit 1' INT TERM

# Launch scans with concurrency limit
for ip in "${IPS[@]}"; do
  # wait until number of running background jobs < MAX_CONCURRENCY
  while true; do
    # count running background jobs started by this shell
    running=$(jobs -pr | wc -l)
    if [ "$running" -lt "$MAX_CONCURRENCY" ]; then
      break
    fi
    sleep 0.5
  done

  ipdir="$BASE_DIR/$ip"
  if [ ! -d "$ipdir" ]; then
    mkdir -p "$ipdir"
    echo "Created $ipdir"
  else
    echo "$ipdir already exists"
  fi

  # start the sequential scans for this IP in the background
  scan_ip "$ip" &
done

# Wait for all background jobs to finish
wait

echo "All scans finished."

