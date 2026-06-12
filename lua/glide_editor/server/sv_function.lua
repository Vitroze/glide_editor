function GLide_Editor:SpawnVehicle( pPlayer, sModel, tSettings, tWheels, tSeats )
    if not IsValid( pPlayer ) then return end
    if not sModel or sModel == "" then return end

    if IsValid( pPlayer.eVehicleGlideEditor ) then
        pPlayer.eVehicleGlideEditor:Remove()
    end

    local eVehicle = ents.Create( "glide_editor_spawn_vehicle" )
    if not IsValid( eVehicle ) then return end

    local tTrace = pPlayer:GetEyeTrace()
    local vSpawnPos = tTrace.HitPos + Vector( 0, 0, 40 )

    -- Settings
    eVehicle.ChassisModel = sModel
    eVehicle.tWheels = tWheels
    eVehicle.tSeats = tSeats

    eVehicle:SetPos( vSpawnPos )
    eVehicle:SetAngles( Angle( 0, pPlayer:EyeAngles().y - 180, 0 ) )
    eVehicle:SetCreator( pPlayer )
    eVehicle:Spawn()
    eVehicle:Activate()

    local oPhys = eVehicle:GetPhysicsObject()
    if IsValid( oPhys ) then
        oPhys:EnableMotion( false )
    end

    pPlayer.eVehicleGlideEditor = eVehicle
end