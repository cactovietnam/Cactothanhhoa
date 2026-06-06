-- ============================================================
-- 🎮 NC_CutoHub.lua v5 — Cuto Hub | Catch A Monster
-- Cập nhật: Auto Equip Best Pet, Code mới, Auto Hatch cải tiến,
--           Auto Attack độc lập, Auto Hop Server theo thời gian,
--           Tự khôi phục sau Hop Server
-- ============================================================

local RS  = game:GetService("ReplicatedStorage")
local HS  = game:GetService("HttpService")
local TS  = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player  = game.Players.LocalPlayer
local placeId = game.PlaceId

-- ─── CONFIG ──────────────────────────────────────────────────
local DISCORD_WH   = "https://discord.com/api/webhooks/1414221632653758666/cS75tL5qKuCyM--U6N48ywXv9s3_BPwHHaovFy0WArVFTDgMyBcMykCP0haWr2ClwXsK"            -- Dán webhook Discord vào đây
local TARGET_EGG   = "Void Egg"    -- Tên trứng muốn ấp
local TARGET_LV    = 30
local EGG_CHECK    = 15
local HOP_MIN_SLOT = 2             -- Server phải còn ít nhất N chỗ trống
local HOP_MINUTES  = 36            -- Tự hop sau X phút

-- ─── STATE ───────────────────────────────────────────────────
local running      = true
local hatching     = true
local hop2         = false
local autoHop      = true          -- Auto Hop bật/tắt
local autoAttack   = true          -- Luôn bật, không bao giờ tắt
local recent       = {}
local startTick    = tick()

-- Tọa độ farm (người dùng chọn qua UI hoặc mặc định)
local FARM_POS = Vector3.new(2915.9, -79.8, 2018.5)

-- ─── DANH SÁCH CODE MỚI ──────────────────────────────────────
-- Chỉnh sửa danh sách này khi cần thêm/bớt code
local CODES = {
    "dueggy",
    "teravok",
    "moovik",
    "danvok",
    "coltasc",
    "Scareep",
    -- Thêm code mới vào đây
}

-- ─── GUI ─────────────────────────────────────────────────────
local screen = Instance.new("ScreenGui")
screen.Name          = "CutoHub"
screen.ResetOnSpawn  = false
screen.IgnoreGuiInset = true
screen.Parent        = player.PlayerGui

local infoFrame = Instance.new("Frame", screen)
infoFrame.Size                = UDim2.new(1, 0, 1, 0)
infoFrame.Position            = UDim2.new(0, 0, 0, 0)
infoFrame.BackgroundTransparency = 1
infoFrame.BorderSizePixel     = 0

-- Helper tạo label nhanh
local function mkLabel(parent, pos, size, color, textSize, bold, align)
    local l = Instance.new("TextLabel", parent)
    l.Size                  = size    or UDim2.new(0, 400, 0, 30)
    l.Position              = pos     or UDim2.new(0.5, -200, 0, 0)
    l.BackgroundTransparency = 1
    l.TextColor3            = color   or Color3.fromRGB(255, 255, 255)
    l.TextSize              = textSize or 20
    l.Font                  = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment        = align   or Enum.TextXAlignment.Center
    l.TextStrokeTransparency = 0
    l.TextStrokeColor3      = Color3.fromRGB(0, 0, 0)
    l.Text                  = ""
    return l
end

-- Các nhãn hiển thị
local titleLbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.12,0), UDim2.new(0,600,0,50),
    Color3.fromRGB(255,140,0), 40, true)

local lvLbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.12,55), UDim2.new(0,600,0,40),
    Color3.fromRGB(255,220,0), 30, true)

local timeLbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.12,100), UDim2.new(0,600,0,32),
    Color3.fromRGB(255,255,255), 22, false)

local statLbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.12,136), UDim2.new(0,600,0,30),
    Color3.fromRGB(100,220,255), 20, false)

local stat2Lbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.12,170), UDim2.new(0,600,0,30),
    Color3.fromRGB(100,255,150), 20, false)

local hopLbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.12,204), UDim2.new(0,600,0,30),
    Color3.fromRGB(255,180,80), 20, false)

-- Nhãn tọa độ góc trái
local posLbl = mkLabel(infoFrame,
    UDim2.new(0,8,0,8), UDim2.new(0,300,0,22),
    Color3.fromRGB(120,210,255), 14, false, Enum.TextXAlignment.Left)

titleLbl.Text = "CUTO HUB"

