import re
import uuid
from datetime import datetime
import sys

# Generate a single UUID for this script version
script_uuid = str(uuid.uuid4())

def get_table_columns(table):
    schema = {
        'tblVersion': ['uuid', 'data_time'],
        'android_metadata': ['locale'],
        'point_ray_db': ['id_ray_db', 'name_ray_db', 'date_ray_db', 'caster_ip_ray_db', 'mount_point_ray_db', 
                         'pitch_tilt_ray_db', 'roll_tilt_ray_db', 'head_tilt_ray_db', 'lat_ray_db', 'lon_ray_db', 
                         'height_ray_db', 'ant_height_ray_db', 'base_lat_ray_db', 'base_lon_ray_db', 'base_height_ray_db', 
                         'hdop_ray_db', 'vdop_ray_db', 'pdop_ray_db', 'hrms_ray_db', 'vrms_ray_db', 'num_sat_used_ray_db', 
                         'num_sat_tracked_ray_db', 'age_ray_db', 'class_ray_db', 'nav_mode_ray_db', 'is_tilt_corrected_ray_db', 
                         'Q_Code', 'picture', 'sigma_ray_db', 'caster_user_ray_db', 'logging_mode_ray_db', 'code', 
                         'description', 'tilt_col_point_db'],
        'multipoint_ray_db': ['id_ray_db', 'name_ray_db', 'date_ray_db', 'point_ids_ray_db', 'line_type_ray_db', 
                              'picture', 'multipoint_color'],
        'multipoint_points_ray_db': ['id_ray_db', 'name_ray_db', 'date_ray_db', 'caster_ip_ray_db', 'mount_point_ray_db', 
                                     'pitch_tilt_ray_db', 'roll_tilt_ray_db', 'head_tilt_ray_db', 'lat_ray_db', 'lon_ray_db', 
                                     'height_ray_db', 'ant_height_ray_db', 'base_lat_ray_db', 'base_lon_ray_db', 'base_height_ray_db', 
                                     'hdop_ray_db', 'vdop_ray_db', 'pdop_ray_db', 'hrms_ray_db', 'vrms_ray_db', 'num_sat_used_ray_db', 
                                     'num_sat_tracked_ray_db', 'age_ray_db', 'class_ray_db', 'nav_mode_ray_db', 'is_tilt_corrected_ray_db',
                                     'sigma_ray_db', 'caster_user_ray_db', 'tilt_col_point_db'],
        'description_project_ray_db': ['description_ray_db', 'model_ray_db', 'date_ray_db', 'reference_ray_db', 
                                       'localization_enable_ray_db', 'localization_ray_db', 'localization_result_ray_db', 
                                       'is_cadastre', 'enable_transformation', 'project_time_zone_ray_db'],
        'custom_field_ray_db': ['id_ray_db', 'name_ray_db', 'description_ray_db', 'line_type_ray_db'],
        'columns_template_ray_db': ['name_ray_db', 'point_columns_list_ray_db', 'point_columns_visibility_ray_db', 
                                    'point_custom_columns_visibility_ray_db', 'polyline_columns_list_ray_db', 
                                    'polyline_columns_visibility_ray_db', 'polyline_custom_columns_visibility_ray_db', 
                                    'polygon_columns_list_ray_db', 'polygon_columns_visibility_ray_db', 
                                    'polygon_custom_columns_visibility_ray_db', 'quick_code_columns_visibility_ray_db'],
        'tblExceptionLog': ['id_ray_db', 'log_info_ray_db', 'date_time_ray_db'],
        'tblQuickCode': ['Id', 'Code', 'Style', 'Color', 'Description', 'GroupId', 'IsActive', 'Size', 'ShortcutKeyCode'],
        'tblQuickCodeGroup': ['Id', 'Title', 'Description', 'IsSelected'],
        'tblCadastreLog': ['id_ray_db', 'data_db']
    }
    
    return schema.get(table, [])


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

def convert_update_to_insert_and_update(match):
    table = match.group(1)
    if table.lower() == 'sqlite_sequence':
        return ''
    set_clause = match.group(2)
    where_clause = match.group(3)
    
    # Step 1: INSERT a copy of the existing row
    insert_statement = f"""INSERT INTO {table} SELECT * FROM {table} WHERE {where_clause} ORDER BY rowid DESC LIMIT 1;"""
    
    # Step 2: UPDATE the newly inserted row
    update_statement = f"""UPDATE {table} SET {set_clause}, uuid = '{script_uuid}' WHERE rowid = ( SELECT rowid FROM {table} WHERE {where_clause} ORDER BY rowid DESC LIMIT 1 );"""
    
    return insert_statement + "\n" + update_statement

# Function to modify INSERT statements (keep as is, just add UUID if not present)
def modify_insert(match):
    table = match.group(1)
    if table.lower() == 'sqlite_sequence':
        return ''
    columns = match.group(2)
    values = match.group(3)
    if 'uuid' not in columns.lower():
        columns += ', uuid'
        values += f", '{script_uuid}'"
    return f"INSERT INTO {table} ({columns}) VALUES ({values})"


# Function to convert DELETE to INSERT with ex values
def convert_delete_to_insert(match):
    table = match.group(1)
    if table.lower() == 'sqlite_sequence':
        return ''
    where_clause = match.group(2)

    insert_statement = f"""INSERT INTO {table} SELECT * FROM {table} WHERE {where_clause} ORDER BY rowid DESC LIMIT 1;"""
    update_statement = f"""UPDATE {table} SET isDeleted = 1, uuid = '{script_uuid}' WHERE rowid = ( SELECT rowid FROM {table} WHERE {where_clause} ORDER BY rowid DESC LIMIT 1 );"""
    
    return insert_statement + "\n" + update_statement

def modify_sql_script(input_script, output_script):
    # Read the input script
    with open(input_script, 'r') as file:
        script_content = file.read()

    # Regular expressions for matching INSERT, UPDATE, and DELETE statements
    insert_pattern = re.compile(r'INSERT\s+INTO\s+(\w+)\s*\((.*?)\)\s*VALUES\s*\((.*?)\)', re.IGNORECASE | re.DOTALL)
    update_pattern = re.compile(r'UPDATE\s+(\w+)\s+SET\s+(.*?)\s+WHERE\s+(.*?);', re.IGNORECASE | re.DOTALL)
    delete_pattern = re.compile(r'DELETE\s+FROM\s+(\w+)\s+WHERE\s+(.*?);', re.IGNORECASE | re.DOTALL)

    # Modify INSERT, convert UPDATE and DELETE to INSERT
    modified_script = insert_pattern.sub(modify_insert, script_content)
    modified_script = update_pattern.sub(convert_update_to_insert_and_update, modified_script)
    modified_script = delete_pattern.sub(convert_delete_to_insert, modified_script)

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
    if len(sys.argv) != 4:
        print("Usage: python script.py old_script.sql new_script.sql masrt")
        sys.exit(1)

    input_script = sys.argv[1]
    output_script = sys.argv[2]
    if sys.argv[3] == "master":
        remove_sqlite_sequence_lines(input_script, output_script)
    else:
        modify_sql_script(input_script, output_script)