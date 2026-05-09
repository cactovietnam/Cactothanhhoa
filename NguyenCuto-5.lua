-- NGUYEN CUTO v8.0 - Catch a Monster
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
local SF="NCv8.json"
local DEF={x=80,y=80,autoHop=false,autoEgg=true,targetEgg="Frostwyrm's Egg",checkInt=5,eggInt=15,fixLag=false,selRifts={},priority="near",autoRift=false,riftDelay=3}
local function loadS()
    local ok,c=pcall(readfile,SF)
    if ok and c and c~=""then
        local ok2,d=pcall(function()return HS:JSONDecode(c)end)
        if ok2 and d then for k,v in pairs(DEF)do if d[k]==nil then d[k]=v end end;return d end
    end;return DEF
end
local function saveS(s)pcall(writefile,SF,HS:JSONEncode(s))end
local C=loadS()

-- ===== STATE =====
local AH=C.autoHop;local AE=C.autoEgg;local TE=C.targetEgg
local CI=C.checkInt;local EI=C.eggInt;local FL=C.fixLag
local AR=C.autoRift;local RDEL=C.riftDelay;local PRIOR=C.priority
local selRifts={};for _,id in ipairs(C.selRifts or {})do selRifts[id]=true end
local recent={};local riftRunning=false

-- ===== FIX LAG =====
local GRAY=Color3.fromRGB(200,200,200);local lagConn=nil
local function isDyn(v)return v:FindFirstChildOfClass("Humanoid") or v:IsA("Tool") or v.Name:lower():find("pet") or v.Name:lower():find("drop") or v.Name:lower():find("coin")end
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
    task.spawn(function()for _,v in ipairs(items)do i=i+1;optObj(v);if i%200==0 then task.wait()end end
        if lagConn then lagConn:Disconnect()end
        lagConn=workspace.DescendantAdded:Connect(function(v)task.wait();optObj(v)end)
    end)
    print("✅ Fix Lag!")
end
local function offLag()if lagConn then lagConn:Disconnect();lagConn=nil end;LT.GlobalShadows=true end

-- ===== CLEAR OLD GUI =====
local oldG=player.PlayerGui:FindFirstChild("NCGui");if oldG then oldG:Destroy()end
if not player.Character then player.CharacterAdded:Wait()end;task.wait(0.5)

-- ===== SCREEN GUI =====
local sg=Instance.new("ScreenGui");sg.Name="NCGui";sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;sg.Parent=player.PlayerGui

-- ===== NÚT MỞ =====
local tF=Instance.new("Frame",sg);tF.Size=UDim2.new(0,52,0,52);tF.Position=UDim2.new(0,8,0.5,-26);tF.BackgroundColor3=Color3.fromRGB(10,10,15);tF.BorderSizePixel=0;tF.ZIndex=20
Instance.new("UICorner",tF).CornerRadius=UDim.new(0.5,0);Instance.new("UIStroke",tF).Color=Color3.fromRGB(80,80,100)
local tB=Instance.new("ImageButton",tF);tB.Size=UDim2.new(0.86,0,0.86,0);tB.Position=UDim2.new(0.07,0,0.07,0);tB.BackgroundTransparency=1;tB.Image="rbxassetid://132832532598279";tB.ScaleType=Enum.ScaleType.Fit;tB.ZIndex=21
Instance.new("UICorner",tB).CornerRadius=UDim.new(0.5,0)

-- ===== WINDOW =====
local WW,WH=600,460
local win=Instance.new("Frame",sg);win.Size=UDim2.new(0,WW,0,WH);win.Position=UDim2.new(0,C.x,0,C.y);win.BackgroundColor3=Color3.fromRGB(10,10,14);win.BorderSizePixel=0;win.ZIndex=5
Instance.new("UICorner",win).CornerRadius=UDim.new(0,12);Instance.new("UIStroke",win).Color=Color3.fromRGB(45,45,65)

