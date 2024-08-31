import re
import uuid
from datetime import datetime
import sys

def get_table_columns(table):
    schema = {
        'tblVersion': ['uuid', 'data_time'],
        'android_metadata': ['locale', 'uuid'],
        'point_ray_db': ['id_ray_db', 'name_ray_db', 'date_ray_db', 'caster_ip_ray_db', 'mount_point_ray_db', 
                         'pitch_tilt_ray_db', 'roll_tilt_ray_db', 'head_tilt_ray_db', 'lat_ray_db', 'lon_ray_db', 
                         'height_ray_db', 'ant_height_ray_db', 'base_lat_ray_db', 'base_lon_ray_db', 'base_height_ray_db', 
                         'hdop_ray_db', 'vdop_ray_db', 'pdop_ray_db', 'hrms_ray_db', 'vrms_ray_db', 'num_sat_used_ray_db', 
                         'num_sat_tracked_ray_db', 'age_ray_db', 'class_ray_db', 'nav_mode_ray_db', 'is_tilt_corrected_ray_db', 
                         'Q_Code', 'picture', 'sigma_ray_db', 'caster_user_ray_db', 'logging_mode_ray_db', 'code', 
                         'description', 'tilt_col_point_db', 'uuid'],
        'multipoint_ray_db': ['id_ray_db', 'name_ray_db', 'date_ray_db', 'point_ids_ray_db', 'line_type_ray_db', 
                              'picture', 'multipoint_color', 'uuid'],
        'multipoint_points_ray_db': ['id_ray_db', 'name_ray_db', 'date_ray_db', 'caster_ip_ray_db', 'mount_point_ray_db', 
                                     'pitch_tilt_ray_db', 'roll_tilt_ray_db', 'head_tilt_ray_db', 'lat_ray_db', 'lon_ray_db', 
                                     'height_ray_db', 'ant_height_ray_db', 'base_lat_ray_db', 'base_lon_ray_db', 'base_height_ray_db', 
                                     'hdop_ray_db', 'vdop_ray_db', 'pdop_ray_db', 'hrms_ray_db', 'vrms_ray_db', 'num_sat_used_ray_db', 
                                     'num_sat_tracked_ray_db', 'age_ray_db', 'class_ray_db', 'nav_mode_ray_db', 'is_tilt_corrected_ray_db',
                                     'sigma_ray_db', 'caster_user_ray_db', 'tilt_col_point_db', 'uuid'],
        'description_project_ray_db': ['description_ray_db', 'model_ray_db', 'date_ray_db', 'reference_ray_db', 
                                       'localization_enable_ray_db', 'localization_ray_db', 'localization_result_ray_db', 
                                       'is_cadastre', 'enable_transformation', 'project_time_zone_ray_db', 'uuid'],
        'custom_field_ray_db': ['id_ray_db', 'name_ray_db', 'description_ray_db', 'line_type_ray_db', 'uuid'],
        'columns_template_ray_db': ['name_ray_db', 'point_columns_list_ray_db', 'point_columns_visibility_ray_db', 
                                    'point_custom_columns_visibility_ray_db', 'polyline_columns_list_ray_db', 
                                    'polyline_columns_visibility_ray_db', 'polyline_custom_columns_visibility_ray_db', 
                                    'polygon_columns_list_ray_db', 'polygon_columns_visibility_ray_db', 
                                    'polygon_custom_columns_visibility_ray_db', 'quick_code_columns_visibility_ray_db', 'uuid'],
        'tblExceptionLog': ['id_ray_db', 'log_info_ray_db', 'date_time_ray_db', 'uuid'],
        'tblQuickCode': ['Id', 'Code', 'Style', 'Color', 'Description', 'GroupId', 'IsActive', 'Size', 'ShortcutKeyCode', 'uuid'],
        'tblQuickCodeGroup': ['Id', 'Title', 'Description', 'IsSelected', 'uuid'],
        'tblCadastreLog': ['id_ray_db', 'data_db', 'uuid']
    }
    
    return schema.get(table, [])

def modify_update_script(input_script, output_script):
    # Generate a single UUID for this script version
    script_uuid = str(uuid.uuid4())

    # Read the input script
    with open(input_script, 'r') as file:
        script_content = file.read()

    # Regular expressions for matching INSERT, UPDATE, and DELETE statements
    insert_pattern = re.compile(r'INSERT\s+INTO\s+(\w+)\s*\((.*?)\)\s*VALUES\s*\((.*?)\)', re.IGNORECASE | re.DOTALL)
    update_pattern = re.compile(r'UPDATE\s+(\w+)\s+SET\s+(.*?)\s+WHERE\s+(.*?);', re.IGNORECASE | re.DOTALL)
    delete_pattern = re.compile(r'DELETE\s+FROM\s+(\w+)\s+WHERE\s+(.*?);', re.IGNORECASE | re.DOTALL)

    # Function to add UUID to INSERT statements
    def modify_insert(match):
        table = match.group(1)
        columns = match.group(2)
        values = match.group(3)
        if 'uuid' not in columns.lower():
            columns += ', uuid'
            values += f", '{script_uuid}'"
        return f"INSERT INTO {table} ({columns}) VALUES ({values})"

    # Function to add UUID to UPDATE statements
    def modify_update(match):
        table = match.group(1)
        set_clause = match.group(2)
        where_clause = match.group(3)
        if 'uuid' not in set_clause.lower():
            set_clause += f", uuid = '{script_uuid}'"
        return f"UPDATE {table} SET {set_clause} WHERE {where_clause};"

    # Function to convert DELETE to UPDATE with NULL values
    def convert_delete_to_update(match):
        table = match.group(1)
        where_clause = match.group(2)
        
        # Get all column names for the table
        column_names = get_table_columns(table)
        
        # Create SET clause with NULL values for all columns except the primary key
        primary_key = column_names[0]  # Assuming the first column is always the primary key
        set_clause = ', '.join([f"{col} = NULL" for col in column_names if col.lower() != primary_key.lower() and col.lower() != 'uuid'])
        
        # Add UUID to the SET clause
        set_clause += f", uuid = '{script_uuid}'"
        
        return f"UPDATE {table} SET {set_clause} WHERE {where_clause};"

    # Modify INSERT, UPDATE, and DELETE statements
    modified_script = insert_pattern.sub(modify_insert, script_content)
    modified_script = update_pattern.sub(modify_update, modified_script)
    modified_script = delete_pattern.sub(convert_delete_to_update, modified_script)

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