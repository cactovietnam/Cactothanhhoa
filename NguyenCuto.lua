-- ================================================
--         NGUYEN CUTO - Catch a Monster Tool
--         Update: New Theme & Egg Timer (1-30s)
-- ================================================

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local placeId = game.PlaceId

-[span_0](start_span)- =================== CÀI ĐẶT[span_0](end_span) ===================
local MIN_PLAYERS     = 5
local DETECT_RADIUS   = 40
local CHECK_INTERVAL  = 5
local EGG_INTERVAL    = 15 -- Mặc định 15s, có thể chỉnh 1-30s qua UI
local AUTO_HOP        = false
local AUTO_EGG        = true
[span_1](start_span)local TARGET_EGG      = "Frostwyrm's Egg"[span_1](end_span)
local recentServers   = {}

-[span_2](start_span)- =================== LƯU VỊ TRÍ[span_2](end_span) ===================
local SAVE_FILE = "NguyenCutoPos.json"
local function savePos(pos)
    pcall(function()
        writefile(SAVE_FILE, HttpService:JSONEncode({x=pos.X.Offset, y=pos.Y.Offset}))
    end)
end

local function loadPos()
    local ok, c = pcall(function() return readfile(SAVE_FILE) end)
    if ok and c then
        local ok2, d = pcall(function() return HttpService:JSONDecode(c) end)
        if ok2 and d then return UDim2.new(0, d.x, 0, d.y) end
    end
    [span_3](start_span)return UDim2.new(0, 10, 0.5, -200)[span_3](end_span)
end

-[span_4](start_span)- =================== XÓA GUI CŨ[span_4](end_span) ===================
local oldGui = player.PlayerGui:FindFirstChild("NguyenCutoGui")
if oldGui then oldGui:Destroy() end
if not player.Character then player.CharacterAdded:Wait() end
task.wait(1)

-- =================== GUI CHÍNH ===================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NguyenCutoGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- NÚT KHOANH ĐỎ (CÔNG TẮC BẬT TẮT UI)
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "ToggleUI"
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Image = "rbxassetid://1777515689830" -- Ảnh công tắc khoanh đỏ
toggleBtn.BackgroundTransparency = 1
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

-- HIỆU ỨNG THU NHỎ NÚT KHOANH ĐỎ (ĐỂ KHÔNG MẤT ẢNH)
toggleBtn.MouseEnter:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.3), {Size = UDim2.new(0, 45, 0, 45)}):Play()
end)
toggleBtn.MouseLeave:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.3), {Size = UDim2.new(0, 30, 0, 30)}):Play()
end)

-- KHUNG KHOANH TRẮNG (UI CHỨC NĂNG)
local frame = Instance.new("ImageLabel")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 240, 0, 460)
frame.Position = loadPos()
frame.Image = "rbxassetid://32856190" -- Ảnh UI khoanh trắng
frame.ScaleType = Enum.ScaleType.Stretch
frame.Active = true
frame.Draggable = true -- Có thể kéo nhưng không mất ảnh của người
frame.Parent = screenGui

-- Ẩn hiện UI chính
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-[span_5](start_span)- =================== TITLE 7 MÀU[span_5](end_span) ===================
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 36)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "NGUYEN CUTO"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = frame

task.spawn(function()
    local colors = {
        Color3.fromRGB(255,0,0), Color3.fromRGB(255,165,0), Color3.fromRGB(255,255,0),
        Color3.fromRGB(0,255,0), Color3.fromRGB(0,150,255), Color3.fromRGB(200,0,200)
    }
    local idx = 1
    while task.wait(0.3) do
        titleLabel.TextColor3 = colors[idx]
        [span_6](start_span)idx = idx % #colors + 1[span_6](end_span)
    end
end)

-[span_7](start_span)- =================== CHỨC NĂNG[span_7](end_span) ===================
local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -20, 1, -50)
container.Position = UDim2.new(0, 10, 0, 40)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 2
container.Parent = frame

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)

