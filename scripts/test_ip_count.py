#!/usr/bin/env python3
"""
Unit tests for ip_count.py
"""

import io
import unittest
from collections import Counter

from ip_count import count_ips, format_output, parse_ip_from_line


class TestParseIpFromLine(unittest.TestCase):
    """Tests for parse_ip_from_line function."""

    def test_valid_log_line(self):
        """Should extract IP from valid log line."""
        line = "[29/Sep/2021:10:20:48+0100] 192.168.21.34 /healthz GET Mozilla/5.0"
        self.assertEqual(parse_ip_from_line(line), "192.168.21.34")

    def test_blank_line(self):
        """Should return None for blank lines."""
        self.assertIsNone(parse_ip_from_line(""))
        self.assertIsNone(parse_ip_from_line("   "))
        self.assertIsNone(parse_ip_from_line("\n"))

    def test_malformed_line(self):
        """Should return None for malformed lines."""
        self.assertIsNone(parse_ip_from_line("only one field"))
        self.assertIsNone(parse_ip_from_line("[timestamp] not-an-ip /path"))

    def test_invalid_ip_format(self):
        """Should return None for invalid IP formats."""
        # Note: regex doesn't validate octet ranges, only structure
        self.assertIsNone(parse_ip_from_line("[ts] abc.def.ghi.jkl /path"))
        self.assertIsNone(parse_ip_from_line("[ts] 192.168.1 /path"))
        self.assertIsNone(parse_ip_from_line("[ts] not-an-ip /path"))


class TestCountIps(unittest.TestCase):
    """Tests for count_ips function."""

    def test_basic_counting(self):
        """Should correctly count IP occurrences."""
        log_data = """[ts] 192.168.1.1 /a GET ua
[ts] 192.168.1.2 /b POST ua
[ts] 192.168.1.1 /c GET ua
[ts] 192.168.1.1 /d DELETE ua
"""
        stream = io.StringIO(log_data)
        result = count_ips(stream)

        self.assertEqual(result["192.168.1.1"], 3)
        self.assertEqual(result["192.168.1.2"], 1)

    def test_skips_blank_lines(self):
        """Should skip blank lines without error."""
        log_data = """[ts] 192.168.1.1 /a GET ua

[ts] 192.168.1.1 /b GET ua

[ts] 192.168.1.1 /c GET ua
"""
        stream = io.StringIO(log_data)
        result = count_ips(stream)

        self.assertEqual(result["192.168.1.1"], 3)

    def test_skips_malformed_lines(self):
        """Should skip malformed lines gracefully."""
        log_data = """[ts] 192.168.1.1 /a GET ua
malformed line
[ts] 192.168.1.1 /b GET ua
single
[ts] 192.168.1.1 /c GET ua
"""
        stream = io.StringIO(log_data)
        result = count_ips(stream)

        self.assertEqual(result["192.168.1.1"], 3)
        self.assertEqual(len(result), 1)

    def test_empty_input(self):
        """Should handle empty input."""
        stream = io.StringIO("")
        result = count_ips(stream)

        self.assertEqual(len(result), 0)


class TestFormatOutput(unittest.TestCase):
    """Tests for format_output function."""

    def test_sorted_descending(self):
        """Should format output sorted by count descending."""
        counts = Counter({"192.168.1.1": 10, "10.0.0.1": 5, "172.16.0.1": 20})
        result = format_output(counts)

        lines = result.split("\n")
        self.assertEqual(lines[0], "20 172.16.0.1")
        self.assertEqual(lines[1], "10 192.168.1.1")
        self.assertEqual(lines[2], "5 10.0.0.1")

    def test_empty_counter(self):
        """Should return empty string for empty counter."""
        result = format_output(Counter())
        self.assertEqual(result, "")


if __name__ == "__main__":
    unittest.main()
