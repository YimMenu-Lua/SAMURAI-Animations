---@diagnostic disable: undefined-global, lowercase-global

anim_player = gui.get_tab("SAMURAI's Animations")

local animlist = require ("animdata")

local anim_index = 1

anim_player:add_text("Search animations :")

local searchQuery = ""

local is_playing_anim = false
local is_typing = false
script.register_looped("-_-", function()
	if is_typing then
		PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
	end
    if is_playing_anim and PAD.IS_CONTROL_PRESSED(0, 252) then
        cleanup()
        -- //fix player clipping through the ground after ending low-positioned anims//
        local current_coords = ENTITY.GET_ENTITY_COORDS(ped)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
        is_playing_anim = false
    end
end)

anim_player:add_imgui(function()
    searchQuery, used = ImGui.InputText("", searchQuery, 32)
    if ImGui.IsItemActive() then
		is_typing = true
	else
		is_typing = false
	end
    ImGui.PushItemWidth(350)
end)

local filteredAnims = {}
local function updatefilteredAnims()
    filteredAnims = {}
    for _, anim in ipairs(animlist) do
        if string.find(string.lower(anim.name), string.lower(searchQuery)) then
            table.insert(filteredAnims, anim)
        end
    end
    table.sort(animlist, function(a, b)
        return a.name < b.name
    end)
end

local function displayFilteredList()
    updatefilteredAnims()
    local animNames = {}
    for _, anim in ipairs(filteredAnims) do
        table.insert(animNames, anim.name)
    end
    anim_index, used = ImGui.ListBox(" ", anim_index, animNames, #filteredAnims)
end

anim_player:add_imgui(displayFilteredList)

anim_player:add_separator()

anim_player:add_text("TIP : You can stop a currently playing animation \nby pressing 'X' on keyboard or 'LT' on controller.")

anim_player:add_separator()

anim_player:add_imgui(function()
local info = filteredAnims[anim_index+1]
local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
local coords = ENTITY.GET_ENTITY_COORDS(ped, false)
local heading = ENTITY.GET_ENTITY_HEADING(ped)
local forwardX = ENTITY.GET_ENTITY_FORWARD_X(ped)
local forwardY = ENTITY.GET_ENTITY_FORWARD_Y(ped)
local boneIndex = PED.GET_PED_BONE_INDEX(ped, info.boneID)
local bonecoords = PED.GET_PED_BONE_COORDS(ped, info.boneID)
function cleanup()
    script.run_in_fiber(function()
        TASK.CLEAR_PED_TASKS(ped)
        ENTITY.DELETE_ENTITY(prop1)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop1)
        ENTITY.DELETE_ENTITY(prop2)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop2)
        GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
        while STREAMING.DOES_ANIM_DICT_EXIST(info.dict) and STREAMING.DOES_ANIM_SET_EXIST(info.anim) do
            STREAMING.REMOVE_ANIM_DICT(info.dict)
            STREAMING.REMOVE_ANIM_SET(info.anim)
            coroutine.yield()
        end
        while STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
            STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
            coroutine.yield()
        end
    end)
