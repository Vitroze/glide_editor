hook.Add("PreDrawHalos", "GLide_Editor:SelectWheel", function()
    if not GLide_Editor:GetTab() or GLide_Editor:GetTab() ~= "Wheels" then return end

    halo.Add({LocalPlayer():GetNW2Entity("GLide_Editor::Target", nil)}, Color(255, 0, 0), 1, 1, 1, true, true)
end)