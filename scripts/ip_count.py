#!/usr/bin/env python3
"""
Log Analysis - IP Address Frequency Counter (Python)

Parses web log files and outputs IP address counts sorted descending.
Input format: [timestamp] <ip> <path> <verb> <user-agent>

Usage:
    python ip_count.py --file logfile.log
    cat logfile.log | python ip_count.py

Output format:
    <count> <ip>
"""

import argparse
import re
import sys
from collections import Counter
from typing import Optional, TextIO


# IPv4 regex pattern
IP_PATTERN = re.compile(r"^(\d{1,3}\.){3}\d{1,3}$")


def is_valid_ip(ip: str) -> bool:
    """
    Validate IPv4 address format and octet ranges.

    Returns True if IP matches format and all octets are 0-255.
    """
    if not IP_PATTERN.match(ip):
        return False
    try:
        octets = ip.split(".")
        return all(0 <= int(octet) <= 255 for octet in octets)
    except ValueError:
        return False


def parse_ip_from_line(line: str) -> Optional[str]:
    """
    Extract IP address from a log line.

    Expected format: [timestamp] <ip> <path> <verb> <user-agent>
    Returns None for blank or malformed lines.
    """
    line = line.strip()
    if not line:
        return None

    parts = line.split()
    if len(parts) < 2:
        return None

    # IP is the second field (after timestamp)
    ip = parts[1]

    # Validate IP format and octet ranges
    if is_valid_ip(ip):
        return ip

    return None


def count_ips(input_stream: TextIO) -> Counter:
    """
    Count IP address occurrences from a text stream.

    Args:
        input_stream: File-like object to read log lines from

    Returns:
        Counter with IP addresses as keys and counts as values
    """
    ip_counts: Counter = Counter()

    for line in input_stream:
        ip = parse_ip_from_line(line)
        if ip:
            ip_counts[ip] += 1

    return ip_counts


def format_output(ip_counts: Counter) -> str:
    """
    Format IP counts as sorted output string.

    Returns lines in format: "<count> <ip>" sorted by count descending.
    """
    lines = []
    for ip, count in ip_counts.most_common():
        lines.append(f"{count} {ip}")
    return "\n".join(lines)


def main() -> None:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Count IP address frequency from web logs"
    )
    parser.add_argument(
        "--file",
        "-f",
        type=str,
        help="Log file to analyze (reads stdin if not provided)",
    )

    args = parser.parse_args()

    if args.file:
        with open(args.file, "r") as f:
            ip_counts = count_ips(f)
    else:
        ip_counts = count_ips(sys.stdin)

    output = format_output(ip_counts)
    if output:
        print(output)


if __name__ == "__main__":
    main()
