-- ================================================
--      NGUYEN CUTO v3.0 - Catch a Monster Tool
-- ================================================

local TeleportService = game:GetService("TeleportService")
local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")
local RS              = game:GetService("ReplicatedStorage")
local UIS             = game:GetService("UserInputService")

local player  = Players.LocalPlayer
local placeId = game.PlaceId

-- =================== LƯU SETTING ===================
local SAVE_FILE = "NguyenCutoSettings.json"

local defaultSettings = {
    x            = 100,
    y            = 200,
    autoHop      = false,
    autoEgg      = true,
    targetEgg    = "Frostwyrm's Egg",
    checkInterval= 5,
    eggInterval  = 15,
}

local function loadSettings()
    local ok, c = pcall(function() return readfile(SAVE_FILE) end)
    if ok and c and c ~= "" then
        local ok2, d = pcall(function() return HttpService:JSONDecode(c) end)
        if ok2 and d then
            for k, v in pairs(defaultSettings) do
                if d[k] == nil then d[k] = v end
            end
            return d
        end
    end
    return defaultSettings
end

local function saveSettings(s)
    pcall(function() writefile(SAVE_FILE, HttpService:JSONEncode(s)) end)
end

local cfg = loadSettings()

-- =================== BIẾN TRẠNG THÁI ===================
local MIN_PLAYERS   = 5
local DETECT_RADIUS = 40
local AUTO_HOP      = cfg.autoHop
local AUTO_EGG      = cfg.autoEgg
local TARGET_EGG    = cfg.targetEgg
local CHECK_INT     = cfg.checkInterval
local EGG_INT       = cfg.eggInterval
local recentServers = {}

-- =================== XÓA GUI CŨ ===================
local oldGui = player.PlayerGui:FindFirstChild("NguyenCutoGui")
if oldGui then oldGui:Destroy() end
if not player.Character then player.CharacterAdded:Wait() end
task.wait(1)

-- =================== SCREEN GUI ===================
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "NguyenCutoGui"
screenGui.ResetOnSpawn  = false
screenGui.ZIndexBehavior= Enum.ZIndexBehavior.Sibling
screenGui.Parent        = player.PlayerGui

-- =============================================
-- NÚT TOGGLE NHỎ (ảnh khoanh đỏ)
-- Cố định góc trái, KHÔNG kéo được
-- =============================================
local toggleFrame = Instance.new("Frame")
toggleFrame.Size              = UDim2.new(0, 56, 0, 56)
toggleFrame.Position          = UDim2.new(0, 8, 0.5, -28)
toggleFrame.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
toggleFrame.BackgroundTransparency = 0.3
toggleFrame.BorderSizePixel   = 0
toggleFrame.ZIndex            = 20
toggleFrame.Parent            = screenGui
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0.5, 0)
Instance.new("UIStroke", toggleFrame).Color = Color3.fromRGB(100, 100, 100)

local toggleImg = Instance.new("ImageButton")
toggleImg.Size                = UDim2.new(1, 0, 1, 0)
toggleImg.BackgroundTransparency = 1
toggleImg.Image               = "https://raw.githubusercontent.com/cactovietnam/Thame-b-t-t-c-UI/refs/heads/main/1777515689830.jpg"
toggleImg.ScaleType           = Enum.ScaleType.Fit
toggleImg.ZIndex              = 21
toggleImg.Parent              = toggleFrame
Instance.new("UICorner", toggleImg).CornerRadius = UDim.new(0.5, 0)

-- =============================================
-- MAIN FRAME (ảnh khoanh trắng) - KÉO ĐƯỢC
-- =============================================
local mainFrame = Instance.new("Frame")
mainFrame.Size              = UDim2.new(0, 300, 0, 520)
mainFrame.Position          = UDim2.new(0, cfg.x, 0, cfg.y)
mainFrame.BackgroundColor3  = Color3.fromRGB(5, 5, 10)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel   = 0
mainFrame.ZIndex            = 5
mainFrame.Parent            = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(50, 50, 80)

-- Ảnh nền
local bgImg = Instance.new("ImageLabel")
bgImg.Size               = UDim2.new(1, 0, 1, 0)
bgImg.BackgroundTransparency = 1
bgImg.Image              = "https://raw.githubusercontent.com/cactovietnam/Thame-b-t-t-c-UI/refs/heads/main/32856190.avif"
bgImg.ScaleType          = Enum.ScaleType.Crop
bgImg.ImageTransparency  = 0.65
bgImg.ZIndex             = 5
bgImg.Parent             = mainFrame
Instance.new("UICorner", bgImg).CornerRadius = UDim.new(0, 14)

