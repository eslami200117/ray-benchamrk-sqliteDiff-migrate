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
CREATE TRIGGER tr_android_metadata_delete
BEFORE DELETE ON android_metadata
FOR EACH ROW
BEGIN
    INSERT INTO android_metadata (locale, uuid, isDeleted)
    VALUES (OLD.locale,  (SELECT uuid FROM current_uuid), 1);
    SELECT RAISE(IGNORE);
END;

-- Trigger for point_ray_db
CREATE TRIGGER tr_point_ray_db_delete
BEFORE DELETE ON point_ray_db
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
        OLD.id_ray_db, OLD.name_ray_db, OLD.date_ray_db, OLD.caster_ip_ray_db, OLD.mount_point_ray_db, 
        OLD.pitch_tilt_ray_db, OLD.roll_tilt_ray_db, OLD.head_tilt_ray_db, OLD.lat_ray_db, OLD.lon_ray_db, 
        OLD.height_ray_db, OLD.ant_height_ray_db, OLD.base_lat_ray_db, OLD.base_lon_ray_db, OLD.base_height_ray_db, 
        OLD.hdop_ray_db, OLD.vdop_ray_db, OLD.pdop_ray_db, OLD.hrms_ray_db, OLD.vrms_ray_db, OLD.num_sat_used_ray_db, 
        OLD.num_sat_tracked_ray_db, OLD.age_ray_db, OLD.class_ray_db, OLD.nav_mode_ray_db, OLD.is_tilt_corrected_ray_db, 
        OLD.Q_Code, OLD.picture, OLD.sigma_ray_db, OLD.caster_user_ray_db, OLD.logging_mode_ray_db, OLD.code, OLD.description, 
        OLD.tilt_col_point_db,  (SELECT uuid FROM current_uuid), 1
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for multipoint_ray_db
CREATE TRIGGER tr_multipoint_ray_db_delete
BEFORE DELETE ON multipoint_ray_db
FOR EACH ROW
BEGIN
    INSERT INTO multipoint_ray_db (
        id_ray_db, name_ray_db, date_ray_db, point_ids_ray_db, line_type_ray_db, 
        picture, multipoint_color, uuid, isDeleted
    )
    VALUES (
        OLD.id_ray_db, OLD.name_ray_db, OLD.date_ray_db, OLD.point_ids_ray_db, OLD.line_type_ray_db, 
        OLD.picture, OLD.multipoint_color,  (SELECT uuid FROM current_uuid), 1
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for multipoint_points_ray_db
CREATE TRIGGER tr_multipoint_points_ray_db_delete
BEFORE DELETE ON multipoint_points_ray_db
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
        OLD.id_ray_db, OLD.name_ray_db, OLD.date_ray_db, OLD.caster_ip_ray_db, OLD.mount_point_ray_db, 
        OLD.pitch_tilt_ray_db, OLD.roll_tilt_ray_db, OLD.head_tilt_ray_db, OLD.lat_ray_db, OLD.lon_ray_db, 
        OLD.height_ray_db, OLD.ant_height_ray_db, OLD.base_lat_ray_db, OLD.base_lon_ray_db, OLD.base_height_ray_db, 
        OLD.hdop_ray_db, OLD.vdop_ray_db, OLD.pdop_ray_db, OLD.hrms_ray_db, OLD.vrms_ray_db, OLD.num_sat_used_ray_db, 
        OLD.num_sat_tracked_ray_db, OLD.age_ray_db, OLD.class_ray_db, OLD.nav_mode_ray_db, OLD.is_tilt_corrected_ray_db,
        OLD.sigma_ray_db, OLD.caster_user_ray_db, OLD.tilt_col_point_db,  (SELECT uuid FROM current_uuid), 1
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for description_project_ray_db
CREATE TRIGGER tr_description_project_ray_db_delete
BEFORE DELETE ON description_project_ray_db
FOR EACH ROW
BEGIN
    INSERT INTO description_project_ray_db (
        description_ray_db, model_ray_db, date_ray_db, reference_ray_db, localization_enable_ray_db,
        localization_ray_db, localization_result_ray_db, is_cadastre, enable_transformation, 
        project_time_zone_ray_db, uuid, isDeleted
    )
    VALUES (
        OLD.description_ray_db, OLD.model_ray_db, OLD.date_ray_db, OLD.reference_ray_db, OLD.localization_enable_ray_db,
        OLD.localization_ray_db, OLD.localization_result_ray_db, OLD.is_cadastre, OLD.enable_transformation, 
        OLD.project_time_zone_ray_db,  (SELECT uuid FROM current_uuid), 1
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for custom_field_ray_db
CREATE TRIGGER tr_custom_field_ray_db_delete
BEFORE DELETE ON custom_field_ray_db
FOR EACH ROW
BEGIN
    INSERT INTO custom_field_ray_db (
        id_ray_db, name_ray_db, description_ray_db, line_type_ray_db, uuid, isDeleted
    )
    VALUES (
        OLD.id_ray_db, OLD.name_ray_db, OLD.description_ray_db, OLD.line_type_ray_db,  (SELECT uuid FROM current_uuid), 1
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for columns_template_ray_db
CREATE TRIGGER tr_columns_template_ray_db_delete
BEFORE DELETE ON columns_template_ray_db
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
        OLD.name_ray_db, OLD.point_columns_list_ray_db, OLD.point_columns_visibility_ray_db, 
        OLD.point_custom_columns_visibility_ray_db, OLD.polyline_columns_list_ray_db, 
        OLD.polyline_columns_visibility_ray_db, OLD.polyline_custom_columns_visibility_ray_db, 
        OLD.polygon_columns_list_ray_db, OLD.polygon_columns_visibility_ray_db, 
        OLD.polygon_custom_columns_visibility_ray_db, OLD.quick_code_columns_visibility_ray_db, 
         (SELECT uuid FROM current_uuid), 1
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for tblExceptionLog
CREATE TRIGGER tr_tblExceptionLog_delete
BEFORE DELETE ON tblExceptionLog
FOR EACH ROW
BEGIN
    INSERT INTO tblExceptionLog (
        id_ray_db, log_info_ray_db, date_time_ray_db, uuid, isDeleted
    )
    VALUES (
        OLD.id_ray_db, OLD.log_info_ray_db, OLD.date_time_ray_db,  (SELECT uuid FROM current_uuid), 1
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for tblQuickCode
CREATE TRIGGER tr_tblQuickCode_delete
BEFORE DELETE ON tblQuickCode
FOR EACH ROW
BEGIN
    INSERT INTO tblQuickCode (
        Id, Code, Style, Color, Description, GroupId, IsActive, Size, ShortcutKeyCode, uuid, isDeleted
    )
    VALUES (
        OLD.Id, OLD.Code, OLD.Style, OLD.Color, OLD.Description, OLD.GroupId, OLD.IsActive, 
        OLD.Size, OLD.ShortcutKeyCode,  (SELECT uuid FROM current_uuid), 1
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for tblQuickCodeGroup
CREATE TRIGGER tr_tblQuickCodeGroup_delete
BEFORE DELETE ON tblQuickCodeGroup
FOR EACH ROW
BEGIN
    INSERT INTO tblQuickCodeGroup (
        Id, Title, Description, IsSelected, uuid, isDeleted
    )
    VALUES (
        OLD.Id, OLD.Title, OLD.Description, OLD.IsSelected,  (SELECT uuid FROM current_uuid), 1
    );
    SELECT RAISE(IGNORE);
END;

-- Trigger for tblCadastreLog
CREATE TRIGGER tr_tblCadastreLog_delete
BEFORE DELETE ON tblCadastreLog
FOR EACH ROW
BEGIN
    INSERT INTO tblCadastreLog (
        id_ray_db, data_db, uuid, isDeleted
    )
    VALUES (
        OLD.id_ray_db, OLD.data_db,  (SELECT uuid FROM current_uuid), 1
    );
    SELECT RAISE(IGNORE);
END;

