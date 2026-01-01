#!/usr/bin/env python3
"""
Simple test suite for checking common errors in markdown files.
This module provides a framework for defining regex patterns that should never
occur in the source markdown files, with support for exceptions.
"""

import re
from pathlib import Path
import sys
from typing import List, Optional


class TestPattern:
    """A class to represent a test pattern with description, regex, and exceptions."""

    def __init__(
        self, description: str, pattern: str, exceptions: Optional[List[str]] = None
    ):
        """
        Initialize a test pattern.

        Args:
            description: Description of what the test checks
            pattern: Regex pattern to search for
            exceptions: List of strings that are acceptable exceptions
        """
        self.description = description
        self.pattern = pattern
        self.exceptions = exceptions or []

    def __str__(self):
        """Return a string representation of the test pattern."""
        result = f"Test: {self.description}\n"
        result += f"  Pattern: {self.pattern}\n"
        if self.exceptions:
            result += f"  Exceptions: {self.exceptions}\n"
        return result

    def __repr__(self):
        """Return a detailed representation of the test pattern."""
        return f"TestPattern(description='{self.description}', pattern='{self.pattern}', exceptions={self.exceptions})"


class FileTestPattern:
    """A class to represent a file-wide test pattern with description, regex, and exceptions."""

    def __init__(
        self, description: str, pattern: str, exceptions: Optional[List[str]] = None
    ):
        """
        Initialize a file-wide test pattern.

        Args:
            description: Description of what the test checks
            pattern: Regex pattern to search for in the entire file content
            exceptions: List of strings that are acceptable exceptions
        """
        self.description = description
        self.pattern = pattern
        self.exceptions = exceptions or []

    def __str__(self):
        """Return a string representation of the file test pattern."""
        result = f"File Test: {self.description}\n"
        result += f"  Pattern: {self.pattern}\n"
        if self.exceptions:
            result += f"  Exceptions: {self.exceptions}\n"
        return result

    def __repr__(self):
        """Return a detailed representation of the file test pattern."""
        return f"FileTestPattern(description='{self.description}', pattern='{self.pattern}', exceptions={self.exceptions})"


# Define test patterns
# Define test patterns
TEST_PATTERNS: List[TestPattern] = [
    # Example patterns (replace or modify these as needed)
    TestPattern(
        "space quote ' >'",
        "^ >",
        [],
    ),
    TestPattern(
        "quote no space '>Some text",
        r">\S",
        [],
    ),
    TestPattern(
        "Italics starts with * but does not close with *",
        r"^[^*]*\*[^*]*$",
        [],
    ),
    TestPattern(
        "Reference links without display text",
        r"\[\[(?![^\]|]*\.(mp3|svg))[^\]|]+\]\](?!\{)",
        # Matches [[target]] but not [[target|display]] and excludes .mp3 and .svg files
        [],
    ),
    TestPattern(
        "Single dash for quotations",
        r"^ - \*.*\*$",
        [],
    ),
    TestPattern(
        "Triple dash for quotations",
        r"^ --- \*.*\*$",
        [],
    ),
    TestPattern(
        "No Space before quote '>--'",
        ">--",
        [],
    ),
]

FILE_TEST_PATTERNS: List[FileTestPattern] = [
    FileTestPattern(
        "Multiple consecutive blank lines",
        r"\n\s*\n\s*\n",
        # Matches three or more newlines with optional whitespace in between
        [],
    ),
]


def check_filename_pattern(md_files: List[Path]) -> bool:
    """
    Check if filenames follow the correct pattern (number.number. title.md).

    Args:
        md_files: List of markdown file paths

    Returns:
        bool: True if all filenames are correct, False otherwise
    """
    pattern_passed = True

    # Pattern for incorrect filename format: number.number title.md (missing dot)
    incorrect_pattern = re.compile(r"^[0-9]+\.[0-9]+ [^\.].*\.md$")

    for md_file in md_files:
        filename = md_file.name
        # Skip files that don't start with a number
        if not re.match(r"^[0-9]", filename):
            continue

        # Check if filename matches the incorrect pattern
        if incorrect_pattern.match(filename):
            print("FAIL")
            print(f"File:    {filename}")
            print(
                "Pattern: Filename should be number.number. title.md not number.number title.md"
            )
            print(f"Found:   {filename}")
            print()
            pattern_passed = False

    return pattern_passed


