-- Create a temporary table to store the current UUID
CREATE TABLE IF NOT EXISTS current_uuid (uuid TEXT);

-- Create a trigger to update the UUID whenever tblVersion is updated
CREATE TRIGGER IF NOT EXISTS update_current_uuid
AFTER INSERT ON tblVersion
BEGIN
    DELETE FROM current_uuid;
    INSERT INTO current_uuid SELECT uuid FROM tblVersion ORDER BY date_time DESC LIMIT 1;
END;

-- Trigger for android_metadata
CREATE TRIGGER tr_android_metadata_update
BEFORE UPDATE ON android_metadata
FOR EACH ROW
BEGIN
    INSERT INTO android_metadata (locale, uuid, isDeleted)
    VALUES (NEW.locale,  (SELECT uuid FROM current_uuid), 0);
    SELECT RAISE(IGNORE);
END;

-- Trigger for point_ray_db
CREATE TRIGGER tr_point_ray_db_update
BEFORE UPDATE ON point_ray_db
FOR EACH ROW
BEGIN
    INSERT INTO point_ray_db (
        id_ray_db, name_ray_db, date_ray_db, caster_ip_ray_db, mount_point_ray_db, 
        pitch_tilt_ray_db, roll_tilt_ray_db, head_tilt_ray_db, lat_ray_db, lon_ray_db, 
        height_ray_db, ant_height_ray_db, base_lat_ray_db, base_lon_ray_db, base_height_ray_db, 
        hdop_ray_db, vdop_ray_db, pdop_ray_db, hrms_ray_db, vrms_ray_db, num_sat_used_ray_db, 
        num_sat_tracked_ray_db, age_ray_db, class_ray_db, nav_mode_ray_db, is_tilt_corrected_ray_db, 
        Q_Code, picture, sigma_ray_db, caster_user_ray_db, logging_mode_ray_db, code, description, 
        tilt_col_point_db, uuid, isDeleted
    )
    VALUES (
        NEW.id_ray_db, NEW.name_ray_db, NEW.date_ray_db, NEW.caster_ip_ray_db, NEW.mount_point_ray_db, 
        NEW.pitch_tilt_ray_db, NEW.roll_tilt_ray_db, NEW.head_tilt_ray_db, NEW.lat_ray_db, NEW.lon_ray_db, 
        NEW.height_ray_db, NEW.ant_height_ray_db, NEW.base_lat_ray_db, NEW.base_lon_ray_db, NEW.base_height_ray_db, 
        NEW.hdop_ray_db, NEW.vdop_ray_db, NEW.pdop_ray_db, NEW.hrms_ray_db, NEW.vrms_ray_db, NEW.num_sat_used_ray_db, 
        NEW.num_sat_tracked_ray_db, NEW.age_ray_db, NEW.class_ray_db, NEW.nav_mode_ray_db, NEW.is_tilt_corrected_ray_db, 
        NEW.Q_Code, NEW.picture, NEW.sigma_ray_db, NEW.caster_user_ray_db, NEW.logging_mode_ray_db, NEW.code, NEW.description, 
        NEW.tilt_col_point_db,  (SELECT uuid FROM current_uuid), 0
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for multipoint_ray_db
CREATE TRIGGER tr_multipoint_ray_db_update
BEFORE UPDATE ON multipoint_ray_db
FOR EACH ROW
BEGIN
    INSERT INTO multipoint_ray_db (
        id_ray_db, name_ray_db, date_ray_db, point_ids_ray_db, line_type_ray_db, 
        picture, multipoint_color, uuid, isDeleted
    )
    VALUES (
        NEW.id_ray_db, NEW.name_ray_db, NEW.date_ray_db, NEW.point_ids_ray_db, NEW.line_type_ray_db, 
        NEW.picture, NEW.multipoint_color,  (SELECT uuid FROM current_uuid), 0
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for multipoint_points_ray_db
CREATE TRIGGER tr_multipoint_points_ray_db_update
BEFORE UPDATE ON multipoint_points_ray_db
FOR EACH ROW
BEGIN
    INSERT INTO multipoint_points_ray_db (
        id_ray_db, name_ray_db, date_ray_db, caster_ip_ray_db, mount_point_ray_db, 
        pitch_tilt_ray_db, roll_tilt_ray_db, head_tilt_ray_db, lat_ray_db, lon_ray_db, 
        height_ray_db, ant_height_ray_db, base_lat_ray_db, base_lon_ray_db, base_height_ray_db, 
        hdop_ray_db, vdop_ray_db, pdop_ray_db, hrms_ray_db, vrms_ray_db, num_sat_used_ray_db, 
        num_sat_tracked_ray_db, age_ray_db, class_ray_db, nav_mode_ray_db, is_tilt_corrected_ray_db,
        sigma_ray_db, caster_user_ray_db, tilt_col_point_db, uuid, isDeleted
    )
    VALUES (
        NEW.id_ray_db, NEW.name_ray_db, NEW.date_ray_db, NEW.caster_ip_ray_db, NEW.mount_point_ray_db, 
        NEW.pitch_tilt_ray_db, NEW.roll_tilt_ray_db, NEW.head_tilt_ray_db, NEW.lat_ray_db, NEW.lon_ray_db, 
        NEW.height_ray_db, NEW.ant_height_ray_db, NEW.base_lat_ray_db, NEW.base_lon_ray_db, NEW.base_height_ray_db, 
        NEW.hdop_ray_db, NEW.vdop_ray_db, NEW.pdop_ray_db, NEW.hrms_ray_db, NEW.vrms_ray_db, NEW.num_sat_used_ray_db, 
        NEW.num_sat_tracked_ray_db, NEW.age_ray_db, NEW.class_ray_db, NEW.nav_mode_ray_db, NEW.is_tilt_corrected_ray_db,
        NEW.sigma_ray_db, NEW.caster_user_ray_db, NEW.tilt_col_point_db,  (SELECT uuid FROM current_uuid), 0
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for description_project_ray_db
CREATE TRIGGER tr_description_project_ray_db_update
BEFORE UPDATE ON description_project_ray_db
FOR EACH ROW
BEGIN
    INSERT INTO description_project_ray_db (
        description_ray_db, model_ray_db, date_ray_db, reference_ray_db, localization_enable_ray_db,
        localization_ray_db, localization_result_ray_db, is_cadastre, enable_transformation, 
        project_time_zone_ray_db, uuid, isDeleted
    )
    VALUES (
        NEW.description_ray_db, NEW.model_ray_db, NEW.date_ray_db, NEW.reference_ray_db, NEW.localization_enable_ray_db,
        NEW.localization_ray_db, NEW.localization_result_ray_db, NEW.is_cadastre, NEW.enable_transformation, 
        NEW.project_time_zone_ray_db,  (SELECT uuid FROM current_uuid), 0
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for custom_field_ray_db
CREATE TRIGGER tr_custom_field_ray_db_update
BEFORE UPDATE ON custom_field_ray_db
FOR EACH ROW
BEGIN
    INSERT INTO custom_field_ray_db (
        id_ray_db, name_ray_db, description_ray_db, line_type_ray_db, uuid, isDeleted
    )
    VALUES (
        NEW.id_ray_db, NEW.name_ray_db, NEW.description_ray_db, NEW.line_type_ray_db,  (SELECT uuid FROM current_uuid), 0
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for columns_template_ray_db
CREATE TRIGGER tr_columns_template_ray_db_update
BEFORE UPDATE ON columns_template_ray_db
FOR EACH ROW
BEGIN
    INSERT INTO columns_template_ray_db (
        name_ray_db, point_columns_list_ray_db, point_columns_visibility_ray_db, 
        point_custom_columns_visibility_ray_db, polyline_columns_list_ray_db, 
        polyline_columns_visibility_ray_db, polyline_custom_columns_visibility_ray_db, 
        polygon_columns_list_ray_db, polygon_columns_visibility_ray_db, 
        polygon_custom_columns_visibility_ray_db, quick_code_columns_visibility_ray_db, 
        uuid, isDeleted
    )
    VALUES (
        NEW.name_ray_db, NEW.point_columns_list_ray_db, NEW.point_columns_visibility_ray_db, 
        NEW.point_custom_columns_visibility_ray_db, NEW.polyline_columns_list_ray_db, 
        NEW.polyline_columns_visibility_ray_db, NEW.polyline_custom_columns_visibility_ray_db, 
        NEW.polygon_columns_list_ray_db, NEW.polygon_columns_visibility_ray_db, 
        NEW.polygon_custom_columns_visibility_ray_db, NEW.quick_code_columns_visibility_ray_db, 
         (SELECT uuid FROM current_uuid), 0
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for tblExceptionLog
CREATE TRIGGER tr_tblExceptionLog_update
BEFORE UPDATE ON tblExceptionLog
FOR EACH ROW
BEGIN
    INSERT INTO tblExceptionLog (
        id_ray_db, log_info_ray_db, date_time_ray_db, uuid, isDeleted
    )
    VALUES (
        NEW.id_ray_db, NEW.log_info_ray_db, NEW.date_time_ray_db,  (SELECT uuid FROM current_uuid), 0
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for tblQuickCode
CREATE TRIGGER tr_tblQuickCode_update
BEFORE UPDATE ON tblQuickCode
FOR EACH ROW
BEGIN
    INSERT INTO tblQuickCode (
        Id, Code, Style, Color, Description, GroupId, IsActive, Size, ShortcutKeyCode, uuid, isDeleted
    )
    VALUES (
        NEW.Id, NEW.Code, NEW.Style, NEW.Color, NEW.Description, NEW.GroupId, NEW.IsActive, 
        NEW.Size, NEW.ShortcutKeyCode,  (SELECT uuid FROM current_uuid), 0
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for tblQuickCodeGroup
CREATE TRIGGER tr_tblQuickCodeGroup_update
BEFORE UPDATE ON tblQuickCodeGroup
FOR EACH ROW
BEGIN
    INSERT INTO tblQuickCodeGroup (
        Id, Title, Description, IsSelected, uuid, isDeleted
    )
    VALUES (
        NEW.Id, NEW.Title, NEW.Description, NEW.IsSelected,  (SELECT uuid FROM current_uuid), 0
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for tblCadastreLog
CREATE TRIGGER tr_tblCadastreLog_update
BEFORE UPDATE ON tblCadastreLog
FOR EACH ROW
BEGIN
    INSERT INTO tblCadastreLog (
        id_ray_db, data_db, uuid, isDeleted
    )
    VALUES (
        NEW.id_ray_db, NEW.data_db,  (SELECT uuid FROM current_uuid), 0
    );
    SELECT RAISE(IGNORE);
END;

