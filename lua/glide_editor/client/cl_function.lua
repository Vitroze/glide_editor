function GLide_Editor:GetVehicle(sClass)
    -- Name : Class
    local sClassNice = sClass:match(" : (.+)$") or sClass
    net.Start("GLide_Editor:GetVehicle")
        net.WriteString(sClassNice)
    net.SendToServer()
    return sClassNice
end

/*

            for _, pos in ipairs(tPos) do
                AddSliderLabel(TList, 5, 5 + (25 * _), "Seat " .. string.upper(pos), -iLimit, iLimit, tSeat["Pos"] and tSeat["Pos"][pos] or 0, function(newValue)
                    VCMOD_EditorVitroze.tData["ExtraSeats"] = VCMOD_EditorVitroze.tData["ExtraSeats"] or {}
                    VCMOD_EditorVitroze.tData["ExtraSeats"][iID]["Pos"] = VCMOD_EditorVitroze.tData["ExtraSeats"][iID]["Pos"] or {}
                    VCMOD_EditorVitroze.tData["ExtraSeats"][iID]["Pos"][pos] = newValue
                end)
            end

            AddLabel(TList, 5, 5 + (25 * #tPos) + 30, "Angle")
            for _, ang in ipairs(tAng) do
                AddSliderLabel(TList, 5, 5 + (25 * #tPos) + 30 + (25 * _), "Seat " .. string.upper(ang), -180, 180, tSeat["Ang"] and tSeat["Ang"][ang] or 0, function(newValue)
                    VCMOD_EditorVitroze.tData["ExtraSeats"] = VCMOD_EditorVitroze.tData["ExtraSeats"] or {}
                    VCMOD_EditorVitroze.tData["ExtraSeats"][iID]["Ang"] = VCMOD_EditorVitroze.tData["ExtraSeats"][iID]["Ang"] or {}
                    VCMOD_EditorVitroze.tData["ExtraSeats"][iID]["Ang"][ang] = newValue
                end)
            end
*/

function GLide_Editor:UpdateTable(sKey, aValue, bNoUpdateVGUI)
    if not sKey or sKey == "" then return end

    self.tSettings[sKey] = aValue

    if IsValid(self.vgFrame) and self.tSettingsVGUI and self.tSettingsVGUI[sKey] then
        print("GLide_Editor:UpdateTable() = ", sKey, aValue)
        self.tSettingsVGUI[sKey]:SetValue(aValue)
    end
end

net.Receive("GLide_Editor:GetVehicle", function()
    local sName = net.ReadString()
    local sCategory = net.ReadString()
    local sChassisModel = net.ReadString()
    local iChassisMass = net.ReadUInt( 16 )

    print("GLide_Editor:GetVehicle() = ", sName, sCategory, sChassisModel, iChassisMass)

    if not IsValid( GLide_Editor.vgFrame ) then return end
    if not GLide_Editor.tSettingsVGUI then return end

    -- GLide_Editor.tSettingsVGUI.Name:SetValue( sName )
    -- GLide_Editor.tSettingsVGUI.Category:SetValue( sCategory )
    -- GLide_Editor.tSettingsVGUI.ChassisModel:SetValue( sChassisModel )
    -- GLide_Editor.tSettingsVGUI.ChassisMass:SetValue( iChassisMass )

    GLide_Editor:UpdateTable("Name", sName)
    GLide_Editor:UpdateTable("Category", sCategory)
    GLide_Editor:UpdateTable("ChassisModel", sChassisModel)
    GLide_Editor:UpdateTable("ChassisMass", iChassisMass)

    print("GLide_Editor:GetVehicle() = ", sName, sCategory, sChassisModel, iChassisMass)
end )

function GLide_Editor:GetTab()
    if not IsValid( self.vgFrame ) then return end
    local iIndex = self.vgFrame.lastTabIndex
    if not iIndex then return end

    local vgButton = self.vgFrame.tabs[iIndex] and self.vgFrame.tabs[iIndex].button
    if not IsValid( vgButton ) then return end

    return vgButton:GetTooltip()
end

print("GLide_Editor:GetTab() = " , GLide_Editor:GetTab())