-- 1. CHỌN THỜI GIAN CHECK TRỨNG (1-30 GIÂY)
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0, 20)
timerLabel.Text = "⏱ Thời gian check trứng (1-30s):"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.BackgroundTransparency = 1
timerLabel.TextScaled = true
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Parent = container

local timerInput = Instance.new("TextBox")
timerInput.Size = UDim2.new(1, 0, 0, 30)
timerInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
timerInput.Text = tostring(EGG_INTERVAL)
timerInput.TextColor3 = Color3.fromRGB(0, 255, 0)
timerInput.Font = Enum.Font.Gotham
timerInput.Parent = container
Instance.new("UICorner", timerInput)

timerInput.FocusLost:Connect(function()
    local val = tonumber(timerInput.Text)
    if val and val >= 1 and val <= 30 then
        EGG_INTERVAL = val
        print("✅ Đã cập nhật thời gian check: " .. val .. " giây")
    else
        timerInput.Text = tostring(EGG_INTERVAL)
    end
end)

-[span_8](start_span)- 2. AUTO EGG BUTTON[span_8](end_span)
local eggBtn = Instance.new("TextButton")
eggBtn.Size = UDim2.new(1, 0, 0, 35)
eggBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
eggBtn.Text = "🥚 Auto Egg: BẬT"
eggBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
eggBtn.Font = Enum.Font.GothamBold
eggBtn.Parent = container
Instance.new("UICorner", eggBtn)

eggBtn.MouseButton1Click:Connect(function()
    AUTO_EGG = not AUTO_EGG
    eggBtn.Text = AUTO_EGG and "🥚 Auto Egg: BẬT" or "🥚 Auto Egg: TẮT"
    eggBtn.BackgroundColor3 = AUTO_EGG and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(80, 80, 80)
end)

-[span_9](start_span)[span_10](start_span)- =================== LOGIC AUTO EGG[span_9](end_span)[span_10](end_span) ===================
local function setupEgg()
    local ok1, EggSys = pcall(function() return require(RS.CommonLogic.Egg.EggSystem) end)
    local ok2, EggSel = pcall(function() return require(RS.ClientLogic.Egg.EggSelectView) end)
    local ok3, IBag   = pcall(function() return require(RS.ClientLogic.Item.ItemBagView) end)
    local ok4, CfgEgg = pcall(function() return require(RS:FindFirstChild("CfgEgg", true)) end)
    local ok5, VUtil  = pcall(function() return require(RS:FindFirstChild("ViewUtil", true)) end)
    if ok1 and ok2 and ok3 and ok4 and ok5 then return EggSys, EggSel, IBag, CfgEgg, VUtil end
    return nil
end

local function runEgg()
    local EggSys, EggSel, IBag, CfgEgg, VUtil = setupEgg()
    if not EggSys then return end
    local gp = EggSel._GamePlayer
    if not gp then return end

    for slot = 1, 5 do
        pcall(function()
            if not gp.egg:IsHatchUnlocked(slot) then return end
            local eggId = gp.egg:GetHatchEggTmplId(slot)
            if eggId then
                [span_11](start_span)local startTick = gp.egg:GetHatchEggStartTick(slot) or 0[span_11](end_span)
                local hatchTime = CfgEgg.Tmpls[eggId].HatchTime
                local timeLeft = startTick + hatchTime - os.time()
                if timeLeft <= 0 then
                    [span_12](start_span)VUtil.DoRequest(EggSys.ClientHatchTaken, slot)[span_12](end_span)
                    task.wait(0.5)
                end
            end
        end)
    end
end

-- VÒNG LẶP CHECK TRỨNG THEO THỜI GIAN ĐÃ CHỌN
task.spawn(function()
    while true do
        task.wait(EGG_INTERVAL) -- Sử dụng thời gian từ UI
        if AUTO_EGG then
            pcall(runEgg)
        end
    end
end)

-- TỰ ĐỘNG LƯU VỊ TRÍ KHI KÉO
frame:GetPropertyChangedSignal("Position"):Connect(function()
    savePos(frame.Position)
end)

print("✅ NGUYEN CUTO v2.0 ĐÃ SẴN SÀNG!")
