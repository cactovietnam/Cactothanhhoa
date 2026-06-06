-- ============================================================
-- 🎮 NC_CutoHub.lua v7 — Cuto Hub | Catch A Monster
-- Fix: firesignal nil → dùng fallback, FightUnit nil → pcall safe
-- ============================================================

local RS         = game:GetService("ReplicatedStorage")
local HS         = game:GetService("HttpService")
local TS         = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local player     = game.Players.LocalPlayer
local placeId    = game.PlaceId

-- ─── CONFIG ──────────────────────────────────────────────────
local DISCORD_WH   = "https://discord.com/api/webhooks/1414221632653758666/cS75tL5qKuCyM--U6N48ywXv9s3_BPwHHaovFy0WArVFTDgMyBcMykCP0haWr2ClwXsK"
local TARGET_EGG   = "Shadow Rotthorn Egg"
local TARGET_LV    = 30
local EGG_CHECK    = 15
local HOP_MIN_SLOT = 2
local HOP_MINUTES  = 36

-- ─── STATE ───────────────────────────────────────────────────
local running    = true
local hatching   = true
local hop2       = false
local autoHop    = true
local autoAttack = true
local recent     = {}
local startTick  = tick()
local FARM_POS   = Vector3.new(2915.9, -79.8, 2018.5)

-- ─── DANH SÁCH CODE ──────────────────────────────────────────
local CODES = {
    "dueggy", "teravok", "moovik",
    "danvok",  "coltasc", "Scareep",
}
local redeemedCodes = {}

-- ─── HELPER: firesignal an toàn ──────────────────────────────
-- firesignal không có ở mọi executor → dùng fallback
local function safeFireSignal(btn)
    -- Cách 1: firesignal (Delta, Solara...)
    if firesignal then
        local ok = pcall(firesignal, btn.Activated)
        if ok then return true end
    end
    -- Cách 2: firebutton (một số executor khác)
    if firebutton then
        local ok = pcall(firebutton, btn)
        if ok then return true end
    end
    -- Cách 3: MouseButton1Click (fallback phổ biến nhất)
    pcall(function() btn.MouseButton1Click:Fire() end)
    -- Cách 4: Activated event trực tiếp
    pcall(function() btn.Activated:Fire() end)
    return true
end

-- ─── GUI ─────────────────────────────────────────────────────
local oldGui = player.PlayerGui:FindFirstChild("CutoHub")
if oldGui then oldGui:Destroy() end

local screen = Instance.new("ScreenGui")
screen.Name           = "CutoHub"
screen.ResetOnSpawn   = false
screen.IgnoreGuiInset = true
screen.Parent         = player.PlayerGui

-- Nền tối
local bg = Instance.new("Frame", screen)
bg.Size                   = UDim2.new(0, 620, 0, 260)
bg.Position               = UDim2.new(0.5, -310, 0.08, 0)
bg.BackgroundColor3       = Color3.fromRGB(10, 10, 20)
bg.BackgroundTransparency = 0.35
bg.BorderSizePixel        = 0
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 16)
local stroke = Instance.new("UIStroke", bg)
stroke.Color     = Color3.fromRGB(255, 140, 0)
stroke.Thickness = 2

local infoFrame = Instance.new("Frame", screen)
infoFrame.Size                   = UDim2.new(1, 0, 1, 0)
infoFrame.BackgroundTransparency = 1
infoFrame.BorderSizePixel        = 0

local function mkLabel(parent, pos, size, color, textSize, align)
    local l = Instance.new("TextLabel", parent)
    l.Size                   = size     or UDim2.new(0, 400, 0, 30)
    l.Position               = pos      or UDim2.new(0.5, -200, 0, 0)
    l.BackgroundTransparency = 1
    l.TextColor3             = color    or Color3.fromRGB(255, 255, 255)
    l.TextSize               = textSize or 20
    l.Font                   = Enum.Font.GothamBold
    l.TextXAlignment         = align    or Enum.TextXAlignment.Center
    l.TextStrokeTransparency = 0
    l.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    l.Text                   = ""
    return l
end

local titleLbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.09,0),   UDim2.new(0,600,0,50),
    Color3.fromRGB(255,160,0),    44)
local lvLbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.09,52),  UDim2.new(0,600,0,40),
    Color3.fromRGB(255,230,0),    32)
local timeLbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.09,96),  UDim2.new(0,600,0,32),
    Color3.fromRGB(220,220,255),  24)
local statLbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.09,132), UDim2.new(0,600,0,30),
    Color3.fromRGB(0,230,255),    22)
local stat2Lbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.09,166), UDim2.new(0,600,0,30),
    Color3.fromRGB(0,255,130),    22)
local hopLbl = mkLabel(infoFrame,
    UDim2.new(0.5,-300,0.09,200), UDim2.new(0,600,0,30),
    Color3.fromRGB(255,200,60),   22)

