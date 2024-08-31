import re
import uuid
from datetime import datetime
import sys

def modify_update_script(input_script, output_script):
    # Generate a single UUID for this script version
    script_uuid = str(uuid.uuid4())

    # Read the input script
    with open(input_script, 'r') as file:
        script_content = file.read()

    # Regular expressions for matching INSERT and UPDATE statements
    insert_pattern = re.compile(r'INSERT\s+INTO\s+(\w+)\s*\((.*?)\)\s*VALUES\s*\((.*?)\)', re.IGNORECASE | re.DOTALL)
    update_pattern = re.compile(r'UPDATE\s+(\w+)\s+SET\s+(.*?)\s+WHERE\s+(.*?);', re.IGNORECASE | re.DOTALL)

    # Function to add UUID to INSERT statements and skip sqlite_sequence
    def modify_insert(match):
        table = match.group(1)
        if table.lower() == 'sqlite_sequence':
            return ''  # Skip this INSERT statement
        columns = match.group(2)
        values = match.group(3)
        if 'uuid' not in columns.lower():
            columns += ', uuid'
            values += f", '{script_uuid}'"
        return f"INSERT INTO {table} ({columns}) VALUES ({values})"

    # Function to add UUID to UPDATE statements and skip sqlite_sequence
    def modify_update(match):
        table = match.group(1)
        if table.lower() == 'sqlite_sequence':
            return ''  # Skip this UPDATE statement
        set_clause = match.group(2)
        where_clause = match.group(3)
        if 'uuid' not in set_clause.lower():
            set_clause += f", uuid = '{script_uuid}'"
        return f"UPDATE {table} SET {set_clause} WHERE {where_clause};"

    # Modify INSERT and UPDATE statements
    modified_script = insert_pattern.sub(modify_insert, script_content)
    modified_script = update_pattern.sub(modify_update, modified_script)

    # Remove any empty lines that might have been created by skipping statements
    modified_script = '\n'.join(line for line in modified_script.split('\n') if line.strip())

    # Add entry to tblVersion
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    version_entry = f"INSERT INTO tblVersion (uuid, data_time) VALUES ('{script_uuid}', '{current_time}');"
    modified_script += "\n" + version_entry

    # Write the modified script
    with open(output_script, 'w') as file:
        file.write(modified_script)

    print(f"Modified script has been saved as {output_script}")
    print(f"Script version UUID: {script_uuid}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py old_script.sql new_script.sql")
        sys.exit(1)

    input_script = sys.argv[1]
    output_script = sys.argv[2]
    modify_update_script(input_script, output_script)