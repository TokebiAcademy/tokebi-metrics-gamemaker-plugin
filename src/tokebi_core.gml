/// Tokebi Analytics Core Functions
/// All main functions in one simple script

// Global variables
global.tokebi_initialized = false;
global.tokebi_event_queue = undefined;
global.tokebi_player_id = "";
global.tokebi_session_id = "";
global.tokebi_game_registered = false;
global.tokebi_real_game_id = "";

// Settings (set these before calling tokebi_init)
global.tokebi_api_key = "";
global.tokebi_game_id = "";
global.tokebi_endpoint = "https://tokebi-api.vercel.app";

/// @description Initialize Tokebi Analytics
function tokebi_init() {
    if (global.tokebi_initialized) return;
    
    show_debug_message("🔧 Initializing Tokebi Analytics...");
    
    // Setup
    global.tokebi_event_queue = ds_list_create();
    global.tokebi_player_id = tokebi_get_player_id();
    global.tokebi_initialized = true;
    
    // Create manager if needed
    if (!instance_exists(obj_tokebi_manager)) {
        var manager = instance_create_depth(0, 0, 0, obj_tokebi_manager);
        instance_mark_persistent(manager, true);
    }
    
    // Load offline events and register game
    tokebi_load_offline_events();
    tokebi_register_game();
    
    show_debug_message("✅ Tokebi Analytics ready!");
}

/// @description Start analytics session
function tokebi_start_session() {
    global.tokebi_session_id = "session_" + string(date_current_datetime()) + "_" + string(irandom(99999));
    
    var data = ds_map_create();
    ds_map_add(data, "session_id", global.tokebi_session_id);
    tokebi_track("session_start", data);
    ds_map_destroy(data);
    
    show_debug_message("🎮 Session started: " + global.tokebi_session_id);
}

/// @description End analytics session  
function tokebi_end_session() {
    if (global.tokebi_session_id == "") return;
    
    var data = ds_map_create();
    ds_map_add(data, "session_id", global.tokebi_session_id);
    tokebi_track("session_end", data);
    ds_map_destroy(data);
    
    tokebi_flush_events(); // Force send on session end
    global.tokebi_session_id = "";
    
    show_debug_message("🎮 Session ended");
}

/// @description Track custom event
/// @param {string} event_name - Name of event
/// @param {ds_map} event_data - Data map (optional)
function tokebi_track(event_name, event_data = noone) {
    if (!global.tokebi_initialized) {
        show_debug_message("❌ Call tokebi_init() first!");
        return;
    }
    
    // Create event object
    var event_obj = ds_map_create();
    ds_map_add(event_obj, "eventType", event_name);
    ds_map_add(event_obj, "gameId", global.tokebi_real_game_id != "" ? global.tokebi_real_game_id : global.tokebi_game_id);
    ds_map_add(event_obj, "playerId", global.tokebi_player_id);
    ds_map_add(event_obj, "platform", "gamemaker");
    ds_map_add(event_obj, "timestamp", string(date_current_datetime()));
    
    // Add session if active
    if (global.tokebi_session_id != "") {
        ds_map_add(event_obj, "session_id", global.tokebi_session_id);
    }
    
    // Add custom data
    var payload = ds_map_create();
    if (event_data != noone && ds_exists(event_data, ds_type_map)) {
        ds_map_copy(payload, event_data);
    }
    ds_map_add_map(event_obj, "payload", payload);
    
    // Queue event
    ds_list_add(global.tokebi_event_queue, event_obj);
    
    show_debug_message("📊 Tracked: " + event_name + " (Queue: " + string(ds_list_size(global.tokebi_event_queue)) + ")");
    
    // Auto-flush if queue is full
    if (ds_list_size(global.tokebi_event_queue) >= 100) {
        tokebi_flush_events();
    }
}

/// @description Track level start
function tokebi_track_level_start(level_name) {
    var data = ds_map_create();
    ds_map_add(data, "level", level_name);
    tokebi_track("level_start", data);
    ds_map_destroy(data);
}

/// @description Track level completion
function tokebi_track_level_complete(level_name, completion_time, score) {
    var data = ds_map_create();
    ds_map_add(data, "level", level_name);
    ds_map_add(data, "completion_time", string(completion_time));
    ds_map_add(data, "score", string(score));
    tokebi_track("level_complete", data);
    ds_map_destroy(data);
}

/// @description Track purchase
function tokebi_track_purchase(item_id, currency, cost) {
    var data = ds_map_create();
    ds_map_add(data, "item_id", item_id);
    ds_map_add(data, "currency", currency);
    ds_map_add(data, "cost", string(cost));
    tokebi_track("item_purchase", data);
    ds_map_destroy(data);
}

/// @description Manually flush all queued events
function tokebi_flush_events() {
    if (!global.tokebi_initialized || ds_list_size(global.tokebi_event_queue) == 0) {
        return;
    }
    
    show_debug_message("📤 Flushing " + string(ds_list_size(global.tokebi_event_queue)) + " events...");
    
    // Create batch payload
    var events_array = ds_list_create();
    for (var i = 0; i < ds_list_size(global.tokebi_event_queue); i++) {
        ds_list_add(events_array, ds_list_find_value(global.tokebi_event_queue, i));
    }
    
    var batch = ds_map_create();
    ds_map_add_list(batch, "events", events_array);
    var json_payload = json_encode(batch);
    ds_map_destroy(batch);
    
    // Send HTTP request
    tokebi_send_events(json_payload, ds_list_size(global.tokebi_event_queue));
    
    // Clear queue
    tokebi_clear_queue();
}

/// @description Get persistent player ID
function tokebi_get_player_id() {
    var file_name = "tokebi_player_id.txt";
    
    // Try to load existing ID
    if (file_exists(file_name)) {
        var file = file_text_open_read(file_name);
        var player_id = file_text_read_string(file);
        file_text_close(file);
        if (string_length(player_id) > 0) {
            return player_id;
        }
    }
    
    // Generate new ID
    var new_id = "player_" + string(date_current_datetime()) + "_" + string(irandom(999999));
    
    // Save it
    var file = file_text_open_write(file_name);
    file_text_write_string(file, new_id);
    file_text_close(file);
    
    return new_id;
}

/// @description Clear event queue and cleanup
function tokebi_clear_queue() {
    for (var i = 0; i < ds_list_size(global.tokebi_event_queue); i++) {
        var event_obj = ds_list_find_value(global.tokebi_event_queue, i);
        if (ds_exists(event_obj, ds_type_map)) {
            ds_map_destroy(event_obj);
        }
    }
    ds_list_clear(global.tokebi_event_queue);
}
