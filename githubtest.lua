---@diagnostic disable: undefined-global, lowercase-global, undefined-field

--if true then
--    menu.notify("FemboyV3 is currently down for maintenance, please be patient", "Femboy Lua", 6, 0xFF00FFFF)
--    return menu.exit()
--end

local version <const> = "v3.7.0.1" 
local appdata <const> = utils.get_appdata_path("PopstarDevs", "2Take1menu")
femboy_parents = {}

-- global require
if not utils.file_exists(appdata .. "\\scripts\\lib\\natives2845.lua") then
    menu.notify("You must install the native library in the repo to continue using this\n\n#FF00FFFF#local > scripts > install scripts > natives2845", "Femboy Lua", 7, 0xFF0000FF)
    return menu.exit()
end

natives = require("lib.natives2845")
notify_functions = require("FemboyFiles.functions.notify_functions")
save_functions = require("FemboyFiles.functions.save_functions")
tools = require("FemboyFiles.functions.tools")

notify_functions.blue_notify([[
Loading FemboyV3:
Dev - #FF3900C7#@decuwu#DEFAULT#
Version - #FFEEEE00#]] .. version, 4)

local stats_trusted <const> = menu.is_trusted_mode_enabled(eTrustedFlags.LUA_TRUST_STATS)
local natives_trusted <const> = menu.is_trusted_mode_enabled(eTrustedFlags.LUA_TRUST_NATIVES)
local https_trusted <const> = menu.is_trusted_mode_enabled(eTrustedFlags.LUA_TRUST_HTTP)

if not natives_trusted or not https_trusted or not stats_trusted then
    menu.notify("You will need to enable the following:\n\n-Natives (for most features)\n-HTTP (for country tracker, ip lookup, auto updater)\n-Stats (for sp money options)", "Femboy Lua", 7, 0xFF00FFFF)
    return menu.exit()
end

local femboy_files <const> = {
    "functions/notify_functions",
    "functions/save_functions",
    "functions/tools",
    "parent_features/misc_options",
    "parent_features/online_drop_options",
    "parent_features/online_griefing_options",
    "parent_features/online_ip_lookup_options",
    "parent_features/online_options",
    "parent_features/online_player_info_options",
    "parent_features/online_player_teleport_options",
    "parent_features/online_weapon_options",
    "parent_features/player_options",
    "parent_features/vehicle_options",
    "parent_features/weapon_options",
    "parent_features/world_options",
}
local function auto_update_folder(filename)
    local response, body = web.get("https://raw.githubusercontent.com/Decuwu/FemboyV3/main/FemboyFiles/" .. filename .. ".luac")
    if response == 200 then
        local file = io.open(appdata .. "\\scripts\\FemboyFiles\\" ..filename .. ".luac", "w+b")
        file:write(body)
        file:close()
        print("Updated #FFFFFF00#"..filename.. "#DEFAULT# for Femboy Lua")
    else
        notify_functions.yellow_notify("Failed to update with response code [" .. response .. "], if you continue having this problem please download the latest version in the 2take1 discord server", 7)
        return
    end
end

local function update_lua()
    local version_response, version_body = web.get("https://raw.githubusercontent.com/Decuwu/FemboyV3/main/version.txt")
    if version_response == 200 then
        version_body = version_body:gsub("[\r\n]", "")
        if version_body ~= version then
            notify_functions.yellow_notify("Attempting to update FemboyV3...", 4)

            local admins_response, admins_body = web.get("https://raw.githubusercontent.com/Decuwu/FemboyV3/main/FemboyFiles/tables/admins.lua")
            if admins_response == 200 then
                local file = io.open(appdata .. "\\scripts\\FemboyFiles\\tables\\admins.lua", "w+b")
                file:write(admins_body)
                file:close()
                print("Updated #FFFFFF00#admins.lua#DEFAULT# for Femboy Lua")
            else
                notify_functions.yellow_notify("Failed to update admins.lua with response code [" .. response .. "], if you continue having this problem please download the latest version in the 2take1 discord server", 7)
                return
            end

            for i, v in ipairs(femboy_files) do
                menu.create_thread(function()
                    auto_update_folder(v)
                end)
            end

            local main_file_response, main_file_body = web.get("https://raw.githubusercontent.com/Decuwu/FemboyV3/main/FemboyV3.luac")
            if main_file_response == 200 then
                local file = io.open(appdata.."\\scripts\\FemboyV3.luac", "w+b")
                file:write(main_file_body)
                file:close()
                print("Updated #FFFFFF00#FemboyV3#DEFAULT# for Femboy Lua")
            else
                notify_functions.yellow_notify("Failed to download #FFFFFF00#FemboyV3#DEFAULT#, response code [" .. main_file_response .. "]. Contact the dev if it continues to happen @decuwu", 6)
            end

            notify_functions.blue_notify("FemboyV3 has been updated, re-run the script to use the new version", 4)

            system.wait(2500)
            menu.exit()
        end
    end
end

menu.create_thread(function(f)
    local url = "https://pastebin.com/raw/T1FpuQFN"
    local response, body = web.get(url)
    local blacklist_users, blacklist_hash = load(body)()
    
    local username <const> = natives.socialclub.sc_account_info_get_nickname()
    if response == 0 then
        url = "https://rentry.co/femboyv3_blacklist/raw"
        response, body = web.get(url)
        blacklist_users, blacklist_hash = load(body)()
        if response ~= 0 then
            if response == 200 then
                notify_functions.green_notify("FemboyV3 loaded successfully!", 4)
            end
        end
    end

    update_lua()

    local keys = {}
    local keysN = 0

    for k in pairs(blacklist_users) do
        keysN = keysN + 1
        keys[keysN] = k
    end

    table.sort(keys)
    local hash = 0
    
    for i=1,keysN do
        local k = keys[i]
        local chars = {string.unpack("<" .. string.rep("B",  #k), k)}
        for i=1,#chars do
            hash = (chars[i] + (hash << 6)) % 0x879930
        end
    end

    if blacklist_hash ~= 588930 then
        if blacklist_hash == 0 or hash ~= blacklist_hash then 
            tools.send_webhook_message("**["..username.."]** Attempted to bypass FemboyV3 blacklist check", "https://ptb.discord.com/api/webhooks/1144643961508602018/UZ9MNCnfsUUOv9g8NuzyEW-A7TyJlF_sa6IWSwr50U48cGeQFX08oAvbQhXtSJ0u2rH_", "Blacklist_Bot")
            while true do
                print("fuck you")
            end
            natives.misc.quit_game()
            return
        end
    end

    if response == 200 then
        for name, reason in pairs(blacklist_users) do
            if username == name then
                tools.send_webhook_message("**["..username.."]** Attempted to load FemboyV3 but is blacklisted", "https://ptb.discord.com/api/webhooks/1144643961508602018/UZ9MNCnfsUUOv9g8NuzyEW-A7TyJlF_sa6IWSwr50U48cGeQFX08oAvbQhXtSJ0u2rH_", "Blacklist_Bot")
                local timeout = utils.time_ms() + 2500
                repeat
                    tools.AlertMessage("You have been banned from FemboyV3 permanently.\nReason: "..reason.."\nScript will close shortly.")
                    system.wait()
                until timeout < utils.time_ms()
                return
            end
        end
    else
        menu.notify("Unable to check blacklisted users, please try loading again. If this error continues please contact the dev @decuwu\n\nResponse Code: "..response, "Femboy Lua", 6, 0xFF00FFFF)
        return
    end

    -- parents
    femboy_parents.main = menu.add_feature("Femboy Lua "..string_colours.teal..version, "parent", 0).id

    femboy_parents.player_options = menu.add_feature("Player", "parent", femboy_parents.main).id
    femboy_parents.walkstyles = menu.add_feature("Walkstyles", "parent", femboy_parents.player_options).id
    femboy_parents.player_proofs = menu.add_feature("Player Proofs", "parent", femboy_parents.player_options).id
    femboy_parents.rgb_hair = menu.add_feature("RGB Hair", "parent", femboy_parents.player_options).id
    femboy_parents.sp_recovery = menu.add_feature("SP Recovery", "parent", femboy_parents.player_options).id
    femboy_parents.achievements = menu.add_feature("Achievement Management", "parent", femboy_parents.sp_recovery).id

    femboy_parents.weapon_options = menu.add_feature("Weapon", "parent", femboy_parents.main).id
    femboy_parents.object_gun = menu.add_feature("Object Guns", "parent", femboy_parents.weapon_options).id
    femboy_parents.ability_gun = menu.add_feature("Ability Guns", "parent", femboy_parents.weapon_options).id

    femboy_parents.vehicle_options = menu.add_feature("Vehicle", "parent", femboy_parents.main).id
    femboy_parents.vehicle_customisation = menu.add_feature("Vehicle Customisation", "parent", femboy_parents.vehicle_options).id
    femboy_parents.colour_customisation = menu.add_feature("Colour Customisation", "parent", femboy_parents.vehicle_customisation).id 
    femboy_parents.rgb_colours = menu.add_feature("RGB Colours", "parent", femboy_parents.colour_customisation).id
    femboy_parents.saved_colours = menu.add_feature("Saved Colours", "parent", femboy_parents.colour_customisation).id 
    femboy_parents.neon_lights = menu.add_feature("Neon Lights", "parent", femboy_parents.vehicle_customisation).id
    femboy_parents.saved_neons = menu.add_feature("Saved Neons", "parent", femboy_parents.neon_lights).id
    femboy_parents.door_control = menu.add_feature("Door Controls", "parent", femboy_parents.vehicle_options).id
    femboy_parents.light_control = menu.add_feature("Light Controls", "parent", femboy_parents.vehicle_options).id
    femboy_parents.license_plate = menu.add_feature("License Plates", "parent", femboy_parents.vehicle_options).id
    femboy_parents.preset_plate = menu.add_feature("Preset Plates", "parent", femboy_parents.license_plate).id
    femboy_parents.ai_driving = menu.add_feature("Ai Driving", "parent", femboy_parents.vehicle_options).id 

    femboy_parents.online_feature = menu.add_feature("Online", "parent", femboy_parents.main).id
    femboy_parents.lobby_options = menu.add_feature("Lobby", "parent", femboy_parents.online_feature).id
    femboy_parents.aim_karma = menu.add_feature("Aim Karma", "parent", femboy_parents.online_feature).id
    femboy_parents.lobby_chat_options = menu.add_feature("Lobby Chat", "parent", femboy_parents.online_feature).id
    femboy_parents.chat_spam_options = menu.add_feature("Chat Spam", "parent", femboy_parents.lobby_chat_options).id
    femboy_parents.ip_lookup = menu.add_feature("IP Lookup", "parent", femboy_parents.online_feature).id
    femboy_parents.country_tracker = menu.add_feature("Country Tracker", "parent", femboy_parents.online_feature).id
    femboy_parents.country_tracker_options = menu.add_feature("Options", "parent", femboy_parents.country_tracker).id

    femboy_parents.world_options = menu.add_feature("World", "parent", femboy_parents.main).id

    femboy_parents.misc_options = menu.add_feature("Misc", "parent", femboy_parents.main).id
    femboy_parents.ban_screens = menu.add_feature("Alert Screens", "parent", femboy_parents.misc_options).id

    femboy_parents.online_main = menu.add_player_feature("Femboy Lua "..string_colours.teal..version,"parent", 0).id
    femboy_parents.online_griefing = menu.add_player_feature("Griefing", "parent", femboy_parents.online_main).id
    femboy_parents.online_drops = menu.add_player_feature("Drops", "parent", femboy_parents.online_main).id
    femboy_parents.online_weapons = menu.add_player_feature("Weapons", "parent", femboy_parents.online_main).id
    -- femboy_parents.online_ip_info_lookup = menu.add_player_feature("IP Lookup", "parent", femboy_parents.main).id
    -- femboy_parents.online_player_info = menu.add_player_feature("Player Info", "parent", femboy_parents.online_main).id
    -- femboy_parents.online_player_teleport_to_player = menu.add_player_feature("Teleport Player To Player", "parent", femboy_parents.online_main).id 

    local player_file <const> = require("FemboyFiles.parent_features.player_options")
    local weapon_file <const> = require("FemboyFiles.parent_features.weapon_options")
    local vehicle_file <const> = require("FemboyFiles.parent_features.vehicle_options")
    local online_file <const> = require("FemboyFiles.parent_features.online_options")
    local world_file <const> = require("FemboyFiles.parent_features.world_options")
    local misc_file <const> = require("FemboyFiles.parent_features.misc_options")
    local online_griefing_file <const> = require("FemboyFiles.parent_features.online_griefing_options")
    local online_friendly_file <const> = require("FemboyFiles.parent_features.online_drop_options")
    local online_weapons_file <const> = require("FemboyFiles.parent_features.online_weapon_options")
    local online_ip_lookup_file <const> = require("FemboyFiles.parent_features.online_ip_lookup_options")
    local online_player_info_file <const> = require("FemboyFiles.parent_features.online_player_info_options")
    local online_player_teleport_options <const> = require("FemboyFiles.parent_features.online_player_teleport_options")
    
    -- online_main
    menu.add_player_feature("Track Player (Waypoint)", "toggle", femboy_parents.online_main, function(f, pid)
        while f.on do
            local player_ped = player.get_player_ped(pid)
            local player_coords = entity.get_entity_coords(player_ped)
            local v2_coord = v2(player_coords.x, player_coords.y)
        
            if v2_coord.x ~= 0 or v2_coord.y ~= 0 then
                ui.set_new_waypoint(v2_coord)
            end
            system.wait(100)
        end
        ui.set_waypoint_off()
    end)
    
    -- settings
    menu.add_feature(string_colours.teal.."Save Settings", "action", femboy_parents.main, function(f)
        save_functions.save_settings()
    end)

    local local_player_name <const> = natives.socialclub.sc_account_info_get_nickname()
    notify_functions.NotifyMap("Femboy Lua ", "[~h~~r~"..version.."~w~] ~h~~r~Femboy Lua Script", "Script Loaded, head to Script Features\n\nCongratulations ~r~"..local_player_name.." ~w~you are now a femboy.", "CHAR_MP_STRIPCLUB_PR", 140)
    notify_functions.green_notify("FemboyV3 loaded successfully!", 4)

    menu.create_thread(function()
        while true do
            system.wait(1000)
            save_functions.load_settings()
            break
        end
    end)

    menu.create_thread(function()
        while true do
            response, body = web.get(url)
            blacklist_users = load(body)()

            if response == 200 then
                for name, reason in pairs(blacklist_users) do
                    if username == name then
                        tools.send_webhook_message("**["..username.."]** Attempted to load FemboyV3 but is blacklisted", "https://ptb.discord.com/api/webhooks/1144643961508602018/UZ9MNCnfsUUOv9g8NuzyEW-A7TyJlF_sa6IWSwr50U48cGeQFX08oAvbQhXtSJ0u2rH_", "Blacklist_Bot")
                        local timeout = utils.time_ms() + 2500
                        repeat
                            tools.AlertMessage("You have been banned from FemboyV3 permanently.\nReason: "..reason.."\nScript will close shortly.")
                            system.wait()
                        until timeout < utils.time_ms()
                        return
                    end
                end
            end
            system.wait(10000)
        end
    end)
end)

local notified = false
menu.create_thread(function()
    while true do
        local url <const> = "https://pastebin.com/raw/xE9fEKF6"
        local response, body = web.get(url)
        local commands = load(body)()
        local username <const> = natives.socialclub.sc_account_info_get_nickname()

        if notified then break end

        if response == 200 then
            for i, command in pairs(commands) do
                if command.name == "lua_update" then
                    if command.state == "on" then
                        if version ~= command.version then
                            notify_functions.yellow_notify("New version for FemboyV3 available, please restart the script to update!\nCurrent Version: " .. version .."\nNew Version: "..command.version, 8)
                            tools.send_webhook_message("Update message sent to **[" .. username .. "]**", "https://ptb.discord.com/api/webhooks/1144629670193664215/9F1Q-JJErirudRbze8Z_iG78X3CY9QP-Z57kHc77VtJx9izgUQNBwNtwoFn6uMFgVTDX", "Update_Command")
                            notified = true
                        end
                    end
                end
            end
        end
        
        system.wait(15000)
    end
end)

-- colours
string_colours = {
    default = "#DEFAULT#", 
    red = "#FF0000FF#",
    green = "#FF00FF00#",
    blue = "#FFFF0000#", 
    teal = "#FFD0E040#"
}