-- TOPBAR
local tb=Instance.new("Frame",win);tb.Size=UDim2.new(1,0,0,44);tb.BackgroundColor3=Color3.fromRGB(15,15,22);tb.BorderSizePixel=0;tb.ZIndex=6
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,12)
local tbFix=Instance.new("Frame",tb);tbFix.Size=UDim2.new(1,0,0,12);tbFix.Position=UDim2.new(0,0,1,-12);tbFix.BackgroundColor3=Color3.fromRGB(15,15,22);tbFix.BorderSizePixel=0;tbFix.ZIndex=6
local acc=Instance.new("Frame",tb);acc.Size=UDim2.new(0,3,0.6,0);acc.Position=UDim2.new(0,10,0.2,0);acc.BackgroundColor3=Color3.fromRGB(130,80,255);acc.BorderSizePixel=0;acc.ZIndex=7
Instance.new("UICorner",acc).CornerRadius=UDim.new(0,2)
local tLbl=Instance.new("TextLabel",tb);tLbl.Size=UDim2.new(0.6,0,1,0);tLbl.Position=UDim2.new(0,18,0,0);tLbl.BackgroundTransparency=1;tLbl.Text="✦ NGUYEN CUTO ✦";tLbl.TextColor3=Color3.fromRGB(255,255,255);tLbl.TextScaled=true;tLbl.Font=Enum.Font.GothamBold;tLbl.TextXAlignment=Enum.TextXAlignment.Left;tLbl.ZIndex=7
local RB={Color3.fromRGB(255,80,80),Color3.fromRGB(255,160,0),Color3.fromRGB(255,255,60),Color3.fromRGB(60,255,100),Color3.fromRGB(60,180,255),Color3.fromRGB(150,60,255),Color3.fromRGB(255,60,200)}
local rci=1;task.spawn(function()while task.wait(0.22)do if tLbl and tLbl.Parent then tLbl.TextColor3=RB[rci];rci=rci%#RB+1 end end end)
local cB=Instance.new("TextButton",tb);cB.Size=UDim2.new(0,26,0,26);cB.Position=UDim2.new(1,-34,0.5,-13);cB.BackgroundColor3=Color3.fromRGB(180,50,50);cB.TextColor3=Color3.fromRGB(255,255,255);cB.Text="✕";cB.TextScaled=true;cB.Font=Enum.Font.GothamBold;cB.BorderSizePixel=0;cB.ZIndex=7
Instance.new("UICorner",cB).CornerRadius=UDim.new(0,6);cB.MouseButton1Click:Connect(function()win.Visible=false end)
Instance.new("Frame",win).Size=UDim2.new(1,0,0,1);local d1=win:FindFirstChildOfClass("Frame");if d1 then d1.Position=UDim2.new(0,0,0,44);d1.BackgroundColor3=Color3.fromRGB(35,35,55);d1.BorderSizePixel=0;d1.ZIndex=6 end

-- TAB BAR
local tabBar=Instance.new("Frame",win);tabBar.Size=UDim2.new(1,0,0,38);tabBar.Position=UDim2.new(0,0,0,45);tabBar.BackgroundColor3=Color3.fromRGB(13,13,20);tabBar.BorderSizePixel=0;tabBar.ZIndex=6
local tabL=Instance.new("UIListLayout",tabBar);tabL.FillDirection=Enum.FillDirection.Horizontal;tabL.HorizontalAlignment=Enum.HorizontalAlignment.Left;tabL.VerticalAlignment=Enum.VerticalAlignment.Center;tabL.Padding=UDim.new(0,4)
local tabPad=Instance.new("UIPadding",tabBar);tabPad.PaddingLeft=UDim.new(0,8);tabPad.PaddingTop=UDim.new(0,4);tabPad.PaddingBottom=UDim.new(0,4)
local tabD=Instance.new("Frame",win);tabD.Size=UDim2.new(1,0,0,1);tabD.Position=UDim2.new(0,0,0,83);tabD.BackgroundColor3=Color3.fromRGB(35,35,55);tabD.BorderSizePixel=0;tabD.ZIndex=6

-- CONTENT
local cont=Instance.new("Frame",win);cont.Size=UDim2.new(1,0,1,-84);cont.Position=UDim2.new(0,0,0,84);cont.BackgroundTransparency=1;cont.ClipsDescendants=true;cont.ZIndex=6

-- ===== PAGE SYSTEM =====
local pages={};local curTab=nil
local function showPage(n)for k,p in pairs(pages)do p.Visible=(k==n)end end
local function mkPage(n)
    local s=Instance.new("ScrollingFrame",cont);s.Size=UDim2.new(1,0,1,0);s.BackgroundTransparency=1;s.BorderSizePixel=0;s.ScrollBarThickness=3;s.ScrollBarImageColor3=Color3.fromRGB(70,70,100);s.Visible=false;s.ZIndex=7
    local l=Instance.new("UIListLayout",s);l.Padding=UDim.new(0,6);l.SortOrder=Enum.SortOrder.LayoutOrder
    local p=Instance.new("UIPadding",s);p.PaddingLeft=UDim.new(0,10);p.PaddingRight=UDim.new(0,10);p.PaddingTop=UDim.new(0,10);p.PaddingBottom=UDim.new(0,10)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()s.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+20)end)
    pages[n]=s;return s
end
local ord={};local function no(n)ord[n]=(ord[n] or 0)+1;return ord[n]end

-- TAB BUTTON
local function mkTab(lbl,icon,pg)
    local b=Instance.new("TextButton",tabBar);b.Size=UDim2.new(0,108,1,0);b.BackgroundColor3=Color3.fromRGB(22,22,32);b.TextColor3=Color3.fromRGB(140,140,170);b.Text=icon.."  "..lbl;b.TextScaled=true;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.ZIndex=7
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    b.MouseButton1Click:Connect(function()
        showPage(pg)
        if curTab then curTab.BackgroundColor3=Color3.fromRGB(22,22,32);curTab.TextColor3=Color3.fromRGB(140,140,170)end
        curTab=b;b.BackgroundColor3=Color3.fromRGB(130,80,255);b.TextColor3=Color3.fromRGB(255,255,255)
    end);return b
end

-- ===== UI HELPERS =====
local function mkSec(pg,txt,col)
    local l=Instance.new("TextLabel",pages[pg]);l.Size=UDim2.new(1,0,0,22);l.BackgroundColor3=Color3.fromRGB(20,20,32);l.Text="  "..txt;l.TextColor3=col or Color3.fromRGB(130,80,255);l.TextScaled=true;l.Font=Enum.Font.GothamBold;l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=8;l.LayoutOrder=no(pg)
    Instance.new("UICorner",l).CornerRadius=UDim.new(0,6)
