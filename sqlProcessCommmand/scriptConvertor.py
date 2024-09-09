import re
import uuid
from datetime import datetime
import sys

# Generate a single UUID for this script version
script_uuid = str(uuid.uuid4())

def remove_sqlite_sequence_lines(input_script, output_script):
    sqlite_sequence_pattern = re.compile(r'^\s*(INSERT INTO|UPDATE|DELETE FROM)\s+sqlite_sequence', re.IGNORECASE)

    with open(input_script, 'r') as file:
        lines = file.readlines()

    filtered_lines = [
        line for line in lines 
        if not sqlite_sequence_pattern.search(line)
    ]
    with open(output_script, 'w') as file:
        file.writelines(filtered_lines)

def add_version_sql_script(input_script, output_script):

    # Add entry to tblVersion
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    version_entry = f"INSERT INTO tblVersion (uuid, date_time) VALUES ('{script_uuid}', '{current_time}');"

    with open(output_script, 'w') as file:
        file.writelines(version_entry)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py old_script.sql new_script.sql masrt")
        sys.exit(1)

    input_script = sys.argv[1]
    output_script = sys.argv[2]
    if sys.argv[3] == "master":
        remove_sqlite_sequence_lines(input_script, output_script)
    else:
        add_version_sql_script(input_script, output_script)