
local dimensions = StyledTheme.dimensions
local function CreateTextEntry( parent, text, defaultText, callback )
    local panel = vgui.Create( "DPanel", parent )
    panel:SetTall( dimensions.buttonHeight )
    panel:SetPaintBackground( false )
    panel:Dock( TOP )
    panel:DockMargin( 0, 0, 0, dimensions.formSeparator )

    local label = vgui.Create( "DLabel", panel )
    label:Dock( LEFT )
    label:DockMargin( 0, 0, 0, 0 )
    label:SetText( text )
    label:SetWide( dimensions.formLabelWidth )

    StyledTheme.Apply( label )

    local textentry = vgui.Create( "DTextEntry", panel )
    textentry:Dock( FILL )
    textentry:SetPlaceholderText( defaultText )
    textentry.OnTextChanged = function()
        callback( textentry:GetValue() )
    end

    StyledTheme.Apply( textentry )

    return textentry, label, panel
end

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

local tPos = { "x", "y", "z" }
local tAng = {"p", "y", "r"}
function GLide_Editor:OpenMenu()
    if IsValid( self.vgFrame ) then
        self.vgFrame:Remove()
    end

    local vgFrame = vgui.Create( "Styled_TabbedFrame" )
    vgFrame:SetIcon( "glide/icons/car.png" )
    vgFrame:SetTitle( "Glide Editor" )
    vgFrame:CenterHorizontal(0.75)
    vgFrame:MakePopup()
    vgFrame.bVisible = true

    vgFrame.OnKeyCodeReleased = function(s, key)
        if (key == KEY_LALT or key == KEY_RALT) and s.bVisible then
            s:AlphaTo(80, 0.2, 0)
            s:SetMouseInputEnabled(false)
            s:SetKeyboardInputEnabled(false)
            s.bVisible = false
        end
    end

    self.vgFrame = vgFrame

    local CreateHeader = StyledTheme.CreateFormHeader
    local CreateButton = StyledTheme.CreateFormButton
    local CreateComboBox = StyledTheme.CreateFormCombo
    local CreateSlider = StyledTheme.CreateFormSlider
    local CreateToggle = StyledTheme.CreateFormToggle

    -- 
    local vgHome = vgFrame:AddTab( "glide/icons/car.png", "Home" )

    CreateHeader( vgHome, "Default Configuration" )

    local vgTextEntryName = CreateTextEntry( vgHome, "Vehicle Name", "Enter the name of the vehicle", function( value )
        print( "Vehicle Name: " .. value )
    end )

    local vgTextEntryClass = CreateTextEntry( vgHome, "Vehicle Class", "Enter the class of the vehicle", function( value )
        print( "Vehicle Class: " .. value )
    end )

    local vgTextEntryCategory = CreateTextEntry( vgHome, "Vehicle Category", "Enter the category of the vehicle", function( value )
        value = value or "Default"
        print( "Vehicle Category: " .. value )
    end )

    local vgTextEntryChassisModel = CreateTextEntry( vgHome, "Chassis Model", "Enter the model for the chassis", function( value )
        print( "Chassis Model: " .. value )
    end )

    local vgSliderChassisMass = CreateSlider( vgHome, "Chassis Mass", 25, 0, 1000, 2, function( value )
        print( "Chassis Mass: " .. value )
    end )

    self.tSettingsVGUI = {
        Name = vgTextEntryName,
        Class = vgTextEntryClass,
        Category = vgTextEntryCategory,
        ChassisModel = vgTextEntryChassisModel,
        ChassisMass = vgSliderChassisMass
    }

    self.tSettings = {
        Name = "",
        Class = "",
        Category = "",
        ChassisModel = "",
        ChassisMass = 0,
        Wheels = {},
    }

    -- Category
    -- ChassisModel
    -- ChassisMass

    CreateButton( vgHome, "Spawn Vehicle", function()
        net.Start("GLide_Editor:SpawnVehicle")
            net.WriteString( vgTextEntryChassisModel:GetValue() )
            net.WriteUInt( vgSliderChassisMass:GetValue(), 16 )
            -- Wheels
            -- Settings
        net.SendToServer()
    end )

    -- CreateButton( vgHome, "Select Vehicle Glide", function()
    --     net.Start("GLide_Editor:SpawnProps")
    --     net.SendToServer()
    -- end )

    local tVehicle = { "" }
    for sClass, tData in pairs( list.Get( "GlideVehicles" ) ) do
        table.insert( tVehicle, ("%s : %s"):format( tData.Name, sClass ) )
    end

    CreateComboBox( vgHome, "Select Vehicle Glide", tVehicle, 1, function( value )
        local sClassNice = GLide_Editor:GetVehicle( tVehicle[ value ] )
        if not sClassNice then return end

        vgTextEntryClass:SetValue( sClassNice )
    end )

    CreateHeader( vgHome, "Engine Configuration" )

    local vgWheel = vgFrame:AddTab( "styledstrike/icons/cog.png", "Wheels" )

	local vgPanelLeft = vgui.Create( "DPanel", vgWheel )
    vgPanelLeft:SetWide( StyledTheme.ScaleSize( 200 ) )
    vgPanelLeft:SetTall( StyledTheme.ScaleSize(500) )
    vgPanelLeft:Dock( LEFT )
    vgPanelLeft:DockMargin( 10, 10, 0, 0 )
    vgPanelLeft.Paint = function( _, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, StyledTheme.colors.panelBackground  )
    end

    local vgScroll = vgui.Create( "DScrollPanel", vgPanelLeft )
    vgScroll:Dock( FILL )

    local vgPanelRight = vgui.Create( "DPanel", vgWheel )
    vgPanelRight:Dock( FILL )
    vgPanelRight:DockMargin( 10, 10, 0, 0 )
    vgPanelRight:DockPadding( 10, 10, 10, 10 )
    vgPanelRight.Paint = vgPanelLeft.Paint

    local vgScrollRight = vgui.Create( "DScrollPanel", vgPanelRight )
    vgScrollRight:Dock( FILL )

    local function UpdateWheel(iID, tData)
        if not IsValid(GLide_Editor.vgFrame) then return end
        if not GLide_Editor.tSettings then return end

        net.Start("GLide_Editor:UpdateWheel")
            net.WriteUInt( iID, 8 )
            net.WriteVector( tData.Pos or Vector(0, 0, 0) )
            Glide.WriteTable( tData )
        net.SendToServer()
    end

    local function CreatePosSlider( parent, iID, pos, tData )
        for _, sPos in ipairs(tPos) do
            CreateSlider( parent, ("Wheel Position %s"):format( sPos:upper() ), 0, -500, 500, 4, function( value )
                tData.Pos = tData.Pos or Vector(0, 0, 0)
                tData.Pos[sPos] = value

                UpdateWheel(iID, tData)
            end )
        end
    end

    local function CreateAngSlider( parent, iID, ang, tData )
        for _, sAng in ipairs(tAng) do
            CreateSlider( parent, ("Wheel Angle %s"):format( sAng:upper() ), 0, -180, 180, 4, function( value )
                tData.modelAngle = tData.modelAngle or Angle(0, 0, 0)
                tData.modelAngle[sAng] = value

                UpdateWheel(iID, tData)
            end )
        end
    end

    local function OpenMenuWheel( tData, iID )
        vgScrollRight:Clear()

        -- Model
        CreateHeader( vgScrollRight, "Settings Model" )
        CreateTextEntry( vgScrollRight, "Wheel Model", "Enter the model for the wheel", function( value )
            tData.model = value

            UpdateWheel(iID, tData)
        end )

        CreateHeader( vgScrollRight, "Position" )
        CreatePosSlider( vgScrollRight, iID, tPos, tData )

        -- CreateHeader( vgScrollRight, "Angle" )
        CreateAngSlider( vgScrollRight, iID, tAng, tData )

        CreateHeader( vgScrollRight, "Wheel Settings" )

        CreateSlider( vgScrollRight, "Wheel Radius", 1, 100, tData.Radius or 15, 2, function(newValue)
            tData.Radius = newValue
        end )

        -- steerMultiplier
        CreateSlider( vgScrollRight, "Steer Multiplier", 0, 10, tData.SteerMultiplier or 1, 2, function(newValue)
            tData.SteerMultiplier = newValue
        end )

        -- isBulletProof
        CreateToggle( vgScrollRight, "Bullet Proof", tData.IsBulletProof or false, function(newValue)
            tData.IsBulletProof = newValue
        end )

        CreateToggle( vgScrollRight, "Disable Sounds", tData.disableSounds or false, function(newValue)
            tData.disableSounds = newValue
        end )

        CreateHeader( vgScrollRight, "Wheel Actions" )

        local vgPanelButtons = vgui.Create( "DPanel", vgScrollRight )
        vgPanelButtons:Dock( TOP )
        vgPanelButtons.Paint = function() end

        local vgDuplicateButton = CreateButton( vgPanelButtons, "Duplicate Wheel", function()
            local tNewData = table.Copy( tData )
            tNewData.vgButton = nil
            table.insert( GLide_Editor.tSettings.Wheels, tNewData )
            AddWheel()
        end )
        vgDuplicateButton:SetSize( 150, 30 )
        vgDuplicateButton:Dock( LEFT )
        vgDuplicateButton:DockMargin( 0, 0, 10, 0 )

        local vgSymmetryButton = CreateButton( vgPanelButtons, "Duplicate Wheel and Symmetry", function()
            local tNewData = table.Copy( tData )
            tNewData.vgButton = nil
            tNewData.Pos.x = -tNewData.Pos.x
            table.insert( GLide_Editor.tSettings.Wheels, tNewData )
            AddWheel()
        end )
        vgSymmetryButton:Dock( LEFT )
        vgSymmetryButton:SetSize( 250, 30 )
        vgSymmetryButton:DockMargin( 0, 0, 10, 0 )
    end

    local function AddWheel()
        local vgButtonWheel = CreateButton( vgScroll, "Wheel " .. (#GLide_Editor.tSettings.Wheels + 1), function( selfBtn )
            selfBtn.isToggle  = true

            for _, tData in ipairs( GLide_Editor.tSettings.Wheels ) do
                if tData.vgButton ~= selfBtn then
                    tData.vgButton.isToggle = false
                end
            end

            OpenMenuWheel( GLide_Editor.tSettings.Wheels[#GLide_Editor.tSettings.Wheels], #GLide_Editor.tSettings.Wheels )

            net.Start("GLide_Editor:SelectWheel")
                net.WriteUInt( #GLide_Editor.tSettings.Wheels, 8 )
            net.SendToServer()
        end )

        vgButtonWheel.isChecked = true


        function vgButtonWheel:DoRightClick()
            Derma_Query(
                "Are you sure you want to remove this wheel?",
                "Remove Wheel",
                "Yes", function()
                    for i, tData in ipairs( GLide_Editor.tSettings.Wheels ) do
                        if tData.vgButton == vgButtonWheel then
                            table.remove( GLide_Editor.tSettings.Wheels, i )
                            vgButtonWheel:Remove()
                            break
                        end
                    end
                end,
                "No", function() end
            )
        end

        table.insert( GLide_Editor.tSettings.Wheels, {
            Pos = Vector( 0, 0, 0 ),
            Ang = Angle( 0, 0, 0 ),
            vgButton = vgButtonWheel
        } )
    end

    local vgButtonAddWheel = CreateButton( vgPanelLeft, "Add Wheel", function()
        AddWheel()
    end )
    vgButtonAddWheel:Dock( BOTTOM )
end

GLide_Editor:OpenMenu()

local iCooldown = 0
hook.Add("PlayerButtonDown", "GLide_Editor::ToggleMenu", function(pPlayer, button)
    if not IsValid(GLide_Editor.vgFrame) then return end

    if button == KEY_LALT or button == KEY_RALT and not GLide_Editor.vgFrame.bVisible then
        if CurTime() < iCooldown then return end

        GLide_Editor.vgFrame:AlphaTo(255, 0.2, 0)
        GLide_Editor.vgFrame:SetMouseInputEnabled(true)
        GLide_Editor.vgFrame:SetKeyboardInputEnabled(true)
        GLide_Editor.vgFrame.bVisible = true

        print("Menu shown")

        iCooldown = CurTime() + 0.3 -- Add a short cooldown to prevent rapid toggling
    end
end)

net.Receive("GLide_Editor:GetVehicle", function()
    local sName = net.ReadString()
    local sCategory = net.ReadString()
    local sChassisModel = net.ReadString()
    local iChassisMass = net.ReadUInt( 16 )

    if not IsValid( GLide_Editor.vgFrame ) then return end
    if not GLide_Editor.tSettingsVGUI then return end

    GLide_Editor.tSettingsVGUI.Name:SetValue( sName )
    GLide_Editor.tSettingsVGUI.Category:SetValue( sCategory )
    GLide_Editor.tSettingsVGUI.ChassisModel:SetValue( sChassisModel )
    GLide_Editor.tSettingsVGUI.ChassisMass:SetValue( iChassisMass )
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