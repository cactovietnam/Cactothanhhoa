-- ================================================
--      NGUYEN CUTO v5.0 - Catch a Monster Tool
-- ================================================

local TeleportService = game:GetService("TeleportService")
local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")
local RS              = game:GetService("ReplicatedStorage")
local UIS             = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local Lighting        = game:GetService("Lighting")

local player  = Players.LocalPlayer
local placeId = game.PlaceId

-- =================== LƯU SETTING ===================
local SAVE_FILE = "NguyenCutoV5.json"
local defaults  = {
    x=220, y=120,
    autoHop=false, autoEgg=true,
    targetEgg="Frostwyrm's Egg",
    checkInterval=5, eggInterval=15,
    fixLag=false,
}
local function loadCfg()
    local ok, c = pcall(readfile, SAVE_FILE)
    if ok and c and c ~= "" then
        local ok2, d = pcall(function() return HttpService:JSONDecode(c) end)
        if ok2 and d then
            for k,v in pairs(defaults) do if d[k]==nil then d[k]=v end end
            return d
        end
    end
    return defaults
end
local function saveCfg(s) pcall(writefile, SAVE_FILE, HttpService:JSONEncode(s)) end
local cfg = loadCfg()

-- =================== STATE ===================
local MIN_PLAYERS   = 5
local DETECT_RADIUS = 40
local AUTO_HOP      = cfg.autoHop
local AUTO_EGG      = cfg.autoEgg
local TARGET_EGG    = cfg.targetEgg
local CHECK_INT     = cfg.checkInterval
local EGG_INT       = cfg.eggInterval
local FIX_LAG       = cfg.fixLag
local recentServers = {}

-- =================== FIX LAG ===================
local function applyFixLag()
    -- Xóa texture, decal, particle, shadow
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj:Destroy()
            elseif obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Material   = Enum.Material.SmoothPlastic
            elseif obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            end
        end)
    end

    -- Tắt lighting effects
    for _, e in ipairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BloomEffect") or e:IsA("BlurEffect") or
               e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or
               e:IsA("DepthOfFieldEffect") then
                e:Destroy()
            end
        end)
    end

    -- Xóa Sky & Atmosphere
    pcall(function()
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
        local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmo then atmo:Destroy() end
    end)

    -- Tắt shadow toàn cục
    Lighting.GlobalShadows = false
    Lighting.FogEnd        = 100000
    Lighting.Brightness    = 1

    -- Giảm quality rendering
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    -- Auto xóa object mới
    workspace.DescendantAdded:Connect(function(obj)
        pcall(function()
            if obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj:Destroy()
            elseif obj:IsA("BasePart") then obj.CastShadow = false end
        end)
    end)

    print("✅ Fix Lag đã áp dụng!")
end

local function removeFixLag()
    -- Khôi phục shadow
    Lighting.GlobalShadows = true
    print("⚠️ Fix Lag đã tắt - cần rejoin để khôi phục hoàn toàn!")
end

-- =================== CLEAR OLD GUI ===================
local old = player.PlayerGui:FindFirstChild("NCGui")
if old then old:Destroy() end
if not player.Character then player.CharacterAdded:Wait() end
task.wait(1)

-- =================== SCREEN GUI ===================
local sg = Instance.new("ScreenGui")
sg.Name           = "NCGui"
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = player.PlayerGui

-- =================== NÚT MỞ UI ===================
local toggleFrame = Instance.new("Frame", sg)
toggleFrame.Size             = UDim2.new(0, 58, 0, 58)
toggleFrame.Position         = UDim2.new(0, 8, 0.5, -29)
toggleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
toggleFrame.BorderSizePixel  = 0
toggleFrame.ZIndex           = 20
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0.5, 0)
local tfs = Instance.new("UIStroke", toggleFrame)
tfs.Color = Color3.fromRGB(80, 80, 100); tfs.Thickness = 1.5

local toggleBtn = Instance.new("ImageButton", toggleFrame)
toggleBtn.Size                   = UDim2.new(0.88, 0, 0.88, 0)
toggleBtn.Position               = UDim2.new(0.06, 0, 0.06, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Image                  = "rbxassetid://132832532598279"
toggleBtn.ScaleType              = Enum.ScaleType.Fit
toggleBtn.ZIndex                 = 21
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0.5, 0)

