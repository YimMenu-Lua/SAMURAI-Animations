---@diagnostic disable: undefined-global, lowercase-global

anim_player = gui.get_tab("SAMURAI's Animations")

local animlist = require ("animdata")

local anim_index = 1

anim_player:add_text("Search animations :")

local searchQuery = ""

local is_typing = false
script.register_looped("Animations", function()
	if is_typing then
		PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
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

local info = filteredAnims[anim_index+1] or nil
local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
local coords = ENTITY.GET_ENTITY_COORDS(ped, false)
local heading = ENTITY.GET_ENTITY_HEADING(ped)
local forwardX = ENTITY.GET_ENTITY_FORWARD_X(ped)
local forwardY = ENTITY.GET_ENTITY_FORWARD_Y(ped)
    if ImGui.Button("Play") then
        if info ~= nil then
            local boneIndex = PED.GET_PED_BONE_INDEX(ped, info.boneID)
            script.run_in_fiber(function(script)
                STREAMING.REQUEST_ANIM_DICT(info.dict)
                STREAMING.REQUEST_ANIM_SET(info.anim)
                coroutine.yield()

                if info.type == 1 then
                    ENTITY.DELETE_ENTITY(prop1)
                    ENTITY.DELETE_ENTITY(prop2)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                    GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                    script:sleep(50)
                    while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                        STREAMING.REQUEST_MODEL(info.prop1)
                        coroutine.yield()
                    end
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0,0.0,0, true, true, false)
                    ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.prop1)
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, info.flag, 1.0, false, false, false)
                    is_playing_anim = true

                elseif info.type == 2 then
                    ENTITY.DELETE_ENTITY(prop1)
                    ENTITY.DELETE_ENTITY(prop2)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                    GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                    script:sleep(50)
                    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                        STREAMING.REQUEST_NAMED_PTFX_ASSET(info.ptfxdict)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, info.flag, 0, false, false, false)
                    script:sleep(400)
                    GRAPHICS.USE_PARTICLE_FX_ASSET(info.ptfxdict)
                    loopedFX = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(info.ptfxname, ped, info.ptfxOffx, info.ptfxOffy, info.ptfxOffz, 0.0, 0.0, 0.0, boneIndex, info.ptfxscale, false, false, false, 0, 0, 0, 0)
                    is_playing_anim = true

                elseif info.type == 3 then
                    ENTITY.DELETE_ENTITY(prop1)
                    ENTITY.DELETE_ENTITY(prop2)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                    GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                    script:sleep(50)
                    while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                        STREAMING.REQUEST_MODEL(info.prop1)
                        coroutine.yield()
                    end
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, coords.x + (forwardX), coords.y + (forwardY), coords.z, true, true, false)
                    ENTITY.SET_ENTITY_HEADING(prop1, heading)
                    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(prop1)
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.prop1)
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, info.flag, 1.0, false, false, false)
                    is_playing_anim = true

                elseif info.type == 4 then
                    ENTITY.DELETE_ENTITY(prop1)
                    ENTITY.DELETE_ENTITY(prop2)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                    GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                    script:sleep(50)
                    while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                        STREAMING.REQUEST_MODEL(info.prop1)
                        coroutine.yield()
                    end
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, info.flag, 1.0, false, false, false)
                    script:sleep(400)
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0,0.0,0, true, true, false)
                    local bonecoords = PED.GET_PED_BONE_COORDS(ped, info.boneID)
                    ENTITY.SET_ENTITY_COORDS(prop1, bonecoords.x + info.posx, bonecoords.y + info.posy, bonecoords.z + info.posz)
                    ENTITY.SET_ENTITY_COLLISION(prop1, info.propColl, info.propColl)
                    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(prop1)
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.prop1)
                    is_playing_anim = true

                elseif info.type == 5 then
                    ENTITY.DELETE_ENTITY(prop1)
                    ENTITY.DELETE_ENTITY(prop2)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                    GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                    script:sleep(50)
                    while not STREAMING.HAS_MODEL_LOADED(info.prop1) do
                        STREAMING.REQUEST_MODEL(info.prop1)
                        coroutine.yield()
                    end
                    prop1 = OBJECT.CREATE_OBJECT(info.prop1, 0.0,0.0,0, true, true, false)
                    ENTITY.ATTACH_ENTITY_TO_ENTITY(prop1, ped, boneIndex, info.posx, info.posy, info.posz, info.rotx, info.roty, info.rotz, false, false, false, false, 2, true, 1)
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.prop1)
                    script:sleep(50)
                    while not STREAMING.HAS_MODEL_LOADED(info.prop2) do
                        STREAMING.REQUEST_MODEL(info.prop2)
                        coroutine.yield()
                    end
                    prop2 = OBJECT.CREATE_OBJECT(info.prop2, coords.x + (forwardX), coords.y + (forwardY), coords.z, true, true, false)
                    ENTITY.SET_ENTITY_HEADING(prop2, heading)
                    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(prop2)
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(info.prop2)
                    script:sleep(50)
                    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(info.ptfxdict) do
                        STREAMING.REQUEST_NAMED_PTFX_ASSET(info.ptfxdict)
                        coroutine.yield()
                    end
                    GRAPHICS.USE_PARTICLE_FX_ASSET(info.ptfxdict)
                    loopedFX = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY(info.ptfxname, prop2, info.ptfxOffx, info.ptfxOffy, info.ptfxOffz, 0.0, 0.0, 0.0, info.ptfxscale, false, false, false, 0, 0, 0, 0)
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, info.flag, 1.0, false, false, false)
                    is_playing_anim = true

                else
                    ENTITY.DELETE_ENTITY(prop1)
                    ENTITY.DELETE_ENTITY(prop2)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
                    STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                    GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                    script:sleep(50)
                    TASK.TASK_PLAY_ANIM(ped, info.dict, info.anim, 4.0, -4.0, -1, info.flag, 0.0, false, false, false)
                    is_playing_anim = true
                end
            end)
        end
    end