end
local function mkStat(pg,txt)
    local l=Instance.new("TextLabel",pages[pg]);l.Size=UDim2.new(1,0,0,16);l.BackgroundTransparency=1;l.Text="  "..txt;l.TextColor3=Color3.fromRGB(130,130,160);l.TextScaled=true;l.Font=Enum.Font.Gotham;l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=8;l.LayoutOrder=no(pg);return l
end
local function mkDiv(pg)
    local d=Instance.new("Frame",pages[pg]);d.Size=UDim2.new(1,0,0,1);d.BackgroundColor3=Color3.fromRGB(35,35,55);d.BorderSizePixel=0;d.ZIndex=8;d.LayoutOrder=no(pg)
end
local function mkRow(pg,h)
    local r=Instance.new("Frame",pages[pg]);r.Size=UDim2.new(1,0,0,h or 54);r.BackgroundColor3=Color3.fromRGB(18,18,26);r.BorderSizePixel=0;r.ZIndex=8;r.LayoutOrder=no(pg)
    Instance.new("UICorner",r).CornerRadius=UDim.new(0,8);local s=Instance.new("UIStroke",r);s.Color=Color3.fromRGB(38,38,58);s.Thickness=1;return r
end
local function rLbl(r,lbl,desc)
    local l=Instance.new("TextLabel",r);l.Size=UDim2.new(0.54,0,0,22);l.Position=UDim2.new(0,12,0,7);l.BackgroundTransparency=1;l.Text=lbl;l.TextColor3=Color3.fromRGB(230,230,255);l.TextScaled=true;l.Font=Enum.Font.GothamBold;l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=9
    if desc then
        local d=Instance.new("TextLabel",r);d.Size=UDim2.new(0.54,0,0,14);d.Position=UDim2.new(0,12,0,31);d.BackgroundTransparency=1;d.Text=desc;d.TextColor3=Color3.fromRGB(80,80,110);d.TextScaled=true;d.Font=Enum.Font.Gotham;d.TextXAlignment=Enum.TextXAlignment.Left;d.ZIndex=9
    end
