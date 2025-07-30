#!/bin/bash
echo "Time: $(date)"
echo "SOURCE_BASE_DIR: '$SOURCE_BASE_DIR'"
echo "SUB_DIRS_TO_BACKUP: '$SUB_DIRS_TO_BACKUP'"

IFS=',' read -r -a DIRS_ARRAY <<< "$SUB_DIRS_TO_BACKUP"

for SUB_DIR in "${DIRS_ARRAY[@]}"; do
  FULL_PATH="${SOURCE_BASE_DIR}/${SUB_DIR}"
 
  if [ -d "$FULL_PATH" ]; then
    echo "Printing files in: $FULL_PATH"
    ls -F "$FULL_PATH"
  else
    echo "Error: Directory '$FULL_PATH' does not exist or is not accessible."
  fi
done

echo ""
echo "--- Test script finished ---"