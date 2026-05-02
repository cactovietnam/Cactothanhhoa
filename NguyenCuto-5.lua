-- NGUYEN CUTO v7.0 - Catch a Monster
local TS=game:GetService("TeleportService")
local PL=game:GetService("Players")
local HS=game:GetService("HttpService")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local TW=game:GetService("TweenService")
local LT=game:GetService("Lighting")
local player=PL.LocalPlayer
local placeId=game.PlaceId

-- ===== SAVE =====
local SF="NguyenCutoV7.json"
local DEF={x=100,y=100,autoHop=false,autoEgg=true,targetEgg="Frostwyrm's Egg",checkInt=5,eggInt=15,fixLag=false,riftId=71,riftName="Spirit Grove Rift I",autoRift=false}
local function loadS()
    local ok,c=pcall(readfile,SF)
    if ok and c and c~="" then
        local ok2,d=pcall(function()return HS:JSONDecode(c)end)
        if ok2 and d then for k,v in pairs(DEF)do if d[k]==nil then d[k]=v end end;return d end
    end;return DEF
end
local function saveS(s)pcall(writefile,SF,HS:JSONEncode(s))end
local C=loadS()

-- ===== STATE =====
local AH=C.autoHop;local AE=C.autoEgg;local TE=C.targetEgg
local CI=C.checkInt;local EI=C.eggInt;local FL=C.fixLag
local RI=C.riftId;local RN=C.riftName;local AR=C.autoRift
local recent={}

-- ===== FIX LAG (NEW) =====
local GRAY=Color3.fromRGB(200,200,200)
local lagConn=nil
local function isDynamic(v)
    return v:FindFirstChildOfClass("Humanoid") or v:IsA("Tool")
        or v.Name:lower():find("pet") or v.Name:lower():find("drop")
        or v.Name:lower():find("coin") or v.Name:lower():find("orb")
end
local function optimizeObj(v)
    pcall(function()
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled=false
        elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
        elseif isDynamic(v) then
            for _,p in pairs(v:GetDescendants())do
                if p:IsA("BasePart") then p.Transparency=1;p.CanCollide=false end
            end
        elseif v:IsA("BasePart") then
            v.Material=Enum.Material.SmoothPlastic;v.Color=GRAY;v.CastShadow=false
        end
    end)
end
local function applyFixLag()
    LT.GlobalShadows=false;LT.Brightness=2;LT.FogEnd=9e9
    for _,v in pairs(LT:GetDescendants())do pcall(function()if v:IsA("PostEffect")then v.Enabled=false end end)end
    -- Quét workspace theo batch để không block
    local items=workspace:GetDescendants()
    local i=0
    task.spawn(function()
        for _,v in ipairs(items)do
            i=i+1;optimizeObj(v)
            if i%200==0 then task.wait() end
        end
        if lagConn then lagConn:Disconnect() end
        lagConn=workspace.DescendantAdded:Connect(function(v)task.wait();optimizeObj(v)end)
        print("✅ FIX LAG: MAP GIỮ NGUYÊN - RÁC BIẾN MẤT")
    end)
end
local function disableFixLag()
    if lagConn then lagConn:Disconnect();lagConn=nil end
    LT.GlobalShadows=true
end

-- ===== CLEAR OLD GUI =====
local old=player.PlayerGui:FindFirstChild("NCGui");if old then old:Destroy() end
if not player.Character then player.CharacterAdded:Wait() end
task.wait(0.5)

-- ===== SCREEN GUI =====
local sg=Instance.new("ScreenGui")
sg.Name="NCGui";sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;sg.Parent=player.PlayerGui

-- ===== TOGGLE BTN =====
local tF=Instance.new("Frame",sg)
tF.Size=UDim2.new(0,54,0,54);tF.Position=UDim2.new(0,8,0.5,-27)
tF.BackgroundColor3=Color3.fromRGB(10,10,15);tF.BorderSizePixel=0;tF.ZIndex=20
Instance.new("UICorner",tF).CornerRadius=UDim.new(0.5,0)
local tS=Instance.new("UIStroke",tF);tS.Color=Color3.fromRGB(80,80,100);tS.Thickness=1.5
local tB=Instance.new("ImageButton",tF)
tB.Size=UDim2.new(0.88,0,0.88,0);tB.Position=UDim2.new(0.06,0,0.06,0)
tB.BackgroundTransparency=1;tB.Image="rbxassetid://132832532598279"
tB.ScaleType=Enum.ScaleType.Fit;tB.ZIndex=21
Instance.new("UICorner",tB).CornerRadius=UDim.new(0.5,0)

