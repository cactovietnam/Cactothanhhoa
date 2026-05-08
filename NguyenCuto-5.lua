-- NGUYEN CUTO v8.0
local TS=game:GetService("TeleportService")
local PL=game:GetService("Players")
local HS=game:GetService("HttpService")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local TW=game:GetService("TweenService")
local LT=game:GetService("Lighting")
local player=PL.LocalPlayer
local placeId=game.PlaceId

-- SAVE
local SF="NCv8.json"
local DEF={x=80,y=80,autoHop=false,autoEgg=true,targetEgg="Frostwyrm's Egg",checkInt=5,eggInt=15,fixLag=false,selectedRifts={},riftPriority="nearest",autoRift=false,riftDelay=3}
local function loadS()
    local ok,c=pcall(readfile,SF)
    if ok and c and c~=""then
        local ok2,d=pcall(function()return HS:JSONDecode(c)end)
        if ok2 and d then for k,v in pairs(DEF)do if d[k]==nil then d[k]=v end end;return d end
    end;return DEF
end
local function saveS(s)pcall(writefile,SF,HS:JSONEncode(s))end
local C=loadS()

-- STATE
local AH=C.autoHop;local AE=C.autoEgg;local TE=C.targetEgg
local CI=C.checkInt;local EI=C.eggInt;local FL=C.fixLag
local AR=C.autoRift;local SEL=C.selectedRifts or {};local PRIOR=C.riftPriority;local RDEL=C.riftDelay
local recent={};local riftRunning=false

-- FIX LAG
local GRAY=Color3.fromRGB(200,200,200);local lagConn=nil
local function isDyn(v)return v:FindFirstChildOfClass("Humanoid") or v:IsA("Tool") or v.Name:lower():find("pet") or v.Name:lower():find("drop") or v.Name:lower():find("coin") or v.Name:lower():find("orb")end
local function optObj(v)pcall(function()
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled=false
    elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
    elseif isDyn(v) then for _,p in pairs(v:GetDescendants())do if p:IsA("BasePart")then p.Transparency=1;p.CanCollide=false end end
    elseif v:IsA("BasePart") then v.Material=Enum.Material.SmoothPlastic;v.Color=GRAY;v.CastShadow=false end
end)end
local function applyLag()
    LT.GlobalShadows=false;LT.Brightness=2;LT.FogEnd=9e9
    for _,v in pairs(LT:GetDescendants())do pcall(function()if v:IsA("PostEffect")then v.Enabled=false end end)end
    local items=workspace:GetDescendants();local i=0
    task.spawn(function()
        for _,v in ipairs(items)do i=i+1;optObj(v);if i%200==0 then task.wait()end end
        if lagConn then lagConn:Disconnect()end
        lagConn=workspace.DescendantAdded:Connect(function(v)task.wait();optObj(v)end)
    end)
end
local function offLag()if lagConn then lagConn:Disconnect();lagConn=nil end;LT.GlobalShadows=true end

-- CLEAR OLD
local old=player.PlayerGui:FindFirstChild("NCGui");if old then old:Destroy()end
if not player.Character then player.CharacterAdded:Wait()end;task.wait(0.5)

-- GUI
local sg=Instance.new("ScreenGui");sg.Name="NCGui";sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;sg.Parent=player.PlayerGui

-- Toggle btn
local tF=Instance.new("Frame",sg);tF.Size=UDim2.new(0,52,0,52);tF.Position=UDim2.new(0,8,0.5,-26)
tF.BackgroundColor3=Color3.fromRGB(10,10,15);tF.BorderSizePixel=0;tF.ZIndex=20
Instance.new("UICorner",tF).CornerRadius=UDim.new(0.5,0)
Instance.new("UIStroke",tF).Color=Color3.fromRGB(80,80,100)
local tB=Instance.new("ImageButton",tF);tB.Size=UDim2.new(0.86,0,0.86,0);tB.Position=UDim2.new(0.07,0,0.07,0)
tB.BackgroundTransparency=1;tB.Image="rbxassetid://132832532598279";tB.ScaleType=Enum.ScaleType.Fit;tB.ZIndex=21
Instance.new("UICorner",tB).CornerRadius=UDim.new(0.5,0)

-- Main window
local WW,WH=600,440
local win=Instance.new("Frame",sg);win.Size=UDim2.new(0,WW,0,WH);win.Position=UDim2.new(0,C.x,0,C.y)
win.BackgroundColor3=Color3.fromRGB(10,10,14);win.BorderSizePixel=0;win.ZIndex=5
Instance.new("UICorner",win).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",win).Color=Color3.fromRGB(45,45,65)