-- Overlay tối
local overlay = Instance.new("Frame")
overlay.Size              = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.45
overlay.BorderSizePixel   = 0
overlay.ZIndex            = 6
overlay.Parent            = mainFrame
Instance.new("UICorner", overlay).CornerRadius = UDim.new(0, 14)

-- =================== TITLE BAR (dùng để kéo) ===================
local titleBar = Instance.new("Frame")
titleBar.Size              = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundTransparency = 1
titleBar.ZIndex            = 7
titleBar.Parent            = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size             = UDim2.new(1, -10, 1, 0)
titleLabel.Position         = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text             = "✦  NGUYEN CUTO  ✦"
titleLabel.TextColor3       = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled       = true
titleLabel.Font             = Enum.Font.GothamBold
titleLabel.ZIndex           = 8
titleLabel.Parent           = titleBar

-- 7 màu cầu vồng
local rainbow = {
    Color3.fromRGB(255,80,80),   Color3.fromRGB(255,165,0),
    Color3.fromRGB(255,255,80),  Color3.fromRGB(80,255,80),
    Color3.fromRGB(80,180,255),  Color3.fromRGB(160,80,255),
    Color3.fromRGB(255,80,200),
}
local ci = 1
task.spawn(function()
    while task.wait(0.22) do
        if titleLabel and titleLabel.Parent then
            titleLabel.TextColor3 = rainbow[ci]
            ci = ci % #rainbow + 1
        end
    end
end)

-- Divider tiêu đề
local function makeDivLine(parent, yPos, zIdx)
    local d = Instance.new("Frame", parent)
    d.Size              = UDim2.new(1, -20, 0, 1)
    d.Position          = UDim2.new(0, 10, 0, yPos)
    d.BackgroundColor3  = Color3.fromRGB(60, 60, 90)
    d.BorderSizePixel   = 0
    d.ZIndex            = zIdx or 7
end
makeDivLine(mainFrame, 46)

-- =================== SCROLL CONTENT ===================
local scroll = Instance.new("ScrollingFrame")
scroll.Size                  = UDim2.new(1, 0, 1, -50)
scroll.Position              = UDim2.new(0, 0, 0, 50)
scroll.BackgroundTransparency= 1
scroll.BorderSizePixel       = 0
scroll.ScrollBarThickness    = 3
scroll.ScrollBarImageColor3  = Color3.fromRGB(80, 80, 120)
scroll.ZIndex                = 7
scroll.Parent                = mainFrame

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding    = UDim.new(0, 5)
listLayout.SortOrder  = Enum.SortOrder.LayoutOrder
local pad = Instance.new("UIPadding", scroll)
pad.PaddingLeft   = UDim.new(0, 10)
pad.PaddingRight  = UDim.new(0, 10)
pad.PaddingTop    = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
end)

-- =================== HELPER FUNCTIONS ===================
local orderCounter = 0
local function nextOrder()
    orderCounter = orderCounter + 1
    return orderCounter
end

local function makeSection(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text              = text
    lbl.TextColor3        = color or Color3.fromRGB(0, 200, 255)
    lbl.TextScaled        = true
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 8
    lbl.LayoutOrder       = nextOrder()
    lbl.Parent            = scroll
end

local function makeStatus(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, 0, 0, 17)
    lbl.BackgroundTransparency = 1
    lbl.Text              = text
    lbl.TextColor3        = Color3.fromRGB(170, 170, 170)
    lbl.TextScaled        = true
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 8
    lbl.LayoutOrder       = nextOrder()
    lbl.Parent            = scroll
    return lbl
end

local function makeDivider()
    local d = Instance.new("Frame")
    d.Size             = UDim2.new(1, 0, 0, 1)
    d.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
    d.BorderSizePixel  = 0
    d.ZIndex           = 8
    d.LayoutOrder      = nextOrder()
    d.Parent           = scroll
end

local function makeToggleBtn(labelText, initState, onColor, onToggle)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = initState and onColor or Color3.fromRGB(55, 55, 55)
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Text             = labelText .. (initState and ": BẬT ✓" or ": TẮT ✗")
    btn.TextScaled       = true
    btn.Font             = Enum.Font.GothamBold
    btn.ZIndex           = 8
    btn.LayoutOrder      = nextOrder()
    btn.Parent           = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(80, 80, 110)
    s.Thickness = 1

    local state = initState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = labelText .. (state and ": BẬT ✓" or ": TẮT ✗")
        btn.BackgroundColor3 = state and onColor or Color3.fromRGB(55, 55, 55)
        if onToggle then onToggle(state) end
    end)
    return btn