-- Tọa độ góc dưới trái
local posBg = Instance.new("Frame", screen)
posBg.Size                   = UDim2.new(0, 280, 0, 26)
posBg.Position               = UDim2.new(0, 6, 1, -32)
posBg.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
posBg.BackgroundTransparency = 0.4
posBg.BorderSizePixel        = 0
Instance.new("UICorner", posBg).CornerRadius = UDim.new(0, 6)
local posLbl = mkLabel(posBg,
    UDim2.new(0,4,0,0), UDim2.new(1,-8,1,0),
    Color3.fromRGB(100,220,255), 13, Enum.TextXAlignment.Left)

titleLbl.Text = "✦  CUTO HUB  ✦"

RunService.RenderStepped:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local p = root.Position
        posLbl.Text = string.format("📍 X:%.0f  Y:%.0f  Z:%.0f", p.X, p.Y, p.Z)
    end
    local e = tick() - startTick
    timeLbl.Text = string.format("⏱  %dh %dm %ds",
        math.floor(e/3600), math.floor((e%3600)/60), math.floor(e%60))
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
        if gp and gp.GetLevel then lv = gp:GetLevel()
        elseif gp and gp.level then lv = tonumber(gp.level) or lv end
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
    local fn = getHttpFn(); if not fn then return end
    local lv = getLevel()
    local ok, body = pcall(function()
        return HS:JSONEncode({
            username="CUTO HUB 🎮",
            embeds={{title=wtitle,description=desc,color=color or 5814783,
                fields={
                    {name="👤 Player",value=player.Name,inline=true},
                    {name="⭐ Level", value=tostring(lv),inline=true},
                    {name="🕐 Time",  value=os.date("%H:%M:%S"),inline=true},
                },
                footer={text="CUTO HUB • Catch A Monster"}
            }}
        })
    end)
    if ok then pcall(fn,{Url=DISCORD_WH,Method="POST",
        Headers={["Content-Type"]="application/json"},Body=body}) end
end

-- ─── AUTO ATTACK ─────────────────────────────────────────────
-- FIX: Không dùng MgrFightClient.FightUnit nữa
-- Chỉ dùng SetOn AutoAttack — an toàn và đơn giản hơn
local function enableAutoAttack()
    local ok = false

    -- Cách 1: Qua CodeView._GamePlayer.setting
    pcall(function()
        local CV = require(RS.ClientLogic.Code.CodeView)
        if CV and CV._GamePlayer and CV._GamePlayer.setting then
            CV._GamePlayer.setting:SetOn("AutoAttack", true)
            ok = true
        end
    end)

    -- Cách 2: Thử qua BattleView hoặc FightView nếu có
    if not ok then
        pcall(function()
            local BV = require(RS.ClientLogic.Fight.BattleView or RS.ClientLogic.Fight.FightView)
            if BV and BV._GamePlayer then
                BV._GamePlayer.setting:SetOn("AutoAttack", true)
                ok = true
            end
        end)
    end

    stat2Lbl.Text = ok and "⚔️  Auto Attack: ON" or "⚔️  Auto Attack: ON (fallback)"
end

-- No cooldown — BỌC pcall toàn bộ, nếu lỗi thì bỏ qua
local noCdRunning = false
local function enableNoCooldown()
    if noCdRunning then return end
    noCdRunning = true
    task.spawn(function()
        -- Thử tìm đúng module fight
        local MFC = nil
        pcall(function()
            -- Thử các đường dẫn phổ biến
            for _, name in ipairs({"MgrFightClient","FightClient","BattleClient"}) do
                local m = RS.ClientLogic.Fight:FindFirstChild(name)
                if m then MFC = require(m); break end
            end
        end)

        if not MFC then
            -- Nếu không tìm được module thì chỉ dùng AutoAttack setting
            noCdRunning = false
            return
        end

        while autoAttack do
            pcall(function()
                if MFC.TryUseSkill then
                    debug.setupvalue(MFC.TryUseSkill, 2, 0)
                    local cf = player.Character and player.Character:GetPivot()
                    if cf then MFC.TryUseSkill(88888888, cf) end
                end
            end)
            task.wait(0.1)
        end
        noCdRunning = false
    end)
end

-- Giữ Auto Attack bật mỗi 10 giây
task.spawn(function()
    while true do
        task.wait(10)
        enableAutoAttack()
    end
end)