-- Topbar
local tb=Instance.new("Frame",win);tb.Size=UDim2.new(1,0,0,44);tb.BackgroundColor3=Color3.fromRGB(15,15,22);tb.BorderSizePixel=0;tb.ZIndex=6
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,12)
local tbF2=Instance.new("Frame",tb);tbF2.Size=UDim2.new(1,0,0,12);tbF2.Position=UDim2.new(0,0,1,-12);tbF2.BackgroundColor3=Color3.fromRGB(15,15,22);tbF2.BorderSizePixel=0;tbF2.ZIndex=6
local acc=Instance.new("Frame",tb);acc.Size=UDim2.new(0,3,0.6,0);acc.Position=UDim2.new(0,10,0.2,0);acc.BackgroundColor3=Color3.fromRGB(130,80,255);acc.BorderSizePixel=0;acc.ZIndex=7
Instance.new("UICorner",acc).CornerRadius=UDim.new(0,2)
local tLbl=Instance.new("TextLabel",tb);tLbl.Size=UDim2.new(0,180,1,0);tLbl.Position=UDim2.new(0,18,0,0)
tLbl.BackgroundTransparency=1;tLbl.Text="NGUYEN CUTO";tLbl.TextColor3=Color3.fromRGB(255,255,255)
tLbl.TextScaled=true;tLbl.Font=Enum.Font.GothamBold;tLbl.TextXAlignment=Enum.TextXAlignment.Left;tLbl.ZIndex=7
local RB={Color3.fromRGB(255,80,80),Color3.fromRGB(255,160,0),Color3.fromRGB(255,255,60),Color3.fromRGB(60,255,100),Color3.fromRGB(60,180,255),Color3.fromRGB(150,60,255),Color3.fromRGB(255,60,200)}
local rci=1;task.spawn(function()while task.wait(0.22)do if tLbl and tLbl.Parent then tLbl.TextColor3=RB[rci];rci=rci%#RB+1 end end end)
local sub=Instance.new("TextLabel",tb);sub.Size=UDim2.new(0,200,0,14);sub.Position=UDim2.new(0,18,0,28)
sub.BackgroundTransparency=1;sub.Text="Catch a Monster • v8.0";sub.TextColor3=Color3.fromRGB(60,60,90)
sub.TextScaled=true;sub.Font=Enum.Font.Gotham;sub.TextXAlignment=Enum.TextXAlignment.Left;sub.ZIndex=7
local cB=Instance.new("TextButton",tb);cB.Size=UDim2.new(0,26,0,26);cB.Position=UDim2.new(1,-34,0.5,-13)
cB.BackgroundColor3=Color3.fromRGB(180,50,50);cB.TextColor3=Color3.fromRGB(255,255,255);cB.Text="✕"
cB.TextScaled=true;cB.Font=Enum.Font.GothamBold;cB.BorderSizePixel=0;cB.ZIndex=7
Instance.new("UICorner",cB).CornerRadius=UDim.new(0,6);cB.MouseButton1Click:Connect(function()win.Visible=false end)
local tDiv=Instance.new("Frame",win);tDiv.Size=UDim2.new(1,0,0,1);tDiv.Position=UDim2.new(0,0,0,44);tDiv.BackgroundColor3=Color3.fromRGB(35,35,55);tDiv.BorderSizePixel=0;tDiv.ZIndex=6

-- Tab bar
local tabBar=Instance.new("Frame",win);tabBar.Size=UDim2.new(1,0,0,36);tabBar.Position=UDim2.new(0,0,0,45)
tabBar.BackgroundColor3=Color3.fromRGB(13,13,20);tabBar.BorderSizePixel=0;tabBar.ZIndex=6
local tabL=Instance.new("UIListLayout",tabBar);tabL.FillDirection=Enum.FillDirection.Horizontal
tabL.HorizontalAlignment=Enum.HorizontalAlignment.Left;tabL.VerticalAlignment=Enum.VerticalAlignment.Center;tabL.Padding=UDim.new(0,3)
local tabP=Instance.new("UIPadding",tabBar);tabP.PaddingLeft=UDim.new(0,6);tabP.PaddingTop=UDim.new(0,3);tabP.PaddingBottom=UDim.new(0,3)
local tabDiv=Instance.new("Frame",win);tabDiv.Size=UDim2.new(1,0,0,1);tabDiv.Position=UDim2.new(0,0,0,81);tabDiv.BackgroundColor3=Color3.fromRGB(35,35,55);tabDiv.BorderSizePixel=0;tabDiv.ZIndex=6
local cont=Instance.new("Frame",win);cont.Size=UDim2.new(1,0,1,-82);cont.Position=UDim2.new(0,0,0,82);cont.BackgroundTransparency=1;cont.ClipsDescendants=true;cont.ZIndex=6

-- Page system
local pages={};local curTab=nil
local function showPage(n)for k,p in pairs(pages)do p.Visible=(k==n)end end
local function mkPage(n)
    local s=Instance.new("ScrollingFrame",cont);s.Size=UDim2.new(1,0,1,0);s.BackgroundTransparency=1;s.BorderSizePixel=0
    s.ScrollBarThickness=3;s.ScrollBarImageColor3=Color3.fromRGB(70,70,100);s.Visible=false;s.ZIndex=7
    local l=Instance.new("UIListLayout",s);l.Padding=UDim.new(0,5);l.SortOrder=Enum.SortOrder.LayoutOrder
    local p=Instance.new("UIPadding",s);p.PaddingLeft=UDim.new(0,10);p.PaddingRight=UDim.new(0,10);p.PaddingTop=UDim.new(0,8);p.PaddingBottom=UDim.new(0,8)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()s.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+16)end)
    pages[n]=s;return s
end
local ord={};local function no(n)ord[n]=(ord[n] or 0)+1;return ord[n]end

local function mkTab(lbl,icon,pg)
    local b=Instance.new("TextButton",tabBar);b.Size=UDim2.new(0,105,1,0);b.BackgroundColor3=Color3.fromRGB(20,20,30)
    b.TextColor3=Color3.fromRGB(150,150,175);b.Text=icon.."  "..lbl;b.TextScaled=true;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.ZIndex=7
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    b.MouseButton1Click:Connect(function()
        showPage(pg);if curTab then curTab.BackgroundColor3=Color3.fromRGB(20,20,30);curTab.TextColor3=Color3.fromRGB(150,150,175)end
        curTab=b;b.BackgroundColor3=Color3.fromRGB(130,80,255);b.TextColor3=Color3.fromRGB(255,255,255)
    end);return b
end

-- UI helpers
local function mkSec(pg,txt,col)
    local l=Instance.new("TextLabel",pages[pg]);l.Size=UDim2.new(1,0,0,20);l.BackgroundTransparency=1;l.Text=txt
    l.TextColor3=col or Color3.fromRGB(130,80,255);l.TextScaled=true;l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=8;l.LayoutOrder=no(pg)
end
local function mkStat(pg,txt)
    local l=Instance.new("TextLabel",pages[pg]);l.Size=UDim2.new(1,0,0,15);l.BackgroundTransparency=1;l.Text=txt
    l.TextColor3=Color3.fromRGB(140,140,165);l.TextScaled=true;l.Font=Enum.Font.Gotham
    l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=8;l.LayoutOrder=no(pg);return l