-- =================== MAIN WINDOW ===================
local WIN_W, WIN_H = 560, 400

local win = Instance.new("Frame", sg)
win.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
win.Position         = UDim2.new(0, cfg.x, 0, cfg.y)
win.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
win.BorderSizePixel  = 0
win.ZIndex           = 5
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)
local winStroke = Instance.new("UIStroke", win)
winStroke.Color = Color3.fromRGB(45, 45, 65); winStroke.Thickness = 1.5

-- =================== TOPBAR ===================
local topbar = Instance.new("Frame", win)
topbar.Size             = UDim2.new(1, 0, 0, 46)
topbar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
topbar.BorderSizePixel  = 0
topbar.ZIndex           = 6
Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 12)
local tbFix = Instance.new("Frame", topbar)
tbFix.Size=UDim2.new(1,0,0,12); tbFix.Position=UDim2.new(0,0,1,-12)
tbFix.BackgroundColor3=Color3.fromRGB(15,15,22); tbFix.BorderSizePixel=0; tbFix.ZIndex=6

-- Accent bar
local accent = Instance.new("Frame", topbar)
accent.Size             = UDim2.new(0, 3, 0.7, 0)
accent.Position         = UDim2.new(0, 10, 0.15, 0)
accent.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
accent.BorderSizePixel  = 0
accent.ZIndex           = 7
Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

-- Title (7 màu)
local titleLbl = Instance.new("TextLabel", topbar)
titleLbl.Size             = UDim2.new(0.6, 0, 0, 22)
titleLbl.Position         = UDim2.new(0, 20, 0, 6)
titleLbl.BackgroundTransparency = 1
titleLbl.Text             = "NGUYEN CUTO"
titleLbl.TextColor3       = Color3.fromRGB(255, 255, 255)
titleLbl.TextScaled       = true
titleLbl.Font             = Enum.Font.GothamBold
titleLbl.TextXAlignment   = Enum.TextXAlignment.Left
titleLbl.ZIndex           = 7

local rainbow = {
    Color3.fromRGB(255,80,80),  Color3.fromRGB(255,160,0),
    Color3.fromRGB(255,255,60), Color3.fromRGB(60,255,100),
    Color3.fromRGB(60,180,255), Color3.fromRGB(150,60,255),
    Color3.fromRGB(255,60,200),
}
local ci = 1
task.spawn(function()
    while task.wait(0.22) do
        if titleLbl and titleLbl.Parent then
            titleLbl.TextColor3 = rainbow[ci]
            ci = ci % #rainbow + 1
        end
    end
end)

local subLbl = Instance.new("TextLabel", topbar)
subLbl.Size             = UDim2.new(0.6, 0, 0, 14)
subLbl.Position         = UDim2.new(0, 20, 0, 28)
subLbl.BackgroundTransparency = 1
subLbl.Text             = "Catch a Monster  •  v5.0"
subLbl.TextColor3       = Color3.fromRGB(80, 80, 110)
subLbl.TextScaled       = true
subLbl.Font             = Enum.Font.Gotham
subLbl.TextXAlignment   = Enum.TextXAlignment.Left
subLbl.ZIndex           = 7

-- Close btn
local closeBtn = Instance.new("TextButton", topbar)
closeBtn.Size             = UDim2.new(0, 28, 0, 28)
closeBtn.Position         = UDim2.new(1, -38, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
closeBtn.Text             = "✕"
closeBtn.TextScaled       = true
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.BorderSizePixel  = 0
closeBtn.ZIndex           = 7
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() win.Visible = false end)

-- Topbar divider
local topDiv = Instance.new("Frame", win)
topDiv.Size=UDim2.new(1,0,0,1); topDiv.Position=UDim2.new(0,0,0,46)
topDiv.BackgroundColor3=Color3.fromRGB(35,35,55); topDiv.BorderSizePixel=0; topDiv.ZIndex=6

