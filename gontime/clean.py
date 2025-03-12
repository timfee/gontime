import os
import subprocess
import re
import datetime

PROJECT_NAME = "gOnTime"
AUTHOR_EMAIL = "timfee@"
COPYRIGHT_YEAR = "2025"

def process_swift_file(file_path):
    with open(file_path, 'r+') as f:
        lines = f.readlines()

        # 1. Header and Comment Removal
        lines = remove_leading_comments(lines)
        lines = add_header(lines, file_path)
        lines = remove_trailing_comments(lines)

        # 2. MARK: - Spacing
        lines = handle_mark_spacing(lines)

        # 3. /// Spacing
        lines = handle_doc_comments(lines)

        # 4. Function/Struct/Class Spacing
        lines = handle_function_struct_class_spacing(lines)

        # 5. Brace Handling
        lines = handle_brace_spacing(lines)

    with open(file_path, 'w') as f:
        f.writelines(lines)

    subprocess.run(['swift-format', '-i', file_path])
    print(f"Processed: {os.path.relpath(file_path)}")

def remove_leading_comments(lines):
    i = 0
    while i < len(lines) and (lines[i].strip().startswith('//') or lines[i].strip() == ''):
        i += 1
    return lines[i:]

def add_header(lines, file_path):
    username = os.getenv('USER')
    current_year = datetime.datetime.now().year

    header = [
        '//\n',
        f'//  {os.path.basename(file_path)}\n',
        f'//  {PROJECT_NAME}\n',
        '//\n',
        f'//  Copyright {current_year} Google LLC\n',
        '//\n',
        f'//  Author: {username}@google.com\n',
        '//\n\n',
    ]
    return header + lines

def remove_trailing_comments(lines):
    while lines and (lines[-1].strip().startswith('//') or lines[-1].strip() == ''):
        lines.pop()
    return lines

def handle_mark_spacing(lines):
    modified_lines = []
    for i, line in enumerate(lines):
        if line.strip().startswith("// MARK: -"):
            if modified_lines and modified_lines[-1].strip() != "":
                if modified_lines[-1] != "\n":
                    modified_lines.append("\n")
            modified_lines.append(line)
            if i + 1 < len(lines) and lines[i + 1].strip() != "":
                modified_lines.append("\n")
        else:
            modified_lines.append(line)
    return modified_lines

def handle_doc_comments(lines):
    modified_lines = []
    in_doc_comment_block = False
    for i, line in enumerate(lines):
        if line.strip().startswith("///"):
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
    return modified_lines

def handle_function_struct_class_spacing(lines):
    modified_lines = []
    prev_line = None
    in_function = False
    for i, line in enumerate(lines):
        if prev_line:
            if re.match(r'^\s*func\s', prev_line):
                in_function = True
                if line.strip() == "{":
                    if modified_lines[-1].strip() == "":
                        modified_lines.pop()
                    modified_lines.append(line)
                    prev_line = line
                    continue
            elif re.match(r'^\s*(struct|class)\s', prev_line):
                in_function = False
                if line.strip() != "" and modified_lines[-2] != "\n":
                    modified_lines.insert(len(modified_lines)-1,"\n\n\n")
            elif line.strip() == "}":
                if in_function:
                    modified_lines.append(line)
                    modified_lines.append("\n\n")
                    in_function = False
                    prev_line = line
                    continue
        modified_lines.append(line)
        prev_line = line
    return modified_lines

def handle_brace_spacing(lines):
    modified_lines = []
    prev_line = None
    for i, line in enumerate(lines):
        if prev_line and re.match(r'^\s*func\s', prev_line) and line.strip() == "{":
            if modified_lines[-1].strip() == "":
                modified_lines.pop()
        modified_lines.append(line)
        prev_line = line
    return modified_lines

def main():
    for root, _, files in os.walk('.'):
        for file in files:
            if file.endswith('.swift'):
                file_path = os.path.join(root, file)
                process_swift_file(file_path)

    print("Finished processing all Swift files.")

if __name__ == "__main__":
    main()