end
local function mkToggle(pg,lbl,desc,init,col,cb)
    local r=mkRow(pg);rLbl(r,lbl,desc)
    local bg=Instance.new("Frame",r);bg.Size=UDim2.new(0,44,0,24);bg.Position=UDim2.new(1,-54,0.5,-12);bg.BackgroundColor3=init and col or Color3.fromRGB(45,45,60);bg.BorderSizePixel=0;bg.ZIndex=9
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0.5,0)
    local k=Instance.new("Frame",bg);k.Size=UDim2.new(0,18,0,18);k.Position=init and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9);k.BackgroundColor3=Color3.fromRGB(255,255,255);k.BorderSizePixel=0;k.ZIndex=10
    Instance.new("UICorner",k).CornerRadius=UDim.new(0.5,0)
    local st=init
    local function tog()st=not st;TW:Create(bg,TweenInfo.new(0.15),{BackgroundColor3=st and col or Color3.fromRGB(45,45,60)}):Play();TW:Create(k,TweenInfo.new(0.15),{Position=st and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play();if cb then cb(st)end end
    r.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then tog()end end)
end
local function mkBtn(pg,lbl,desc,col,cb)
    local r=mkRow(pg);rLbl(r,lbl,desc)
    local b=Instance.new("TextButton",r);b.Size=UDim2.new(0,68,0,30);b.Position=UDim2.new(1,-78,0.5,-15);b.BackgroundColor3=col or Color3.fromRGB(130,80,255);b.TextColor3=Color3.fromRGB(255,255,255);b.Text="▶ Go";b.TextScaled=true;b.Font=Enum.Font.GothamBold;b.BorderSizePixel=0;b.ZIndex=9
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function()TW:Create(b,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play();task.wait(0.08);TW:Create(b,TweenInfo.new(0.08),{BackgroundColor3=col or Color3.fromRGB(130,80,255)}):Play();if cb then cb()end end)
    return b
end
local function mkInput(pg,lbl,desc,init,mn,mx,cb)
    local r=mkRow(pg);rLbl(r,lbl,desc)
    local b=Instance.new("TextBox",r);b.Size=UDim2.new(0,68,0,30);b.Position=UDim2.new(1,-78,0.5,-15);b.BackgroundColor3=Color3.fromRGB(22,22,34);b.TextColor3=Color3.fromRGB(255,215,80);b.Text=tostring(init);b.TextScaled=true;b.Font=Enum.Font.GothamBold;b.ClearTextOnFocus=false;b.BorderSizePixel=0;b.ZIndex=9
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",b).Color=Color3.fromRGB(80,80,120)
    b.FocusLost:Connect(function()local v=tonumber(b.Text);if v and v>=mn and v<=mx then if cb then cb(v)end;init=v else b.Text=tostring(init)end end);return b
end

-- ===== RIFT DATA =====
local RIFTS={
    {id=71,name="Spirit Grove I",diff=1},{id=72,name="Spirit Grove II",diff=2},{id=73,name="Spirit Grove III",diff=3},
    {id=91,name="Blossom Haven I",diff=1},{id=92,name="Blossom Haven II",diff=2},{id=93,name="Blossom Haven III",diff=3},
    {id=41,name="Neverland I",diff=1},{id=42,name="Neverland II",diff=2},
    {id=61,name="Tideland I",diff=1},{id=62,name="Tideland II",diff=2},{id=63,name="Tideland III",diff=3},
    {id=21,name="Volcano I",diff=1},{id=22,name="Volcano II",diff=2},
    {id=51,name="Duneveil Isle I",diff=1},{id=52,name="Duneveil Isle II",diff=2},{id=53,name="Duneveil Isle III",diff=3},
    {id=83,name="Dragon's Breath III",diff=3},
    {id=10000,name="Strange Rift",diff=2},{id=10005,name="Chaos Rift",diff=2},{id=10006,name="Valentine's Rift",diff=3},
}
local DIFF_STAR={"⭐","⭐⭐","⭐⭐⭐"}
local DIFF_COL={Color3.fromRGB(60,200,80),Color3.fromRGB(220,160,0),Color3.fromRGB(220,60,60)}

-- ===== CREATE PAGES =====
mkPage("hop");mkPage("egg");mkPage("rift");mkPage("lag")
local t1=mkTab("Hop","⚡","hop")
local t2=mkTab("Egg","🥚","egg")
local t3=mkTab("Rift","🌀","rift")
local t4=mkTab("Lag","⚙️","lag")

-- ===== PAGE: HOP =====
mkSec("hop","⚡  Hop Server",Color3.fromRGB(0,180,255))
local hStat=mkStat("hop","⏸  Sẵn sàng hop...")
local mStat=mkStat("hop","🔍  Kiểm tra monster...")
mkDiv("hop")
mkToggle("hop","Auto Hop","Tự động hop khi không có monster",AH,Color3.fromRGB(0,150,220),function(v)AH=v;C.autoHop=v;saveS(C)end)
mkInput("hop","Check interval","Thời gian kiểm tra (1-60 giây)",CI,1,60,function(v)CI=v;C.checkInt=v;saveS(C)end)
local hBtn=mkBtn("hop","Hop Ngay","Tìm server ít người và teleport",Color3.fromRGB(0,175,80),nil)

-- ===== PAGE: EGG =====
mkSec("egg","🥚  Auto Egg",Color3.fromRGB(255,175,0))
local eStat=mkStat("egg","🥚  Đang chờ...")
mkDiv("egg")
mkToggle("egg","Auto Egg","Tự động ấp và lấy trứng",AE,Color3.fromRGB(200,100,0),function(v)AE=v;C.autoEgg=v;saveS(C)end)
mkInput("egg","Egg interval","Thời gian kiểm tra (1-30 giây)",EI,1,30,function(v)EI=v;C.eggInt=v;saveS(C)end)
-- Egg name input
local eRow=mkRow("egg",54);rLbl(eRow,"Tên trứng","Gõ tên hoặc chọn bên dưới")
local eBox=Instance.new("TextBox",eRow);eBox.Size=UDim2.new(0.44,0,0,30);eBox.Position=UDim2.new(0.54,0,0.5,-15);eBox.BackgroundColor3=Color3.fromRGB(22,22,34);eBox.TextColor3=Color3.fromRGB(255,215,80);eBox.Text=TE;eBox.TextScaled=true;eBox.Font=Enum.Font.GothamBold;eBox.ClearTextOnFocus=false;eBox.BorderSizePixel=0;eBox.ZIndex=9
Instance.new("UICorner",eBox).CornerRadius=UDim.new(0,6);Instance.new("UIStroke",eBox).Color=Color3.fromRGB(200,140,0)
eBox.FocusLost:Connect(function()TE=eBox.Text;C.targetEgg=TE;saveS(C);eStat.Text="🥚  Target: "..TE end)
-- Egg quick select
local eHdr=Instance.new("TextLabel",pages["egg"]);eHdr.Size=UDim2.new(1,0,0,16);eHdr.BackgroundTransparency=1;eHdr.Text="  Chọn nhanh:";eHdr.TextColor3=Color3.fromRGB(100,100,130);eHdr.TextScaled=true;eHdr.Font=Enum.Font.GothamBold;eHdr.TextXAlignment=Enum.TextXAlignment.Left;eHdr.ZIndex=8;eHdr.LayoutOrder=no("egg")
local eSF=Instance.new("ScrollingFrame",pages["egg"]);eSF.Size=UDim2.new(1,0,0,85);eSF.BackgroundColor3=Color3.fromRGB(14,14,22);eSF.BorderSizePixel=0;eSF.ScrollBarThickness=3;eSF.CanvasSize=UDim2.new(0,0,0,230);eSF.ZIndex=8;eSF.LayoutOrder=no("egg")
Instance.new("UICorner",eSF).CornerRadius=UDim.new(0,8);Instance.new("UIStroke",eSF).Color=Color3.fromRGB(38,38,58)
local eSL=Instance.new("UIListLayout",eSF);eSL.Padding=UDim.new(0,2);local eSP=Instance.new("UIPadding",eSF);eSP.PaddingLeft=UDim.new(0,5);eSP.PaddingRight=UDim.new(0,5);eSP.PaddingTop=UDim.new(0,4)
local eSelB=nil
local eggNames={"Blossom Egg","Rosette Egg","Gildron's Egg","Coral Egg","TideVex's Egg","Giant Tree Egg","Frostwyrm's Egg","Thunderclaw's Egg","GrassEgg","SwampEgg"}
for _,name in ipairs(eggNames) do
    local isSel=name:lower()==TE:lower()
    local b=Instance.new("TextButton",eSF);b.Size=UDim2.new(1,0,0,22);b.BackgroundColor3=isSel and Color3.fromRGB(180,90,0) or Color3.fromRGB(22,22,32);b.TextColor3=isSel and Color3.fromRGB(255,255,200) or Color3.fromRGB(185,185,210);b.Text=(isSel and "✓  " or "  ")..name;b.TextScaled=true;b.Font=Enum.Font.Gotham;b.BorderSizePixel=0;b.TextXAlignment=Enum.TextXAlignment.Left;b.ZIndex=9
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5);if isSel then eSelB=b end
    b.MouseButton1Click:Connect(function()
        if eSelB then eSelB.BackgroundColor3=Color3.fromRGB(22,22,32);eSelB.TextColor3=Color3.fromRGB(185,185,210);eSelB.Text="  "..eSelB.Text:gsub("^✓  ","")end
        eSelB=b;b.BackgroundColor3=Color3.fromRGB(180,90,0);b.TextColor3=Color3.fromRGB(255,255,200);b.Text="✓  "..name
        TE=name;eBox.Text=name;C.targetEgg=name;saveS(C);eStat.Text="🥚  Target: "..name
    end)