-- ===== MAIN WIN =====
local WW,WH=580,420
local win=Instance.new("Frame",sg)
win.Size=UDim2.new(0,WW,0,WH);win.Position=UDim2.new(0,C.x,0,C.y)
win.BackgroundColor3=Color3.fromRGB(10,10,14);win.BorderSizePixel=0;win.ZIndex=5
Instance.new("UICorner",win).CornerRadius=UDim.new(0,12)
local wS=Instance.new("UIStroke",win);wS.Color=Color3.fromRGB(45,45,65);wS.Thickness=1.5

-- TOPBAR
local tb=Instance.new("Frame",win)
tb.Size=UDim2.new(1,0,0,44);tb.BackgroundColor3=Color3.fromRGB(15,15,22)
tb.BorderSizePixel=0;tb.ZIndex=6
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,12)
local tbF=Instance.new("Frame",tb);tbF.Size=UDim2.new(1,0,0,12);tbF.Position=UDim2.new(0,0,1,-12)
tbF.BackgroundColor3=Color3.fromRGB(15,15,22);tbF.BorderSizePixel=0;tbF.ZIndex=6
local acc=Instance.new("Frame",tb);acc.Size=UDim2.new(0,3,0.65,0);acc.Position=UDim2.new(0,10,0.175,0)
acc.BackgroundColor3=Color3.fromRGB(130,80,255);acc.BorderSizePixel=0;acc.ZIndex=7
Instance.new("UICorner",acc).CornerRadius=UDim.new(0,2)
local tLbl=Instance.new("TextLabel",tb)
tLbl.Size=UDim2.new(0,180,1,0);tLbl.Position=UDim2.new(0,18,0,0)
tLbl.BackgroundTransparency=1;tLbl.Text="NGUYEN CUTO"
tLbl.TextColor3=Color3.fromRGB(255,255,255);tLbl.TextScaled=true
tLbl.Font=Enum.Font.GothamBold;tLbl.TextXAlignment=Enum.TextXAlignment.Left;tLbl.ZIndex=7
local RB={Color3.fromRGB(255,80,80),Color3.fromRGB(255,160,0),Color3.fromRGB(255,255,60),Color3.fromRGB(60,255,100),Color3.fromRGB(60,180,255),Color3.fromRGB(150,60,255),Color3.fromRGB(255,60,200)}
local rci=1;task.spawn(function()while task.wait(0.22)do if tLbl and tLbl.Parent then tLbl.TextColor3=RB[rci];rci=rci%#RB+1 end end end)
local cB=Instance.new("TextButton",tb)
cB.Size=UDim2.new(0,26,0,26);cB.Position=UDim2.new(1,-34,0.5,-13)
cB.BackgroundColor3=Color3.fromRGB(180,50,50);cB.TextColor3=Color3.fromRGB(255,255,255)
cB.Text="✕";cB.TextScaled=true;cB.Font=Enum.Font.GothamBold;cB.BorderSizePixel=0;cB.ZIndex=7
Instance.new("UICorner",cB).CornerRadius=UDim.new(0,6)
cB.MouseButton1Click:Connect(function()win.Visible=false end)
local tDiv=Instance.new("Frame",win);tDiv.Size=UDim2.new(1,0,0,1);tDiv.Position=UDim2.new(0,0,0,44)
tDiv.BackgroundColor3=Color3.fromRGB(35,35,55);tDiv.BorderSizePixel=0;tDiv.ZIndex=6

-- TAB BAR
local tabBar=Instance.new("Frame",win)
tabBar.Size=UDim2.new(1,0,0,36);tabBar.Position=UDim2.new(0,0,0,45)
tabBar.BackgroundColor3=Color3.fromRGB(13,13,20);tabBar.BorderSizePixel=0;tabBar.ZIndex=6
local tabL=Instance.new("UIListLayout",tabBar)
tabL.FillDirection=Enum.FillDirection.Horizontal;tabL.HorizontalAlignment=Enum.HorizontalAlignment.Left
tabL.VerticalAlignment=Enum.VerticalAlignment.Center;tabL.Padding=UDim.new(0,3)
local tabP=Instance.new("UIPadding",tabBar);tabP.PaddingLeft=UDim.new(0,6);tabP.PaddingTop=UDim.new(0,3);tabP.PaddingBottom=UDim.new(0,3)
local tabDiv=Instance.new("Frame",win);tabDiv.Size=UDim2.new(1,0,0,1);tabDiv.Position=UDim2.new(0,0,0,81)
tabDiv.BackgroundColor3=Color3.fromRGB(35,35,55);tabDiv.BorderSizePixel=0;tabDiv.ZIndex=6

-- CONTENT
local cont=Instance.new("Frame",win)
cont.Size=UDim2.new(1,0,1,-82);cont.Position=UDim2.new(0,0,0,82)
cont.BackgroundTransparency=1;cont.ClipsDescendants=true;cont.ZIndex=6

-- ===== PAGE SYSTEM =====
local pages={};local curTab=nil
local function showPage(n)for k,p in pairs(pages)do p.Visible=(k==n)end end
local function mkPage(n)
    local s=Instance.new("ScrollingFrame",cont)
    s.Size=UDim2.new(1,0,1,0);s.BackgroundTransparency=1;s.BorderSizePixel=0
    s.ScrollBarThickness=3;s.ScrollBarImageColor3=Color3.fromRGB(70,70,100);s.Visible=false;s.ZIndex=7
    local l=Instance.new("UIListLayout",s);l.Padding=UDim.new(0,5);l.SortOrder=Enum.SortOrder.LayoutOrder
    local p=Instance.new("UIPadding",s);p.PaddingLeft=UDim.new(0,10);p.PaddingRight=UDim.new(0,10);p.PaddingTop=UDim.new(0,8);p.PaddingBottom=UDim.new(0,8)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()s.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+16)end)
    pages[n]=s;return s