def run_tests(source_dir: Path) -> bool:
    """
    Run all tests on markdown files in the source directory.

    Args:
        source_dir: Path to the source directory containing markdown files

    Returns:
        bool: True if all tests pass, False otherwise
    """
    # Find all markdown files
    md_files = list(source_dir.glob("*.md"))

    if not md_files:
        print("No markdown files found in source directory")
        return True

    all_tests_passed = True
    # Include the filename pattern check in the total test count
    total_tests = (
        len(TEST_PATTERNS) + len(FILE_TEST_PATTERNS) + 1
    )  # +1 for filename check
    passed_tests = 0

    # Run line-based tests
    for test_pattern in TEST_PATTERNS:
        # print(f"\nRunning test: {test_pattern.description}")
        # print(f"Pattern: {test_pattern.pattern}")

        pattern_passed = True

        # Compile the regex pattern
        try:
            regex = re.compile(test_pattern.pattern)
        except re.error as e:
            print(f"  ERROR: Invalid regex pattern: {e}")
            all_tests_passed = False
            continue

        # Check each markdown file
        for md_file in md_files:
            try:
                content = md_file.read_text(encoding="utf-8")
                lines = content.splitlines()

                # Check each line in the file
                for line_num, line in enumerate(lines, 1):
                    # Skip empty lines
                    if not line.strip():
                        continue

                    # Check if pattern matches
                    match = regex.search(line)
                    if match:
                        # Check if this match is in exceptions
                        is_exception = False
                        for exception in test_pattern.exceptions:
                            if exception in line:
                                is_exception = True
                                break

                        # If not an exception, report the error
                        if not is_exception:
                            print("FAIL")
                            print(f"File:    {md_file.name}")
                            print(f"Line:    {line_num}")
                            print(f"Pattern: {test_pattern.pattern}")
                            print(f"Found:   {line.strip()}")
                            print()
                            pattern_passed = False

            except Exception as e:
                print(f"  ERROR reading {md_file.name}: {e}")
                pattern_passed = False

        if pattern_passed:
            passed_tests += 1
        else:
            all_tests_passed = False

    # Run file-based tests
    for file_test_pattern in FILE_TEST_PATTERNS:
        # print(f"\nRunning file test: {file_test_pattern.description}")
        # print(f"Pattern: {file_test_pattern.pattern}")

        pattern_passed = True

        # Compile the regex pattern
        try:
            regex = re.compile(file_test_pattern.pattern)
        except re.error as e:
            print(f"  ERROR: Invalid regex pattern: {e}")
            all_tests_passed = False
            continue

        # Check each markdown file
        for md_file in md_files:
            try:
                content = md_file.read_text(encoding="utf-8")

                # Check if pattern matches in the entire file content
                matches = regex.finditer(content)
                for match in matches:
                    # Check if this match is in exceptions
                    is_exception = False
                    for exception in file_test_pattern.exceptions:
                        if exception in match.group(0):
                            is_exception = True
                            break

                    # If not an exception, report the error
                    if not is_exception:
                        print("FAIL")
                        print(f"File:    {md_file.name}")
                        print(f"Pattern: {file_test_pattern.pattern}")
                        print(f"Found:   {repr(match.group(0))}")
                        print()
                        pattern_passed = False

            except Exception as e:
                print(f"  ERROR reading {md_file.name}: {e}")
                pattern_passed = False

        if pattern_passed:
            passed_tests += 1
        else:
            all_tests_passed = False

    # Run filename pattern check
    print("\nRunning filename pattern check...")
    if check_filename_pattern(md_files):
        passed_tests += 1
        print("Filename pattern check passed!")
    else:
        all_tests_passed = False
        print("Filename pattern check failed!")

    # Print summary
    print(f"\nTests: {passed_tests}/{total_tests} passed")
    print()

    return all_tests_passed


def add_test(description: str, pattern: str, exceptions: Optional[List[str]] = None):
    """
    Add a new test pattern to the test suite.

    Args:
        description: Description of what the test checks
        pattern: Regex pattern to search for
        exceptions: List of strings that are acceptable exceptions
    """
    new_test = TestPattern(description, pattern, exceptions)
    TEST_PATTERNS.append(new_test)
    print(f"Added line test: {description}")


def add_file_test(
    description: str, pattern: str, exceptions: Optional[List[str]] = None
):
    """
    Add a new file-wide test pattern to the test suite.

    Args:
        description: Description of what the test checks
        pattern: Regex pattern to search for in the entire file content
        exceptions: List of strings that are acceptable exceptions
    """
    new_test = FileTestPattern(description, pattern, exceptions)
    FILE_TEST_PATTERNS.append(new_test)
    print(f"Added file test: {description}")


def list_tests():
    """Print all currently defined tests."""
    print("Current line-based test patterns:")
    for i, test_pattern in enumerate(TEST_PATTERNS, 1):
        print(f"  {i}. {test_pattern}")

    print("\nCurrent file-based test patterns:")
    for i, file_test_pattern in enumerate(FILE_TEST_PATTERNS, 1):
        print(f"  {i}. {file_test_pattern}")


def print_test_patterns():
    """Print just the test patterns (regex) for easy reference."""
    print("Line-based Test Patterns:")
    for i, test_pattern in enumerate(TEST_PATTERNS, 1):
        print(f"  {i}. {test_pattern.pattern}")

    print("\nFile-based Test Patterns:")
    for i, file_test_pattern in enumerate(FILE_TEST_PATTERNS, 1):
        print(f"  {i}. {file_test_pattern.pattern}")


def main():
    """Main function to run tests independently."""
    print("\n--- Running files tests ---")

    # Calculate the correct source directory path
    project_root = Path(__file__).parent
    source_dir = project_root / "source"

    print(f"Running tests on markdown files in: {source_dir}")
    print()

    if run_tests(source_dir):
        print("\nAll tests passed!")
        return True
    else:
        print("\nSome tests failed!")
        return False


if __name__ == "__main__":
    if not main():
        sys.exit(1)