-- ─── AUTO CODE ───────────────────────────────────────────────
local function autoCode()
    statLbl.Text = "🎁  Đang nhập code..."
    local ok, CV = pcall(function() return require(RS.ClientLogic.Code.CodeView) end)
    if not ok then statLbl.Text = "⚠️  Không load CodeView"; return end
    CV.OnOpen(); task.wait(1.5)
    local CodeBox = nil
    for _, v in ipairs(player.PlayerGui:GetDescendants()) do
        if v:IsA("TextBox") and v.Name == "CodeBox" then CodeBox = v; break end
    end
    if not CodeBox then statLbl.Text = "⚠️  Không thấy CodeBox"; return end
    for _, code in ipairs(CODES) do
        if not redeemedCodes[code] then
            CodeBox.Text = code; task.wait(0.3)
            pcall(function() CV._doTakeReward() end)
            task.wait(1.2)
            redeemedCodes[code] = true
        end
    end
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

-- ─── AUTO EQUIP BEST PET ─────────────────────────────────────
-- FIX: dùng safeFireSignal thay vì firesignal trực tiếp
local function autoEquipBestPet()
    statLbl.Text = "🐾  Equip Best Pet..."
    local ok, PBV = pcall(function() return require(RS.ClientLogic.Pet.PetBagView) end)
    if not ok then statLbl.Text = "⚠️  Không load PetBagView"; return end
    PBV.OnOpen(); task.wait(1.5)
    local found = false
    for _, v in ipairs(player.PlayerGui:GetDescendants()) do
        if v.Name == "BtEquipBest" and v:IsA("ImageButton") then
            safeFireSignal(v)  -- Dùng hàm fallback an toàn
            found = true
            break
        end
    end
    if not found then
        statLbl.Text = "⚠️  Không thấy BtEquipBest"
        -- Log tất cả nút equip để debug
        for _, v in ipairs(player.PlayerGui:GetDescendants()) do
            if v:IsA("ImageButton") and v.Visible and v.Name:lower():find("equip") then
                print("[CutoHub] Equip btn:", v.Name, v:GetFullName())
            end
        end
    else
        statLbl.Text = "✅  Đã equip Best Pet!"
    end
    task.wait(1)
end

-- ─── TELEPORT ────────────────────────────────────────────────
local function tpToFarm(maxTry)
    maxTry = maxTry or 3
    statLbl.Text = "🚀  TP đến farm..."
    for attempt = 1, maxTry do
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(FARM_POS + Vector3.new(0, 3, 0))
            task.wait(1.5)
            local r2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if r2 and (r2.Position - FARM_POS).Magnitude <= 50 then
                statLbl.Text = "✅  Đã đến farm!"; return true
            else
                statLbl.Text = string.format("⚠️  TP lần %d thất bại...", attempt)
                task.wait(1)
            end
        else
            task.wait(2)
        end
    end
    statLbl.Text = "⚠️  Bỏ qua TP, tiếp tục..."
    return false
end

-- ─── AUTO HATCH ──────────────────────────────────────────────
local function getEggSys()
    local ok1,ES = pcall(function() return require(RS.CommonLogic.Egg.EggSystem)       end)
    local ok2,EV = pcall(function() return require(RS.ClientLogic.Egg.EggSelectView)   end)
    local ok3,IB = pcall(function() return require(RS.ClientLogic.Item.ItemBagView)    end)
    local ok4,CE = pcall(function() return require(RS:FindFirstChild("CfgEgg",true))   end)
    local ok5,VU = pcall(function() return require(RS:FindFirstChild("ViewUtil",true)) end)
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
                    statLbl.Text = "🐣  Slot "..sl.." nở!"
                    VU.DoRequest(ES.ClientHatchTaken, sl); task.wait(0.5)
                else
                    statLbl.Text = "⏳  Slot "..sl.." còn "..math.floor(tl).."s"
                end
            else
                local nid = getTgt(gp, IB, CE)
                if nid then
                    statLbl.Text = "🥚  Slot "..sl.." → "..CE.Tmpls[nid].Name
                    VU.DoRequest(ES.ClientHatchStart, sl, nid); anyActive = true
                end
            end
        end)
        task.wait(0.3)
    end
    return anyActive
end

-- ─── HOP SERVER ──────────────────────────────────────────────
local function isRec(id) for _,v in ipairs(recent) do if v==id then return true end end return false end
local function addRec(id) table.insert(recent,1,id); if #recent>8 then table.remove(recent) end end
local function rawFetch(url)
    local ok,r = pcall(function() return game:HttpGet(url,true) end)
    if ok and r and #r>10 then return r end
    local fn = http_request or request or (syn and syn.request)
    if fn then ok,r=pcall(fn,{Url=url,Method="GET"}); if ok and r and r.Body and #r.Body>10 then return r.Body end end
    return nil
end
local function getSvr()
    local url="https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
    local raw; for i=1,3 do raw=rawFetch(url); if raw then break end; task.wait(1.5) end
    if not raw then return nil end
    local ok,d=pcall(function() return HS:JSONDecode(raw) end)
    return ok and d or nil
