util.AddNetworkString( "GLide_Editor:SpawnVehicle" )
util.AddNetworkString( "GLide_Editor:GetVehicle" )

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