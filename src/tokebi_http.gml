/// Tokebi HTTP Functions - Minimal Logging

// Track pending requests
global.tokebi_pending_requests = ds_map_create();

/// @description Register game with Tokebi
function tokebi_register_game() {
    if (global.tokebi_game_registered || global.tokebi_api_key == "" || global.tokebi_game_id == "") {
        return;
    }
    
    var payload = ds_map_create();
    ds_map_add(payload, "gameName", global.tokebi_game_id);
    ds_map_add(payload, "platform", "gamemaker");
    ds_map_add(payload, "playerCount", 1);
    
    var json_payload = json_encode(payload);
    ds_map_destroy(payload);
    
    var headers = ds_map_create();
    ds_map_add(headers, "Content-Type", "application/json");
    ds_map_add(headers, "Authorization", global.tokebi_api_key);
    
    var request_id = http_request(global.tokebi_endpoint + "/api/games", "POST", headers, json_payload);
    ds_map_add(global.tokebi_pending_requests, string(request_id), "registration");
}

/// @description Send events batch to Tokebi
function tokebi_send_events(json_payload, event_count) {
    if (global.tokebi_api_key == "" || global.tokebi_game_id == "") return;
    
    var headers = ds_map_create();
    ds_map_add(headers, "Content-Type", "application/json");
    ds_map_add(headers, "Authorization", global.tokebi_api_key);
    
    var request_id = http_request(global.tokebi_endpoint + "/api/track", "POST", headers, json_payload);
    ds_map_add(global.tokebi_pending_requests, string(request_id), "events:" + string(event_count));
}

/// @description Handle HTTP response
function tokebi_handle_http_response() {
    var request_id = string(async_load[? "id"]);
    var status = async_load[? "http_status"];
    var result = async_load[? "result"];
    
    if (!ds_map_exists(global.tokebi_pending_requests, request_id)) {
        return;
    }
    
    var request_type = ds_map_find_value(global.tokebi_pending_requests, request_id);
    ds_map_delete(global.tokebi_pending_requests, request_id);
    
    if (request_type == "registration") {
        tokebi_handle_registration_response(status, result);
    } else if (string_pos("events:", request_type) == 1) {
        var event_count = real(string_delete(request_type, 1, 7));
        tokebi_handle_events_response(status, result, event_count);
    }
}

/// @description Update queued events with real game ID
function tokebi_update_queued_game_ids() {
    var queue_size = ds_list_size(global.tokebi_event_queue);
    if (queue_size == 0) return;
    
    for (var i = 0; i < queue_size; i++) {
        var event_obj = ds_list_find_value(global.tokebi_event_queue, i);
        if (ds_exists(event_obj, ds_type_map) && ds_map_exists(event_obj, "gameId")) {
            var current_id = ds_map_find_value(event_obj, "gameId");
            if (current_id == global.tokebi_game_id) {
                ds_map_replace(event_obj, "gameId", global.tokebi_real_game_id);
            }
        }
    }
}

/// @description Handle game registration response
function tokebi_handle_registration_response(status, result) {
    if (status == 200 || status == 201) {
        var response_map = json_decode(result);
        if (ds_exists(response_map, ds_type_map) && ds_map_exists(response_map, "game_id")) {
            global.tokebi_real_game_id = ds_map_find_value(response_map, "game_id");
            tokebi_update_queued_game_ids();
            ds_map_destroy(response_map);
        }
        global.tokebi_game_registered = true;
        show_debug_message("Tokebi game registered");
    }
}

/// @description Handle events batch response
function tokebi_handle_events_response(status, result, event_count) {
    if (status == 200) {
        show_debug_message("Tokebi events sent: " + string(event_count));
    } else {
        show_debug_message("Tokebi events failed: " + string(status));
    }
}