end

-- ===== PAGE: RIFT =====
mkSec("rift","🌀  Auto Rift",Color3.fromRGB(150,80,255))
local rStat=mkStat("rift","🌀  Chờ khởi động...")
local rSelCount=mkStat("rift","📋  Đã chọn: 0 Rift")
mkDiv("rift")

-- Toggle + delay
mkToggle("rift","Auto Rift","Tự động loop tìm và vào Rift",AR,Color3.fromRGB(130,60,220),function(v)AR=v;C.autoRift=v;saveS(C)end)
mkInput("rift","Delay giữa Rift","Thời gian nghỉ giữa các lần (1-30s)",RDEL,1,30,function(v)RDEL=v;C.riftDelay=v;saveS(C)end)

-- Priority row
local prRow=mkRow("rift",54);rLbl(prRow,"Ưu tiên chọn","📍 Gần nhất  ⬆ Sao cao  🎲 Ngẫu nhiên")
local prFrame=Instance.new("Frame",prRow);prFrame.Size=UDim2.new(0,165,0,32);prFrame.Position=UDim2.new(1,-175,0.5,-16);prFrame.BackgroundTransparency=1;prFrame.ZIndex=9
local prLayout=Instance.new("UIListLayout",prFrame);prLayout.FillDirection=Enum.FillDirection.Horizontal;prLayout.Padding=UDim.new(0,4);prLayout.VerticalAlignment=Enum.VerticalAlignment.Center
local prBtns={}
for _,opt in ipairs({{"near","📍Near"},{"high","⬆High"},{"rand","🎲Rand"}}) do
    local key,lbl=opt[1],opt[2];local isS=(PRIOR==key)
    local pb=Instance.new("TextButton",prFrame);pb.Size=UDim2.new(0,52,0,28);pb.BackgroundColor3=isS and Color3.fromRGB(130,80,255) or Color3.fromRGB(30,30,45);pb.TextColor3=Color3.fromRGB(255,255,255);pb.Text=lbl;pb.TextScaled=true;pb.Font=Enum.Font.GothamBold;pb.BorderSizePixel=0;pb.ZIndex=10
    Instance.new("UICorner",pb).CornerRadius=UDim.new(0,5);prBtns[key]=pb
    pb.MouseButton1Click:Connect(function()for k,b in pairs(prBtns)do b.BackgroundColor3=Color3.fromRGB(30,30,45)end;pb.BackgroundColor3=Color3.fromRGB(130,80,255);PRIOR=key;C.priority=key;saveS(C)end)
end

-- Rift multi-select list
local rListHdr=Instance.new("TextLabel",pages["rift"]);rListHdr.Size=UDim2.new(1,0,0,18);rListHdr.BackgroundColor3=Color3.fromRGB(20,20,32);rListHdr.Text="  🗂  Chọn Rift (chọn nhiều được):";rListHdr.TextColor3=Color3.fromRGB(150,80,255);rListHdr.TextScaled=true;rListHdr.Font=Enum.Font.GothamBold;rListHdr.TextXAlignment=Enum.TextXAlignment.Left;rListHdr.ZIndex=8;rListHdr.LayoutOrder=no("rift")
Instance.new("UICorner",rListHdr).CornerRadius=UDim.new(0,5)

