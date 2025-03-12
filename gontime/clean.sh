#!/bin/zsh

PROJECT_ROOT=$(pwd)

find "$PROJECT_ROOT" -name "*.swift" | while read -r FILE; do
# Generate relative file path
REL_PATH=${FILE#$PROJECT_ROOT/}

# Remove top lines beginning with // or whitespace/newlines
sed -i '' -e ':a' -e '/^\(\/\/.*\|[[:space:]]*\)$/ {d;N;ba;}' "$FILE"

# Remove trailing lines that are comments or whitespace
sed -i '' -e ':a' -e '$!{N;ba;}' -e ':b' -e '/^\(\/\/.*\|[[:space:]]*\)$/{$d;bb;}' "$FILE"

# Add standardized header at the top
HEADER="//\n//  ${REL_PATH}\n//  gOnTime\n//\n//  Copyright 2025 Google LLC\n//\n//  Author: timfee@ (Tim Feeley)\n//\n"

# Insert the new header
sed -i '' "1s|^|$HEADER\\n|" "$FILE"
done

# Run swift-format on all files
find "$PROJECT_ROOT" -name "*.swift" -exec swift-format -i {} \;

echo "Swift files updated and formatted successfully."