end

local function makeActionBtn(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = color
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Text             = text
    btn.TextScaled       = true
    btn.Font             = Enum.Font.GothamBold
    btn.ZIndex           = 8
    btn.LayoutOrder      = nextOrder()
    btn.Parent           = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

local function makeInputRow(labelTxt, initVal, minV, maxV, onChanged)
    local row = Instance.new("Frame")
    row.Size              = UDim2.new(1, 0, 0, 32)
    row.BackgroundTransparency = 1
    row.ZIndex            = 8
    row.LayoutOrder       = nextOrder()
    row.Parent            = scroll

    local lbl = Instance.new("TextLabel", row)
    lbl.Size              = UDim2.new(0.65, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = labelTxt
    lbl.TextColor3        = Color3.fromRGB(195, 195, 195)
    lbl.TextScaled        = true
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 8

    local box = Instance.new("TextBox", row)
    box.Size              = UDim2.new(0.33, 0, 0.85, 0)
    box.Position          = UDim2.new(0.66, 0, 0.075, 0)
    box.BackgroundColor3  = Color3.fromRGB(20, 20, 30)
    box.TextColor3        = Color3.fromRGB(255, 215, 80)
    box.Text              = tostring(initVal)
    box.TextScaled        = true
    box.Font              = Enum.Font.GothamBold
    box.ClearTextOnFocus  = false
    box.ZIndex            = 9
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", box)
    bs.Color = Color3.fromRGB(80, 80, 120)

    box.FocusLost:Connect(function()
        local v = tonumber(box.Text)
        if v and v >= minV and v <= maxV then
            if onChanged then onChanged(v) end
        else
            box.Text = tostring(initVal)
        end
        initVal = tonumber(box.Text) or initVal
    end)
    return box
end

-- =============================================
--        MỤC 1: HOP SERVER
-- =============================================
makeSection("⚡   HOP SERVER", Color3.fromRGB(0, 200, 255))
local hopStatus = makeStatus("⏸ Sẵn sàng hop...")
local monStatus = makeStatus("🔍 Đang kiểm tra monster...")

makeInputRow("⏱ Check interval (1-60s):", CHECK_INT, 1, 60, function(v)
    CHECK_INT = v
    cfg.checkInterval = v
    saveSettings(cfg)
end)

makeToggleBtn("🤖 Auto Hop", AUTO_HOP, Color3.fromRGB(0, 140, 200), function(v)
    AUTO_HOP = v
    cfg.autoHop = v
    saveSettings(cfg)
end)

local hopBtn = makeActionBtn("⚡ HOP NGAY", Color3.fromRGB(0, 175, 80), nil)

makeDivider()

-- =============================================
--        MỤC 2: AUTO EGG HATCH
-- =============================================
makeSection("🥚   AUTO EGG HATCH", Color3.fromRGB(255, 175, 0))
local eggStatus = makeStatus("🥚 Chờ khởi động...")

-- Input tên trứng
local eggRow = Instance.new("Frame")
eggRow.Size              = UDim2.new(1, 0, 0, 32)
eggRow.BackgroundTransparency = 1
eggRow.ZIndex            = 8
eggRow.LayoutOrder       = nextOrder()
eggRow.Parent            = scroll

local eggLbl = Instance.new("TextLabel", eggRow)
eggLbl.Size              = UDim2.new(0.4, 0, 1, 0)
eggLbl.BackgroundTransparency = 1
eggLbl.Text              = "Tên trứng:"
eggLbl.TextColor3        = Color3.fromRGB(195, 195, 195)
eggLbl.TextScaled        = true
eggLbl.Font              = Enum.Font.Gotham
eggLbl.TextXAlignment    = Enum.TextXAlignment.Left
eggLbl.ZIndex            = 8

local eggBox = Instance.new("TextBox", eggRow)
eggBox.Size              = UDim2.new(0.58, 0, 0.85, 0)
eggBox.Position          = UDim2.new(0.41, 0, 0.075, 0)
eggBox.BackgroundColor3  = Color3.fromRGB(20, 20, 30)
eggBox.TextColor3        = Color3.fromRGB(255, 215, 80)
eggBox.Text              = TARGET_EGG
eggBox.TextScaled        = true
eggBox.Font              = Enum.Font.GothamBold
eggBox.ClearTextOnFocus  = false
eggBox.ZIndex            = 9
Instance.new("UICorner", eggBox).CornerRadius = UDim.new(0, 6)
local ebs = Instance.new("UIStroke", eggBox)
ebs.Color = Color3.fromRGB(200, 140, 0)

eggBox.FocusLost:Connect(function()
    TARGET_EGG = eggBox.Text
    cfg.targetEgg = TARGET_EGG
    saveSettings(cfg)
    eggStatus.Text = "🥚 Target: "..TARGET_EGG
end)

-- Egg check interval (1-30)
makeInputRow("⏱ Egg check (1-30s):", EGG_INT, 1, 30, function(v)
    EGG_INT = v
    cfg.eggInterval = v
    saveSettings(cfg)
end)

-- Label chọn nhanh
local qLabel = Instance.new("TextLabel")
qLabel.Size              = UDim2.new(1, 0, 0, 17)
qLabel.BackgroundTransparency = 1
qLabel.Text              = "Chọn nhanh:"
qLabel.TextColor3        = Color3.fromRGB(130, 130, 160)
qLabel.TextScaled        = true
qLabel.Font              = Enum.Font.Gotham
qLabel.TextXAlignment    = Enum.TextXAlignment.Left
qLabel.ZIndex            = 8
qLabel.LayoutOrder       = nextOrder()
qLabel.Parent            = scroll

-- Danh sách trứng (từ ảnh bạn gửi)
local eggNames = {
    "Blossom Egg",      "Rosette Egg",
    "Gildron's Egg",    "Coral Egg",
    "TideVex's Egg",    "Giant Tree Egg",
    "Frostwyrm's Egg",  "Thunderclaw's Egg",
    "GrassEgg",         "SwampEgg",
}

local eggListFrame = Instance.new("ScrollingFrame")
eggListFrame.Size              = UDim2.new(1, 0, 0, 80)
eggListFrame.BackgroundColor3  = Color3.fromRGB(12, 12, 18)
eggListFrame.BackgroundTransparency = 0.2
eggListFrame.BorderSizePixel   = 0
eggListFrame.ScrollBarThickness= 3
eggListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
eggListFrame.CanvasSize        = UDim2.new(0, 0, 0, #eggNames * 26)
eggListFrame.ZIndex            = 8
eggListFrame.LayoutOrder       = nextOrder()
eggListFrame.Parent            = scroll
Instance.new("UICorner", eggListFrame).CornerRadius = UDim.new(0, 8)

local eggListLayout = Instance.new("UIListLayout", eggListFrame)
eggListLayout.Padding = UDim.new(0, 2)
local elPad = Instance.new("UIPadding", eggListFrame)
elPad.PaddingLeft   = UDim.new(0, 4)
elPad.PaddingRight  = UDim.new(0, 4)
elPad.PaddingTop    = UDim.new(0, 4)

local selectedEggBtn = nil
for _, name in ipairs(eggNames) do
    local isSelected = string.lower(name) == string.lower(TARGET_EGG)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 23)
    btn.BackgroundColor3 = isSelected and Color3.fromRGB(170, 100, 0) or Color3.fromRGB(25, 25, 38)
    btn.TextColor3       = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
    btn.Text             = name
    btn.TextScaled       = true
    btn.Font             = Enum.Font.Gotham
    btn.ZIndex           = 9
    btn.Parent           = eggListFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    if isSelected then selectedEggBtn = btn end

    btn.MouseButton1Click:Connect(function()
        if selectedEggBtn then
            selectedEggBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
            selectedEggBtn.TextColor3       = Color3.fromRGB(200, 200, 200)
        end
        selectedEggBtn              = btn
        btn.BackgroundColor3        = Color3.fromRGB(170, 100, 0)
        btn.TextColor3              = Color3.fromRGB(255, 255, 255)
        TARGET_EGG                  = name
        eggBox.Text                 = name
        cfg.targetEgg               = name
        saveSettings(cfg)
        eggStatus.Text              = "🥚 Target: "..name
    end)
end

makeToggleBtn("🥚 Auto Egg", AUTO_EGG, Color3.fromRGB(190, 95, 0), function(v)
    AUTO_EGG = v
    cfg.autoEgg = v
    saveSettings(cfg)
end)

makeDivider()

local verLbl = Instance.new("TextLabel")
verLbl.Size              = UDim2.new(1, 0, 0, 14)
verLbl.BackgroundTransparency = 1
verLbl.Text              = "v3.0  |  Catch a Monster  |  NGUYEN CUTO"
verLbl.TextColor3        = Color3.fromRGB(60, 60, 80)
verLbl.TextScaled        = true
verLbl.Font              = Enum.Font.Gotham
verLbl.ZIndex            = 8
verLbl.LayoutOrder       = nextOrder()
verLbl.Parent            = scroll

-- =================== TOGGLE BUTTON ===================
local uiVisible = true
toggleImg.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    mainFrame.Visible = uiVisible
end)

-- =================== DRAG MAIN FRAME ===================
-- Chỉ kéo qua titleBar, KHÔNG mất khỏi màn hình
local dragging, dStart, dPos = false, nil, nil

local function clampPos(x, y)
    local sw = workspace.CurrentCamera.ViewportSize.X
    local sh = workspace.CurrentCamera.ViewportSize.Y
    local fw = mainFrame.AbsoluteSize.X
    local fh = mainFrame.AbsoluteSize.Y
    x = math.clamp(x, 0, sw - fw)
    y = math.clamp(y, 0, sh - fh)
    return x, y
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dStart   = input.Position
        dPos     = mainFrame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local d  = input.Position - dStart
        local nx = dPos.X.Offset + d.X
        local ny = dPos.Y.Offset + d.Y
        nx, ny   = clampPos(nx, ny)
        mainFrame.Position = UDim2.new(0, nx, 0, ny)
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            dragging        = false
            cfg.x           = mainFrame.Position.X.Offset
            cfg.y           = mainFrame.Position.Y.Offset
            saveSettings(cfg)
        end
    end
end)

