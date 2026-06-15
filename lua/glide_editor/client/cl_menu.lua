local dimensions = StyledTheme.dimensions
local function CreateTextEntry( parent, text, defaultText, defaultValue, callback )
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
    textentry:SetValue( defaultValue or "" )
    textentry.OnTextChanged = function()
        callback( textentry:GetValue() )
    end

    textentry.OnEnter = function()
        callback( textentry:GetValue() )
    end

    StyledTheme.Apply( textentry )

    return textentry, label, panel
end

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

    self.tSettings = self.tSettings or {
        Name = "",
        Class = "",
        Category = "",
        ChassisModel = "",
        ChassisMass = 0,
        Wheels = {},
    }

    self.vgFrame = vgFrame

    local CreateHeader = StyledTheme.CreateFormHeader
    local CreateButton = StyledTheme.CreateFormButton
    local CreateComboBox = StyledTheme.CreateFormCombo
    local CreateSlider = StyledTheme.CreateFormSlider
    local CreateToggle = StyledTheme.CreateFormToggle

    -- 
    local vgHome = vgFrame:AddTab( "glide/icons/car.png", "Home" )

    CreateHeader( vgHome, "Default Configuration" )

    local vgTextEntryName = CreateTextEntry( vgHome, "Vehicle Name", "Enter the name of the vehicle", self.tSettings.Name or "", function( value )
        GLide_Editor:UpdateTable("Name", value, true)
    end )

    print(self.tSettings.Class)
    local vgTextEntryClass = CreateTextEntry( vgHome, "Vehicle Class", "Enter the class of the vehicle", self.tSettings.Class or "", function( value )
        GLide_Editor:UpdateTable("Class", value, true)
    end )

    local vgTextEntryCategory = CreateTextEntry( vgHome, "Vehicle Category", "Enter the category of the vehicle", self.tSettings.Category or "", function( value )
        value = value or "Default"
        GLide_Editor:UpdateTable("Category", value, true)
    end )

    local vgTextEntryChassisModel = CreateTextEntry( vgHome, "Chassis Model", "Enter the model for the chassis", self.tSettings.ChassisModel or "", function( value )
        GLide_Editor:UpdateTable("ChassisModel", value, true)
    end )

    local vgSliderChassisMass = CreateSlider( vgHome, "Chassis Mass", 25, 0, 1000, 2, function( value )
        GLide_Editor:UpdateTable("ChassisMass", value, true)
    end )

    self.tSettingsVGUI = {
        Name = vgTextEntryName,
        Class = vgTextEntryClass,
        Category = vgTextEntryCategory,
        ChassisModel = vgTextEntryChassisModel,
        ChassisMass = vgSliderChassisMass
    }

    PrintTable(self.tSettings)


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

    local tVehicle = { "" }
    for sClass, tData in pairs( list.Get( "GlideVehicles" ) ) do
        table.insert( tVehicle, ("%s : %s"):format( tData.Name, sClass ) )
    end

    
    CreateComboBox( vgHome, "Select Vehicle Glide", tVehicle, GLide_Editor.tSettings.ClassIndex or 1, function( value )
        local sClassNice = GLide_Editor:GetVehicle( tVehicle[ value ] )
        if not sClassNice then return end

        GLide_Editor:UpdateTable("ClassIndex", value, true)

        if sClassNice == "" then return end
        GLide_Editor:UpdateTable("Class", sClassNice, true)
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

    local function CreatePosSlider( parent, iID, sTitle, sKey, tData, vecDefault )
        for _, sPos in ipairs(tPos) do
            CreateSlider( parent, ("%s %s"):format( sTitle, sPos:upper() ), vecDefault[sPos], -500, 500, 4, function( value )
                tData[sKey] = tData[sKey] or vecDefault
                tData[sKey][sPos] = value

                UpdateWheel(iID, tData)
            end )
        end
    end

    local function CreateAngSlider( parent, iID, ang, tData, angDefault )
        for _, sAng in ipairs(tAng) do
            CreateSlider( parent, ("Wheel Angle %s"):format( sAng:upper() ), angDefault[sAng], -180, 180, 4, function( value )
                tData.modelAngle = tData.modelAngle or angDefault
                tData.modelAngle[sAng] = value

                UpdateWheel(iID, tData)
            end )
        end
    end

    local function OpenMenuWheel( tData, iID )
        vgScrollRight:Clear()

        -- Model
        CreateHeader( vgScrollRight, "Settings Model" )
        CreateTextEntry( vgScrollRight, "Wheel Model", "Enter the model for the wheel", tData.model or "", function( value )
            tData.model = value

            UpdateWheel(iID, tData)
        end )

        -- ModelScale
        CreatePosSlider( vgScrollRight, iID, "Model Scale", "modelScale", tData, tData.modelScale or Vector( 0.3, 1, 1 ) )

        CreateHeader( vgScrollRight, "Position" )
        CreatePosSlider( vgScrollRight, iID, "Position", "Pos", tData, tData.Pos or Vector(0, 0, 0) )

        CreateHeader( vgScrollRight, "Angle" )
        CreateAngSlider( vgScrollRight, iID, tAng, tData, tData.modelAngle or Angle(0, 0, 0) )

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
            tNewData.Pos = Vector( -tNewData.Pos.x, tNewData.Pos.y, tNewData.Pos.z )
            tNewData.Ang = Angle( tNewData.Ang.p, -tNewData.Ang.y, -tNewData.Ang.r )
            
            tNewData.vgButton = nil
            table.insert( GLide_Editor.tSettings.Wheels, tNewData )
            local vgButtonWheel = vgFrame:AddWheel( false, #GLide_Editor.tSettings.Wheels )
            tNewData.vgButton = vgButtonWheel

            vgButtonWheel:DoClick( true )
        end )
        vgSymmetryButton:Dock( LEFT )
        vgSymmetryButton:SetSize( 250, 30 )
        vgSymmetryButton:DockMargin( 0, 0, 10, 0 )
    end

    function vgFrame:AddWheel(bCreateButton, iID)
        local vgButtonWheel = CreateButton( vgScroll, "Wheel " .. iID, function( selfBtn, bUpdate )
            selfBtn.isToggle  = true

            for _, tData in ipairs( GLide_Editor.tSettings.Wheels ) do
                if tData.vgButton ~= selfBtn then
                    tData.vgButton.isToggle = false
                end
            end

            OpenMenuWheel( GLide_Editor.tSettings.Wheels[iID], iID )

            -- net.Start("GLide_Editor:SelectWheel")
            --     net.WriteUInt( iID, 8 )
            -- net.SendToServer()

            print("Selected Wheel ", selfBtn, bUpdate)
            net.Start("GLide_Editor:UpdateWheel")
                net.WriteUInt( iID, 8 )
                net.WriteVector( GLide_Editor.tSettings.Wheels[iID].Pos or Vector(0, 0, 0) )
                Glide.WriteTable( GLide_Editor.tSettings.Wheels[iID] )
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

                    net.Start("GLide_Editor:RemoveWheel")
                        net.WriteUInt( iID, 8 )
                    net.SendToServer()
                end,
                "No", function() end
            )
        end

        if not bCreateButton then return vgButtonWheel end

        table.insert( GLide_Editor.tSettings.Wheels, {
            Pos = Vector( 0, 0, 0 ),
            Ang = Angle( 0, 0, 0 ),
            vgButton = vgButtonWheel
        } )
    end

    for iID, tData in ipairs( GLide_Editor.tSettings.Wheels ) do
        local vgButtonWheel = vgFrame:AddWheel( false, iID )
        tData.vgButton = vgButtonWheel
    end

    local vgButtonAddWheel = CreateButton( vgPanelLeft, "Add Wheel", function()
        vgFrame:AddWheel( true, #GLide_Editor.tSettings.Wheels + 1 )
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