local rSF=Instance.new("ScrollingFrame",pages["rift"]);rSF.Size=UDim2.new(1,0,0,150);rSF.BackgroundColor3=Color3.fromRGB(14,14,22);rSF.BorderSizePixel=0;rSF.ScrollBarThickness=3;rSF.ScrollBarImageColor3=Color3.fromRGB(100,60,200);rSF.CanvasSize=UDim2.new(0,0,0,#RIFTS*28);rSF.ZIndex=8;rSF.LayoutOrder=no("rift")
Instance.new("UICorner",rSF).CornerRadius=UDim.new(0,8);Instance.new("UIStroke",rSF).Color=Color3.fromRGB(60,40,100)
local rSLayout=Instance.new("UIListLayout",rSF);rSLayout.Padding=UDim.new(0,2)
local rSPad=Instance.new("UIPadding",rSF);rSPad.PaddingLeft=UDim.new(0,5);rSPad.PaddingRight=UDim.new(0,5);rSPad.PaddingTop=UDim.new(0,4)

local function updateSelCount()
    local n=0;for _ in pairs(selRifts)do n=n+1 end
    rSelCount.Text="  📋  Đã chọn: "..n.." Rift"
end

for _,rift in ipairs(RIFTS) do
    local isSel=selRifts[rift.id]==true
    local dc=DIFF_COL[rift.diff] or Color3.fromRGB(130,80,255)
    local b=Instance.new("TextButton",rSF);b.Size=UDim2.new(1,0,0,25)
    b.BackgroundColor3=isSel and Color3.fromRGB(45,25,80) or Color3.fromRGB(20,20,30)
    b.TextColor3=isSel and Color3.fromRGB(220,180,255) or Color3.fromRGB(170,170,200)
    b.Text=(isSel and "  ☑  " or "  ☐  ")..DIFF_STAR[rift.diff].."  "..rift.name
    b.TextScaled=true;b.Font=Enum.Font.Gotham;b.BorderSizePixel=0;b.TextXAlignment=Enum.TextXAlignment.Left;b.ZIndex=9
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    -- Diff color bar
    local dot=Instance.new("Frame",b);dot.Size=UDim2.new(0,4,0.65,0);dot.Position=UDim2.new(1,-9,0.175,0);dot.BackgroundColor3=dc;dot.BorderSizePixel=0;dot.ZIndex=10
    Instance.new("UICorner",dot).CornerRadius=UDim.new(0,2)
    b.MouseButton1Click:Connect(function()
        selRifts[rift.id]=not selRifts[rift.id]
        local s=selRifts[rift.id]
        b.BackgroundColor3=s and Color3.fromRGB(45,25,80) or Color3.fromRGB(20,20,30)
        b.TextColor3=s and Color3.fromRGB(220,180,255) or Color3.fromRGB(170,170,200)
        b.Text=(s and "  ☑  " or "  ☐  ")..DIFF_STAR[rift.diff].."  "..rift.name
        local arr={};for id,v in pairs(selRifts)do if v then table.insert(arr,id)end end
        C.selRifts=arr;saveS(C);updateSelCount()
    end)
end
updateSelCount()
mkDiv("rift")

-- Start/Stop buttons
local rStartBtn=mkBtn("rift","▶ Start","Bắt đầu auto Rift loop",Color3.fromRGB(130,60,220),nil)
local rStopBtn=mkBtn("rift","⏹ Stop","Dừng auto Rift",Color3.fromRGB(150,50,50),function()riftRunning=false;rStat.Text="⏹  Đã dừng"end)

-- ===== PAGE: LAG =====
mkSec("lag","⚙️  Fix Lag",Color3.fromRGB(200,80,80))
mkStat("lag","Giữ nguyên map, ẩn rác/effect")
mkDiv("lag")
mkToggle("lag","Fix Lag","Bật/tắt toàn bộ fix lag",FL,Color3.fromRGB(200,60,60),function(v)FL=v;C.fixLag=v;saveS(C);if v then applyLag()else offLag()end end)
mkBtn("lag","Áp dụng ngay","Chạy fix lag ngay lập tức",Color3.fromRGB(180,50,50),function()applyLag()end)

-- ===== TOGGLE WINDOW =====
tB.MouseButton1Click:Connect(function()win.Visible=not win.Visible end)
showPage("hop");curTab=t1;t1.BackgroundColor3=Color3.fromRGB(130,80,255);t1.TextColor3=Color3.fromRGB(255,255,255)

-- ===== DRAG =====
local drg,dS,dP=false,nil,nil
local function clamp(x,y)local sw=workspace.CurrentCamera.ViewportSize.X;local sh=workspace.CurrentCamera.ViewportSize.Y;return math.clamp(x,0,sw-WW),math.clamp(y,0,sh-WH)end
tb.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=true;dS=i.Position;dP=win.Position end end)
UIS.InputChanged:Connect(function(i)if not drg then return end;if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-dS;local nx,ny=clamp(dP.X.Offset+d.X,dP.Y.Offset+d.Y);win.Position=UDim2.new(0,nx,0,ny)end end)
UIS.InputEnded:Connect(function(i)if(i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch)and drg then drg=false;C.x=win.Position.X.Offset;C.y=win.Position.Y.Offset;saveS(C)end end)

