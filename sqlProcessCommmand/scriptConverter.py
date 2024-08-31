import re
import uuid
from datetime import datetime
import sys

def generate_uuid():
    """Generates a unique UUID for the entire script."""
    return str(uuid.uuid4())

def process_sql_commands(sql_script, version_uuid=None):
    """Process the SQL script to add the same UUID to all commands and update tblVersion."""
    if version_uuid is None:
        version_uuid = generate_uuid()
    
    lines = sql_script.splitlines()
    processed_lines = []
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    for line in lines:
        # Process INSERT commands
        if line.strip().upper().startswith("INSERT INTO"):
            table_name = re.search(r'INSERT INTO\s+(\w+)', line, re.IGNORECASE)
            if table_name:
                table_name = table_name.group(1)
                if table_name not in ['android_metadata', 'tblVersion']:
                    # Modify the INSERT statement to include the uuid column and value
                    line = re.sub(
                        r'(\(.*?\))\s*VALUES\s*\((.*?)\)',
                        r"\1, uuid) VALUES (\2, '{}')".format(version_uuid),
                        line,
                        flags=re.IGNORECASE | re.DOTALL
                    )
        
        # Process UPDATE commands
        elif line.strip().upper().startswith("UPDATE"):
            table_name = re.search(r'UPDATE\s+(\w+)', line, re.IGNORECASE)
            if table_name:
                table_name = table_name.group(1)
                if table_name not in ['android_metadata', 'tblVersion']:
                    # Add UUID update to the SET clause
                    line = re.sub(r'SET', f"SET uuid = '{version_uuid}',", line, flags=re.IGNORECASE)
        
        processed_lines.append(line)
    
    # Add a new entry in tblVersion
    tbl_version_entry = f"INSERT INTO tblVersion (uuid, data_time) VALUES ('{version_uuid}', '{timestamp}');"
    processed_lines.append(tbl_version_entry)
    
    return '\n'.join(processed_lines)

def main():
    if len(sys.argv) != 3:
        print("Usage: python script.py old_script.sql new_script.sql")
        sys.exit(1)
    
    old_script_path = sys.argv[1]
    new_script_path = sys.argv[2]
    
    try:
        # Read the old script
        with open(old_script_path, 'r') as file:
            old_script = file.read()
        
        # Process the script
        new_script = process_sql_commands(old_script)
        
        # Write the new script to the output file
        with open(new_script_path, 'w') as file:
            file.write(new_script)
        
        print(f"New script with UUIDs added has been written to {new_script_path}")
    
    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