-- =================== SIDEBAR ===================
local sidebar = Instance.new("Frame", win)
sidebar.Size             = UDim2.new(0, 120, 1, -48)
sidebar.Position         = UDim2.new(0, 0, 0, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
sidebar.BorderSizePixel  = 0
sidebar.ZIndex           = 6
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)
-- Che góc phải trên để vuông
local sbRFix = Instance.new("Frame", sidebar)
sbRFix.Size=UDim2.new(0,12,0.5,0); sbRFix.Position=UDim2.new(1,-12,0,0)
sbRFix.BackgroundColor3=Color3.fromRGB(13,13,20); sbRFix.BorderSizePixel=0; sbRFix.ZIndex=7

local sbLayout = Instance.new("UIListLayout", sidebar)
sbLayout.Padding           = UDim.new(0,4)
sbLayout.SortOrder         = Enum.SortOrder.LayoutOrder
sbLayout.FillDirection     = Enum.FillDirection.Vertical
sbLayout.HorizontalAlignment= Enum.HorizontalAlignment.Center
sbLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local sbPad = Instance.new("UIPadding", sidebar)
sbPad.PaddingTop    = UDim.new(0,10)
sbPad.PaddingLeft   = UDim.new(0,6)
sbPad.PaddingRight  = UDim.new(0,6)
sbPad.PaddingBottom = UDim.new(0,6)

local sbDiv = Instance.new("Frame", win)
sbDiv.Size=UDim2.new(0,1,1,-48); sbDiv.Position=UDim2.new(0,120,0,48)
sbDiv.BackgroundColor3=Color3.fromRGB(35,35,55); sbDiv.BorderSizePixel=0; sbDiv.ZIndex=6

-- =================== CONTENT AREA ===================
local content = Instance.new("Frame", win)
content.Size             = UDim2.new(1,-121,1,-48)
content.Position         = UDim2.new(0,121,0,48)
content.BackgroundTransparency = 1
content.ClipsDescendants = true
content.ZIndex           = 6

-- =================== PAGE SYSTEM ===================
local pages      = {}
local currentSbBtn = nil

local function showPage(name)
    for n, p in pairs(pages) do
        p.Visible = (n == name)
    end
end

local function createPage(name)
    local scroll = Instance.new("ScrollingFrame", content)
    scroll.Size                  = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency= 1
    scroll.BorderSizePixel       = 0
    scroll.ScrollBarThickness    = 3
    scroll.ScrollBarImageColor3  = Color3.fromRGB(70,70,100)
    scroll.Visible               = false
    scroll.ZIndex                = 7
    local lay = Instance.new("UIListLayout", scroll)
    lay.Padding=UDim.new(0,6); lay.SortOrder=Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12)
    pad.PaddingTop=UDim.new(0,10); pad.PaddingBottom=UDim.new(0,10)
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+20)
    end)
    pages[name] = scroll
    return scroll
end

local orders = {}
local function no(name)
    orders[name] = (orders[name] or 0) + 1
    return orders[name]
end

-- =================== SIDEBAR BUTTON ===================
local function makeSideBtn(label, icon, pageName)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size             = UDim2.new(1, 0, 0, 70)
    btn.BackgroundColor3 = Color3.fromRGB(20,20,30)
    btn.TextColor3       = Color3.fromRGB(160,160,185)
    btn.Text             = icon.."\n"..label
    btn.TextScaled       = true
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 7
    btn.AutomaticSize    = Enum.AutomaticSize.None
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        showPage(pageName)
        if currentSbBtn then
            currentSbBtn.BackgroundColor3 = Color3.fromRGB(20,20,30)
            currentSbBtn.TextColor3       = Color3.fromRGB(160,160,185)
        end
        currentSbBtn             = btn
        btn.BackgroundColor3     = Color3.fromRGB(130,80,255)
        btn.TextColor3           = Color3.fromRGB(255,255,255)
    end)
    return btn
end

-- =================== CONTENT HELPERS ===================
local function makeSection(pg, text, color)
    local l = Instance.new("TextLabel", pages[pg])
    l.Size=UDim2.new(1,0,0,22); l.BackgroundTransparency=1
    l.Text=text; l.TextColor3=color or Color3.fromRGB(130,80,255)
    l.TextScaled=true; l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.ZIndex=8; l.LayoutOrder=no(pg)
end

