#!/usr/bin/env python3
"""
Secure Secret Key Generator

This script generates cryptographically secure secret keys using Python's `secrets` module.
You can customize the length, encoding, and number of keys to generate.

Usage:
    python generate_secrets.py [-h] [-n NUM_BYTES] [-e {urlsafe,hex,base64}] [-c COUNT] [-o OUTPUT]

Example:
    python generate_secrets.py -n 32 -e urlsafe -c 5 -o secrets.txt
"""

import secrets
import argparse
import sys
import base64

def generate_secret(num_bytes=32, encoding='urlsafe'):
    """
    Generates a cryptographically secure secret key.

    Args:
        num_bytes (int): Number of bytes to generate.
        encoding (str): One of 'urlsafe', 'hex', or 'base64'.

    Returns:
        str: The generated secret key in the specified encoding.

    Raises:
        ValueError: If the encoding is unsupported.
    """
    if encoding == 'urlsafe':
        return secrets.token_urlsafe(num_bytes)
    if encoding == 'hex':
        return secrets.token_hex(num_bytes)
    if encoding == 'base64':
        token = secrets.token_bytes(num_bytes)
        return base64.b64encode(token).decode('utf-8')

    raise ValueError("Unsupported encoding type. Choose from 'urlsafe', 'hex', 'base64'.")

def parse_arguments():
    """
    Parse command-line arguments and return them as an argparse.Namespace object.
    Shows a help menu if no arguments are provided or if -h/--help is used.
    """
    parser = argparse.ArgumentParser(
        description="Generate cryptographically secure secret keys.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument(
        '-n', '--num_bytes',
        type=int,
        default=32,
        help='Number of bytes for each secret key.'
    )
    parser.add_argument(
        '-e', '--encoding',
        type=str,
        choices=['urlsafe', 'hex', 'base64'],
        default='urlsafe',
        help='Encoding type for the secret keys.'
    )
    parser.add_argument(
        '-c', '--count',
        type=int,
        default=1,
        help='Number of secret keys to generate.'
    )
    parser.add_argument(
        '-o', '--output',
        type=str,
        default=None,
        help='Output file to save the secret keys. If not specified, the keys are printed to the console.'
    )

    # If no arguments are provided OR if -h or --help is requested, print help and exit.
    if len(sys.argv) == 1 or '-h' in sys.argv or '--help' in sys.argv:
        parser.print_help()
        sys.exit(0)

    return parser.parse_args()

def main():
    """
    Main function to generate and optionally save cryptographically secure secret keys.
    """
    args = parse_arguments()

    try:
        # Generate all secrets in a single list comprehension
        secret_keys = [generate_secret(args.num_bytes, args.encoding) for _ in range(args.count)]
    except ValueError as ve:
        print(f"Error: {ve}", file=sys.stderr)
        sys.exit(1)

    if args.output:
        try:
            with open(args.output, 'a') as output_file:
                for key in secret_keys:
                    output_file.write(key + '\n')
            print(f"{args.count} secret key(s) have been written to '{args.output}'.")
        except IOError as io_err:
            print(f"File I/O error: {io_err}", file=sys.stderr)
            sys.exit(1)
    else:
        for idx, key in enumerate(secret_keys, start=1):
            print(f"Secret Key {idx}: {key}")

if __name__ == "__main__":
    main()
