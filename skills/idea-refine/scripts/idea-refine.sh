#!/bin/bash
set -e

# This script helps initialize the feature folder for the idea-refine skill.
# Usage: idea-refine.sh <feature-slug>

if [ -z "$1" ]; then
  echo "Usage: idea-refine.sh <feature-slug>" >&2
  exit 1
fi

IDEAS_DIR=".scratch/$1"

if [ ! -d "$IDEAS_DIR" ]; then
  mkdir -p "$IDEAS_DIR"
  echo "Created directory: $IDEAS_DIR" >&2
else
  echo "Directory already exists: $IDEAS_DIR" >&2
fi

echo "{\"status\": \"ready\", \"directory\": \"$IDEAS_DIR\"}"
