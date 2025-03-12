import os
import subprocess
import re

PROJECT_NAME = "gOnTime"
AUTHOR_EMAIL = "timfee@"
COPYRIGHT_YEAR = "2025"

def process_swift_file(file_path):
    with open(file_path, 'r+') as f:
        lines = f.readlines()

        # 1. Remove leading comments and whitespace
        i = 0
        while i < len(lines) and (lines[i].strip().startswith('//') or lines[i].strip() == ''):
            i += 1
        lines = lines[i:]

        # 2. Add header
        header = [
            '//\n',
            f'//  {os.path.basename(file_path)}\n',
            f'//  {PROJECT_NAME}\n',
            '//\n',
            f'//  Copyright {COPYRIGHT_YEAR} Google LLC\n',
            '//\n',
            f'//  Author: {AUTHOR_EMAIL} (Tim Feeley)\n',
            '//\n',
        ]
        lines = header + lines

        # 3. Remove trailing comments and whitespace
        while lines and (lines[-1].strip().startswith('//') or lines[-1].strip() == ''):
            lines.pop()

    modified_lines = []
    prev_line = None
    prev_prev_line = None
    in_doc_comment_block = False

    for i, line in enumerate(lines):
        stripped_line = line.strip()

        # MARK: - handling
        if stripped_line.startswith("// MARK: -"):
            if modified_lines and modified_lines[-1].strip() != "":
                if modified_lines[-1] != "\n":
                    modified_lines.append("\n")
            modified_lines.append(line)
            if i + 1 < len(lines) and lines[i + 1].strip() != "":
                modified_lines.append("\n")
            prev_line = line
            prev_prev_line = modified_lines[-2] if len(modified_lines) > 1 else None
            continue

        # /// handling
        if stripped_line.startswith("///"):
            if not in_doc_comment_block:
                if modified_lines and modified_lines[-1].strip() != "":
                    modified_lines.append("\n")
                in_doc_comment_block = True
            modified_lines.append(line)
        else:
            if in_doc_comment_block:
                in_doc_comment_block = False
                modified_lines.append(line)
            else:
                modified_lines.append(line)

        # Function/Struct/Class spacing
        if prev_line:
            if re.match(r'^\s*func\s', prev_line):
                if stripped_line.strip() != "" and modified_lines[-2] != "\n":
                    modified_lines.insert(len(modified_lines)-1,"\n\n")
            elif re.match(r'^\s*(struct|class)\s', prev_line):
                if stripped_line.strip() != "" and modified_lines[-2] != "\n":
                    modified_lines.insert(len(modified_lines)-1,"\n\n\n")

        prev_prev_line = prev_line
        prev_line = line

    with open(file_path, 'w') as f:
        f.writelines(modified_lines)

    subprocess.run(['swift-format', '-i', file_path])
    print(f"Processed: {os.path.relpath(file_path)}")

def main():
    for root, _, files in os.walk('.'):
        for file in files:
            if file.endswith('.swift'):
                file_path = os.path.join(root, file)
                process_swift_file(file_path)

    print("Finished processing all Swift files.")

if __name__ == "__main__":
    main()