local function makeStatus(pg, text)
    local l = Instance.new("TextLabel", pages[pg])
    l.Size=UDim2.new(1,0,0,17); l.BackgroundTransparency=1
    l.Text=text; l.TextColor3=Color3.fromRGB(150,150,175)
    l.TextScaled=true; l.Font=Enum.Font.Gotham
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.ZIndex=8; l.LayoutOrder=no(pg)
    return l
end

local function makeDivider(pg)
    local d=Instance.new("Frame", pages[pg])
    d.Size=UDim2.new(1,0,0,1); d.BackgroundColor3=Color3.fromRGB(35,35,55)
    d.BorderSizePixel=0; d.ZIndex=8; d.LayoutOrder=no(pg)
end

-- Row base
local function makeRow(pg, h)
    local r = Instance.new("Frame", pages[pg])
    r.Size             = UDim2.new(1,0,0,h or 56)
    r.BackgroundColor3 = Color3.fromRGB(17,17,25)
    r.BorderSizePixel  = 0
    r.ZIndex           = 8
    r.LayoutOrder      = no(pg)
    Instance.new("UICorner", r).CornerRadius = UDim.new(0,8)
    local s=Instance.new("UIStroke",r); s.Color=Color3.fromRGB(38,38,58); s.Thickness=1
    return r
end

local function rowLabels(row, label, desc)
    local l=Instance.new("TextLabel", row)
    l.Size=UDim2.new(0.55,0,0,22); l.Position=UDim2.new(0,12,0,8)
    l.BackgroundTransparency=1; l.Text=label
    l.TextColor3=Color3.fromRGB(235,235,255); l.TextScaled=true
    l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=9
    if desc then
        local d=Instance.new("TextLabel", row)
        d.Size=UDim2.new(0.55,0,0,16); d.Position=UDim2.new(0,12,0,32)
        d.BackgroundTransparency=1; d.Text=desc
        d.TextColor3=Color3.fromRGB(100,100,130); d.TextScaled=true
        d.Font=Enum.Font.Gotham; d.TextXAlignment=Enum.TextXAlignment.Left; d.ZIndex=9
    end
end

-- Toggle switch
local function makeToggle(pg, label, desc, init, onColor, cb)
    local row = makeRow(pg)
    rowLabels(row, label, desc)

    local bg = Instance.new("Frame", row)
    bg.Size=UDim2.new(0,44,0,24); bg.Position=UDim2.new(1,-56,0.5,-12)
    bg.BackgroundColor3=init and onColor or Color3.fromRGB(45,45,60)
    bg.BorderSizePixel=0; bg.ZIndex=9
    Instance.new("UICorner", bg).CornerRadius=UDim.new(0.5,0)

    local knob = Instance.new("Frame", bg)
    knob.Size=UDim2.new(0,18,0,18)
    knob.Position=init and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    knob.BorderSizePixel=0; knob.ZIndex=10
    Instance.new("UICorner", knob).CornerRadius=UDim.new(0.5,0)

    local state = init
    local function toggle()
        state = not state
        TweenService:Create(bg,TweenInfo.new(0.18),{BackgroundColor3=state and onColor or Color3.fromRGB(45,45,60)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.18),{Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play()
        if cb then cb(state) end
    end
    row.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then toggle() end
    end)
    return row
end

-- Action button
local function makeActionBtn(pg, label, desc, color, cb)
    local row = makeRow(pg)
    rowLabels(row, label, desc)
    local btn = Instance.new("TextButton", row)
    btn.Size=UDim2.new(0,68,0,30); btn.Position=UDim2.new(1,-78,0.5,-15)
    btn.BackgroundColor3=color or Color3.fromRGB(130,80,255)
    btn.TextColor3=Color3.fromRGB(255,255,255); btn.Text="▶"
    btn.TextScaled=true; btn.Font=Enum.Font.GothamBold
    btn.BorderSizePixel=0; btn.ZIndex=9
    Instance.new("UICorner", btn).CornerRadius=UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
        task.wait(0.08)
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=color or Color3.fromRGB(130,80,255)}):Play()
        if cb then cb() end
    end)
    return row, btn
end

