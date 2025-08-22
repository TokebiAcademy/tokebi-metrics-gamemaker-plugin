// basic_usage.gml - Simple implementation example

function example_basic_setup() {
    /*
    Put this in your main game object's Create event
    */
    
    // Configure Tokebi
    global.tokebi_api_key = "your-api-key-from-dashboard";
    global.tokebi_game_id = "my-awesome-game";
    
    // Initialize
    tokebi_init();
    
    // Start session when player begins
    tokebi_start_session();
}

function example_basic_tracking() {
    /*
    Track events throughout your game
    */
    
    // Simple events (no data)
    tokebi_track("game_started", noone);
    tokebi_track("menu_opened", noone);
    
    // Events with data
    var data = ds_map_create();
    ds_map_add(data, "level", "tutorial");
    ds_map_add(data, "difficulty", "easy");
    tokebi_track("level_started", data);
    ds_map_destroy(data);
    
    // Built-in events
    tokebi_track_level_complete("tutorial", 120.5, 1000);
    tokebi_track_purchase("health_potion", "gold", 25);
}

function example_game_end() {
    /*
    Put this when player quits or game closes
    */
    tokebi_end_session();
}

// ---

// rpg_game.gml - RPG-style tracking example

function rpg_character_creation() {
    var char_data = ds_map_create();
    ds_map_add(char_data, "class", "warrior");
    ds_map_add(char_data, "starting_level", "1");
    ds_map_add(char_data, "difficulty", "normal");
    tokebi_track("character_created", char_data);
    ds_map_destroy(char_data);
}

function rpg_combat_tracking() {
    // Track combat encounters
    var combat_data = ds_map_create();
    ds_map_add(combat_data, "enemy_type", "goblin");
    ds_map_add(combat_data, "player_level", "5");
    ds_map_add(combat_data, "damage_dealt", "45");
    ds_map_add(combat_data, "damage_taken", "12");
    ds_map_add(combat_data, "weapon_used", "iron_sword");
    ds_map_add(combat_data, "result", "victory");
    tokebi_track("combat_encounter", combat_data);
    ds_map_destroy(combat_data);
}

function rpg_quest_tracking() {
    // Quest started
    var quest_data = ds_map_create();
    ds_map_add(quest_data, "quest_id", "save_princess");
    ds_map_add(quest_data, "quest_giver", "king");
    ds_map_add(quest_data, "player_level", "8");
    tokebi_track("quest_started", quest_data);
    ds_map_destroy(quest_data);
    
    // Quest completed
    quest_data = ds_map_create();
    ds_map_add(quest_data, "quest_id", "save_princess");
    ds_map_add(quest_data, "completion_time", "1847.5");
    ds_map_add(quest_data, "experience_gained", "500");
    ds_map_add(quest_data, "gold_reward", "200");
    tokebi_track("quest_completed", quest_data);
    ds_map_destroy(quest_data);
}

function rpg_shop_purchases() {
    // Track different purchase types
    tokebi_track_purchase("health_potion", "gold", 50);
    tokebi_track_purchase("magic_scroll", "gems", 5);
    tokebi_track_purchase("premium_armor", "usd", 2.99); // Real money
}

// ---

// puzzle_game.gml - Puzzle game tracking example

function puzzle_level_tracking() {
    // Level start
    tokebi_track_level_start("world_2_puzzle_15");
    
    // Track player actions during puzzle
    var move_data = ds_map_create();
    ds_map_add(move_data, "move_number", "23");
    ds_map_add(move_data, "piece_type", "red_block");
    ds_map_add(move_data, "from_position", "3,4");
    ds_map_add(move_data, "to_position", "5,4");
    tokebi_track("puzzle_move", move_data);
    ds_map_destroy(move_data);
    
    // Hint usage
    var hint_data = ds_map_create();
    ds_map_add(hint_data, "hint_number", "2");
    ds_map_add(hint_data, "moves_so_far", "35");
    ds_map_add(hint_data, "time_elapsed", "145.2");
    tokebi_track("hint_used", hint_data);
    ds_map_destroy(hint_data);
    
    // Puzzle completion
    tokebi_track_level_complete("world_2_puzzle_15", 187.5, 2800);
}

function puzzle_progression_tracking() {
    // World completion
    var world_data = ds_map_create();
    ds_map_add(world_data, "world_number", "2");
    ds_map_add(world_data, "total_time", "3420.8");
    ds_map_add(world_data, "hints_used", "7");
    ds_map_add(world_data, "perfect_levels", "12");
    tokebi_track("world_completed", world_data);
    ds_map_destroy(world_data);
}

function puzzle_monetization_tracking() {
    // Track different IAP types
    tokebi_track_purchase("hint_pack_10", "usd", 0.99);
    tokebi_track_purchase("remove_ads", "usd", 2.99);
    tokebi_track_purchase("premium_worlds", "usd", 4.99);
    
    // Track ad views
    var ad_data = ds_map_create();
    ds_map_add(ad_data, "ad_type", "rewarded_video");
    ds_map_add(ad_data, "reward", "3_hints");
    ds_map_add(ad_data, "placement", "hint_button");
    tokebi_track("ad_watched", ad_data);
    ds_map_destroy(ad_data);
}

// ---

// Complete game session example
function complete_session_example() {
    
    // 1. Game startup
    global.tokebi_api_key = "your-api-key";
    global.tokebi_game_id = "puzzle-adventure";
    tokebi_init();
    
    // 2. Player starts playing
    tokebi_start_session();
    tokebi_track("game_launched", noone);
    
    // 3. Menu interactions
    var menu_data = ds_map_create();
    ds_map_add(menu_data, "button", "play");
    tokebi_track("menu_interaction", menu_data);
    ds_map_destroy(menu_data);
    
    // 4. Gameplay
    tokebi_track_level_start("tutorial");
    
    var gameplay_data = ds_map_create();
    ds_map_add(gameplay_data, "action", "jump");
    ds_map_add(gameplay_data, "success", "true");
    tokebi_track("player_action", gameplay_data);
    ds_map_destroy(gameplay_data);
    
    tokebi_track_level_complete("tutorial", 65.3, 1200);
    
    // 5. Purchase
    tokebi_track_purchase("power_up", "coins", 100);
    
    // 6. Game end
    tokebi_track("game_quit", noone);
    tokebi_end_session();
}
