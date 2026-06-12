
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

    local vgWheel = vgFrame:AddTab( "styledstrike/icons/cog.png", "Home" )

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