-- Input number
local function makeInput(pg, label, desc, init, minV, maxV, cb)
    local row = makeRow(pg)
    rowLabels(row, label, desc)
    local box = Instance.new("TextBox", row)
    box.Size=UDim2.new(0,68,0,30); box.Position=UDim2.new(1,-78,0.5,-15)
    box.BackgroundColor3=Color3.fromRGB(22,22,34)
    box.TextColor3=Color3.fromRGB(255,215,80); box.Text=tostring(init)
    box.TextScaled=true; box.Font=Enum.Font.GothamBold
    box.ClearTextOnFocus=false; box.BorderSizePixel=0; box.ZIndex=9
    Instance.new("UICorner", box).CornerRadius=UDim.new(0,6)
    local bs=Instance.new("UIStroke",box); bs.Color=Color3.fromRGB(80,80,120)
    box.FocusLost:Connect(function()
        local v=tonumber(box.Text)
        if v and v>=minV and v<=maxV then if cb then cb(v) end
        else box.Text=tostring(init) end
        init=tonumber(box.Text) or init
    end)
    return box
end

-- Text input
local function makeTextInput(pg, label, desc, init, cb)
    local row = makeRow(pg, 60)
    rowLabels(row, label, desc)
    local box = Instance.new("TextBox", row)
    box.Size=UDim2.new(0.46,0,0,30); box.Position=UDim2.new(0.52,0,0.5,-15)
    box.BackgroundColor3=Color3.fromRGB(22,22,34)
    box.TextColor3=Color3.fromRGB(255,215,80); box.Text=tostring(init)
    box.TextScaled=true; box.Font=Enum.Font.GothamBold
    box.ClearTextOnFocus=false; box.BorderSizePixel=0; box.ZIndex=9
    Instance.new("UICorner", box).CornerRadius=UDim.new(0,6)
    local bs=Instance.new("UIStroke",box); bs.Color=Color3.fromRGB(180,130,0)
    box.FocusLost:Connect(function()
        if cb then cb(box.Text) end
    end)
    return box
end

-- Egg list picker
local function makeEggPicker(pg, initVal, cb)
    local hdr=Instance.new("TextLabel", pages[pg])
    hdr.Size=UDim2.new(1,0,0,16); hdr.BackgroundTransparency=1
    hdr.Text="Chọn nhanh:"; hdr.TextColor3=Color3.fromRGB(90,90,120)
    hdr.TextScaled=true; hdr.Font=Enum.Font.Gotham
    hdr.TextXAlignment=Enum.TextXAlignment.Left; hdr.ZIndex=8; hdr.LayoutOrder=no(pg)

    local eggNames = {
        "Blossom Egg","Rosette Egg","Gildron's Egg","Coral Egg",
        "TideVex's Egg","Giant Tree Egg","Frostwyrm's Egg",
        "Thunderclaw's Egg","GrassEgg","SwampEgg",
    }

    local sf=Instance.new("ScrollingFrame", pages[pg])
    sf.Size=UDim2.new(1,0,0,90); sf.BackgroundColor3=Color3.fromRGB(13,13,20)
    sf.BorderSizePixel=0; sf.ScrollBarThickness=3
    sf.ScrollBarImageColor3=Color3.fromRGB(70,70,100)
    sf.CanvasSize=UDim2.new(0,0,0,#eggNames*28); sf.ZIndex=8; sf.LayoutOrder=no(pg)
    Instance.new("UICorner",sf).CornerRadius=UDim.new(0,8)
    local ss=Instance.new("UIStroke",sf); ss.Color=Color3.fromRGB(38,38,58); ss.Thickness=1
    local sl=Instance.new("UIListLayout",sf); sl.Padding=UDim.new(0,2)
    local sp=Instance.new("UIPadding",sf); sp.PaddingLeft=UDim.new(0,5); sp.PaddingRight=UDim.new(0,5); sp.PaddingTop=UDim.new(0,4)

    local selB = nil
    for _,name in ipairs(eggNames) do
        local isSel = string.lower(name)==string.lower(initVal)
        local btn=Instance.new("TextButton",sf)
        btn.Size=UDim2.new(1,0,0,24)
        btn.BackgroundColor3=isSel and Color3.fromRGB(130,80,255) or Color3.fromRGB(20,20,30)
        btn.TextColor3=isSel and Color3.fromRGB(255,255,255) or Color3.fromRGB(185,185,205)
        btn.Text=(isSel and "✓  " or "    ")..name
        btn.TextScaled=true; btn.Font=Enum.Font.Gotham
        btn.BorderSizePixel=0; btn.TextXAlignment=Enum.TextXAlignment.Left; btn.ZIndex=9
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,5)
        if isSel then selB=btn end
        btn.MouseButton1Click:Connect(function()
            if selB then
                selB.BackgroundColor3=Color3.fromRGB(20,20,30)
                selB.TextColor3=Color3.fromRGB(185,185,205)
                selB.Text="    "..selB.Text:gsub("^✓  ","")
            end
            selB=btn
            btn.BackgroundColor3=Color3.fromRGB(130,80,255)
            btn.TextColor3=Color3.fromRGB(255,255,255)
            btn.Text="✓  "..name
            if cb then cb(name) end
        end)
    end
