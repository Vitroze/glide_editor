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

function GLide_Editor:UpdateWheel( eVehicle, iID, vOffset, tParams )
    print("Updating wheel " , iID , " with offset " , vOffset , " and params " , tParams)
    print(eVehicle, iID, vOffset, tParams)
    if IsValid(eVehicle.wheels[iID]) then
        eVehicle.wheels[iID]:SetupWheel(tParams)
        eVehicle.wheels[iID]:SetPos(eVehicle:LocalToWorld(vOffset))
    else
        eVehicle:CreateWheel(vOffset, tParams)
    end
end

function GLide_Editor:GetWheel( eVehicle, iID )
    if not IsValid(eVehicle) then return end
    if not eVehicle.wheels[iID] then return end

    return eVehicle.wheels[iID]
end