-- ===== HOP LOGIC =====
local function isRec(id)for _,v in ipairs(recent)do if v==id then return true end end;return false end
local function addRec(id)table.insert(recent,1,id);if #recent>3 then table.remove(recent)end end
local function getSvr()local ok,r=pcall(function()return game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")end);if ok then return HS:JSONDecode(r)end;return nil end
local function hasMon()
    local ch=player.Character;if not ch then return false end;local rt=ch:FindFirstChild("HumanoidRootPart");if not rt then return false end
    for _,f in ipairs({workspace:FindFirstChild("Monsters"),workspace:FindFirstChild("ClientMonsters")})do
        if f then for _,o in ipairs(f:GetDescendants())do if o:IsA("Model")then local hm=o:FindFirstChildOfClass("Humanoid")~=nil;local nm=o.Name:find("Monster_")~=nil;if nm or hm then local r2=o:FindFirstChild("HumanoidRootPart") or o.PrimaryPart;if r2 and(rt.Position-r2.Position).Magnitude<=40 then return true end end end end end
    end;return false
end
local hopBusy=false
local function doHop()
    if hopBusy then return end;hopBusy=true;hStat.Text="⏳  Đang tìm..."
    local d=getSvr();if not d or not d.data then hStat.Text="❌  Lỗi server!";hopBusy=false;return end
    addRec(game.JobId)
    for _,s in ipairs(d.data)do if s.playing<5 and s.id~=game.JobId and not isRec(s.id)then hStat.Text="✅  Hop → "..s.playing.." người";task.wait(1);TS:TeleportToPlaceInstance(placeId,s.id,player);return end end
    hStat.Text="⚠️  Không tìm thấy!";hopBusy=false
end
hBtn.MouseButton1Click:Connect(doHop)
task.spawn(function()while task.wait(CI)do if not AH or hopBusy then continue end;if hasMon()then mStat.Text="🐉  Có monster!";mStat.TextColor3=Color3.fromRGB(255,100,100)else mStat.Text="😴  Không có monster!";mStat.TextColor3=Color3.fromRGB(255,200,0);task.wait(2);doHop()end end end)

-- ===== EGG LOGIC =====
local function getES()
    local ok1,ES=pcall(function()return require(RS.CommonLogic.Egg.EggSystem)end);local ok2,EV=pcall(function()return require(RS.ClientLogic.Egg.EggSelectView)end);local ok3,IB=pcall(function()return require(RS.ClientLogic.Item.ItemBagView)end);local ok4,CE=pcall(function()return require(RS:FindFirstChild("CfgEgg",true))end);local ok5,VU=pcall(function()return require(RS:FindFirstChild("ViewUtil",true))end)
    if ok1 and ok2 and ok3 and ok4 and ok5 then return ES,EV,IB,CE,VU end;return nil
end
local function getTgt(gp,IB,CE)local l=IB._getSortedEggTmplIdList(gp);if #l==0 then return nil end;if TE and TE~=""then for _,id in ipairs(l)do local c=CE.Tmpls[id];if c and c.Name:lower():find(TE:lower())then return id end end;return nil end;return l[1]end
local function runEgg()
    local ES,EV,IB,CE,VU=getES();if not ES then eStat.Text="❌  Lỗi!";return end;local gp=EV._GamePlayer;if not gp then return end
    for sl=1,5 do pcall(function()if not gp.egg:IsHatchUnlocked(sl)then return end;local eid=gp.egg:GetHatchEggTmplId(sl);if eid then local tl=(gp.egg:GetHatchEggStartTick(sl) or 0)+CE.Tmpls[eid].HatchTime-os.time();if tl<=0 then eStat.Text="🐣  Slot "..sl.." nở!";VU.DoRequest(ES.ClientHatchTaken,sl);task.wait(0.5);local nid=getTgt(gp,IB,CE);if nid then eStat.Text="🥚  Slot "..sl;VU.DoRequest(ES.ClientHatchStart,sl,nid)end else eStat.Text="⏳  Slot "..sl.." còn "..math.floor(tl).."s"end else local nid=getTgt(gp,IB,CE);if nid then eStat.Text="🥚  Đặt slot "..sl;VU.DoRequest(ES.ClientHatchStart,sl,nid)else eStat.Text="❌  Không có: "..TE end end end);task.wait(0.3)end
end
task.spawn(function()task.wait(3);while task.wait(EI)do if AE then pcall(runEgg)end end end)

-- ===== RIFT LOGIC =====
local CD2=nil;pcall(function()CD2=require(RS:FindFirstChild("CfgDungeon",true))end)
local enterFunc2=RS:FindFirstChild("BossRoomEnterFunc",true)

local function getPortalPos(arenaId)
    if not CD2 then return nil end
    local cfg=CD2.Tmpls[arenaId];if not cfg then return nil end
    local area=workspace:FindFirstChild("Area");if not area then return nil end
    for _,island in ipairs(area:GetChildren())do
        local ia=island:FindFirstChild("Area");if not ia then continue end
        local dg=ia:FindFirstChild("Dungeon");if not dg then continue end
        for _,dm in ipairs(dg:GetChildren())do
            local portal=dm:FindFirstChild(cfg.EnterModel)
            if portal then
                local pos=nil
                if portal:IsA("BasePart") then pos=portal.Position
                elseif portal.PrimaryPart then pos=portal.PrimaryPart.Position
                else for _,p in ipairs(portal:GetDescendants())do if p:IsA("BasePart")then pos=p.Position;break end end end
                if pos then return pos end
            end
        end
    end
    return nil
end

local function getBestRift()
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local cands={}
    for _,rift in ipairs(RIFTS)do
        if selRifts[rift.id] then
            local pos=getPortalPos(rift.id)
            if pos then
                local dist=root and (root.Position-pos).Magnitude or 9999
                table.insert(cands,{rift=rift,pos=pos,dist=dist})
            end
        end
    end
    if #cands==0 then return nil,nil end
    if PRIOR=="near" then table.sort(cands,function(a,b)return a.dist<b.dist end)
    elseif PRIOR=="high" then table.sort(cands,function(a,b)return a.rift.diff>b.rift.diff end)
    else local i=math.random(1,#cands);return cands[i].rift,cands[i].pos end
    return cands[1].rift,cands[1].pos
end

local function joinRift(arenaId)
    if not enterFunc2 then rStat.Text="❌  Không có enterFunc!";return false end
    local pos=getPortalPos(arenaId)
    if not pos then rStat.Text="❌  Không tìm thấy portal!";return false end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    rStat.Text="🚶  Teleport đến portal..."
    root.CFrame=CFrame.new(pos+Vector3.new(0,4,0))
    task.wait(2)
    rStat.Text="🌀  Join Rift..."
    local ok,res=pcall(function()return enterFunc2:InvokeServer(arenaId)end)
    if ok and res then return true end
    task.wait(1.5)
    local ok2,res2=pcall(function()return enterFunc2:InvokeServer(arenaId)end)
    return ok2 and res2
end

local function startRift(arenaId)
    local ok,DS=pcall(function()return require(RS.CommonLogic.Arena.DungeonSystem)end)
    local ok2,VU=pcall(function()return require(RS:FindFirstChild("ViewUtil",true))end)
    if not ok or not ok2 then return false end
    local _,res=pcall(function()return VU.DoRequest(DS.ClientStartDungeon,arenaId)end)
    return res
end

local function waitRiftEnd()
    -- Win khi CatchDoGui xuất hiện
    local done = false
    local conn = player.PlayerGui.ChildAdded:Connect(function(c)
        if c.Name == "CatchDoGui" then
            done = true
            print("🏆 CatchDoGui detected = Rift WIN!")
        end
    end)
    -- Timeout 10 phút
    local t = 0
    while not done and t < 600 and riftRunning do
        task.wait(1); t = t + 1
    end
    pcall(function() conn:Disconnect() end)

    if done then
        -- Chờ CatchDoGui đóng rồi auto leave
        task.wait(2)
        rStat.Text = "📤  Auto Leave Rift..."
        -- Fire BossRoomLeaveEvent
        local leaveEvent = RS:FindFirstChild("BossRoomLeaveEvent", true)
        if leaveEvent then
            pcall(function() leaveEvent:FireServer() end)
            print("✅ Fired BossRoomLeaveEvent")
        end
        task.wait(3) -- Chờ về map
    end
    return done
end

local function riftLoop()
    if riftRunning then rStat.Text = "⏳  Đang chạy!"; return end
    if not next(selRifts) then rStat.Text = "⚠️  Chưa chọn Rift nào!"; return end
    riftRunning = true
    rStat.Text = "🌀  Bắt đầu Rift loop..."

    while riftRunning do
        -- Tìm rift tốt nhất
        local bestRift, bestPos = getBestRift()
        if not bestRift then
            rStat.Text = "🌐  Không có Rift → Hop server..."
            doHop()
            task.wait(10)
            continue
        end

        rStat.Text = "🎯  " .. bestRift.name .. " " .. DIFF_STAR[bestRift.diff]
        task.wait(1)

        -- Join Rift (teleport + invoke)
        local joined = joinRift(bestRift.id)
        if not joined then
            rStat.Text = "❌  Join thất bại! Thử lại sau 5s..."
            task.wait(5)
            continue
        end
        task.wait(1)

        -- Start Rift
        rStat.Text = "▶  Start Rift..."
        local started = startRift(bestRift.id)
        if started then
            rStat.Text = "⚔️  Trong Rift: " .. bestRift.name .. " " .. DIFF_STAR[bestRift.diff]
        else
            rStat.Text = "⚠️  Start chưa được - đang chờ..."
        end

        -- Chờ win (CatchDoGui)
        local won = waitRiftEnd()

        if not riftRunning then break end

        if won then
            rStat.Text = "🏆  Win! Nghỉ " .. RDEL .. "s..."
            task.wait(RDEL)
        else
            -- Timeout → để tiếp tục loop
            rStat.Text = "⏱️  Timeout, thử Rift khác..."
            task.wait(3)
        end
    end

    rStat.Text = "⏹  Đã dừng"
    riftRunning = false
end

rStartBtn.MouseButton1Click:Connect(function()task.spawn(riftLoop)end)

task.spawn(function()
    task.wait(5);if FL then applyLag()end
    if AR then task.wait(2);task.spawn(riftLoop)end
end)

print("✅ NGUYEN CUTO v8.0 - Ready!")
