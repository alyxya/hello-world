#!/usr/bin/env bash
set -euo pipefail

input_path="${1:-elf_bytes.txt}"
output_path="${2:-helloworld}"

if [[ ! -f "$input_path" ]]; then
  echo "Input file not found: $input_path" >&2
  exit 1
fi

bytes=""
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="${line//$'\r'/}"
  line="${line//[[:space:]]/}"
  if [[ -z "$line" ]]; then
    continue
  fi
  if (( ${#line} % 2 != 0 )); then
    echo "Invalid hex byte sequence length in line: $line" >&2
    exit 1
  fi
  for ((i = 0; i < ${#line}; i += 2)); do
    byte="${line:i:2}"
    if [[ ! "$byte" =~ ^[0-9A-Fa-f]{2}$ ]]; then
      echo "Invalid hex byte: $byte" >&2
      exit 1
    fi
    bytes+="\\x${byte}"
  done
done < "$input_path"

if [[ -z "$bytes" ]]; then
  echo "No bytes found in $input_path" >&2
  exit 1
fi

printf '%b' "$bytes" > "$output_path"
chmod 755 "$output_path"

echo "Created executable '$output_path'"
echo "Run it with: ./$output_path"