end

-- =============================================
--   TẠO PAGES
-- =============================================
createPage("hop")
createPage("egg")
createPage("lag")

local sb1 = makeSideBtn("Hop Server","⚡","hop")
local sb2 = makeSideBtn("Auto Egg",  "🥚","egg")
local sb3 = makeSideBtn("Fix Lag",   "⚙️","lag")

-- =============================================
--   PAGE: HOP SERVER
-- =============================================
makeSection("hop","⚡  Hop Server",Color3.fromRGB(60,180,255))
local hopStatus = makeStatus("hop","⏸  Sẵn sàng...")
local monStatus = makeStatus("hop","🔍  Đang kiểm tra monster...")
makeDivider("hop")

makeToggle("hop","Auto Hop","Tự hop khi không có monster",
    AUTO_HOP, Color3.fromRGB(0,155,215), function(v)
        AUTO_HOP=v; cfg.autoHop=v; saveCfg(cfg)
    end
)

makeInput("hop","Check interval","Thời gian check (1-60s)",
    CHECK_INT,1,60,function(v)
        CHECK_INT=v; cfg.checkInterval=v; saveCfg(cfg)
    end
)

local _, hopBtnObj = makeActionBtn("hop","Hop Ngay","Tìm server ít người và hop",
    Color3.fromRGB(0,175,80), nil
)

-- =============================================
--   PAGE: AUTO EGG
-- =============================================
makeSection("egg","🥚  Auto Egg Hatch",Color3.fromRGB(255,175,0))
local eggStatus = makeStatus("egg","🥚  Chờ khởi động...")
makeDivider("egg")

makeToggle("egg","Auto Egg","Tự động ấp và lấy trứng",
    AUTO_EGG, Color3.fromRGB(200,100,0), function(v)
        AUTO_EGG=v; cfg.autoEgg=v; saveCfg(cfg)
    end
)

makeInput("egg","Egg check interval","Thời gian check trứng (1-30s)",
    EGG_INT,1,30,function(v)
        EGG_INT=v; cfg.eggInterval=v; saveCfg(cfg)
    end
)

local eggBox = makeTextInput("egg","Tên trứng","Gõ hoặc chọn nhanh bên dưới",
    TARGET_EGG, function(v)
        TARGET_EGG=v; cfg.targetEgg=v; saveCfg(cfg)
        eggStatus.Text="🥚  Target: "..v
    end
)

makeEggPicker("egg", TARGET_EGG, function(name)
    TARGET_EGG=name; eggBox.Text=name
    cfg.targetEgg=name; saveCfg(cfg)
    eggStatus.Text="🥚  Target: "..name
end)

-- =============================================
--   PAGE: FIX LAG
-- =============================================
makeSection("lag","⚙️  Fix Lag",Color3.fromRGB(200,80,80))
makeStatus("lag","Giảm lag tối đa bằng cách xóa texture,")
makeStatus("lag","particle, shadow, hiệu ứng lighting...")
makeDivider("lag")

makeToggle("lag","Fix Lag","Xóa texture, particle, shadow...",
    FIX_LAG, Color3.fromRGB(200,60,60), function(v)
        FIX_LAG=v; cfg.fixLag=v; saveCfg(cfg)
        if v then applyFixLag() else removeFixLag() end
    end
)