ImGui.SameLine()

    if ImGui.Button("Stop") then
        if info ~= nil and is_playing_anim then
            script.run_in_fiber(function()
                ENTITY.DELETE_ENTITY(prop1)
                ENTITY.DELETE_ENTITY(prop2)
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                TASK.CLEAR_PED_TASKS(ped)
                TASK.TASK_PLAY_ANIM(ped, "missminuteman_1ig_2", "handsup_base", 8.0, -8.0, -1, 0, 1.0, false, false, false)
                is_playing_anim = false
            end)
        end
    end

    script.register_looped("Stop Animation", function()
        if info ~= nil and is_playing_anim then
            if PAD.IS_CONTROL_PRESSED(0, 252) then
                ENTITY.DELETE_ENTITY(prop1)
                ENTITY.DELETE_ENTITY(prop2)
                STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
                TASK.CLEAR_PED_TASKS(ped)
                TASK.TASK_PLAY_ANIM(ped, "missminuteman_1ig_2", "handsup_base", 8.0, -8.0, -1, 0, 1.0, false, false, false)
                is_playing_anim = false
            end
        end
    end)

    event.register_handler(menu_event.ScriptsReloaded, function()
        if info ~= nil and is_playing_anim then
            ENTITY.DELETE_ENTITY(prop1)
            ENTITY.DELETE_ENTITY(prop2)
            STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
            GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
            TASK.CLEAR_PED_TASKS(ped)
            is_playing_anim = false
        end
    end)

    event.register_handler(menu_event.MenuUnloaded, function()
        if info ~= nil and is_playing_anim then
            ENTITY.DELETE_ENTITY(prop1)
            ENTITY.DELETE_ENTITY(prop2)
            STREAMING.REMOVE_NAMED_PTFX_ASSET(info.ptfxdict)
            GRAPHICS.STOP_PARTICLE_FX_LOOPED(loopedFX)
            TASK.CLEAR_PED_TASKS(ped)
            is_playing_anim = false
        end
    end)
end)