end
local function mkDiv(pg)
    local d=Instance.new("Frame",pages[pg]);d.Size=UDim2.new(1,0,0,1);d.BackgroundColor3=Color3.fromRGB(35,35,55);d.BorderSizePixel=0;d.ZIndex=8;d.LayoutOrder=no(pg)
end
local function mkRow(pg,h)
    local r=Instance.new("Frame",pages[pg]);r.Size=UDim2.new(1,0,0,h or 52);r.BackgroundColor3=Color3.fromRGB(17,17,25);r.BorderSizePixel=0;r.ZIndex=8;r.LayoutOrder=no(pg)
    Instance.new("UICorner",r).CornerRadius=UDim.new(0,8);Instance.new("UIStroke",r).Color=Color3.fromRGB(38,38,58);return r
end
local function rLbl(r,lbl,desc)
    local l=Instance.new("TextLabel",r);l.Size=UDim2.new(0.55,0,0,20);l.Position=UDim2.new(0,10,0,7)
    l.BackgroundTransparency=1;l.Text=lbl;l.TextColor3=Color3.fromRGB(230,230,255);l.TextScaled=true;l.Font=Enum.Font.GothamBold;l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=9
    if desc then
        local d=Instance.new("TextLabel",r);d.Size=UDim2.new(0.55,0,0,14);d.Position=UDim2.new(0,10,0,29)
        d.BackgroundTransparency=1;d.Text=desc;d.TextColor3=Color3.fromRGB(90,90,120);d.TextScaled=true;d.Font=Enum.Font.Gotham;d.TextXAlignment=Enum.TextXAlignment.Left;d.ZIndex=9
    end