-- =================== LOGIC HOP ===================
local function isRecentSvr(id)
    for _, v in ipairs(recentServers) do if v == id then return true end end
    return false
end
local function addRecentSvr(id)
    table.insert(recentServers, 1, id)
    if #recentServers > 3 then table.remove(recentServers) end
end
local function getServers()
    local ok, r = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")
    end)
    if ok then return HttpService:JSONDecode(r) end
    return nil
end

local function hasMonsterNearby()
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    for _, folder in ipairs({
        workspace:FindFirstChild("Monsters"),
        workspace:FindFirstChild("ClientMonsters"),
        workspace:FindFirstChild("Pets"),
        workspace:FindFirstChild("ClientPets"),
    }) do
        if folder then
            for _, obj in ipairs(folder:GetDescendants()) do
                if obj:IsA("Model") then
                    local nm = string.find(obj.Name, "Monster_") ~= nil
                    local hm = obj:FindFirstChildOfClass("Humanoid") ~= nil
                    if nm or hm then
                        local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Root") or obj.PrimaryPart
                        if r then
                            if (root.Position - r.Position).Magnitude <= DETECT_RADIUS then return true end
                        else
                            for _, p in ipairs(obj:GetChildren()) do
                                if p:IsA("BasePart") then
                                    if (root.Position - p.Position).Magnitude <= DETECT_RADIUS then return true end
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