-- Cập nhật vị trí + thời gian liên tục
RunService.RenderStepped:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local p = root.Position
        posLbl.Text = string.format("📍  X:%.0f  Y:%.0f  Z:%.0f", p.X, p.Y, p.Z)
    end
    local elapsed = tick() - startTick
    local h = math.floor(elapsed / 3600)
    local m = math.floor((elapsed % 3600) / 60)
    local s = math.floor(elapsed % 60)
    timeLbl.Text = string.format("⏱  %dh %dm %ds", h, m, s)
end)

-- ─── LEVEL ───────────────────────────────────────────────────
local function getLevel()
    local lv = 0
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v.Name:lower():find("lv") or v.Name:lower():find("level") then
                lv = tonumber(v.Value) or 0
            end
        end
    end
    if lv == 0 then
        lv = tonumber(player:GetAttribute("Level") or player:GetAttribute("Lv") or 0) or 0
    end
    pcall(function()
        local CV = require(RS.ClientLogic.Code.CodeView)
        local gp = CV._GamePlayer
        if gp and gp.GetLevel then
            lv = gp:GetLevel()
        elseif gp and gp.level then
            lv = tonumber(gp.level) or lv
        end
    end)
    lvLbl.Text = "⭐  Level: " .. lv .. " / " .. TARGET_LV
    return lv
end

-- ─── WEBHOOK ─────────────────────────────────────────────────
local function getHttpFn()
    return http_request or request or (syn and syn.request) or (fluxus and fluxus.request)
end

local function sendWebhook(wtitle, desc, color)
    if DISCORD_WH == "" then return end
    local fn = getHttpFn()
    if not fn then return end
    local lv = getLevel()
    local ok, body = pcall(function()
        return HS:JSONEncode({
            username = "CUTO HUB 🎮",
            embeds = {{
                title       = wtitle,
                description = desc,
                color       = color or 5814783,
                fields = {
                    { name="👤 Player", value=player.Name,        inline=true },
                    { name="⭐ Level",  value=tostring(lv),        inline=true },
                    { name="🕐 Time",   value=os.date("%H:%M:%S"), inline=true },
                },
                footer = { text = "CUTO HUB • Catch A Monster" }
            }}
        })
    end)
    if ok then
        pcall(fn, {
            Url     = DISCORD_WH, Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = body
        })
    end
end

-- ─── AUTO ATTACK (LUÔN BẬT, KHÔNG BỊ TẮT BỞI TÍNH NĂNG KHÁC) ──
-- Hàm này được gọi định kỳ và sau mỗi sự kiện (hop, tp, rejoin)
local function enableAutoAttack()
    pcall(function()
        local CV = require(RS.ClientLogic.Code.CodeView)
        CV._GamePlayer.setting:SetOn("AutoAttack", true)
        stat2Lbl.Text = "⚔️  Auto Attack: ON"
    end)
end

-- No cooldown skill - chạy song song, không bị tắt
local function enableNoCooldown()
    pcall(function()
        local MFC = require(RS.ClientLogic.Fight.MgrFightClient)
        task.spawn(function()
            while autoAttack do
                pcall(function()
                    debug.setupvalue(MFC.TryUseSkill, 2, 0)
                    local cf = player.Character and player.Character:GetPivot()
                    if cf then MFC.TryUseSkill(88888888, cf) end
                end)
                task.wait(0.1)
            end
        end)
    end)
end

-- Vòng lặp riêng giữ Auto Attack luôn bật
-- Bật lại mỗi 15s, kể cả sau teleport/hop/rejoin
task.spawn(function()
    while true do
        task.wait(15)
        if autoAttack then
            enableAutoAttack()
        end
    end
end)

-- ─── AUTO CODE (CODE MỚI, MỖI CODE CHỈ NHẬP 1 LẦN) ─────────
local redeemedCodes = {} -- Lưu code đã nhập để không nhập lại