end
local ord={};local function no(n)ord[n]=(ord[n] or 0)+1;return ord[n] end

local function mkTab(lbl,icon,pg)
    local b=Instance.new("TextButton",tabBar)
    b.Size=UDim2.new(0,110,1,0);b.BackgroundColor3=Color3.fromRGB(20,20,30)
    b.TextColor3=Color3.fromRGB(150,150,175);b.Text=icon.."  "..lbl
    b.TextScaled=true;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.ZIndex=7
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    b.MouseButton1Click:Connect(function()
        showPage(pg)
        if curTab then curTab.BackgroundColor3=Color3.fromRGB(20,20,30);curTab.TextColor3=Color3.fromRGB(150,150,175) end
        curTab=b;b.BackgroundColor3=Color3.fromRGB(130,80,255);b.TextColor3=Color3.fromRGB(255,255,255)
    end)
    return b
end

-- ===== UI HELPERS =====
local function mkSec(pg,txt,col)
    local l=Instance.new("TextLabel",pages[pg])
    l.Size=UDim2.new(1,0,0,20);l.BackgroundTransparency=1;l.Text=txt
    l.TextColor3=col or Color3.fromRGB(130,80,255);l.TextScaled=true;l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=8;l.LayoutOrder=no(pg)
end
local function mkStat(pg,txt)
    local l=Instance.new("TextLabel",pages[pg])
    l.Size=UDim2.new(1,0,0,16);l.BackgroundTransparency=1;l.Text=txt
    l.TextColor3=Color3.fromRGB(150,150,175);l.TextScaled=true;l.Font=Enum.Font.Gotham
    l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=8;l.LayoutOrder=no(pg);return l
end
local function mkDiv(pg)
    local d=Instance.new("Frame",pages[pg])
    d.Size=UDim2.new(1,0,0,1);d.BackgroundColor3=Color3.fromRGB(35,35,55)
    d.BorderSizePixel=0;d.ZIndex=8;d.LayoutOrder=no(pg)
end
local function mkRow(pg,h)
    local r=Instance.new("Frame",pages[pg])
    r.Size=UDim2.new(1,0,0,h or 54);r.BackgroundColor3=Color3.fromRGB(17,17,25)
    r.BorderSizePixel=0;r.ZIndex=8;r.LayoutOrder=no(pg)
    Instance.new("UICorner",r).CornerRadius=UDim.new(0,8)
    local s=Instance.new("UIStroke",r);s.Color=Color3.fromRGB(38,38,58);s.Thickness=1
    return r
end
local function rLbl(r,lbl,desc)
    local l=Instance.new("TextLabel",r)
    l.Size=UDim2.new(0.55,0,0,20);l.Position=UDim2.new(0,10,0,8)
    l.BackgroundTransparency=1;l.Text=lbl;l.TextColor3=Color3.fromRGB(235,235,255)
    l.TextScaled=true;l.Font=Enum.Font.GothamBold;l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=9
    if desc then
        local d=Instance.new("TextLabel",r)
        d.Size=UDim2.new(0.55,0,0,15);d.Position=UDim2.new(0,10,0,30)
        d.BackgroundTransparency=1;d.Text=desc;d.TextColor3=Color3.fromRGB(100,100,130)
        d.TextScaled=true;d.Font=Enum.Font.Gotham;d.TextXAlignment=Enum.TextXAlignment.Left;d.ZIndex=9
    end
