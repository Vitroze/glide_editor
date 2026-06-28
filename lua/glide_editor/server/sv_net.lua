util.AddNetworkString( "GLide_Editor:SpawnVehicle" )
util.AddNetworkString( "GLide_Editor:GetVehicle" )
util.AddNetworkString( "GLide_Editor:UpdateWheel" )
util.AddNetworkString( "GLide_Editor:SelectWheel" )
util.AddNetworkString( "GLide_Editor:RemoveWheel" )
util.AddNetworkString( "GLide_Editor:Notify" )

net.Receive( "GLide_Editor:SpawnVehicle", function( _, pPlayer )
    if not IsValid( pPlayer ) then return end
    if not GLide_Editor:IsSinglePlayer() then return end

    local sModel = net.ReadString()
    -- local iWheels = net.ReadUInt( 8 )
    -- for i = 1, iWheels do
    --     local sWheelModel = net.ReadString()
    --     print( "Wheel " .. i .. ": " .. sWheelModel )
    -- end

    GLide_Editor:SpawnVehicle( pPlayer, sModel, {}, {}, {} )
    --local iSettings = net.ReadUInt( 8 )
end )

net.Receive( "GLide_Editor:GetVehicle", function( _, pPlayer )
    if not IsValid( pPlayer ) then return end
    if not GLide_Editor:IsSinglePlayer() then return end

    local sClass = net.ReadString()
    local tData = scripted_ents.GetList()[sClass]
    if not tData then return end

    tData = tData["t"]
    if not tData then return end

    net.Start("GLide_Editor:GetVehicle")
        net.WriteString( tData.PrintName or "" )
        net.WriteString( tData.GlideCategory or "" )
        net.WriteString( tData.ChassisModel or "" )
        net.WriteUInt( tData.ChassisMass or 0, 16 )
    net.Send(pPlayer)
end )

net.Receive( "GLide_Editor:UpdateWheel", function( _, pPlayer )
    if not IsValid( pPlayer ) then return end
    if not GLide_Editor:IsSinglePlayer() then return end

    local iID = net.ReadUInt( 8 )
    local vOffset = net.ReadVector()
    local tParams = Glide.ReadTable()

    local eVehicle = pPlayer.eVehicleGlideEditor
    if not IsValid( eVehicle ) then return end
    GLide_Editor:UpdateWheel( eVehicle, iID, vOffset, tParams )

    print( "TS", eVehicle.wheels, eVehicle.wheels[iID], pPlayer:GetNW2Entity( "GLide_Editor::Target", nil ) )

    if IsValid( eVehicle.wheels[iID] ) and eVehicle.wheels[iID] ~= pPlayer:GetNW2Entity( "GLide_Editor::Target", nil ) then
        pPlayer:SetNW2Entity( "GLide_Editor::Target", eVehicle.wheels[iID] )
    end
end )

-- net.Receive( "GLide_Editor:SelectWheel", function( _, pPlayer )
--     if not IsValid( pPlayer ) then return end
--     if not GLide_Editor:IsSinglePlayer() then return end

--     local iID = net.ReadUInt( 8 )

--     local eVehicle = pPlayer.eVehicleGlideEditor
--     if not IsValid( eVehicle ) then return end

--     local eWheel = GLide_Editor:GetWheel( eVehicle, iID )
--     if not IsValid( eWheel ) then
--         eWheel = eVehicle:CreateWheel( Vector(0, 0, 0), {} )
--         print("Created new wheel " , iID , " for vehicle " , eVehicle)
--     end

--     pPlayer:SetNW2Entity( "GLide_Editor::Target", eWheel )
-- end )

net.Receive( "GLide_Editor:RemoveWheel", function( _, pPlayer )
    if not IsValid( pPlayer ) then return end
    if not GLide_Editor:IsSinglePlayer() then return end

    local iID = net.ReadUInt( 8 )

    local eVehicle = pPlayer.eVehicleGlideEditor
    if not IsValid( eVehicle ) then return end

    if IsValid( eVehicle.wheels[iID] ) then
        eVehicle.wheels[iID]:Remove()
        table.remove( eVehicle.wheels, iID )

        eVehicle.wheelCount = table.Count( eVehicle.wheels )
        GLide_Editor:Notify( pPlayer, ("Removed wheel %d from vehicle %s. Total wheels: %d"):format( iID, eVehicle:GetClass(), eVehicle.wheelCount ), 0, 5 )
    end
end )