makeActionBtn("lag","Áp dụng ngay","Xóa ngay toàn bộ texture/hiệu ứng",
    Color3.fromRGB(180,50,50), function()
        applyFixLag()
    end
)

makeActionBtn("lag","Xóa Particle","Xóa toàn bộ hiệu ứng particle",
    Color3.fromRGB(160,80,0), function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                    obj:Destroy()
                end
            end)
        end
        print("✅ Đã xóa particle!")
    end
)

makeActionBtn("lag","Xóa Texture","Xóa toàn bộ texture/decal",
    Color3.fromRGB(100,60,160), function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy() end
            end)
        end
        print("✅ Đã xóa texture!")
    end
)

makeActionBtn("lag","Tắt Shadow","Tắt shadow toàn bộ map",
    Color3.fromRGB(50,100,180), function()
        Lighting.GlobalShadows=false
        for _,obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") then obj.CastShadow=false end
            end)
        end
        print("✅ Đã tắt shadow!")
    end
)

-- =================== TOGGLE WINDOW ===================
toggleBtn.MouseButton1Click:Connect(function()
    win.Visible = not win.Visible
end)

-- Show page mặc định
showPage("hop")
currentSbBtn = sb1
sb1.BackgroundColor3 = Color3.fromRGB(130,80,255)
sb1.TextColor3       = Color3.fromRGB(255,255,255)

-- =================== DRAG WINDOW ===================
local dragging, dStart, dPos = false, nil, nil
local function clamp(x,y)
    local sw=workspace.CurrentCamera.ViewportSize.X
    local sh=workspace.CurrentCamera.ViewportSize.Y
    return math.clamp(x,0,sw-WIN_W), math.clamp(y,0,sh-WIN_H)
end

topbar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dStart=i.Position; dPos=win.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if not dragging then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        local d=i.Position-dStart
        local nx,ny=clamp(dPos.X.Offset+d.X, dPos.Y.Offset+d.Y)
        win.Position=UDim2.new(0,nx,0,ny)
    end
end)
UIS.InputEnded:Connect(function(i)
    if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and dragging then
        dragging=false
        cfg.x=win.Position.X.Offset; cfg.y=win.Position.Y.Offset; saveCfg(cfg)
    end
end)

-- =================== LOGIC HOP ===================
local function isRecentSvr(id)
    for _,v in ipairs(recentServers) do if v==id then return true end end
    return false
end
local function addRecentSvr(id)
    table.insert(recentServers,1,id)
    if #recentServers>3 then table.remove(recentServers) end
end
local function getServers()
    local ok,r=pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")
    end)
    if ok then return HttpService:JSONDecode(r) end
    return nil
end

local function hasMonsterNearby()
    local char=player.Character
    if not char then return false end
    local root=char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    for _,folder in ipairs({
        workspace:FindFirstChild("Monsters"),
        workspace:FindFirstChild("ClientMonsters"),
        workspace:FindFirstChild("Pets"),
        workspace:FindFirstChild("ClientPets"),
    }) do
        if folder then
            for _,obj in ipairs(folder:GetDescendants()) do
                if obj:IsA("Model") then
                    local nm=string.find(obj.Name,"Monster_")~=nil
                    local hm=obj:FindFirstChildOfClass("Humanoid")~=nil
                    if nm or hm then
                        local r=obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Root") or obj.PrimaryPart
                        if r then
                            if (root.Position-r.Position).Magnitude<=DETECT_RADIUS then return true end
                        else
                            for _,p in ipairs(obj:GetChildren()) do
                                if p:IsA("BasePart") then
                                    if (root.Position-p.Position).Magnitude<=DETECT_RADIUS then return true end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

local isHopping=false
local function hopServer()
    if isHopping then return end
    isHopping=true
    hopStatus.Text="⏳  Đang tìm server..."
    local data=getServers()
    if not data or not data.data then
        hopStatus.Text="❌  Lỗi lấy danh sách server!"
        isHopping=false; return
    end
    addRecentSvr(game.JobId)
    for _,sv in ipairs(data.data) do
        if sv.playing<MIN_PLAYERS and sv.id~=game.JobId and not isRecentSvr(sv.id) then
            hopStatus.Text="✅  Hop → "..sv.playing.." người"
            task.wait(1)
            TeleportService:TeleportToPlaceInstance(placeId,sv.id,player)
            return
        end
    end
    hopStatus.Text="⚠️  Không tìm thấy server phù hợp!"
    isHopping=false