local function autoCode()
    statLbl.Text = "🎁  Đang nhập code..."
    local ok, CV = pcall(function() return require(RS.ClientLogic.Code.CodeView) end)
    if not ok then
        statLbl.Text = "⚠️  Không load được CodeView"
        return
    end

    -- Mở giao diện nhập code
    CV.OnOpen()
    task.wait(1.5)

    -- Tìm ô nhập code
    local CodeBox = nil
    for _, v in ipairs(player.PlayerGui:GetDescendants()) do
        if v:IsA("TextBox") and v.Name == "CodeBox" then
            CodeBox = v
            break
        end
    end

    if not CodeBox then
        statLbl.Text = "⚠️  Không tìm thấy CodeBox"
        return
    end

    -- Nhập từng code, bỏ qua code đã dùng
    for _, code in ipairs(CODES) do
        if not redeemedCodes[code] then
            CodeBox.Text = code
            task.wait(0.3)
            pcall(function() CV._doTakeReward() end)
            task.wait(1.2)
            redeemedCodes[code] = true -- Đánh dấu đã nhập
        end
    end

    -- Đóng giao diện code
    pcall(function() CV.OnClose() end)
    pcall(function() CV._onClose() end)
    pcall(function()
        for _, v in ipairs(player.PlayerGui:GetDescendants()) do
            if v.Name == "BtClose" and v.Visible then
                pcall(function() v.MouseButton1Click:Fire() end)
            end
        end
    end)

    statLbl.Text = "✅  Nhập code xong!"
    task.wait(1)
end

-- ─── AUTO EQUIP BEST PET (THAY THẾ LOGIC CŨ) ────────────────
local function autoEquipBestPet()
    statLbl.Text = "🐾  Equip Best Pet..."
    local ok, PBV = pcall(function()
        return require(RS.ClientLogic.Pet.PetBagView)
    end)
    if not ok then
        statLbl.Text = "⚠️  Không load được PetBagView"
        return
    end

    -- Mở giao diện túi pet
    PBV.OnOpen()
    task.wait(1.5)

    -- Tìm nút BtEquipBest và kích hoạt
    local found = false
    for _, v in ipairs(player.PlayerGui:GetDescendants()) do
        if v.Name == "BtEquipBest" and v:IsA("ImageButton") then
            firesignal(v.Activated)
            found = true
            break
        end
    end

    -- Nếu không tìm thấy BtEquipBest, log các nút equip khác để debug
    if not found then
        statLbl.Text = "⚠️  Không tìm thấy BtEquipBest"
        for _, v in ipairs(player.PlayerGui:GetDescendants()) do
            if v:IsA("ImageButton") and v.Visible and v.Name:lower():find("equip") then
                print("[CutoHub] Equip btn found:", v.Name, v:GetFullName())
            end
        end
    else
        statLbl.Text = "✅  Đã equip Best Pet!"
    end
    task.wait(1)
end

-- ─── TELEPORT ─────────────────────────────────────────────────
-- Teleport tới vị trí farm, thử lại tối đa maxTry lần
local function tpToFarm(maxTry)
    maxTry = maxTry or 3
    statLbl.Text = "🚀  TP đến farm..."
    for attempt = 1, maxTry do
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(FARM_POS + Vector3.new(0, 3, 0))
            task.wait(1.5)
            -- Kiểm tra đã đến đúng vị trí chưa (trong vòng 50 studs)
            local newRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if newRoot then
                local dist = (newRoot.Position - FARM_POS).Magnitude
                if dist <= 50 then
                    statLbl.Text = "✅  Đã đến farm!"
                    return true
                else
                    statLbl.Text = string.format("⚠️  TP lần %d thất bại, thử lại...", attempt)
                    task.wait(1)
                end
            end
        else
            task.wait(2) -- Chờ character load
        end
    end
    -- Sau 3 lần vẫn không được → bỏ qua, tiếp tục
    statLbl.Text = "⚠️  Không TP được, tiếp tục..."
    return false
end

-- ─── AUTO HATCH ───────────────────────────────────────────────
local function getEggSys()
    local ok1,ES = pcall(function() return require(RS.CommonLogic.Egg.EggSystem)         end)
    local ok2,EV = pcall(function() return require(RS.ClientLogic.Egg.EggSelectView)     end)
    local ok3,IB = pcall(function() return require(RS.ClientLogic.Item.ItemBagView)      end)
    local ok4,CE = pcall(function() return require(RS:FindFirstChild("CfgEgg",true))     end)
    local ok5,VU = pcall(function() return require(RS:FindFirstChild("ViewUtil",true))   end)
    if ok1 and ok2 and ok3 and ok4 and ok5 then return ES,EV,IB,CE,VU end
    return nil
end

local function getTgt(gp, IB, CE)
    local l = IB._getSortedEggTmplIdList(gp)
    if #l == 0 then return nil end
    if TARGET_EGG ~= "" then
        for _, id in ipairs(l) do
            local c = CE.Tmpls[id]
            if c and c.Name:lower():find(TARGET_EGG:lower()) then return id end
        end
        return nil
    end
    return l[1]
end

