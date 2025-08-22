/// Tokebi Analytics Core Functions - Minimal Logging

/// @description Initialize Tokebi Analytics
function tokebi_init() {
    global.tokebi_initialized = true;
    global.tokebi_event_queue = ds_list_create();
    global.tokebi_player_id = tokebi_get_player_id();
    global.tokebi_session_id = "";
    global.tokebi_game_registered = false;
    global.tokebi_real_game_id = "";
    
    // Auto-detect environment
    global.tokebi_environment = debug_mode ? "development" : "production";
    
    // Set defaults if not set
    if (!variable_global_exists("tokebi_api_key")) global.tokebi_api_key = "";
    if (!variable_global_exists("tokebi_game_id")) global.tokebi_game_id = "";
    if (!variable_global_exists("tokebi_endpoint")) global.tokebi_endpoint = "https://tokebi-api.vercel.app";
    
    // Create manager
    if (!instance_exists(obj_tokebi_manager)) {
        var mgr = instance_create_depth(0, 0, 0, obj_tokebi_manager);
        instance_mark_persistent(mgr, true);
    }
    
    // Initialize
    tokebi_load_offline_events();
    tokebi_register_game();
    
    show_debug_message("Tokebi Analytics initialized");
}

/// @description Start session
function tokebi_start_session() {
    global.tokebi_session_id = "session_" + string(date_current_datetime()) + "_" + string(irandom(99999));
    
    var session_data = ds_map_create();
    ds_map_add(session_data, "session_id", global.tokebi_session_id);
    tokebi_track("session_start", session_data);
    ds_map_destroy(session_data);
}

/// @description End session  
function tokebi_end_session() {
    if (global.tokebi_session_id == "") return;
    
    var session_data = ds_map_create();
    ds_map_add(session_data, "session_id", global.tokebi_session_id);
    tokebi_track("session_end", session_data);
    ds_map_destroy(session_data);
    
    tokebi_flush_events();
    global.tokebi_session_id = "";
}

/// @description Track custom event
function tokebi_track(event_name, event_data = noone) {
    if (!global.tokebi_initialized) return;
    
    var enhanced_data = ds_map_create();
    
    if (event_data != noone && ds_exists(event_data, ds_type_map)) {
        ds_map_copy(enhanced_data, event_data);
    }
    
    if (global.tokebi_session_id != "") {
        ds_map_add(enhanced_data, "session_id", global.tokebi_session_id);
    }
    
    tokebi_queue_event(event_name, enhanced_data);
    ds_map_destroy(enhanced_data);
}

/// @description Track level start
function tokebi_track_level_start(level_name) {
    var level_data = ds_map_create();
    ds_map_add(level_data, "level", level_name);
    tokebi_track("level_start", level_data);
    ds_map_destroy(level_data);
}

/// @description Track level completion
function tokebi_track_level_complete(level_name, completion_time, score) {
    var level_data = ds_map_create();
    ds_map_add(level_data, "level", level_name);
    ds_map_add(level_data, "completion_time", string(completion_time));
    ds_map_add(level_data, "score", string(score));
    tokebi_track("level_complete", level_data);
    ds_map_destroy(level_data);
}

/// @description Track purchase
function tokebi_track_purchase(item_id, currency, cost) {
    var purchase_data = ds_map_create();
    ds_map_add(purchase_data, "item_id", item_id);
    ds_map_add(purchase_data, "currency", currency);
    ds_map_add(purchase_data, "cost", string(cost));
    tokebi_track("item_purchase", purchase_data);
    ds_map_destroy(purchase_data);
}

/// @description Queue event for sending
function tokebi_queue_event(event_type, event_data) {
    if (global.tokebi_api_key == "" || global.tokebi_game_id == "") return;
    
    var game_id_to_use = global.tokebi_real_game_id != "" ? global.tokebi_real_game_id : global.tokebi_game_id;
    
    var tokebi_event = ds_map_create();
    ds_map_add(tokebi_event, "eventType", event_type);
    ds_map_add(tokebi_event, "gameId", game_id_to_use);
    ds_map_add(tokebi_event, "playerId", global.tokebi_player_id);
    ds_map_add(tokebi_event, "platform", "gamemaker");
    ds_map_add(tokebi_event, "environment", global.tokebi_environment);
    
    var payload_copy = ds_map_create();
    if (ds_exists(event_data, ds_type_map)) {
        ds_map_copy(payload_copy, event_data);
    }
    ds_map_add_map(tokebi_event, "payload", payload_copy);
    
    ds_list_add(global.tokebi_event_queue, tokebi_event);
    
    if (ds_list_size(global.tokebi_event_queue) >= 100) {
        tokebi_flush_events();
    }
}

/// @description Flush all events
function tokebi_flush_events() {
    if (!global.tokebi_initialized) return;
    
    var queue_size = ds_list_size(global.tokebi_event_queue);
    if (queue_size == 0) return;
    
    // Build JSON manually
    var json_string = "{\"events\":[";
    var list_index = 0;
    
    repeat(queue_size) {
        var current_event = ds_list_find_value(global.tokebi_event_queue, list_index);
        
        if (list_index > 0) {
            json_string += ",";
        }
        json_string += json_encode(current_event);
        
        list_index += 1;
    }
    
    json_string += "]}";
    
    tokebi_send_events(json_string, queue_size);
    tokebi_clear_queue();
}

/// @description Get player ID
function tokebi_get_player_id() {
    var file_name = "tokebi_player_id.txt";
    
    if (file_exists(file_name)) {
        var file_handle = file_text_open_read(file_name);
        var player_id = file_text_read_string(file_handle);
        file_text_close(file_handle);
        if (string_length(player_id) > 0) {
            return player_id;
        }
    }
    
    var new_id = "player_" + string(date_current_datetime()) + "_" + string(irandom(999999));
    
    var file_handle = file_text_open_write(file_name);
    file_text_write_string(file_handle, new_id);
    file_text_close(file_handle);
    
    return new_id;
}

/// @description Clear event queue
function tokebi_clear_queue() {
    repeat(ds_list_size(global.tokebi_event_queue)) {
        var event_obj = ds_list_find_value(global.tokebi_event_queue, 0);
        if (ds_exists(event_obj, ds_type_map)) {
            ds_map_destroy(event_obj);
        }
        ds_list_delete(global.tokebi_event_queue, 0);
    }
}