end

hopBtnObj.MouseButton1Click:Connect(hopServer)

task.spawn(function()
    while task.wait(CHECK_INT) do
        if not AUTO_HOP or isHopping then continue end
        local nearby=hasMonsterNearby()
        if nearby then
            monStatus.Text="🐉  Có monster! Đang đánh..."
            monStatus.TextColor3=Color3.fromRGB(255,100,100)
        else
            monStatus.Text="😴  Không có monster → Hop!"
            monStatus.TextColor3=Color3.fromRGB(255,200,0)
            hopStatus.Text="🔄  Auto hop đang xử lý..."
            task.wait(2); hopServer()
        end
    end
end)

-- =================== LOGIC EGG ===================
local function setupEgg()
    local ok1,ES=pcall(function() return require(RS.CommonLogic.Egg.EggSystem) end)
    local ok2,EV=pcall(function() return require(RS.ClientLogic.Egg.EggSelectView) end)
    local ok3,IB=pcall(function() return require(RS.ClientLogic.Item.ItemBagView) end)
    local ok4,CE=pcall(function() return require(RS:FindFirstChild("CfgEgg",true)) end)
    local ok5,VU=pcall(function() return require(RS:FindFirstChild("ViewUtil",true)) end)
    if ok1 and ok2 and ok3 and ok4 and ok5 then return ES,EV,IB,CE,VU end
    return nil
end

local function getTargetId(gp,IB,CE)
    local list=IB._getSortedEggTmplIdList(gp)
    if #list==0 then return nil end
    if TARGET_EGG and TARGET_EGG~="" then
        for _,id in ipairs(list) do
            local c=CE.Tmpls[id]
            if c and string.find(string.lower(c.Name or ""),string.lower(TARGET_EGG)) then return id end
        end
        return nil
    end
    return list[1]
end

local function runEgg()
    local ES,EV,IB,CE,VU=setupEgg()
    if not ES then eggStatus.Text="❌  Lỗi EggSystem!"; return end
    local gp=EV._GamePlayer
    if not gp then eggStatus.Text="❌  Lỗi GamePlayer!"; return end
    for slot=1,5 do
        pcall(function()
            if not gp.egg:IsHatchUnlocked(slot) then return end
            local eggId=gp.egg:GetHatchEggTmplId(slot)
            if eggId then
                local st=gp.egg:GetHatchEggStartTick(slot) or 0
                local tl=st+CE.Tmpls[eggId].HatchTime-os.time()
                if tl<=0 then
                    eggStatus.Text="🐣  Slot "..slot.." nở! Lấy..."
                    VU.DoRequest(ES.ClientHatchTaken,slot)
                    task.wait(0.5)
                    local nid=getTargetId(gp,IB,CE)
                    if nid then
                        eggStatus.Text="🥚  Đặt ["..CE.Tmpls[nid].Name.."] → slot "..slot
                        VU.DoRequest(ES.ClientHatchStart,slot,nid)
                    end
                else
                    eggStatus.Text="⏳  Slot "..slot.." còn "..math.floor(tl).."s"
                end
            else
                local nid=getTargetId(gp,IB,CE)
                if nid then
                    eggStatus.Text="🥚  Đặt ["..CE.Tmpls[nid].Name.."] → slot "..slot
                    VU.DoRequest(ES.ClientHatchStart,slot,nid)
                else
                    eggStatus.Text="❌  Không tìm thấy: "..TARGET_EGG
                end
            end
        end)
        task.wait(0.3)
    end
end

task.spawn(function()
    task.wait(3)
    -- Auto apply fix lag nếu đã bật
    if FIX_LAG then applyFixLag() end
    while task.wait(EGG_INT) do
        if AUTO_EGG then pcall(runEgg) end
    end
end)

print("✅ NGUYEN CUTO v5.0 - Sẵn sàng!")