-- Chạy 1 lượt hatch, trả về true nếu còn trứng đang ấp
local function runEgg()
    local ES,EV,IB,CE,VU = getEggSys()
    if not ES then return false end
    local gp = EV._GamePlayer
    if not gp then return false end
    local anyActive = false
    for sl = 1, 5 do
        pcall(function()
            if not gp.egg:IsHatchUnlocked(sl) then return end
            local eid = gp.egg:GetHatchEggTmplId(sl)
            if eid then
                anyActive = true
                local tl = (gp.egg:GetHatchEggStartTick(sl) or 0) + CE.Tmpls[eid].HatchTime - os.time()
                if tl <= 0 then
                    statLbl.Text = "🐣  Slot " .. sl .. " nở!"
                    VU.DoRequest(ES.ClientHatchTaken, sl)
                    task.wait(0.5)
                else
                    statLbl.Text = "⏳  Slot " .. sl .. " còn " .. math.floor(tl) .. "s"
                end
            else
                local nid = getTgt(gp, IB, CE)
                if nid then
                    statLbl.Text = "🥚  Slot " .. sl .. " → " .. CE.Tmpls[nid].Name
                    VU.DoRequest(ES.ClientHatchStart, sl, nid)
                    anyActive = true
                end
            end
        end)
        task.wait(0.3)
    end
    return anyActive
end

-- ─── HOP SERVER ──────────────────────────────────────────────
local function isRec(id)
    for _, v in ipairs(recent) do if v == id then return true end end
    return false
end
local function addRec(id)
    table.insert(recent, 1, id)
    if #recent > 8 then table.remove(recent) end
end

local function rawFetch(url)
    local ok, r = pcall(function() return game:HttpGet(url, true) end)
    if ok and r and #r > 10 then return r end
    local fn = http_request or request or (syn and syn.request)
    if fn then
        ok, r = pcall(fn, { Url=url, Method="GET" })
        if ok and r and r.Body and #r.Body > 10 then return r.Body end
    end
    return nil
end

local function getSvr()
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local raw
    for i = 1, 3 do
        raw = rawFetch(url)
        if raw then break end
        task.wait(1.5)
    end
    if not raw then return nil end
    local ok, d = pcall(function() return HS:JSONDecode(raw) end)
    if ok and d then return d end
    return nil
end

local function hasOtherPlayer()
    local ch = player.Character
    if not ch then return false end
    local rt = ch:FindFirstChild("HumanoidRootPart")
    if not rt then return false end
    for _, p2 in ipairs(game.Players:GetPlayers()) do
        if p2 ~= player and p2.Character then
            local rt2 = p2.Character:FindFirstChild("HumanoidRootPart")
            if rt2 and (rt.Position - rt2.Position).Magnitude <= 100 then
                return true
            end
        end
    end
    return false
end