local isHopping = false
local function hopServer()
    if isHopping then return end
    isHopping = true
    hopBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    hopBtn.Text             = "⏳ Đang tìm..."
    local data = getServers()
    if not data or not data.data then
        hopStatus.Text          = "❌ Lỗi lấy danh sách server!"
        hopBtn.BackgroundColor3 = Color3.fromRGB(0, 175, 80)
        hopBtn.Text             = "⚡ HOP NGAY"
        isHopping               = false
        return
    end
    addRecentSvr(game.JobId)
    for _, sv in ipairs(data.data) do
        if sv.playing < MIN_PLAYERS and sv.id ~= game.JobId and not isRecentSvr(sv.id) then
            hopStatus.Text = "✅ Hop → "..sv.playing.." người"
            task.wait(1)
            TeleportService:TeleportToPlaceInstance(placeId, sv.id, player)
            return
        end
    end
    hopStatus.Text          = "⚠️ Không tìm thấy server phù hợp!"
    hopBtn.BackgroundColor3 = Color3.fromRGB(0, 175, 80)
    hopBtn.Text             = "⚡ HOP NGAY"
    isHopping               = false
end

hopBtn.MouseButton1Click:Connect(hopServer)

task.spawn(function()
    while task.wait(CHECK_INT) do
        if not AUTO_HOP or isHopping then continue end
        local nearby = hasMonsterNearby()
        if nearby then
            monStatus.Text      = "🐉 Có monster! Đang đánh..."
            monStatus.TextColor3= Color3.fromRGB(255, 100, 100)
        else
            monStatus.Text      = "😴 Không có monster → Hop!"
            monStatus.TextColor3= Color3.fromRGB(255, 200, 0)
            hopStatus.Text      = "🔄 Auto hop đang xử lý..."
            task.wait(2)
            hopServer()
        end
    end
end)

