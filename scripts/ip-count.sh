#!/bin/bash
#
# Log Analysis - IP Address Frequency Counter
#
# Parses web log files and outputs IP address counts sorted descending.
# Input format: [timestamp] <ip> <path> <verb> <user-agent>
#
# Usage:
#   ./ip-count.sh logfile.log
#   cat logfile.log | ./ip-count.sh
#
# Output format:
#   <count> <ip>
#
# Example:
#   23 192.168.22.11
#   18 10.32.89.34
#

set -euo pipefail

# Read from file argument or stdin
input="${1:-/dev/stdin}"

# Extract IP addresses (second field), count occurrences, sort descending
# - Skip blank lines
# - Skip malformed lines (no IP in position 2)
# - Handle various whitespace

awk '
    /^[[:space:]]*$/ { next }  # Skip blank lines
    NF < 2 { next }            # Skip lines with fewer than 2 fields
    {
        # IP is the second field after [timestamp]
        ip = $2
        # Validate IP format (basic check)
        if (ip ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
            count[ip]++
        }
    }
    END {
        for (ip in count) {
            print count[ip], ip
        }
    }
' "$input" | sort -rn
