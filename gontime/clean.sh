#!/bin/zsh

PROJECT_ROOT=$(pwd)

find "$PROJECT_ROOT" -name "*.swift" | while read -r FILE; do
# Generate relative file path
REL_PATH=${FILE#"$PROJECT_ROOT/"}
FILE_NAME=$(basename "$REL_PATH")

# Remove leading comments and whitespace/newlines
sed -i '' '/^[[:space:]]*$/d; /^[[:space:]]*\/\//d' "$FILE"

# Remove trailing comments and whitespace
awk '
{ lines[NR] = $0 }
END {
    last_nonempty = NR
    for (i=NR; i>=1; i--) {
        if ($0 ~ /^[[:space:]]*$/ || $0 ~ /^[[:space:]]*\/\//) {
            last_nonempty--
        } else {
            break
        }
    }
    for (i = 1; i <= last_nonempty; i++)
            print lines[i]
}
' "$FILE" > tmp.swift && mv tmp.swift "$FILE"

# Prepare header with filename
FILENAME=$(basename "$FILE")
HEADER="//\n//  $REL_PATH\n//  gOnTime\n//\n//  Copyright 2025 Google LLC\n//\n//  Author: timfee@ (Tim Feeley)\n//\n"

# Insert the new header at the top
(echo -e "$HEADER\n"; cat "$FILE") > tmp.swift && mv tmp.swift "$FILE"
done

# Run swift-format on all Swift files
find "$PROJECT_ROOT" -name "*.swift" -exec swift-format -i {} \;

echo "Swift files updated and formatted successfully."
