/// Tokebi Offline Storage Functions
/// Simple save/load for failed events

/// @description Save current queue to file (when events fail to send)
function tokebi_save_offline_events() {
    if (ds_list_size(global.tokebi_event_queue) == 0) return;
    
    var file_name = "tokebi_offline_events.json";
    var events_to_save = ds_list_create();
    
    // Load existing events if file exists
    if (file_exists(file_name)) {
        var existing_json = "";
        var file = file_text_open_read(file_name);
        while (!file_text_eof(file)) {
            existing_json += file_text_read_string(file);
            file_text_readln(file);
        }
        file_text_close(file);
        
        if (string_length(existing_json) > 0) {
            var existing_events = json_decode(existing_json);
            if (ds_exists(existing_events, ds_type_list)) {
                ds_list_copy(events_to_save, existing_events);
                ds_list_destroy(existing_events);
            }
        }
    }
    
    // Add current queue to saved events
    for (var i = 0; i < ds_list_size(global.tokebi_event_queue); i++) {
        var event_copy = ds_map_create();
        ds_map_copy(event_copy, ds_list_find_value(global.tokebi_event_queue, i));
        ds_list_add(events_to_save, event_copy);
    }
    
    // Limit saved events (prevent file from growing forever)
    while (ds_list_size(events_to_save) > 500) {
        var old_event = ds_list_find_value(events_to_save, 0);
        ds_map_destroy(old_event);
        ds_list_delete(events_to_save, 0);
    }
    
    // Save to file
    var json_string = json_encode(events_to_save);
    var file = file_text_open_write(file_name);
    file_text_write_string(file, json_string);
    file_text_close(file);
    
    // Cleanup
    for (var i = 0; i < ds_list_size(events_to_save); i++) {
        var event = ds_list_find_value(events_to_save, i);
        ds_map_destroy(event);
    }
    ds_list_destroy(events_to_save);
    
    show_debug_message("💾 Saved " + string(ds_list_size(global.tokebi_event_queue)) + " events offline");
}

/// @description Load offline events back into queue
function tokebi_load_offline_events() {
    var file_name = "tokebi_offline_events.json";
    
    if (!file_exists(file_name)) return;
    
    var file = file_text_open_read(file_name);
    var saved_json = "";
    while (!file_text_eof(file)) {
        saved_json += file_text_read_string(file);
        file_text_readln(file);
    }
    file_text_close(file);
    
    if (string_length(saved_json) == 0) return;
    
    var saved_events = json_decode(saved_json);
    if (!ds_exists(saved_events, ds_type_list)) {
        show_debug_message("❌ Corrupted offline events file, deleting");
        file_delete(file_name);
        return;
    }
    
    // Add saved events to current queue
    var loaded_count = 0;
    for (var i = 0; i < ds_list_size(saved_events); i++) {
        var event = ds_list_find_value(saved_events, i);
        if (ds_exists(event, ds_type_map)) {
            // Fix game ID if we have a real one now
            if (global.tokebi_real_game_id != "" && ds_map_exists(event, "gameId")) {
                var current_game_id = ds_map_find_value(event, "gameId");
                if (current_game_id == global.tokebi_game_id) {
                    ds_map_replace(event, "gameId", global.tokebi_real_game_id);
                }
            }
            
            var event_copy = ds_map_create();
            ds_map_copy(event_copy, event);
            ds_list_add(global.tokebi_event_queue, event_copy);
            loaded_count++;
        }
    }
    
    // Cleanup
    for (var i = 0; i < ds_list_size(saved_events); i++) {
        var event = ds_list_find_value(saved_events, i);
        if (ds_exists(event, ds_type_map)) {
            ds_map_destroy(event);
        }
    }
    ds_list_destroy(saved_events);
    
    // Delete the file since we loaded the events
    file_delete(file_name);
    
    if (loaded_count > 0) {
        show_debug_message("📂 Loaded " + string(loaded_count) + " offline events");
    }
}
