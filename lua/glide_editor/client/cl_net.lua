local tSounds = {
    [NOTIFY_GENERIC] = "buttons/lightswitch2.wav",
    [NOTIFY_ERROR] = "buttons/button10.wav",
    [NOTIFY_UNDO] = "buttons/button14.wav",
    [NOTIFY_HINT] = "buttons/lightswitch2.wav",
    [NOTIFY_CLEANUP] = "buttons/lightswitch2.wav"
}

net.Receive("GLide_Editor:Notify", function()
    local sMessage = net.ReadString()
    local iType = net.ReadUInt(8)
    local iDuration = net.ReadUInt(8)

    notification.AddLegacy(sMessage, iType, iDuration)
    surface.PlaySound(tSounds[iType] or "buttons/lightswitch2.wav")
end)