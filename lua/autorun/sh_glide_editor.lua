GLide_Editor = GLide_Editor or {}

-- TODO: Remove true
function GLide_Editor:IsSinglePlayer()
    return true or game.SinglePlayer()
end

if not GLide_Editor:IsSinglePlayer() then
    MsgC(Color(255, 0, 0), "[GLide Editor] This addon is only compatible with singleplayer mode.\n")
    return
end

local sDirectory = "glide_editor/"
local function loadClient(sFile)
    if SERVER then
        AddCSLuaFile(sFile)
    else
        include(sFile)
    end
end

local function loadServer(sFile)
    if SERVER then
        include(sFile)
    end
end

local function loadShared(sFile)
    if SERVER then
        AddCSLuaFile(sFile)
        include(sFile)
    else
        include(sFile)
    end
end

loadClient(sDirectory .. "client/cl_hook.lua")
loadClient(sDirectory .. "client/cl_menu.lua")
loadClient(sDirectory .. "client/cl_function.lua")

loadServer(sDirectory .. "server/sv_hook.lua")
loadServer(sDirectory .. "server/sv_net.lua")
loadServer(sDirectory .. "server/sv_function.lua")

loadShared(sDirectory .. "sh_function.lua")