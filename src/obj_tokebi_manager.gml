
/// obj_tokebi_manager - Manager Object Events
/// Create this object in GameMaker and add these 4 events:

// ================================================
// CREATE EVENT
// ================================================
alarm[0] = 30 * 60; // 30 seconds at 60 FPS
show_debug_message("⏰ Tokebi manager started - auto-flush every 30 seconds");

// ================================================
// ALARM[0] EVENT (Add Event → Alarm → Alarm 0)
// ================================================
show_debug_message("⏰ Auto-flush triggered");
tokebi_flush_events();
alarm[0] = 30 * 60; // Reset timer

// ================================================
// HTTP EVENT (Add Event → Other → HTTP)
// ================================================
tokebi_handle_http_response();

// ================================================
// DESTROY EVENT
// ================================================
show_debug_message("🔧 Tokebi manager destroyed");
if (global.tokebi_initialized) {
    tokebi_flush_events(); // Final flush
}