end

    if ImGui.Button("	Play	") then
        if info then
            if info.type == 1 then
                cleanup()
                script.run_in_fiber(function()
                    while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                        STREAMING.REQUEST_MODEL(info.prop1)
                        coroutine.yield()
                    end
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, false)
                    ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.prop1)
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) and not STREAMING.HAS_ANIM_SET_LOADED(info.anim) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        STREAMING.REQUEST_ANIM_SET(info.anim)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, info.flag, 1.0, false, false, false)
                end)

            elseif info.type == 2 then
                cleanup()
                script.run_in_fiber(function(type2)
                    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                        STREAMING.REQUEST_NAMED_PTFX_ASSET(info.ptfxdict)
                        coroutine.yield()
                    end
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) and not STREAMING.HAS_ANIM_SET_LOADED(info.anim) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        STREAMING.REQUEST_ANIM_SET(info.anim)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, info.flag, 0, false, false, false)
                    type2:sleep(400)
                    GRAPHICS.USE_PARTICLE_FX_ASSET(info.ptfxdict)
                    loopedFX = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(info.ptfxname, ped, info.ptfxOffx, info.ptfxOffy, info.ptfxOffz, 0.0, 0.0, 0.0, boneIndex, info.ptfxscale, false, false, false, 0, 0, 0, 0)
                    while STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                        STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                        coroutine.yield()
                    end
                end)

            elseif info.type == 3 then
                cleanup()
                script.run_in_fiber(function()
                    while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                        STREAMING.REQUEST_MODEL(info.prop1)
                        coroutine.yield()
                    end
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, coords.x + (forwardX), coords.y + (forwardY), coords.z, true, true, false)
                    ENTITY.SET_ENTITY_HEADING(prop1, heading)
                    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(prop1)
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.prop1)
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) and not STREAMING.HAS_ANIM_SET_LOADED(info.anim) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        STREAMING.REQUEST_ANIM_SET(info.anim)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, info.flag, 1.0, false, false, false)
                end)

            elseif info.type == 4 then
                cleanup()
                script.run_in_fiber(function(type4)
                    while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                        STREAMING.REQUEST_MODEL(info.prop1)
                        coroutine.yield()
                    end
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) and not STREAMING.HAS_ANIM_SET_LOADED(info.anim) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        STREAMING.REQUEST_ANIM_SET(info.anim)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, info.flag, 1.0, false, false, false)
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0, 0.0, 0.0, true, true, false)
                    type4:sleep(200)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(prop1, bonecoords.x + info.posx, bonecoords.y + info.posy, bonecoords.z + info.posz)
                    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(prop1)
                    ENTITY.SET_ENTITY_COLLISION(prop1, info.propColl, info.propColl)
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.prop1)
                end)
            else
                cleanup()
                script.run_in_fiber(function(script)
                    while not STREAMING.HAS_ANIM_DICT_LOADED(info.dict) and not STREAMING.HAS_ANIM_SET_LOADED(info.anim) do
                        STREAMING.REQUEST_ANIM_DICT(info.dict)
                        STREAMING.REQUEST_ANIM_SET(info.anim)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, info.flag, 0.0, false, false, false)
                end)
            end
        end
        is_playing_anim = true
    end
    if info.name == "Crawl Forward" then
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Crawl Forward:\nUse 'A/D' To Turn Right/Left.")
            ImGui.EndTooltip()
        end
    elseif info.name == "Goofy Walk" or info.name == "Boss Walk" or info.name == "Goofy run" then
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Walk or run after playing the animation.")
            ImGui.EndTooltip()
        end
    elseif info.name == "Sleep" or info.name == "Sunbathe" then
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Use 'W A S D' to adjust your position.")
            ImGui.EndTooltip()
        end
    end
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()
ImGui.Spacing()
ImGui.SameLine()

    if ImGui.Button("	Stop	") then
        cleanup()
        -- //fix player clipping through the ground after ending low-positioned anims//
        local current_coords = ENTITY.GET_ENTITY_COORDS(ped)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
        is_playing_anim = false
    end

    event.register_handler(menu_event.ScriptsReloaded, function()
            GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
            ENTITY.DELETE_ENTITY(prop1)
            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop1)
            ENTITY.DELETE_ENTITY(prop2)
            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop2)
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            while STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                coroutine.yield()
            end
            while STREAMING.DOES_ANIM_DICT_EXIST(info.dict) and STREAMING.DOES_ANIM_SET_EXIST(info.anim) do
                STREAMING.REMOVE_ANIM_DICT(info.dict)
                STREAMING.REMOVE_ANIM_SET(info.anim)
                coroutine.yield()
            end
            -- //fix player clipping through the ground after ending low-positioned anims//
            local current_coords = ENTITY.GET_ENTITY_COORDS(ped)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
    end)

    event.register_handler(menu_event.MenuUnloaded, function()
            GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
            ENTITY.DELETE_ENTITY(prop1)
            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop1)
            ENTITY.DELETE_ENTITY(prop2)
            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(prop2)
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            while STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                coroutine.yield()
            end
            while STREAMING.DOES_ANIM_DICT_EXIST(info.dict) and STREAMING.DOES_ANIM_SET_EXIST(info.anim) do
                STREAMING.REMOVE_ANIM_DICT(info.dict)
                STREAMING.REMOVE_ANIM_SET(info.anim)
                coroutine.yield()
            end
            -- //fix player clipping through the ground after ending low-positioned anims//
            local current_coords = ENTITY.GET_ENTITY_COORDS(ped)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, current_coords.x, current_coords.y, current_coords.z, true, false, false)
    end)
end)