end
local function mkToggle(pg,lbl,desc,init,col,cb)
    local r=mkRow(pg);rLbl(r,lbl,desc)
    local bg=Instance.new("Frame",r)
    bg.Size=UDim2.new(0,42,0,22);bg.Position=UDim2.new(1,-52,0.5,-11)
    bg.BackgroundColor3=init and col or Color3.fromRGB(45,45,60);bg.BorderSizePixel=0;bg.ZIndex=9
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0.5,0)
    local k=Instance.new("Frame",bg)
    k.Size=UDim2.new(0,16,0,16);k.Position=init and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    k.BackgroundColor3=Color3.fromRGB(255,255,255);k.BorderSizePixel=0;k.ZIndex=10
    Instance.new("UICorner",k).CornerRadius=UDim.new(0.5,0)
    local st=init
    local function tog()
        st=not st
        TW:Create(bg,TweenInfo.new(0.15),{BackgroundColor3=st and col or Color3.fromRGB(45,45,60)}):Play()
        TW:Create(k,TweenInfo.new(0.15),{Position=st and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
        if cb then cb(st) end
    end
    r.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then tog()end end)
end
local function mkBtn(pg,lbl,desc,col,cb)
    local r=mkRow(pg);rLbl(r,lbl,desc)
    local b=Instance.new("TextButton",r)
    b.Size=UDim2.new(0,64,0,28);b.Position=UDim2.new(1,-74,0.5,-14)
    b.BackgroundColor3=col or Color3.fromRGB(130,80,255);b.TextColor3=Color3.fromRGB(255,255,255)
    b.Text="▶";b.TextScaled=true;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.ZIndex=9
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
        TW:Create(b,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
        task.wait(0.08);TW:Create(b,TweenInfo.new(0.08),{BackgroundColor3=col or Color3.fromRGB(130,80,255)}):Play()
        if cb then cb() end
    end)
    return b
end
local function mkInput(pg,lbl,desc,init,mn,mx,cb)
    local r=mkRow(pg);rLbl(r,lbl,desc)
    local b=Instance.new("TextBox",r)
    b.Size=UDim2.new(0,64,0,28);b.Position=UDim2.new(1,-74,0.5,-14)
    b.BackgroundColor3=Color3.fromRGB(22,22,34);b.TextColor3=Color3.fromRGB(255,215,80)
    b.Text=tostring(init);b.TextScaled=true;b.Font=Enum.Font.GothamBold
    b.ClearTextOnFocus=false;b.BorderSizePixel=0;b.ZIndex=9
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",b).Color=Color3.fromRGB(80,80,120)
    b.FocusLost:Connect(function()
        local v=tonumber(b.Text);if v and v>=mn and v<=mx then if cb then cb(v) end;init=v else b.Text=tostring(init) end
    end)
    return b
end

-- Egg/Rift scroll picker helper
local function mkPicker(pg,items,initKey,col,onSel)
    local sf=Instance.new("ScrollingFrame",pages[pg])
    sf.Size=UDim2.new(1,0,0,100);sf.BackgroundColor3=Color3.fromRGB(13,13,20)
    sf.BorderSizePixel=0;sf.ScrollBarThickness=3;sf.ScrollBarImageColor3=Color3.fromRGB(70,70,100)
    sf.CanvasSize=UDim2.new(0,0,0,#items*26);sf.ZIndex=8;sf.LayoutOrder=no(pg)
    Instance.new("UICorner",sf).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",sf).Color=Color3.fromRGB(38,38,58)
    local sl=Instance.new("UIListLayout",sf);sl.Padding=UDim.new(0,2)
    local sp=Instance.new("UIPadding",sf);sp.PaddingLeft=UDim.new(0,4);sp.PaddingRight=UDim.new(0,4);sp.PaddingTop=UDim.new(0,3)
    local selB=nil
    for _,item in ipairs(items)do
        local isSel=(item.key==initKey)
        local b=Instance.new("TextButton",sf)
        b.Size=UDim2.new(1,0,0,22);b.BackgroundColor3=isSel and col or Color3.fromRGB(20,20,30)
        b.TextColor3=isSel and Color3.fromRGB(255,255,255) or Color3.fromRGB(185,185,205)
        b.Text=(isSel and "✓  " or "    ")..item.label
        b.TextScaled=true;b.Font=Enum.Font.Gotham;b.BorderSizePixel=0
        b.TextXAlignment=Enum.TextXAlignment.Left;b.ZIndex=9
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
        if isSel then selB=b end
        b.MouseButton1Click:Connect(function()
            if selB then selB.BackgroundColor3=Color3.fromRGB(20,20,30);selB.TextColor3=Color3.fromRGB(185,185,205);selB.Text="    "..selB.Text:gsub("^✓  ","")end
            selB=b;b.BackgroundColor3=col;b.TextColor3=Color3.fromRGB(255,255,255);b.Text="✓  "..item.label
            if onSel then onSel(item) end
        end)
    end
end

-- ===== CREATE PAGES =====
mkPage("hop");mkPage("egg");mkPage("rift");mkPage("lag")
local t1=mkTab("Hop","⚡","hop");local t2=mkTab("Egg","🥚","egg")
local t3=mkTab("Rift","🌀","rift");local t4=mkTab("Lag","⚙️","lag")

-- ===== PAGE HOP =====
mkSec("hop","⚡  Hop Server",Color3.fromRGB(60,180,255))
local hStat=mkStat("hop","⏸  Sẵn sàng...")
local mStat=mkStat("hop","🔍  Kiểm tra monster...")
mkDiv("hop")
mkToggle("hop","Auto Hop","Hop khi không có monster",AH,Color3.fromRGB(0,155,215),function(v)AH=v;C.autoHop=v;saveS(C)end)
mkInput("hop","Check interval","Giây (1-60)",CI,1,60,function(v)CI=v;C.checkInt=v;saveS(C)end)
local hBtn=mkBtn("hop","Hop Ngay","Tìm server ít người",Color3.fromRGB(0,175,80),nil)

-- ===== PAGE EGG =====
mkSec("egg","🥚  Auto Egg",Color3.fromRGB(255,175,0))
local eStat=mkStat("egg","🥚  Chờ...")
mkDiv("egg")
mkToggle("egg","Auto Egg","Tự ấp và lấy trứng",AE,Color3.fromRGB(200,100,0),function(v)AE=v;C.autoEgg=v;saveS(C)end)
mkInput("egg","Egg interval","Giây (1-30)",EI,1,30,function(v)EI=v;C.eggInt=v;saveS(C)end)
-- Egg box
local eRow=mkRow("egg",54);rLbl(eRow,"Tên trứng","Gõ hoặc chọn nhanh")
local eBox=Instance.new("TextBox",eRow)
eBox.Size=UDim2.new(0.44,0,0,28);eBox.Position=UDim2.new(0.54,0,0.5,-14)
eBox.BackgroundColor3=Color3.fromRGB(22,22,34);eBox.TextColor3=Color3.fromRGB(255,215,80)
eBox.Text=TE;eBox.TextScaled=true;eBox.Font=Enum.Font.GothamBold;eBox.ClearTextOnFocus=false;eBox.BorderSizePixel=0;eBox.ZIndex=9
Instance.new("UICorner",eBox).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",eBox).Color=Color3.fromRGB(200,140,0)
eBox.FocusLost:Connect(function()TE=eBox.Text;C.targetEgg=TE;saveS(C);eStat.Text="🥚  Target: "..TE end)

local eggItems={
    {key="Blossom Egg",label="Blossom Egg"},{key="Rosette Egg",label="Rosette Egg"},
    {key="Gildron's Egg",label="Gildron's Egg"},{key="Coral Egg",label="Coral Egg"},
    {key="TideVex's Egg",label="TideVex's Egg"},{key="Giant Tree Egg",label="Giant Tree Egg"},
    {key="Frostwyrm's Egg",label="Frostwyrm's Egg"},{key="Thunderclaw's Egg",label="Thunderclaw's Egg"},
    {key="GrassEgg",label="GrassEgg"},{key="SwampEgg",label="SwampEgg"},
}
mkPicker("egg",eggItems,TE,Color3.fromRGB(200,100,0),function(item)
    TE=item.key;eBox.Text=item.key;C.targetEgg=item.key;saveS(C);eStat.Text="🥚  Target: "..item.key
end)

-- ===== PAGE RIFT =====
mkSec("rift","🌀  Auto Rift",Color3.fromRGB(150,80,255))
local rStat=mkStat("rift","🌀  Rift: "..RN)
mkDiv("rift")
mkToggle("rift","Auto Rift","Tự tạo team và start",AR,Color3.fromRGB(130,60,220),function(v)AR=v;C.autoRift=v;saveS(C)end)

local riftItems={
    {key=71,label="★  Spirit Grove Rift I"},{key=72,label="★★ Spirit Grove Rift II"},{key=73,label="★★★ Spirit Grove Rift III"},
    {key=91,label="★  Blossom Haven Rift I"},{key=92,label="★★ Blossom Haven Rift II"},{key=93,label="★★★ Blossom Haven Rift III"},
    {key=41,label="★  Neverland Rift I"},{key=42,label="★★ Neverland Rift II"},
    {key=61,label="★  Tideland Rift I"},{key=62,label="★★ Tideland Rift II"},{key=63,label="★★★ Tideland Rift III"},
    {key=21,label="★  Volcano Rift I"},{key=22,label="★★ Volcano Rift II"},
    {key=51,label="★  Duneveil Isle Rift I"},{key=52,label="★★ Duneveil Isle Rift II"},{key=53,label="★★★ Duneveil Isle Rift III"},
    {key=10000,label="★★ Strange Rift"},{key=10005,label="★★ Chaos Rift"},
}
mkPicker("rift",riftItems,RI,Color3.fromRGB(130,60,220),function(item)
    RI=item.key;RN=item.label;C.riftId=item.key;C.riftName=item.label;saveS(C)
    rStat.Text="🌀  Rift: "..item.label
end)
local rBtn=mkBtn("rift","Start Rift","Tạo team và start ngay",Color3.fromRGB(130,60,220),nil)

-- ===== PAGE LAG =====
mkSec("lag","⚙️  Fix Lag",Color3.fromRGB(200,80,80))
mkStat("lag","Giữ map, ẩn rác, tắt effect")
mkDiv("lag")
mkToggle("lag","Fix Lag","Bật/tắt toàn bộ fix lag",FL,Color3.fromRGB(200,60,60),function(v)
    FL=v;C.fixLag=v;saveS(C)
    if v then applyFixLag() else disableFixLag() end
end)
mkBtn("lag","Áp dụng ngay","Chạy fix lag ngay lập tức",Color3.fromRGB(180,50,50),function()applyFixLag()end)

-- ===== TOGGLE & DEFAULT =====
tB.MouseButton1Click:Connect(function()win.Visible=not win.Visible end)
showPage("hop");curTab=t1;t1.BackgroundColor3=Color3.fromRGB(130,80,255);t1.TextColor3=Color3.fromRGB(255,255,255)

-- ===== DRAG =====
local drg,dS,dP=false,nil,nil
local function clamp(x,y)
    local sw=workspace.CurrentCamera.ViewportSize.X;local sh=workspace.CurrentCamera.ViewportSize.Y
    return math.clamp(x,0,sw-WW),math.clamp(y,0,sh-WH)
end
tb.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=true;dS=i.Position;dP=win.Position end end)
UIS.InputChanged:Connect(function(i)
    if not drg then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        local d=i.Position-dS;local nx,ny=clamp(dP.X.Offset+d.X,dP.Y.Offset+d.Y);win.Position=UDim2.new(0,nx,0,ny)
    end
end)
UIS.InputEnded:Connect(function(i)
    if(i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch)and drg then
        drg=false;C.x=win.Position.X.Offset;C.y=win.Position.Y.Offset;saveS(C)
    end
end)

-- ===== HOP LOGIC =====
local function isRec(id)for _,v in ipairs(recent)do if v==id then return true end end;return false end
local function addRec(id)table.insert(recent,1,id);if #recent>3 then table.remove(recent)end end
local function getSvr()
    local ok,r=pcall(function()return game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")end)
    if ok then return HS:JSONDecode(r) end;return nil
end
local function hasMon()
    local ch=player.Character;if not ch then return false end
    local rt=ch:FindFirstChild("HumanoidRootPart");if not rt then return false end
    for _,f in ipairs({workspace:FindFirstChild("Monsters"),workspace:FindFirstChild("ClientMonsters"),workspace:FindFirstChild("Pets"),workspace:FindFirstChild("ClientPets")})do
        if f then for _,o in ipairs(f:GetDescendants())do
            if o:IsA("Model")then
                local nm=o.Name:find("Monster_")~=nil;local hm=o:FindFirstChildOfClass("Humanoid")~=nil
                if nm or hm then
                    local r2=o:FindFirstChild("HumanoidRootPart") or o:FindFirstChild("Root") or o.PrimaryPart
                    if r2 then if(rt.Position-r2.Position).Magnitude<=40 then return true end
                    else for _,p in ipairs(o:GetChildren())do if p:IsA("BasePart")then if(rt.Position-p.Position).Magnitude<=40 then return true end;break end end end
                end
            end
        end end
    end;return false
end
local hop=false
local function doHop()
    if hop then return end;hop=true;hStat.Text="⏳  Đang tìm..."
    local d=getSvr();if not d or not d.data then hStat.Text="❌  Lỗi!";hop=false;return end
    addRec(game.JobId)
    for _,s in ipairs(d.data)do
        if s.playing<5 and s.id~=game.JobId and not isRec(s.id)then
            hStat.Text="✅  Hop → "..s.playing.." người";task.wait(1)
            TS:TeleportToPlaceInstance(placeId,s.id,player);return
        end
    end;hStat.Text="⚠️  Không tìm thấy!";hop=false
end
hBtn.MouseButton1Click:Connect(doHop)
task.spawn(function()
    while task.wait(CI)do
        if not AH or hop then continue end
        if hasMon()then mStat.Text="🐉  Có monster!";mStat.TextColor3=Color3.fromRGB(255,100,100)
        else mStat.Text="😴  Hop!";mStat.TextColor3=Color3.fromRGB(255,200,0);hStat.Text="🔄  Auto hop...";task.wait(2);doHop()end
    end
end)

-- ===== EGG LOGIC =====
local function getEggSys()
    local ok1,ES=pcall(function()return require(RS.CommonLogic.Egg.EggSystem)end)
    local ok2,EV=pcall(function()return require(RS.ClientLogic.Egg.EggSelectView)end)
    local ok3,IB=pcall(function()return require(RS.ClientLogic.Item.ItemBagView)end)
    local ok4,CE=pcall(function()return require(RS:FindFirstChild("CfgEgg",true))end)
    local ok5,VU=pcall(function()return require(RS:FindFirstChild("ViewUtil",true))end)
    if ok1 and ok2 and ok3 and ok4 and ok5 then return ES,EV,IB,CE,VU end;return nil
end
local function getTgtEgg(gp,IB,CE)
    local l=IB._getSortedEggTmplIdList(gp);if #l==0 then return nil end
    if TE and TE~="" then for _,id in ipairs(l)do local c=CE.Tmpls[id];if c and c.Name:lower():find(TE:lower())then return id end end;return nil end
    return l[1]
end
local function runEgg()
    local ES,EV,IB,CE,VU=getEggSys();if not ES then eStat.Text="❌  Lỗi!";return end
    local gp=EV._GamePlayer;if not gp then return end
    for sl=1,5 do pcall(function()
        if not gp.egg:IsHatchUnlocked(sl)then return end
        local eid=gp.egg:GetHatchEggTmplId(sl)
        if eid then
            local tl=(gp.egg:GetHatchEggStartTick(sl) or 0)+CE.Tmpls[eid].HatchTime-os.time()
            if tl<=0 then
                eStat.Text="🐣  Slot "..sl.." nở!";VU.DoRequest(ES.ClientHatchTaken,sl);task.wait(0.5)
                local nid=getTgtEgg(gp,IB,CE)
                if nid then eStat.Text="🥚  Slot "..sl.." → "..CE.Tmpls[nid].Name;VU.DoRequest(ES.ClientHatchStart,sl,nid)end
            else eStat.Text="⏳  Slot "..sl.." còn "..math.floor(tl).."s" end
        else
            local nid=getTgtEgg(gp,IB,CE)
            if nid then eStat.Text="🥚  Đặt slot "..sl;VU.DoRequest(ES.ClientHatchStart,sl,nid)
            else eStat.Text="❌  Không có: "..TE end
        end
    end);task.wait(0.3)end
end
task.spawn(function()task.wait(3);while task.wait(EI)do if AE then pcall(runEgg)end end end)

-- ===== RIFT LOGIC =====
local CD=nil
pcall(function() CD=require(RS:FindFirstChild("CfgDungeon",true)) end)
local enterFunc=RS:FindFirstChild("BossRoomEnterFunc",true)
local riftRunning=false
local riftDone=false

-- Tìm portal theo EnterModel trong workspace
local function findPortal(enterModelName)
    local areaFolder=workspace:FindFirstChild("Area")
    if not areaFolder then return nil end
    for _,island in ipairs(areaFolder:GetChildren()) do
        local islandArea=island:FindFirstChild("Area")
        if islandArea then
            local dungeon=islandArea:FindFirstChild("Dungeon")
            if dungeon then
                for _,dungeonModel in ipairs(dungeon:GetChildren()) do
                    local portal=dungeonModel:FindFirstChild(enterModelName)
                    if portal then return portal end
                end
            end
        end
    end
    return nil
end

-- Teleport đến portal
local function teleportToPortal(arenaId)
    if not CD then return false end
    local cfg=CD.Tmpls[arenaId]
    if not cfg then return false end
    local portal=findPortal(cfg.EnterModel)
    if not portal then
        rStat.Text="❌  Không tìm thấy portal!"; return false
    end
    local char=player.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    -- Lấy vị trí portal
    local pos=nil
    if portal:IsA("BasePart") then pos=portal.Position
    elseif portal.PrimaryPart then pos=portal.PrimaryPart.Position
    else
        for _,p in ipairs(portal:GetDescendants()) do
            if p:IsA("BasePart") then pos=p.Position;break end
        end
    end
    if not pos then return false end
    root.CFrame=CFrame.new(pos+Vector3.new(0,4,0))
    return true
end

-- Join Rift qua BossRoomEnterFunc
local function joinRift(arenaId)
    if not enterFunc then
        rStat.Text="❌  Không tìm thấy enterFunc!"; return false
    end
    -- Phải đứng gần portal mới join được
    rStat.Text="🚶  Teleport đến portal..."
    if not teleportToPortal(arenaId) then
        rStat.Text="❌  Không tìm thấy portal!"; return false
    end
    task.wait(2) -- Chờ server nhận vị trí

    rStat.Text="🌀  Join Rift..."
    local ok,res=pcall(function()
        return enterFunc:InvokeServer(arenaId)
    end)
    print("Join result: ok="..tostring(ok).." res="..tostring(res))
    if ok and res then return true end

    -- Thử lại lần 2 sau 1 giây
    task.wait(1)
    local ok2,res2=pcall(function()
        return enterFunc:InvokeServer(arenaId)
    end)
    print("Join retry: ok="..tostring(ok2).." res="..tostring(res2))
    return ok2 and res2
end

-- Start Rift
local function startRift(arenaId)
    local ok,DS=pcall(function()return require(RS.CommonLogic.Arena.DungeonSystem)end)
    local ok2,VU=pcall(function()return require(RS:FindFirstChild("ViewUtil",true))end)
    if not ok or not ok2 then return false end
    local ok3,res=pcall(function()
        return VU.DoRequest(DS.ClientStartDungeon,arenaId)
    end)
    return ok3 and res
end

-- Hop server sau khi xong Rift
local function hopAfterRift()
    rStat.Text="🔄  Hop server mới..."
    task.wait(2)
    local data=getSvr()
    if not data or not data.data then rStat.Text="❌  Lỗi hop!"; return end
    addRec(game.JobId)
    for _,s in ipairs(data.data) do
        if s.playing<5 and s.id~=game.JobId and not isRec(s.id) then
            rStat.Text="✅  Hop → "..s.playing.." người"
            task.wait(1)
            TS:TeleportToPlaceInstance(placeId,s.id,player)
            return
        end
    end
    rStat.Text="⚠️  Không tìm thấy server!"
end

-- Detect Rift kết thúc qua CatchDoGui
local function detectRiftEnd(callback)
    local conn
    conn=player.PlayerGui.ChildAdded:Connect(function(child)
        if child.Name=="CatchDoGui" then
            conn:Disconnect()
            riftDone=true
            if callback then callback() end
        end
    end)
    -- Timeout 10 phút
    task.spawn(function()
        task.wait(600)
        if conn then conn:Disconnect() end
    end)
end

-- Full Rift flow
local function doRift()
    if riftRunning then rStat.Text="⏳  Đang chạy Rift..."; return end
    riftRunning=true; riftDone=false

    -- Bước 1+2: Teleport portal + Join Rift (gộp trong joinRift)
    local joined=joinRift(RI)
    if not joined then
        rStat.Text="❌  Join Rift thất bại!"
        riftRunning=false; return
    end
    task.wait(1)

    -- Bước 3: Start Rift
    rStat.Text="▶  Start Rift: "..RN
    local started=startRift(RI)
    if not started then
        rStat.Text="⚠️  Đang chờ start..."
    else
        rStat.Text="⚔️  Trong Rift: "..RN
    end

    -- Bước 4: Detect khi xong → hop server
    detectRiftEnd(function()
        rStat.Text="🏆  Rift xong!"
        riftRunning=false
        task.wait(3)
        if AR then hopAfterRift() end
    end)
end

rBtn.MouseButton1Click:Connect(function()pcall(doRift)end)

task.spawn(function()
    task.wait(5);if FL then applyFixLag()end
    -- Auto Rift: chạy ngay khi bật, rồi sau khi hop server sẽ tự chạy lại
    if AR then task.wait(3);pcall(doRift) end
end)

print("✅ NGUYEN CUTO v7.0")
