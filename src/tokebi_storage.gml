/// Tokebi Offline Storage Functions - FIXED VERSION
/// Simple save/load for failed events

/// @description Save failed events to local file for retry
/// @param {ds_list} events_list - List of events to save
function tokebi_save_offline_events() {
    
    if (ds_list_size(global.tokebi_event_queue) == 0) {
        show_debug_message("📁 No events to save");
        return;
    }
    
    var offline_file = "tokebi_offline_events.json";
    var all_events = ds_list_create();
    
    // Load existing events if file exists
    if (file_exists(offline_file)) {
        var file = file_text_open_read(offline_file);
        if (file != -1) {
            var existing_json = "";
            while (!file_text_eof(file)) {
                existing_json += file_text_read_string(file);
                file_text_readln(file);
            }
            file_text_close(file);
            
            if (string_length(existing_json) > 0) {
                var existing_list = json_decode(existing_json);
                if (ds_exists(existing_list, ds_type_list)) {
                    ds_list_copy(all_events, existing_list);
                    ds_list_destroy(existing_list);
                    show_debug_message("📁 Found " + string(ds_list_size(all_events)) + " existing saved events");
                }
            }
        }
    }
    
    // Add current queue to saved events
    var events_added = 0;
    for (var i = 0; i < ds_list_size(global.tokebi_event_queue); i++) {
        var event = ds_list_find_value(global.tokebi_event_queue, i);
        if (ds_exists(event, ds_type_map)) {
            // Create a copy of the event
            var event_copy = ds_map_create();
            ds_map_copy(event_copy, event);
            ds_list_add(all_events, event_copy);
            events_added++;
        }
    }
    
    // Limit total saved events to prevent unlimited growth
    var MAX_SAVED_EVENTS = 500;
    var total_events = ds_list_size(all_events);
    
    if (total_events > MAX_SAVED_EVENTS) {
        // Keep only the most recent events
        var events_to_remove = total_events - MAX_SAVED_EVENTS;
        for (var i = 0; i < events_to_remove; i++) {
            var old_event = ds_list_find_value(all_events, 0);
            if (ds_exists(old_event, ds_type_map)) {
                ds_map_destroy(old_event);
            }
            ds_list_delete(all_events, 0);
        }
        show_debug_message("⚠️ Trimmed saved events to " + string(ds_list_size(all_events)) + " (max " + string(MAX_SAVED_EVENTS) + ")");
    }
    
    // Serialize to JSON
    var json_string = json_encode(all_events);
    
    // Save to file
    var file = file_text_open_write(offline_file);
    if (file != -1) {
        file_text_write_string(file, json_string);
        file_text_close(file);
        show_debug_message("✅ Saved " + string(events_added) + " failed events to file (total: " + string(ds_list_size(all_events)) + ")");
    } else {
        show_debug_message("❌ Failed to save events to file");
    }
    
    // Clean up
    for (var i = 0; i < ds_list_size(all_events); i++) {
        var event = ds_list_find_value(all_events, i);
        if (ds_exists(event, ds_type_map)) {
            ds_map_destroy(event);
        }
    }
    ds_list_destroy(all_events);
}

/// @description Load saved events from file for retry
function tokebi_load_offline_events() {
    
    var offline_file = "tokebi_offline_events.json";
    
    if (!file_exists(offline_file)) {
        show_debug_message("📁 No saved events file found");
        return;
    }
    
    var file = file_text_open_read(offline_file);
    if (file == -1) {
        show_debug_message("❌ Failed to open saved events file");
        return;
    }
    
    var saved_json = "";
    while (!file_text_eof(file)) {
        saved_json += file_text_read_string(file);
        file_text_readln(file);
    }
    file_text_close(file);
    
    if (string_length(saved_json) == 0) {
        show_debug_message("📁 Saved events file is empty");
        return;
    }
    
    var saved_events_list = json_decode(saved_json);
    
    if (!ds_exists(saved_events_list, ds_type_list)) {
        show_debug_message("❌ Failed to parse saved events JSON, deleting corrupted file");
        file_delete(offline_file);
        return;
    }
    
    var events_loaded = 0;
    var events_fixed = 0;
    
    // Process events and fix game IDs if needed
    for (var i = 0; i < ds_list_size(saved_events_list); i++) {
        var event = ds_list_find_value(saved_events_list, i);
        
        if (ds_exists(event, ds_type_map)) {
            // Check and fix game ID if needed
            if (ds_map_exists(event, "gameId")) {
                var current_game_id = ds_map_find_value(event, "gameId");
                
                // If event has old game ID but we have a registered ID, update it
                if (global.tokebi_real_game_id != "" && 
                    current_game_id == global.tokebi_game_id && 
                    current_game_id != global.tokebi_real_game_id) {
                    
                    ds_map_replace(event, "gameId", global.tokebi_real_game_id);
                    events_fixed++;
                    show_debug_message("🔧 Fixed game ID in saved event: " + current_game_id + " → " + global.tokebi_real_game_id);
                }
            }
            
            // Create a copy and add to queue
            var event_copy = ds_map_create();
            ds_map_copy(event_copy, event);
            ds_list_add(global.tokebi_event_queue, event_copy);
            events_loaded++;
        }
    }
    
    show_debug_message("✅ Loaded " + string(events_loaded) + " saved events for retry (" + string(events_fixed) + " game IDs fixed)");
    
    // Clean up
    for (var i = 0; i < ds_list_size(saved_events_list); i++) {
        var event = ds_list_find_value(saved_events_list, i);
        if (ds_exists(event, ds_type_map)) {
            ds_map_destroy(event);
        }
    }
    ds_list_destroy(saved_events_list);
    
    // Clear the saved file since we've loaded the events
    if (file_delete(offline_file)) {
        show_debug_message("📁 Cleared saved events file");
    }
}