end
local function mkToggle(pg,lbl,desc,init,col,cb)
    local r=mkRow(pg);rLbl(r,lbl,desc)
    local bg=Instance.new("Frame",r);bg.Size=UDim2.new(0,42,0,22);bg.Position=UDim2.new(1,-52,0.5,-11)
    bg.BackgroundColor3=init and col or Color3.fromRGB(45,45,60);bg.BorderSizePixel=0;bg.ZIndex=9
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0.5,0)
    local k=Instance.new("Frame",bg);k.Size=UDim2.new(0,16,0,16);k.Position=init and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    k.BackgroundColor3=Color3.fromRGB(255,255,255);k.BorderSizePixel=0;k.ZIndex=10
    Instance.new("UICorner",k).CornerRadius=UDim.new(0.5,0)
    local st=init
    local function tog()st=not st;TW:Create(bg,TweenInfo.new(0.15),{BackgroundColor3=st and col or Color3.fromRGB(45,45,60)}):Play();TW:Create(k,TweenInfo.new(0.15),{Position=st and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play();if cb then cb(st)end end
    r.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then tog()end end)
    return r,function()return st end
end
local function mkBtn(pg,lbl,desc,col,cb)
    local r=mkRow(pg);rLbl(r,lbl,desc)
    local b=Instance.new("TextButton",r);b.Size=UDim2.new(0,64,0,28);b.Position=UDim2.new(1,-74,0.5,-14)
    b.BackgroundColor3=col or Color3.fromRGB(130,80,255);b.TextColor3=Color3.fromRGB(255,255,255);b.Text="▶";b.TextScaled=true;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.ZIndex=9
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function()TW:Create(b,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play();task.wait(0.08);TW:Create(b,TweenInfo.new(0.08),{BackgroundColor3=col or Color3.fromRGB(130,80,255)}):Play();if cb then cb()end end)
    return b
end
local function mkInput(pg,lbl,desc,init,mn,mx,cb)
    local r=mkRow(pg);rLbl(r,lbl,desc)
    local b=Instance.new("TextBox",r);b.Size=UDim2.new(0,64,0,28);b.Position=UDim2.new(1,-74,0.5,-14)
    b.BackgroundColor3=Color3.fromRGB(22,22,34);b.TextColor3=Color3.fromRGB(255,215,80);b.Text=tostring(init);b.TextScaled=true;b.Font=Enum.Font.GothamBold;b.ClearTextOnFocus=false;b.BorderSizePixel=0;b.ZIndex=9
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",b).Color=Color3.fromRGB(80,80,120)
    b.FocusLost:Connect(function()local v=tonumber(b.Text);if v and v>=mn and v<=mx then if cb then cb(v)end;init=v else b.Text=tostring(init)end end);return b
end

-- RIFT DATA
local RIFTS={
    {id=71,name="Spirit Grove Rift",diff=1},{id=72,name="Spirit Grove Rift",diff=2},{id=73,name="Spirit Grove Rift",diff=3},
    {id=91,name="Blossom Haven Rift",diff=1},{id=92,name="Blossom Haven Rift",diff=2},{id=93,name="Blossom Haven Rift",diff=3},
    {id=41,name="Neverland Rift",diff=1},{id=42,name="Neverland Rift",diff=2},
    {id=61,name="Tideland Rift",diff=1},{id=62,name="Tideland Rift",diff=2},{id=63,name="Tideland Rift",diff=3},
    {id=21,name="Volcano Rift",diff=1},{id=22,name="Volcano Rift",diff=2},
    {id=51,name="Duneveil Isle Rift",diff=1},{id=52,name="Duneveil Isle Rift",diff=2},{id=53,name="Duneveil Isle Rift",diff=3},
    {id=83,name="Dragon's Breath Rift",diff=3},
    {id=10000,name="Strange Rift",diff=2},{id=10005,name="Chaos Rift",diff=2},{id=10006,name="Valentine's Rift",diff=3},
}
local diffStar={"★","★★","★★★"}
local diffCol={Color3.fromRGB(60,200,80),Color3.fromRGB(220,160,0),Color3.fromRGB(220,60,60)}

-- CREATE PAGES
mkPage("hop");mkPage("egg");mkPage("rift");mkPage("lag")
local t1=mkTab("Hop","⚡","hop");local t2=mkTab("Egg","🥚","egg");local t3=mkTab("Rift","🌀","rift");local t4=mkTab("Lag","⚙️","lag")

-- PAGE HOP
mkSec("hop","⚡  Hop Server",Color3.fromRGB(60,180,255))
local hStat=mkStat("hop","⏸  Sẵn sàng...")
local mStat=mkStat("hop","🔍  Kiểm tra monster...")
mkDiv("hop")
mkToggle("hop","Auto Hop","Hop khi không có monster",AH,Color3.fromRGB(0,155,215),function(v)AH=v;C.autoHop=v;saveS(C)end)
mkInput("hop","Check interval","Giây (1-60)",CI,1,60,function(v)CI=v;C.checkInt=v;saveS(C)end)
local hBtn=mkBtn("hop","Hop Ngay","Tìm server ít người",Color3.fromRGB(0,175,80),nil)

-- PAGE EGG
mkSec("egg","🥚  Auto Egg",Color3.fromRGB(255,175,0))
local eStat=mkStat("egg","🥚  Chờ...")
mkDiv("egg")
mkToggle("egg","Auto Egg","Tự ấp và lấy trứng",AE,Color3.fromRGB(200,100,0),function(v)AE=v;C.autoEgg=v;saveS(C)end)
mkInput("egg","Egg interval","Giây (1-30)",EI,1,30,function(v)EI=v;C.eggInt=v;saveS(C)end)
local eRow=mkRow("egg",52);rLbl(eRow,"Tên trứng","Gõ hoặc chọn nhanh")
local eBox=Instance.new("TextBox",eRow);eBox.Size=UDim2.new(0.44,0,0,28);eBox.Position=UDim2.new(0.54,0,0.5,-14)
eBox.BackgroundColor3=Color3.fromRGB(22,22,34);eBox.TextColor3=Color3.fromRGB(255,215,80);eBox.Text=TE;eBox.TextScaled=true;eBox.Font=Enum.Font.GothamBold;eBox.ClearTextOnFocus=false;eBox.BorderSizePixel=0;eBox.ZIndex=9
Instance.new("UICorner",eBox).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",eBox).Color=Color3.fromRGB(200,140,0)
eBox.FocusLost:Connect(function()TE=eBox.Text;C.targetEgg=TE;saveS(C);eStat.Text="🥚  Target: "..TE end)
local eggNames={"Blossom Egg","Rosette Egg","Gildron's Egg","Coral Egg","TideVex's Egg","Giant Tree Egg","Frostwyrm's Egg","Thunderclaw's Egg","GrassEgg","SwampEgg"}
local eHdr=Instance.new("TextLabel",pages["egg"]);eHdr.Size=UDim2.new(1,0,0,14);eHdr.BackgroundTransparency=1;eHdr.Text="Chọn nhanh:";eHdr.TextColor3=Color3.fromRGB(80,80,110);eHdr.TextScaled=true;eHdr.Font=Enum.Font.Gotham;eHdr.TextXAlignment=Enum.TextXAlignment.Left;eHdr.ZIndex=8;eHdr.LayoutOrder=no("egg")
local eSF=Instance.new("ScrollingFrame",pages["egg"]);eSF.Size=UDim2.new(1,0,0,80);eSF.BackgroundColor3=Color3.fromRGB(13,13,20);eSF.BorderSizePixel=0;eSF.ScrollBarThickness=3;eSF.CanvasSize=UDim2.new(0,0,0,#eggNames*25);eSF.ZIndex=8;eSF.LayoutOrder=no("egg")
Instance.new("UICorner",eSF).CornerRadius=UDim.new(0,8);Instance.new("UIStroke",eSF).Color=Color3.fromRGB(38,38,58)
local eSL=Instance.new("UIListLayout",eSF);eSL.Padding=UDim.new(0,2);local eSP=Instance.new("UIPadding",eSF);eSP.PaddingLeft=UDim.new(0,4);eSP.PaddingRight=UDim.new(0,4);eSP.PaddingTop=UDim.new(0,3)
local eSelB=nil
for _,name in ipairs(eggNames) do
    local isSel=name:lower()==TE:lower()
    local b=Instance.new("TextButton",eSF);b.Size=UDim2.new(1,0,0,22);b.BackgroundColor3=isSel and Color3.fromRGB(200,100,0) or Color3.fromRGB(20,20,30);b.TextColor3=isSel and Color3.fromRGB(255,255,255) or Color3.fromRGB(185,185,205);b.Text=(isSel and "✓  " or "    ")..name;b.TextScaled=true;b.Font=Enum.Font.Gotham;b.BorderSizePixel=0;b.TextXAlignment=Enum.TextXAlignment.Left;b.ZIndex=9
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5);if isSel then eSelB=b end
    b.MouseButton1Click:Connect(function()
        if eSelB then eSelB.BackgroundColor3=Color3.fromRGB(20,20,30);eSelB.TextColor3=Color3.fromRGB(185,185,205);eSelB.Text="    "..eSelB.Text:gsub("^✓  ","")end
        eSelB=b;b.BackgroundColor3=Color3.fromRGB(200,100,0);b.TextColor3=Color3.fromRGB(255,255,255);b.Text="✓  "..name
        TE=name;eBox.Text=name;C.targetEgg=name;saveS(C);eStat.Text="🥚  Target: "..name
    end)
end

-- PAGE RIFT
mkSec("rift","🌀  Auto Rift",Color3.fromRGB(150,80,255))
local rStat=mkStat("rift","🌀  Chờ khởi động...")
local rStat2=mkStat("rift","📋  Rift đã chọn: 0")
mkDiv("rift")
mkToggle("rift","Auto Rift","Tự động loop Rift",AR,Color3.fromRGB(130,60,220),function(v)AR=v;C.autoRift=v;saveS(C)end)
mkInput("rift","Delay giữa Rift","Giây (1-30)",RDEL,1,30,function(v)RDEL=v;C.riftDelay=v;saveS(C)end)

-- Priority selector
local prioRow=mkRow("rift",52);rLbl(prioRow,"Ưu tiên","nearest=gần nhất | highest=sao cao nhất | random")
local prioBtns={}
local prioFrame=Instance.new("Frame",prioRow);prioFrame.Size=UDim2.new(0,160,0,30);prioFrame.Position=UDim2.new(1,-170,0.5,-15);prioFrame.BackgroundTransparency=1;prioFrame.ZIndex=9
local prioL=Instance.new("UIListLayout",prioFrame);prioL.FillDirection=Enum.FillDirection.Horizontal;prioL.Padding=UDim.new(0,3)
for _,opt in ipairs({"near","high","rand"}) do
    local labels={near="📍Near",high="⬆High",rand="🎲Rand"}
    local isS=(PRIOR==opt)
    local pb=Instance.new("TextButton",prioFrame);pb.Size=UDim2.new(0,50,1,0);pb.BackgroundColor3=isS and Color3.fromRGB(130,80,255) or Color3.fromRGB(30,30,45);pb.TextColor3=Color3.fromRGB(255,255,255);pb.Text=labels[opt];pb.TextScaled=true;pb.Font=Enum.Font.GothamBold;pb.BorderSizePixel=0;pb.ZIndex=10
    Instance.new("UICorner",pb).CornerRadius=UDim.new(0,5);prioBtns[opt]=pb
    pb.MouseButton1Click:Connect(function()
        for k,b in pairs(prioBtns)do b.BackgroundColor3=Color3.fromRGB(30,30,45)end
        pb.BackgroundColor3=Color3.fromRGB(130,80,255);PRIOR=opt;C.riftPriority=opt;saveS(C)
    end)
end

-- Multi-select Rift list
local rHdr=Instance.new("TextLabel",pages["rift"]);rHdr.Size=UDim2.new(1,0,0,14);rHdr.BackgroundTransparency=1;rHdr.Text="Chọn Rift (có thể chọn nhiều):";rHdr.TextColor3=Color3.fromRGB(80,80,110);rHdr.TextScaled=true;rHdr.Font=Enum.Font.GothamBold;rHdr.TextXAlignment=Enum.TextXAlignment.Left;rHdr.ZIndex=8;rHdr.LayoutOrder=no("rift")
local rSF=Instance.new("ScrollingFrame",pages["rift"]);rSF.Size=UDim2.new(1,0,0,140);rSF.BackgroundColor3=Color3.fromRGB(13,13,20);rSF.BorderSizePixel=0;rSF.ScrollBarThickness=3;rSF.CanvasSize=UDim2.new(0,0,0,#RIFTS*27);rSF.ZIndex=8;rSF.LayoutOrder=no("rift")
Instance.new("UICorner",rSF).CornerRadius=UDim.new(0,8);Instance.new("UIStroke",rSF).Color=Color3.fromRGB(38,38,58)
local rSL=Instance.new("UIListLayout",rSF);rSL.Padding=UDim.new(0,2);local rSP=Instance.new("UIPadding",rSF);rSP.PaddingLeft=UDim.new(0,4);rSP.PaddingRight=UDim.new(0,4);rSP.PaddingTop=UDim.new(0,3)

-- Track selected rifts
local selRifts={}
for _,id in ipairs(SEL)do selRifts[id]=true end

local function updateSelCount()
    local n=0;for _ in pairs(selRifts)do n=n+1 end
    rStat2.Text="📋  Rift đã chọn: "..n
end

for _,rift in ipairs(RIFTS) do
    local isSel=selRifts[rift.id]==true
    local col=diffCol[rift.diff] or Color3.fromRGB(130,80,255)
    local b=Instance.new("TextButton",rSF);b.Size=UDim2.new(1,0,0,24)
    b.BackgroundColor3=isSel and Color3.fromRGB(50,30,80) or Color3.fromRGB(20,20,30)
    b.TextColor3=isSel and Color3.fromRGB(255,255,255) or Color3.fromRGB(185,185,205)
    b.Text=(isSel and "☑ " or "☐ ")..diffStar[rift.diff].."  "..rift.name
    b.TextScaled=true;b.Font=Enum.Font.Gotham;b.BorderSizePixel=0;b.TextXAlignment=Enum.TextXAlignment.Left;b.ZIndex=9
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    -- Star color indicator
    local dot=Instance.new("Frame",b);dot.Size=UDim2.new(0,4,0.6,0);dot.Position=UDim2.new(1,-8,0.2,0);dot.BackgroundColor3=col;dot.BorderSizePixel=0;dot.ZIndex=10
    Instance.new("UICorner",dot).CornerRadius=UDim.new(0,2)
    b.MouseButton1Click:Connect(function()
        selRifts[rift.id]=not selRifts[rift.id]
        local s=selRifts[rift.id]
        b.BackgroundColor3=s and Color3.fromRGB(50,30,80) or Color3.fromRGB(20,20,30)
        b.TextColor3=s and Color3.fromRGB(255,255,255) or Color3.fromRGB(185,185,205)
        b.Text=(s and "☑ " or "☐ ")..diffStar[rift.diff].."  "..rift.name
        local arr={};for id in pairs(selRifts)do if selRifts[id] then table.insert(arr,id)end end
        SEL=arr;C.selectedRifts=arr;saveS(C);updateSelCount()
    end)
end
updateSelCount()

mkDiv("rift")
local rBtn=mkBtn("rift","Start Rift","Tìm và join Rift đã chọn",Color3.fromRGB(130,60,220),nil)
mkBtn("rift","Dừng","Dừng auto rift",Color3.fromRGB(150,50,50),function()riftRunning=false;rStat.Text="⏹  Đã dừng"end)
mkDiv("rift")
-- DEBUG: Test nhanh arenaId=31
mkSec("rift","🧪  Debug Test",Color3.fromRGB(80,80,200))
local dbStat=mkStat("rift","📋  Sẵn sàng test...")
mkBtn("rift","Test ID=31","Thử join arenaId 31",Color3.fromRGB(40,80,200),function()
    task.spawn(function()
        if not ensureDS() then dbStat.Text="❌ Không load DS!";return end
        dbStat.Text="🔍 DS keys: "..tostring(DS2.DungeonJoinTeamChannel~=nil).." | "..tostring(DS2.DungeonStartChannel~=nil)
        task.wait(2)
        dbStat.Text="🚶 TP portal 31..."
        local ok,portal=tpToPortal(31)
        dbStat.Text=ok and "✅ Portal tìm thấy!" or "❌ Không có portal 31"
        task.wait(1)
        if ok and portal then
            local pr=findRiftPrompt(portal)
            dbStat.Text=pr and "✅ Prompt tìm thấy: "..pr.ActionText or "⚠️ Không thấy Prompt"
            task.wait(1)
            if pr then pcall(function()fireproximityprompt(pr)end);dbStat.Text="🔑 Fired prompt";task.wait(1)end
        end
        dbStat.Text="👥 Channel JoinTeam..."
        local r1=doChannel("DungeonJoinTeamChannel",31)
        task.wait(0.8)
        dbStat.Text="▶ Channel Start..."
        local r2=doChannel("DungeonStartChannel",31)
        task.wait(1.5)
        local entered=checkEntered(31)
        dbStat.Text="📊 JoinCh:"..tostring(r1).." StartCh:"..tostring(r2).." Entered:"..tostring(entered)
    end)
end)
mkBtn("rift","Leave 31","Thoát arenaId 31",Color3.fromRGB(120,40,40),function()task.spawn(function()leaveRift(31);dbStat.Text="🚪 Đã leave 31"end)end)

-- PAGE LAG
mkSec("lag","⚙️  Fix Lag",Color3.fromRGB(200,80,80))
mkStat("lag","Giữ map, ẩn rác, tắt effect")
mkDiv("lag")
mkToggle("lag","Fix Lag","Bật/tắt fix lag",FL,Color3.fromRGB(200,60,60),function(v)FL=v;C.fixLag=v;saveS(C);if v then applyLag()else offLag()end end)
mkBtn("lag","Áp dụng ngay","Chạy fix lag ngay",Color3.fromRGB(180,50,50),function()applyLag()end)

-- TOGGLE & DEFAULT TAB
tB.MouseButton1Click:Connect(function()win.Visible=not win.Visible end)
showPage("hop");curTab=t1;t1.BackgroundColor3=Color3.fromRGB(130,80,255);t1.TextColor3=Color3.fromRGB(255,255,255)

-- DRAG
local drg,dS,dP=false,nil,nil
local function clamp(x,y)local sw=workspace.CurrentCamera.ViewportSize.X;local sh=workspace.CurrentCamera.ViewportSize.Y;return math.clamp(x,0,sw-WW),math.clamp(y,0,sh-WH)end
tb.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=true;dS=i.Position;dP=win.Position end end)
UIS.InputChanged:Connect(function(i)if not drg then return end;if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-dS;local nx,ny=clamp(dP.X.Offset+d.X,dP.Y.Offset+d.Y);win.Position=UDim2.new(0,nx,0,ny)end end)
UIS.InputEnded:Connect(function(i)if(i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch)and drg then drg=false;C.x=win.Position.X.Offset;C.y=win.Position.Y.Offset;saveS(C)end end)

-- HOP LOGIC
local function isRec(id)for _,v in ipairs(recent)do if v==id then return true end end;return false end
local function addRec(id)table.insert(recent,1,id);if #recent>3 then table.remove(recent)end end
local function getSvr()local ok,r=pcall(function()return game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")end);if ok then return HS:JSONDecode(r)end;return nil end
local function hasMon()
    local ch=player.Character;if not ch then return false end;local rt=ch:FindFirstChild("HumanoidRootPart");if not rt then return false end
    for _,f in ipairs({workspace:FindFirstChild("Monsters"),workspace:FindFirstChild("ClientMonsters")})do
        if f then for _,o in ipairs(f:GetDescendants())do if o:IsA("Model")then local nm=o.Name:find("Monster_")~=nil;local hm=o:FindFirstChildOfClass("Humanoid")~=nil;if nm or hm then local r2=o:FindFirstChild("HumanoidRootPart") or o.PrimaryPart;if r2 and(rt.Position-r2.Position).Magnitude<=40 then return true end end end end end
    end;return false
end
local hop2=false
local function doHop()
    if hop2 then return end;hop2=true;hStat.Text="⏳  Đang tìm..."
    local d=getSvr();if not d or not d.data then hStat.Text="❌  Lỗi!";hop2=false;return end
    addRec(game.JobId)
    for _,s in ipairs(d.data)do if s.playing<5 and s.id~=game.JobId and not isRec(s.id)then hStat.Text="✅  Hop → "..s.playing.." người";task.wait(1);TS:TeleportToPlaceInstance(placeId,s.id,player);return end end
    hStat.Text="⚠️  Không tìm thấy!";hop2=false
end
hBtn.MouseButton1Click:Connect(doHop)
task.spawn(function()while task.wait(CI)do if not AH or hop2 then continue end;if hasMon()then mStat.Text="🐉  Có monster!";mStat.TextColor3=Color3.fromRGB(255,100,100)else mStat.Text="😴  Hop!";mStat.TextColor3=Color3.fromRGB(255,200,0);hStat.Text="🔄  Auto hop...";task.wait(2);doHop()end end end)

-- EGG LOGIC
local function getEggSys()
    local ok1,ES=pcall(function()return require(RS.CommonLogic.Egg.EggSystem)end);local ok2,EV=pcall(function()return require(RS.ClientLogic.Egg.EggSelectView)end);local ok3,IB=pcall(function()return require(RS.ClientLogic.Item.ItemBagView)end);local ok4,CE=pcall(function()return require(RS:FindFirstChild("CfgEgg",true))end);local ok5,VU=pcall(function()return require(RS:FindFirstChild("ViewUtil",true))end)
    if ok1 and ok2 and ok3 and ok4 and ok5 then return ES,EV,IB,CE,VU end;return nil
end
local function getTgt(gp,IB,CE)local l=IB._getSortedEggTmplIdList(gp);if #l==0 then return nil end;if TE and TE~=""then for _,id in ipairs(l)do local c=CE.Tmpls[id];if c and c.Name:lower():find(TE:lower())then return id end end;return nil end;return l[1]end
local function runEgg()
    local ES,EV,IB,CE,VU=getEggSys();if not ES then eStat.Text="❌  Lỗi!";return end;local gp=EV._GamePlayer;if not gp then return end
    for sl=1,5 do pcall(function()if not gp.egg:IsHatchUnlocked(sl)then return end;local eid=gp.egg:GetHatchEggTmplId(sl);if eid then local tl=(gp.egg:GetHatchEggStartTick(sl) or 0)+CE.Tmpls[eid].HatchTime-os.time();if tl<=0 then eStat.Text="🐣  Slot "..sl.." nở!";VU.DoRequest(ES.ClientHatchTaken,sl);task.wait(0.5);local nid=getTgt(gp,IB,CE);if nid then eStat.Text="🥚  Slot "..sl.." → "..CE.Tmpls[nid].Name;VU.DoRequest(ES.ClientHatchStart,sl,nid)end else eStat.Text="⏳  Slot "..sl.." còn "..math.floor(tl).."s"end else local nid=getTgt(gp,IB,CE);if nid then eStat.Text="🥚  Đặt slot "..sl;VU.DoRequest(ES.ClientHatchStart,sl,nid)else eStat.Text="❌  Không có: "..TE end end end);task.wait(0.3)end
end
task.spawn(function()task.wait(3);while task.wait(EI)do if AE then pcall(runEgg)end end end)

-- RIFT LOGIC
local CD2=nil;pcall(function()CD2=require(RS:FindFirstChild("CfgDungeon",true))end)
local DS2=nil;local VU2=nil
pcall(function()DS2=require(RS.CommonLogic.Arena.DungeonSystem)end)
pcall(function()VU2=require(RS:FindFirstChild("ViewUtil",true))end)
local function ensureDS()
    if not DS2 then pcall(function()DS2=require(RS.CommonLogic.Arena.DungeonSystem)end)end
    if not VU2 then pcall(function()VU2=require(RS:FindFirstChild("ViewUtil",true))end)end
    return DS2~=nil and VU2~=nil
end

-- Tìm ProximityPrompt "Enter the rift"
local function findRiftPrompt(model)
    for _,d in ipairs(model:GetDescendants())do
        if d:IsA("ProximityPrompt") and d.ActionText:lower():find("enter")then return d end
    end
    return nil
end

-- Xác nhận đã vào rift qua DungeonDataSetEnteredSync
local function checkEntered(arenaId)
    if not DS2 then return false end
    local ok,sync=pcall(function()return DS2.DungeonDataSetEnteredSync end)
    return ok and sync and sync[arenaId]==true
end

-- Lấy portal + vị trí cho arenaId
local function getPortalForRift(arenaId)
    local area=workspace:FindFirstChild("Area");if not area then return nil,nil end
    -- Ưu tiên CfgDungeon.EnterModel
    if CD2 then
        local cfg=CD2.Tmpls and CD2.Tmpls[arenaId]
        if cfg and cfg.EnterModel then
            for _,island in ipairs(area:GetChildren())do
                local ia=island:FindFirstChild("Area");if not ia then continue end
                local dg=ia:FindFirstChild("Dungeon");if not dg then continue end
                for _,dm in ipairs(dg:GetChildren())do
                    local p=dm:FindFirstChild(cfg.EnterModel)
                    if p then
                        local pos=nil
                        if p:IsA("BasePart")then pos=p.Position
                        elseif p.PrimaryPart then pos=p.PrimaryPart.Position
                        else for _,c in ipairs(p:GetDescendants())do if c:IsA("BasePart")then pos=c.Position;break end end end
                        if pos then return p,pos end
                    end
                end
            end
        end
    end
    -- Fallback: tìm object có ProximityPrompt ActionText "enter"
    for _,island in ipairs(area:GetChildren())do
        local ia=island:FindFirstChild("Area");if not ia then continue end
        local dg=ia:FindFirstChild("Dungeon");if not dg then continue end
        for _,dm in ipairs(dg:GetChildren())do
            for _,child in ipairs(dm:GetChildren())do
                if findRiftPrompt(child) then
                    local pos=nil
                    if child:IsA("BasePart")then pos=child.Position
                    elseif child.PrimaryPart then pos=child.PrimaryPart.Position
                    else for _,c in ipairs(child:GetDescendants())do if c:IsA("BasePart")then pos=c.Position;break end end end
                    if pos then return child,pos end
                end
            end
        end
    end
    return nil,nil
end

-- Chọn Rift tốt nhất
local function getBestRift()
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local candidates={}
    for _,rift in ipairs(RIFTS)do
        if selRifts[rift.id] then
            local _,pos=getPortalForRift(rift.id)
            if pos then
                local dist=root and (root.Position-pos).Magnitude or 999
                table.insert(candidates,{rift=rift,pos=pos,dist=dist})
            end
        end
    end
    if #candidates==0 then return nil,nil end
    if PRIOR=="near" then table.sort(candidates,function(a,b)return a.dist<b.dist end)
    elseif PRIOR=="high" then table.sort(candidates,function(a,b)return a.rift.diff>b.rift.diff end)
    else local i=math.random(1,#candidates);return candidates[i].rift,candidates[i].pos end
    return candidates[1].rift,candidates[1].pos
end

-- Teleport sát portal
local function tpToPortal(arenaId)
    local portal,pos=getPortalForRift(arenaId)
    if not pos then return false,nil end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false,nil end
    root.CFrame=CFrame.new(pos+Vector3.new(0,3,0))
    return true,portal
end

-- Gửi request qua Channel (cách đúng để giao tiếp server)
local function doChannel(key,...)
    if not ensureDS() then return false end
    -- Thử VU.DoRequest với Channel key trước
    local ok,res=pcall(function()return VU2.DoRequest(DS2[key],...)end)
    if ok and res then return true end
    -- Fallback: fire trực tiếp nếu là RemoteEvent
    local ok2,re=pcall(function()return DS2[key]end)
    if ok2 and re then
        if re:IsA("RemoteEvent")then pcall(function()re:FireServer(...)end);return true end
        if re:IsA("RemoteFunction")then local ok3,r=pcall(function()return re:InvokeServer(...)end);return ok3 and r end
    end
    return false
end

-- JOIN RIFT: teleport → ProximityPrompt → Channel Join → Channel Start
local function joinRift(arenaId)
    if not ensureDS() then rStat.Text="❌  Không load DungeonSystem!";return false end

    -- 1. Teleport sát portal
    rStat.Text="🚶  Đến portal "..arenaId.."..."
    local ok,portal=tpToPortal(arenaId)
    if not ok then rStat.Text="❌  Không tìm thấy portal!";return false end
    task.wait(1.5)

    -- 2. Fire ProximityPrompt (mở UI, dù mobile hay PC)
    if portal then
        local prompt=findRiftPrompt(portal)
        if prompt then
            rStat.Text="🔑  Fire ProximityPrompt..."
            pcall(function()fireproximityprompt(prompt)end)
            task.wait(0.8)
        end
    end

    -- 3. Tạo team qua DungeonJoinTeamChannel (channel key thực sự gửi server)
    rStat.Text="👥  CreateTeam (channel)..."
    doChannel("DungeonJoinTeamChannel",arenaId)
    task.wait(0.8)

    -- 4. Join team
    rStat.Text="🤝  JoinTeam (channel)..."
    doChannel("DungeonJoinTeamChannel",arenaId)
    task.wait(0.8)

    -- 5. Start dungeon qua DungeonStartChannel
    rStat.Text="▶  Start (channel)..."
    doChannel("DungeonStartChannel",arenaId)
    task.wait(1.5)

    -- 6. Xác nhận DungeonDataSetEnteredSync
    if checkEntered(arenaId) then rStat.Text="✅  Đã vào Rift!";return true end

    -- Retry: thử cả ClientCreateTeam + ClientStartDungeon phòng trường hợp tên key khác
    rStat.Text="🔄  Retry via Client keys..."
    pcall(function()VU2.DoRequest(DS2.ClientCreateTeam,arenaId)end);task.wait(0.5)
    pcall(function()VU2.DoRequest(DS2.ClientJoinTeam,arenaId)end);task.wait(0.5)
    pcall(function()VU2.DoRequest(DS2.ClientStartDungeon,arenaId)end);task.wait(1.5)
    return checkEntered(arenaId)
end

-- Leave Rift
local function leaveRift(arenaId)
    if not ensureDS() then return end
    rStat.Text="🚪  Thoát Rift..."
    doChannel("DungeonLeaveTeamChannel",arenaId)
    pcall(function()VU2.DoRequest(DS2.ClientLeaveTeam,arenaId)end)
end

-- Hop sau khi xong rift
local function hopForNewRift()
    -- Thử tìm rift trên server này trước
    local bestRift=getBestRift()
    if bestRift then
        rStat.Text="🔄  Tìm thấy Rift mới: "..bestRift.name
        return true -- Có rift trên server này
    end
    -- Không có → hop server
    rStat.Text="🌐  Hop server tìm Rift..."
    task.wait(2)
    local d=getSvr();if not d or not d.data then return false end
    addRec(game.JobId)
    for _,s in ipairs(d.data)do
        if s.playing<5 and s.id~=game.JobId and not isRec(s.id)then
            rStat.Text="✅  Hop → "..s.playing.." người"
            task.wait(1);TS:TeleportToPlaceInstance(placeId,s.id,player);return false
        end
    end
    rStat.Text="⚠️  Không tìm thấy server!";return false
end

-- Detect rift kết thúc
local function waitRiftEnd()
    local done=false
    local conn=player.PlayerGui.ChildAdded:Connect(function(child)
        if child.Name=="CatchDoGui" then done=true end
    end)
    -- Timeout 10 phút
    local t=0
    while not done and t<600 do task.wait(1);t=t+1 end
    pcall(function()conn:Disconnect()end)
    return done
end

-- MAIN RIFT LOOP
local function riftLoop()
    if riftRunning then rStat.Text="⏳  Đang chạy...";return end
    if not next(selRifts) then rStat.Text="⚠️  Chọn Rift trước!";return end
    riftRunning=true
    rStat.Text="🌀  Bắt đầu Rift loop..."

    while riftRunning do
        -- Tìm rift tốt nhất
        local bestRift,bestPos=getBestRift()
        if not bestRift then
            rStat.Text="❌  Không tìm thấy Rift trên map!"
            -- Hop server
            rStat.Text="🌐  Hop server..."
            doHop();task.wait(10)
            continue
        end

        rStat.Text="🎯  Target: "..bestRift.name.." "..diffStar[bestRift.diff]

        -- Join + Start (teleport → prompt → channel → xác nhận)
        local joined=joinRift(bestRift.id)
        if not joined then
            rStat.Text="❌  Join thất bại! Hop server..."
            task.wait(2);doHop();task.wait(10);continue
        end
        rStat.Text="⚔️  Trong Rift: "..bestRift.name

        -- Chờ kết thúc
        local finished=waitRiftEnd()
        if finished then
            rStat.Text="🏆  Xong! Chờ "..RDEL.."s..."
            task.wait(RDEL)
        end

        if not riftRunning then break end
    end

    rStat.Text="⏹  Đã dừng"
    riftRunning=false
end

rBtn.MouseButton1Click:Connect(function()task.spawn(riftLoop)end)

-- INIT
task.spawn(function()
    task.wait(5)
    if FL then applyLag()end
    if AR then task.wait(2);task.spawn(riftLoop)end
end)

print("✅ NGUYEN CUTO v8.0 - Ready!")