-- =================== LOGIC EGG ===================
local function setupEgg()
    local ok1, ES = pcall(function() return require(RS.CommonLogic.Egg.EggSystem) end)
    local ok2, EV = pcall(function() return require(RS.ClientLogic.Egg.EggSelectView) end)
    local ok3, IB = pcall(function() return require(RS.ClientLogic.Item.ItemBagView) end)
    local ok4, CE = pcall(function() return require(RS:FindFirstChild("CfgEgg", true)) end)
    local ok5, VU = pcall(function() return require(RS:FindFirstChild("ViewUtil", true)) end)
    if ok1 and ok2 and ok3 and ok4 and ok5 then return ES, EV, IB, CE, VU end
    return nil
end

local function getTargetId(gp, IB, CE)
    local list = IB._getSortedEggTmplIdList(gp)
    if #list == 0 then return nil end
    if TARGET_EGG and TARGET_EGG ~= "" then
        for _, id in ipairs(list) do
            local c = CE.Tmpls[id]
            if c and string.find(string.lower(c.Name or ""), string.lower(TARGET_EGG)) then
                return id
            end
        end
        return nil
    end
    return list[1]
end

local function runEgg()
    local ES, EV, IB, CE, VU = setupEgg()
    if not ES then eggStatus.Text = "❌ Lỗi EggSystem!"; return end
    local gp = EV._GamePlayer
    if not gp then eggStatus.Text = "❌ Lỗi GamePlayer!"; return end
    for slot = 1, 5 do
        pcall(function()
            if not gp.egg:IsHatchUnlocked(slot) then return end
            local eggId = gp.egg:GetHatchEggTmplId(slot)
            if eggId then
                local st  = gp.egg:GetHatchEggStartTick(slot) or 0
                local tl  = st + CE.Tmpls[eggId].HatchTime - os.time()
                if tl <= 0 then
                    eggStatus.Text = "🐣 Slot "..slot.." nở! Lấy..."
                    VU.DoRequest(ES.ClientHatchTaken, slot)
                    task.wait(0.5)
                    local nid = getTargetId(gp, IB, CE)
                    if nid then
                        eggStatus.Text = "🥚 Đặt ["..CE.Tmpls[nid].Name.."] → slot "..slot
                        VU.DoRequest(ES.ClientHatchStart, slot, nid)
                    end
                else
                    eggStatus.Text = "⏳ Slot "..slot.." còn "..math.floor(tl).."s"
                end
            else
                local nid = getTargetId(gp, IB, CE)
                if nid then
                    eggStatus.Text = "🥚 Đặt ["..CE.Tmpls[nid].Name.."] → slot "..slot
                    VU.DoRequest(ES.ClientHatchStart, slot, nid)
                else
                    eggStatus.Text = "❌ Không tìm thấy: "..TARGET_EGG
                end
            end
        end)
        task.wait(0.3)
    end
end

task.spawn(function()
    task.wait(3)
    while task.wait(EGG_INT) do
        if AUTO_EGG then pcall(runEgg) end
    end
end)

print("✅ NGUYEN CUTO v3.0 sẵn sàng! Setting đã load từ file.")