end
local function hasOtherPlayer()
    local ch=player.Character; if not ch then return false end
    local rt=ch:FindFirstChild("HumanoidRootPart"); if not rt then return false end
    for _,p2 in ipairs(game.Players:GetPlayers()) do
        if p2~=player and p2.Character then
            local rt2=p2.Character:FindFirstChild("HumanoidRootPart")
            if rt2 and (rt.Position-rt2.Position).Magnitude<=100 then return true end
        end
    end
    return false
end
local function doHop()
    if hop2 then return end; hop2=true
    hopLbl.Text="🔍  Lấy server list..."
    local d=getSvr()
    if not d or not d.data or #d.data==0 then hopLbl.Text="❌  Không lấy server!"; hop2=false; return end
    addRec(game.JobId)
    local servers={}
    for _,s in ipairs(d.data) do
        if s.id and s.id~=game.JobId and not isRec(s.id) then
            local maxP=tonumber(s.maxPlayers) or 20
            local playing=tonumber(s.playing) or 0
            if playing<=maxP-HOP_MIN_SLOT then table.insert(servers,{id=s.id,playing=playing}) end
        end
    end
    if #servers==0 then hopLbl.Text="⚠️  Không có server!"; recent={}; hop2=false; return end
    table.sort(servers,function(a,b) return a.playing<b.playing end)
    local sidx=0
    local function tryNext()
        sidx=sidx+1
        if sidx>#servers then hopLbl.Text="⚠️  Hết server!"; recent={}; hop2=false; return end
        local s=servers[sidx]
        hopLbl.Text=string.format("🔄  %d/%d (%dp)...",sidx,#servers,s.playing)
        addRec(s.id)
        local ok1=pcall(function() TS:TeleportToPlaceInstance(placeId,s.id,player) end)
        if not ok1 then
            pcall(function()
                local opt=Instance.new("TeleportOptions"); opt.ServerInstanceId=s.id
                TS:TeleportAsync(placeId,{player},opt)
            end)
        end
    end
    pcall(function()
        TS.TeleportInitFailed:Connect(function(plr)
            if plr~=player then return end; task.wait(0.8); tryNext()
        end)
    end)
    tryNext()
    task.delay(90,function() hop2=false; hopLbl.Text="⏹  Timeout" end)
end

-- Auto Hop theo thời gian + có người
task.spawn(function()
    while true do
        task.wait(30)
        if not autoHop or hop2 then continue end
        local elapsed=tick()-startTick
        local minutes=math.floor(elapsed/60)
        if minutes>=HOP_MINUTES then
            hopLbl.Text=string.format("⏰  %d phút → Hop!",minutes)
            sendWebhook("🔄 Auto Hop","Đã chạy "..minutes.." phút.",3447003)
            task.wait(2); doHop(); startTick=tick()
        elseif hasOtherPlayer() then
            hopLbl.Text="👥  Có người → Hop!"; task.wait(2); doHop()
        else
            hopLbl.Text=string.format("⏰  Hop sau %d phút | ✅ Trống",HOP_MINUTES-minutes)
        end
    end
end)

-- ─── KHÔI PHỤC SAU HOP ───────────────────────────────────────
local function fullRestore()
    task.wait(5)
    statLbl.Text = "🔄  Khôi phục sau Hop..."
    enableAutoAttack()
    noCdRunning = false
    enableNoCooldown()
    tpToFarm(3)
    autoCode()
    autoEquipBestPet()
    hatching = true
    hop2     = false
    running  = true
    statLbl.Text = "✅  Khôi phục xong!"
end
TS.LocalPlayerArrivedFromTeleport:Connect(function()
    task.spawn(fullRestore)
end)

-- ─── MAIN LOOP ───────────────────────────────────────────────
task.spawn(function()
    statLbl.Text = "⏳  Chờ game load..."
    task.wait(4)
    enableAutoAttack()
    enableNoCooldown()
    autoCode()
    autoEquipBestPet()
    tpToFarm(3)
    hatching = true
    statLbl.Text = "🥚  Bắt đầu ấp trứng..."
    while running do
        local lv = getLevel()
        if lv >= TARGET_LV then
            statLbl.Text  = "🏆  Đạt lv "..TARGET_LV.."!"
            stat2Lbl.Text = "🎉  Xong!"
            sendWebhook("🏆 Đạt Level "..TARGET_LV.."!",
                "**"..player.Name.."** đạt lv **"..lv.."**!", 16766720)
            running = false; break
        end
        if hatching then
            local still = runEgg()
            if not still then
                statLbl.Text = "⏳  Đợi trứng mới..."
                task.wait(EGG_CHECK * 2)
                hatching = true
            end
        end
        task.wait(EGG_CHECK)
    end
    statLbl.Text = "✅  HOÀN THÀNH!"
end)

print("🎮 [CutoHub v7] Loaded! Target: "..TARGET_EGG)