local function doHop()
    if hop2 then return end
    hop2 = true
    hopLbl.Text = "🔍  Lấy server list..."
    local d = getSvr()
    if not d or not d.data or #d.data == 0 then
        hopLbl.Text = "❌  Không lấy được server list!"
        hop2 = false; return
    end
    addRec(game.JobId)
    local servers = {}
    for _, s in ipairs(d.data) do
        if s.id and s.id ~= game.JobId and not isRec(s.id) then
            local maxP    = tonumber(s.maxPlayers) or 20
            local playing = tonumber(s.playing)    or 0
            if playing <= maxP - HOP_MIN_SLOT then
                table.insert(servers, { id=s.id, playing=playing, maxP=maxP })
            end
        end
    end
    if #servers == 0 then
        hopLbl.Text = "⚠️  Không có server trống!"
        recent = {}; hop2 = false; return
    end
    table.sort(servers, function(a, b) return a.playing < b.playing end)

    local sidx = 0
    local function tryNext()
        sidx = sidx + 1
        if sidx > #servers then
            hopLbl.Text = "⚠️  Hết server!"
            recent = {}; hop2 = false; return
        end
        local s = servers[sidx]
        hopLbl.Text = string.format("🔄  %d/%d (%dp)...", sidx, #servers, s.playing)
        addRec(s.id)
        local ok1 = pcall(function() TS:TeleportToPlaceInstance(placeId, s.id, player) end)
        if not ok1 then
            pcall(function()
                local opt = Instance.new("TeleportOptions")
                opt.ServerInstanceId = s.id
                TS:TeleportAsync(placeId, { player }, opt)
            end)
        end
    end

    pcall(function()
        TS.TeleportInitFailed:Connect(function(plr, result)
            if plr ~= player then return end
            task.wait(0.8); tryNext()
        end)
    end)

    tryNext()
    task.delay(90, function()
        hop2 = false
        hopLbl.Text = "⏹  Timeout hop"
    end)
end

-- ─── AUTO HOP SERVER THEO THỜI GIAN (MỚI) ───────────────────
-- Hop khi đã chạy đủ HOP_MINUTES phút
task.spawn(function()
    while true do
        task.wait(30) -- Kiểm tra mỗi 30 giây
        if not autoHop or hop2 then continue end

        local elapsed = tick() - startTick
        local minutes = math.floor(elapsed / 60)

        -- Hop sau HOP_MINUTES phút
        if minutes >= HOP_MINUTES then
            hopLbl.Text = string.format("⏰  %d phút → Hop Server!", minutes)
            task.wait(2)
            sendWebhook("🔄 Auto Hop", "Đã chạy " .. minutes .. " phút, hop server mới.", 3447003)
            doHop()
            -- Reset timer sau khi hop
            startTick = tick()
        else
            -- Hiển thị thời gian còn lại đến khi hop
            local remaining = HOP_MINUTES - minutes
            hopLbl.Text = string.format("⏰  Hop sau %d phút | 👥 %s",
                remaining,
                hasOtherPlayer() and "Có người!" or "Server trống")
        end

        -- Vẫn giữ logic hop khi có người
        if hasOtherPlayer() then
            hopLbl.Text = "👥  Có người → Hop!"
            task.wait(2)
            doHop()
        end
    end
end)

-- ─── KHÔI PHỤC SAU KHI HOP SERVER / REJOIN ──────────────────
-- Lắng nghe sự kiện teleport xong → bật lại tất cả tính năng
TS.LocalPlayerArrivedFromTeleport:Connect(function()
    task.wait(4) -- Đợi game load

    statLbl.Text = "🔄  Khôi phục sau Hop..."

    -- Bước 1: Load lại Auto Attack ngay lập tức
    enableAutoAttack()
    enableNoCooldown()

    -- Bước 2: Đọc tọa độ đã lưu và teleport
    tpToFarm(3) -- Thử tối đa 3 lần

    -- Bước 3: Auto Code (chỉ nhập code chưa nhập)
    autoCode()

    -- Bước 4: Equip Best Pet
    autoEquipBestPet()

    -- Bước 5: Bật lại Auto Hatch
    hatching = true
    statLbl.Text = "✅  Khôi phục xong! Tiếp tục farm..."

    -- Reset hop state
    hop2 = false
end)

-- ─── MAIN LOOP ───────────────────────────────────────────────
task.spawn(function()
    statLbl.Text = "⏳  Chờ game load..."
    task.wait(4)

    -- Khởi động ban đầu
    -- 1. Auto Attack trước tiên (không bao giờ bị tắt)
    enableAutoAttack()
    enableNoCooldown()

    -- 2. Auto Code
    autoCode()

    -- 3. Equip Best Pet
    autoEquipBestPet()

    -- 4. Teleport đến farm
    tpToFarm(3)

    -- 5. Bắt đầu Auto Hatch
    hatching = true
    statLbl.Text = "🥚  Bắt đầu ấp trứng..."

    -- Vòng lặp chính
    while running do
        -- Kiểm tra level
        local lv = getLevel()
        if lv >= TARGET_LV then
            statLbl.Text  = "🏆  Đạt lv " .. TARGET_LV .. "!"
            stat2Lbl.Text = "🎉  Xong!"
            sendWebhook(
                "🏆 Đạt Level " .. TARGET_LV .. "!",
                "**" .. player.Name .. "** đạt level **" .. lv .. "**!",
                16766720
            )
            running = false
            break
        end

        -- Auto Hatch (chạy song song với Auto Attack)
        if hatching then
            local still = runEgg()
            if not still then
                -- Hết trứng → chờ một chút rồi thử lại
                statLbl.Text = "✅  Trứng nở → Đợi trứng mới..."
                task.wait(EGG_CHECK * 2)
                -- Thử hatch lại sau khi đợi
                hatching = true
            end
        end

        task.wait(EGG_CHECK)
    end

    statLbl.Text = "✅  HOÀN THÀNH!"
end)

print("🎮 [CutoHub v5] Loaded!")
print("📋 Tính năng: Auto Attack | Auto Code | Auto Equip Pet | Auto Hatch | Auto Hop " .. HOP_MINUTES .. "min")
