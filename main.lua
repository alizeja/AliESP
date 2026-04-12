local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Connections = {}
local chms = false

--=========================================GENERAL FUNCS OK===========================================================--

function notif(text, title, dur, btn1, btn2)
    StarterGui:SetCore("SendNotification", {
        Text = text;
        Title = title or "ESP";
        Duration = dur or 5;
        Button1 = btn1 or nil;
        Button2 = btn2 or nil;
    })
end

local function getChar(player)
    return player.Character or player.CharacterAdded:Wait()
end
local function getHuman(char)
    return char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 2)
end
local function getRoot(char, humanoid)
    if not humanoid then humanoid = getHuman(char) end
    return char:FindFirstChild("HumanoidRootPart") or (humanoid and humanoid.RootPart) or char:WaitForChild("HumanoidRootPart", 2)
end
local function getRigType(char)
    return char:FindFirstChild("UpperTorso") and "R15"
            or char:FindFirstChild("Torso") and "R6"
            or nil
end
local function sameTeam(player, allyTeams: table)
    local localTeam = LocalPlayer.Team
    local plrTeam = player.Team

    if LocalPlayer.Neutral or player.Neutral then
        return false
    elseif localTeam == plrTeam or table.find(allyTeams, plrTeam) ~= nil then
        return true
    else
        return false
    end
end
local function isDead(player)
    local char = getChar(player)
    local humanoid = char and getHuman(char)

    return char == nil
        or humanoid == nil
        or humanoid:GetState() == Enum.HumanoidStateType.Dead
        or humanoid.Health <= 0
end

--==========================================================================================================================================================--
local function createUICorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function createSliderTrack(parent)
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, -20, 0, 8)
	track.Position = UDim2.new(0, 10, 0, 30)
	track.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	track.BorderSizePixel = 1
	track.BorderColor3 = Color3.fromRGB(27, 42, 53)
	track.Parent = parent
	createUICorner(track, 4)
	
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.new(0, 0.75, 0.75)
	fill.BorderSizePixel = 0
	fill.Parent = track
	createUICorner(fill, 4)
	
	local handle = Instance.new("TextButton")
	handle.Name = "Handle"
	handle.Size = UDim2.new(0, 20, 0, 20)
	handle.Position = UDim2.new(0, -10, 0.5, -10)
	handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	handle.BorderSizePixel = 0
	handle.Text = ""
	handle.Parent = track
	createUICorner(handle, 100)
	
	local currentVal = Instance.new("TextLabel")
	currentVal.Parent = handle
	currentVal.Name = "CurrentVal"
	currentVal.Size = UDim2.new(0, 50, 0, 20)
	currentVal.Position = UDim2.new(-1.225, 10, 1.277, -10)
	currentVal.BackgroundTransparency = 1
	currentVal.Text = ""
	currentVal.TextColor3 = Color3.fromRGB(255, 255, 255)
	currentVal.TextSize = 14
	currentVal.Font = Enum.Font.Montserrat
	
	return track, fill, handle, currentVal
end

local function createToggleButton(parent, name, text, position, size)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = size or UDim2.new(0, 125, 0, 30)
	btn.Position = position
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 0, 0)
	btn.TextSize = 20
	btn.Font = Enum.Font.Montserrat
	btn.Parent = parent
	createUICorner(btn, 8)
	return btn
end

if CoreGui:FindFirstChild("AliESP") then
    CoreGui:FindFirstChild("AliESP"):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AliESP"
screenGui.ResetOnSpawn = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

local esp = Instance.new("Frame")
esp.Name = "ESP"
esp.Size = UDim2.new(0, 300, 0, 300)
esp.Position = UDim2.new(0.407, 0, 0.289, 0)
esp.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
esp.BorderSizePixel = 0
esp.ZIndex = 200
esp.Parent = screenGui
createUICorner(esp, 15)

local espLabel = Instance.new("TextLabel")
espLabel.Name = "Label"
espLabel.Size = UDim2.new(1, 0, 0, 20)
espLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
espLabel.BorderSizePixel = 0
espLabel.Text = "ESP"
espLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
espLabel.TextSize = 14
espLabel.Font = Enum.Font.Montserrat
espLabel.TextScaled = true
espLabel.Parent = esp
createUICorner(espLabel, 15)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollingFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, -30)
scrollFrame.Position = UDim2.new(0, 0, 0, 30)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
scrollFrame.ZIndex = 100
scrollFrame.Parent = esp

local toggleBtn = createToggleButton(scrollFrame, "Toggle", "Disabled", UDim2.new(0.033, 0, 0, 5), UDim2.new(0, 280, 0, 30))

local highlightsBtn = createToggleButton(scrollFrame, "Highlights", "Highlights", UDim2.new(0.033, 0, 0, 50))
local tracersBtn = createToggleButton(scrollFrame, "Tracers", "Tracers", UDim2.new(0.55, 0, 0, 50))
local boxesBtn = createToggleButton(scrollFrame, "Boxes", "Boxes", UDim2.new(0.033, 0, 0, 100))
local skeletonBtn = createToggleButton(scrollFrame, "Skeleton", "Skeleton", UDim2.new(0.55, 0, 0, 100))
local namesBtn = createToggleButton(scrollFrame, "Names", "Names", UDim2.new(0.033, 0, 0, 150))
local distanceBtn = createToggleButton(scrollFrame, "Distance", "Distance", UDim2.new(0.55, 0, 0, 150))
local healthBtn = createToggleButton(scrollFrame, "Health", "Health", UDim2.new(0.033, 0, 0, 200))
local chamsBtn = createToggleButton(scrollFrame, "CHAMS", "CHAMS", UDim2.new(0.55, 0, 0, 200))

local settingsBtn = Instance.new("TextButton")
settingsBtn.Name = "Settings"
settingsBtn.Size = UDim2.new(0, 280, 0, 30)
settingsBtn.Position = UDim2.new(0.033, 0, 0, 250)
settingsBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
settingsBtn.BorderSizePixel = 0
settingsBtn.Text = "ESP Settings"
settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsBtn.TextSize = 20
settingsBtn.Font = Enum.Font.Montserrat
settingsBtn.Parent = scrollFrame
createUICorner(settingsBtn, 8)

local settings = Instance.new("Frame")
settings.Name = "Settings"
settings.Size = UDim2.new(0, 300, 0, 300)
settings.Position = UDim2.fromScale(0, 0)
settings.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
settings.BorderSizePixel = 0
settings.ZIndex = 0
settings.Visible = false
settings.Parent = esp
createUICorner(settings, 15)
local startSettingsPos = settings.Position
local realSettingsPos = UDim2.new(1, 1, 0, 0)

local settingsLabel = Instance.new("TextLabel")
settingsLabel.Name = "Label"
settingsLabel.Size = UDim2.new(1, 0, 0, 20)
settingsLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
settingsLabel.BorderSizePixel = 0
settingsLabel.Text = "Settings"
settingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsLabel.TextSize = 14
settingsLabel.Font = Enum.Font.Montserrat
settingsLabel.TextScaled = true
settingsLabel.Parent = settings
createUICorner(settingsLabel, 15)

local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Name = "ScrollingFrame"
settingsScroll.Size = UDim2.new(1, 0, 1, -30)
settingsScroll.Position = UDim2.new(0, 0, 0, 30)
settingsScroll.BackgroundTransparency = 1
settingsScroll.ScrollBarThickness = 5
settingsScroll.ZIndex = 0
settingsScroll.CanvasSize = UDim2.new(0, 0, 2, 0)
settingsScroll.Visible = false
settingsScroll.Parent = settings

local maxDistSlider = Instance.new("Frame")
maxDistSlider.Name = "MaxDistSlider"
maxDistSlider.Size = UDim2.new(0, 280, 0, 60)
maxDistSlider.Position = UDim2.new(0.033, 0, 0, 5)
maxDistSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
maxDistSlider.BorderSizePixel = 1
maxDistSlider.BorderColor3 = Color3.fromRGB(0, 0, 0)
maxDistSlider.ZIndex = 0
maxDistSlider.Parent = settingsScroll
createUICorner(maxDistSlider, 8)

local maxDistLabel = Instance.new("TextLabel")
maxDistLabel.Name = "Label"
maxDistLabel.Size = UDim2.new(1, 0, 0, 20)
maxDistLabel.BackgroundTransparency = 1
maxDistLabel.Text = "Max Detection Distance"
maxDistLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
maxDistLabel.TextSize = 14
maxDistLabel.Font = Enum.Font.Montserrat
maxDistLabel.Parent = maxDistSlider

local maxDistValMin = Instance.new("TextLabel")
maxDistValMin.Name = "ValMin"
maxDistValMin.Size = UDim2.new(0, 50, 0, 20)
maxDistValMin.Position = UDim2.new(0, 10, 0.4, -10)
maxDistValMin.BackgroundTransparency = 1
maxDistValMin.Text = "500"
maxDistValMin.TextColor3 = Color3.fromRGB(255, 255, 255)
maxDistValMin.TextSize = 14
maxDistValMin.Font = Enum.Font.Montserrat
maxDistValMin.TextXAlignment = Enum.TextXAlignment.Left
maxDistValMin.Parent = maxDistSlider

local maxDistValMax = Instance.new("TextLabel")
maxDistValMax.Name = "ValMax"
maxDistValMax.Size = UDim2.new(0, 50, 0, 20)
maxDistValMax.Position = UDim2.new(0.75, 10, 0.4, -10)
maxDistValMax.BackgroundTransparency = 1
maxDistValMax.Text = "2500"
maxDistValMax.TextColor3 = Color3.fromRGB(255, 255, 255)
maxDistValMax.TextSize = 14
maxDistValMax.Font = Enum.Font.Montserrat
maxDistValMax.TextXAlignment = Enum.TextXAlignment.Right
maxDistValMax.Parent = maxDistSlider

local maxDistTrack,maxDistFill,maxDistHandle,maxDistCurrentVal = createSliderTrack(maxDistSlider)

local distCutoff = Instance.new("Frame")
distCutoff.Name = "DistCutoff"
distCutoff.Size = UDim2.new(0, 280, 0, 60)
distCutoff.Position = UDim2.new(0.033, 0, 0, 75)
distCutoff.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
distCutoff.BorderSizePixel = 1
distCutoff.BorderColor3 = Color3.fromRGB(0, 0, 0)
distCutoff.ZIndex = 0
distCutoff.Parent = settingsScroll
createUICorner(distCutoff, 8)

local cutoffLabel = Instance.new("TextLabel")
cutoffLabel.Name = "Label"
cutoffLabel.Size = UDim2.new(1, 0, 0, 20)
cutoffLabel.BackgroundTransparency = 1
cutoffLabel.Text = "Cutoff Distance"
cutoffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cutoffLabel.TextSize = 14
cutoffLabel.Font = Enum.Font.Montserrat
cutoffLabel.Parent = distCutoff

local cutoffValMin = Instance.new("TextLabel")
cutoffValMin.Name = "ValMin"
cutoffValMin.Size = UDim2.new(0, 50, 0, 20)
cutoffValMin.Position = UDim2.new(0, 10, 0.4, -10)
cutoffValMin.BackgroundTransparency = 1
cutoffValMin.Text = "750"
cutoffValMin.TextColor3 = Color3.fromRGB(255, 255, 255)
cutoffValMin.TextSize = 14
cutoffValMin.Font = Enum.Font.Montserrat
cutoffValMin.TextXAlignment = Enum.TextXAlignment.Left
cutoffValMin.Parent = distCutoff

local cutoffValMax = Instance.new("TextLabel")
cutoffValMax.Name = "ValMax"
cutoffValMax.Size = UDim2.new(0, 50, 0, 20)
cutoffValMax.Position = UDim2.new(0.75, 10, 0.4, -10)
cutoffValMax.BackgroundTransparency = 1
cutoffValMax.Text = "1500"
cutoffValMax.TextColor3 = Color3.fromRGB(255, 255, 255)
cutoffValMax.TextSize = 14
cutoffValMax.Font = Enum.Font.Montserrat
cutoffValMax.TextXAlignment = Enum.TextXAlignment.Right
cutoffValMax.Parent = distCutoff

local cutoffTrack,cutoffFill,cutoffHandle,cutoffCurrentVal = createSliderTrack(distCutoff)

local chmsTrans = Instance.new("Frame")
chmsTrans.Name = "CHMSTransparency"
chmsTrans.Size = UDim2.new(0, 280, 0, 60)
chmsTrans.Position = UDim2.new(0.033, 0, 0, 145)
chmsTrans.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
chmsTrans.BorderSizePixel = 1
chmsTrans.BorderColor3 = Color3.fromRGB(0, 0, 0)
chmsTrans.ZIndex = 0
chmsTrans.Parent = settingsScroll
createUICorner(chmsTrans, 8)

local chmsLabel = Instance.new("TextLabel")
chmsLabel.Name = "Label"
chmsLabel.Size = UDim2.new(1, 0, 0, 20)
chmsLabel.BackgroundTransparency = 1
chmsLabel.Text = "Highlight and CHAMS Transparency"
chmsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
chmsLabel.TextSize = 14
chmsLabel.Font = Enum.Font.Montserrat
chmsLabel.Parent = chmsTrans

local chmsValMin = Instance.new("TextLabel")
chmsValMin.Name = "ValMin"
chmsValMin.Size = UDim2.new(0, 50, 0, 20)
chmsValMin.Position = UDim2.new(0, 10, 0.4, -10)
chmsValMin.BackgroundTransparency = 1
chmsValMin.Text = "0"
chmsValMin.TextColor3 = Color3.fromRGB(255, 255, 255)
chmsValMin.TextSize = 14
chmsValMin.Font = Enum.Font.Montserrat
chmsValMin.TextXAlignment = Enum.TextXAlignment.Left
chmsValMin.Parent = chmsTrans

local chmsValMax = Instance.new("TextLabel")
chmsValMax.Name = "ValMax"
chmsValMax.Size = UDim2.new(0, 50, 0, 20)
chmsValMax.Position = UDim2.new(0.75, 10, 0.4, -10)
chmsValMax.BackgroundTransparency = 1
chmsValMax.Text = "1"
chmsValMax.TextColor3 = Color3.fromRGB(255, 255, 255)
chmsValMax.TextSize = 14
chmsValMax.Font = Enum.Font.Montserrat
chmsValMax.TextXAlignment = Enum.TextXAlignment.Right
chmsValMax.Parent = chmsTrans

local chmsTrack,chmsFill,chmsHandle,chmsCurrentVal = createSliderTrack(chmsTrans)

local tracerSettings = Instance.new("Frame")
tracerSettings.Name = "TracerSettings"
tracerSettings.Size = UDim2.new(0, 280, 0, 180)
tracerSettings.Position = UDim2.new(0.033, 0, 0, 215)
tracerSettings.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tracerSettings.BorderSizePixel = 0
tracerSettings.ZIndex = 0
tracerSettings.Parent = settingsScroll
createUICorner(tracerSettings, 8)

local tracerLabel = Instance.new("TextLabel")
tracerLabel.Name = "Label"
tracerLabel.Size = UDim2.new(1, 0, 0, 20)
tracerLabel.BackgroundTransparency = 1
tracerLabel.Text = "Tracer Settings"
tracerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
tracerLabel.TextSize = 14
tracerLabel.Font = Enum.Font.Montserrat
tracerLabel.Parent = tracerSettings

local mouseBtn = Instance.new("TextButton")
mouseBtn.Name = "Mouse"
mouseBtn.Size = UDim2.new(0, 114, 0, 35)
mouseBtn.Position = UDim2.new(0.035, 0, 0.15, 0)
mouseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mouseBtn.BorderSizePixel = 0
mouseBtn.Text = "From Mouse"
mouseBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
mouseBtn.TextSize = 16
mouseBtn.Font = Enum.Font.Montserrat
mouseBtn.Parent = tracerSettings
createUICorner(mouseBtn, 8)

local charBtn = Instance.new("TextButton")
charBtn.Name = "Character"
charBtn.Size = UDim2.new(0, 114, 0, 35)
charBtn.Position = UDim2.new(0.56, 0, 0.15, 0)
charBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
charBtn.BorderSizePixel = 0
charBtn.Text = "From Character"
charBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
charBtn.TextSize = 16
charBtn.Font = Enum.Font.Montserrat
charBtn.Parent = tracerSettings
createUICorner(charBtn, 8)

local centerBtn = Instance.new("TextButton")
centerBtn.Name = "Center"
centerBtn.Size = UDim2.new(0, 114, 0, 35)
centerBtn.Position = UDim2.new(0.035, 0, 0.4, 0)
centerBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
centerBtn.BorderSizePixel = 0
centerBtn.Text = "From Screen Center"
centerBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
centerBtn.TextSize = 14
centerBtn.Font = Enum.Font.Montserrat
centerBtn.TextWrapped = true
centerBtn.Parent = tracerSettings
createUICorner(centerBtn, 8)

local bottomBtn = Instance.new("TextButton")
bottomBtn.Name = "Bottom"
bottomBtn.Size = UDim2.new(0, 114, 0, 35)
bottomBtn.Position = UDim2.new(0.56, 0, 0.4, 0)
bottomBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
bottomBtn.BorderSizePixel = 0
bottomBtn.Text = "From Screen Bottom"
bottomBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
bottomBtn.TextSize = 14
bottomBtn.Font = Enum.Font.Montserrat
bottomBtn.TextWrapped = true
bottomBtn.Parent = tracerSettings
createUICorner(bottomBtn, 8)

local topBtn = Instance.new("TextButton")
topBtn.Name = "Top"
topBtn.Size = UDim2.new(0, 114, 0, 35)
topBtn.Position = UDim2.new(0.3, 0, 0.68, 0)
topBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBtn.BorderSizePixel = 0
topBtn.Text = "From Screen Top"
topBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
topBtn.TextSize = 14
topBtn.Font = Enum.Font.Montserrat
topBtn.TextWrapped = true
topBtn.Parent = tracerSettings
createUICorner(topBtn, 8)

local reloadBtn = Instance.new("TextButton")
reloadBtn.Name = "Reload"
reloadBtn.Size = UDim2.new(0, 200, 0, 50)
reloadBtn.Position = UDim2.new(0.15, 0, 0.75, 0)
reloadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
reloadBtn.BorderSizePixel = 0
reloadBtn.Text = "Reload ESP"
reloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
reloadBtn.TextSize = 25
reloadBtn.Font = Enum.Font.Montserrat
reloadBtn.ZIndex = 0
reloadBtn.Parent = settingsScroll
createUICorner(reloadBtn, 8)

local destroyBtn = Instance.new("TextButton")
destroyBtn.Name = "Destroy"
destroyBtn.Size = UDim2.new(0, 200, 0, 50)
destroyBtn.Position = UDim2.new(0.15, 0, 0.85, 0)
destroyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
destroyBtn.BorderSizePixel = 0
destroyBtn.Text = "Destroy ESP"
destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyBtn.TextSize = 25
destroyBtn.Font = Enum.Font.Montserrat
destroyBtn.ZIndex = 0
destroyBtn.Parent = settingsScroll
createUICorner(reloadBtn, 8)

------------------drag

local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    esp.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

espLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = esp.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

espLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

--==========================================================================================================================================================--

local settingsEnabled = false
local settingsBeingInit = false

local MAX_DIST_MIN = 500
local MAX_DIST_MAX = 2500
local CUTOFF_MIN = math.round(MAX_DIST_MAX/2 / 10) * 10

local maxDistValue = 1500
local cutoffValue = 1500
local espTransparency = 0.5

local isDraggingMaxDist = false
local isDraggingCutoff = false
local isDraggingCHMS = false

--==========================================================================================================================================================--

local function updateMaxDistVisual(value)
	local clampedValue = math.clamp(value, MAX_DIST_MIN, MAX_DIST_MAX)
	clampedValue = math.round(clampedValue / 10) * 10
	
	local percent = (clampedValue - MAX_DIST_MIN) / (MAX_DIST_MAX - MAX_DIST_MIN)
	
	maxDistFill.Size = UDim2.new(percent, 0, 1, 0)
	maxDistHandle.Position = UDim2.new(percent, -10, 0.5, -10)
	maxDistCurrentVal.Text = tostring(clampedValue)
	
	return clampedValue
end

local function updateCutoffVisual(value, maxValue, cutoffMin)
	local maxVal = maxValue or maxDistValue
	local clampedValue = math.clamp(value, cutoffMin, maxVal)
	clampedValue = math.round(clampedValue / 10) * 10
	
	local percent = (clampedValue - cutoffMin) / (maxVal - cutoffMin)
	
	cutoffFill.Size = UDim2.new(percent, 0, 1, 0)
	cutoffHandle.Position = UDim2.new(percent, -10, 0.5, -10)
	cutoffCurrentVal.Text = tostring(clampedValue)
	cutoffValMin.Text = cutoffMin
	cutoffValMax.Text = maxVal
	
	return clampedValue
end

local function updateCHMSVisual(value)
	local clampedValue = math.clamp(value, 0, 1)
	clampedValue = math.round(clampedValue / 0.05) * 0.05
	
	local percent = clampedValue
	
	chmsFill.Size = UDim2.new(percent, 0, 1, 0)
	chmsHandle.Position = UDim2.new(percent, -10, 0.5, -10)
	chmsCurrentVal.Text = string.format("%.2f", clampedValue)

    if chms then
        for _, v in ipairs(Players:GetPlayers()) do
			if v.Name ~= LocalPlayer.Name then
				CHMS(v)
			end
		end
        
    end
	
	return clampedValue
end

local function getValueFromMouse(mouseX, track, minVal, maxVal)
	local trackAbsoluteSize = track.AbsoluteSize.X
	local trackAbsolutePosition = track.AbsolutePosition.X
	
	local relativeX = (mouseX - trackAbsolutePosition) / trackAbsoluteSize
	relativeX = math.clamp(relativeX, 0, 1)
	
	return minVal + (relativeX * (maxVal - minVal))
end

--===============================================THE SETTINGS. YES. JUST THE SETTINGS.=======================================================================--

local sbmbc = settingsBtn.MouseButton1Click:Connect(function()
    if settingsBeingInit then return end
	if settingsEnabled then
        settingsEnabled = false
        settingsBeingInit = true
        settingsScroll.Visible = false

        local twinfo = TweenInfo.new(.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(settings, twinfo, {
            Position = startSettingsPos
        })
        tween:Play()
        tween.Completed:Wait()

        settings.Visible = false
        settingsBeingInit = false
    else
        settingsEnabled = true
        settings.Visible = true
        settingsBeingInit = true

        local twinfo = TweenInfo.new(.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(settings, twinfo, {
            Position = realSettingsPos
        })
        tween:Play()
        tween.Completed:Wait()

        settingsBeingInit = false
        settingsScroll.Visible = true
    end
end)
table.insert(Connections, sbmbc)

--================================================SLIDER FUNCTIONS================================================--

local mdhmbd = maxDistHandle.MouseButton1Down:Connect(function()
	if not settingsEnabled then return end
	isDraggingMaxDist = true
end)
local mdtib = maxDistTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and settingsEnabled then
		isDraggingMaxDist = true
		local mouseX = input.Position.X
		local cutoffMin = math.round(maxDistValue/2 / 10) * 10
		maxDistValue = updateMaxDistVisual(getValueFromMouse(mouseX, maxDistTrack, MAX_DIST_MIN, MAX_DIST_MAX))

		cutoffValue = updateCutoffVisual(cutoffValue, maxDistValue, cutoffMin)
	end
end)
local cohmbd = cutoffHandle.MouseButton1Down:Connect(function()
	if not settingsEnabled then return end
	isDraggingCutoff = true
end)
local cotib = cutoffTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and settingsEnabled then
		isDraggingCutoff = true
		local mouseX = input.Position.X
		local cutoffMin = math.round(maxDistValue/2 / 10) * 10
		
		cutoffValue = updateCutoffVisual(getValueFromMouse(mouseX, cutoffTrack, cutoffMin, maxDistValue), maxDistValue, cutoffMin)
	end
end)
local chmshmbd = chmsHandle.MouseButton1Down:Connect(function()
	if not settingsEnabled then return end
	isDraggingCHMS = true
end)
local chmstib = chmsTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and settingsEnabled then
		isDraggingCHMS = true
		local mouseX = input.Position.X
		espTransparency = updateCHMSVisual(getValueFromMouse(mouseX, chmsTrack, 0, 1))
	end
end)
local uisic = UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if isDraggingMaxDist and settingsEnabled then
			local mouseX = input.Position.X
			local cutoffMin = math.round(maxDistValue/2 / 10) * 10
			maxDistValue = updateMaxDistVisual(getValueFromMouse(mouseX, maxDistTrack, MAX_DIST_MIN, MAX_DIST_MAX))
			
			cutoffValue = updateCutoffVisual(cutoffValue, maxDistValue, cutoffMin)
		elseif isDraggingCutoff and settingsEnabled then
			local mouseX = input.Position.X
			local cutoffMin = math.round(maxDistValue/2 / 10) * 10
			cutoffValue = updateCutoffVisual(getValueFromMouse(mouseX, cutoffTrack, cutoffMin, maxDistValue), maxDistValue, cutoffMin)
		elseif isDraggingCHMS and settingsEnabled then
			local mouseX = input.Position.X
			espTransparency = updateCHMSVisual(getValueFromMouse(mouseX, chmsTrack, 0, 1))
		end
	end

    ----drag
    if input == dragInput and dragging then
        update(input)
    end
end)
local uisie = UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if isDraggingMaxDist then
			isDraggingMaxDist = false
		end
		if isDraggingCutoff then
			isDraggingCutoff = false
		end
		if isDraggingCHMS then
			isDraggingCHMS = false
		end
	end
end)

maxDistValue = updateMaxDistVisual(maxDistValue)
cutoffValue = updateCutoffVisual(cutoffValue, maxDistValue, CUTOFF_MIN)
espTransparency = updateCHMSVisual(espTransparency)

table.insert(Connections, mdhmbd)
table.insert(Connections, mdtib)
table.insert(Connections, cohmbd)
table.insert(Connections, cotib)
table.insert(Connections, chmshmbd)
table.insert(Connections, chmstib)
table.insert(Connections, uisic)
table.insert(Connections, uisie)

--===============================ESP FUNCTIONS. WELL TECHNICALLY VARIABLES=============================================--

local esp_enabled = false
local esp_tracers = false
local esp_names = false
local esp_boxes = false
local esp_hl = false
local esp_skeleton = false
local esp_distance = false
local esp_health = false
local tracer_option = "From Mouse"

local espDrawings = {}
local R15Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "HumanoidRootPart"},

    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},

    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},

    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},

    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}
local R6Bones = {
    {"Head", "Torso"},
    {"Torso", "HumanoidRootPart"},

    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local reloading = false

--========================================ESP FUNCTIONS FR NOW==========================================================--

function CHMS(plr)
	task.spawn(function()
		for i,v in pairs(CoreGui:GetChildren()) do
			if v.Name == plr.Name..'_CHMS' then
				v:Destroy()
			end
		end

		task.wait()

		if plr.Character and plr.Name ~= LocalPlayer.Name and not CoreGui:FindFirstChild(plr.Name..'_CHMS') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_CHMS'
			ESPholder.Parent = CoreGui

			repeat task.wait(.1) until plr.Character and getRoot(plr.Character) and getHuman(plr.Character)

			for b,n in pairs(plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color3 = plr.TeamColor.Color
				end
			end

			local addedFunc
			local teamChange
			local CHMSremoved
            
			addedFunc = plr.CharacterAdded:Connect(function()
				if chms then
					ESPholder:Destroy()
					teamChange:Disconnect()
					repeat task.wait(.1) until getRoot(plr.Character) and getHuman(plr.Character)
					CHMS(plr)
					addedFunc:Disconnect()
				else
					teamChange:Disconnect()
					addedFunc:Disconnect()
				end
			end)
			teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
				if chms then
					ESPholder:Destroy()
					addedFunc:Disconnect()
					repeat task.wait(.1) until getRoot(plr.Character) and getHuman(plr.Character)
					CHMS(plr)
					teamChange:Disconnect()
				else
					teamChange:Disconnect()
				end
			end)
			CHMSremoved = ESPholder.AncestryChanged:Connect(function()
				teamChange:Disconnect()
				addedFunc:Disconnect()
				CHMSremoved:Disconnect()
			end)
		end
	end)
end

local tgbmbd = toggleBtn.MouseButton1Down:Connect(function()
    if esp_enabled then
        esp_enabled = false
        toggleBtn.Text = "Disabled"
        toggleBtn.TextColor3 = Color3.new(1,0,0)
    else
        esp_enabled = true
        toggleBtn.Text = "Enabled"
        toggleBtn.TextColor3 = Color3.new(0,1,0)
    end
end)
local trbmbd = tracersBtn.MouseButton1Down:Connect(function()
    if esp_tracers then
        esp_tracers = false
        tracersBtn.TextColor3 = Color3.new(1,0,0)
    else
        esp_tracers = true
        tracersBtn.TextColor3 = Color3.new(0,1,0)
    end
end)
local nbmbd = namesBtn.MouseButton1Down:Connect(function()
    if esp_names then
        esp_names = false
        namesBtn.TextColor3 = Color3.new(1,0,0)
    else
        esp_names = true
        namesBtn.TextColor3 = Color3.new(0,1,0)
    end
end)
local bbmbd = boxesBtn.MouseButton1Down:Connect(function()
    if esp_boxes then
        esp_boxes = false
        boxesBtn.TextColor3 = Color3.new(1,0,0)
    else
        esp_boxes = true
        boxesBtn.TextColor3 = Color3.new(0,1,0)
    end
end)
local hlbmbd = highlightsBtn.MouseButton1Down:Connect(function()
    if esp_hl then
        esp_hl = false
        highlightsBtn.TextColor3 = Color3.new(1,0,0)
    else
        esp_hl = true
        highlightsBtn.TextColor3 = Color3.new(0,1,0)
    end
end)
local sbmbd = skeletonBtn.MouseButton1Down:Connect(function()
    if esp_skeleton then
        esp_skeleton = false
        skeletonBtn.TextColor3 = Color3.new(1,0,0)
    else
        esp_skeleton = true
        skeletonBtn.TextColor3 = Color3.new(0,1,0)
    end
end)
local dbmbd = distanceBtn.MouseButton1Down:Connect(function()
    if esp_distance then
        esp_distance = false
        distanceBtn.TextColor3 = Color3.new(1,0,0)
    else
        esp_distance = true
        distanceBtn.TextColor3 = Color3.new(0,1,0)
    end
end)
local hbmbd = healthBtn.MouseButton1Down:Connect(function()
    if esp_health then
        esp_health = false
        healthBtn.TextColor3 = Color3.new(1,0,0)
    else
        esp_health = true
        healthBtn.TextColor3 = Color3.new(0,1,0)
    end
end)
local chmsbmbd = chamsBtn.MouseButton1Down:Connect(function()
    if not esp_enabled then return end
	if chms then
        chms = false
        chamsBtn.TextColor3 = Color3.new(1,0,0)

        for _, v in ipairs(Players:GetPlayers()) do
		    local chmsplr = v

		    for _, c in pairs(CoreGui:GetChildren()) do
		    	if c.Name:find("_CHMS") then
		    		c:Destroy()
		    	end
		    end
        end
    else
        chms = true
        chamsBtn.TextColor3 = Color3.new(0,1,0)

        for _, v in ipairs(Players:GetPlayers()) do
			if v.Name ~= LocalPlayer.Name then
				CHMS(v)
			end
		end
    end
end)
local rbmbd = reloadBtn.MouseButton1Down:Connect(function()
    if reloading then
        notif("Already reloading...", "ESP")
        return
    end
    reloading = true

    notif("Reloading ESP", "ESP", 7.5)
    local dlay = #Players:GetPlayers() / 50

    for _, p in Players:GetPlayers() do
        task.spawn(function()
            removeESP(p)
            task.delay(dlay, function()
                createESP(p)
            end)
        end)
    end

    task.wait(dlay)
    reloading = false
end)
local dtbmbd = destroyBtn.MouseButton1Down:Connect(function()
    notif("Destroying...")
    task.wait(0.5)
    screenGui:Destroy()
end)
table.insert(Connections, tgbmbd)
table.insert(Connections, trbmbd)
table.insert(Connections, nbmbd)
table.insert(Connections, bbmbd)
table.insert(Connections, hlbmbd)
table.insert(Connections, sbmbd)
table.insert(Connections, dbmbd)
table.insert(Connections, hbmbd)
table.insert(Connections, chmsbmbd)
table.insert(Connections, rbmbd)
table.insert(Connections, dtbmbd)

local mbmbd = mouseBtn.MouseButton1Down:Connect(function()
    tracer_option = "From Mouse"
end)
local cbmbd = charBtn.MouseButton1Down:Connect(function()
    tracer_option = "From Character"    
end)
local ctbmbd = centerBtn.MouseButton1Down:Connect(function()
    tracer_option = "From Center"
end)
local btmbd = bottomBtn.MouseButton1Down:Connect(function()
    tracer_option = "From Bottom"
end)
local tbmbd = topBtn.MouseButton1Down:Connect(function()
    tracer_option = "From Top"
end)
table.insert(Connections, mbmbd)
table.insert(Connections, cbmbd)
table.insert(Connections, ctbmbd)
table.insert(Connections, btmbd)
table.insert(Connections, tbmbd)

--============================================================--
local function getBoundingBox(char)
    local cf, size = char:GetBoundingBox()
    return cf, size
end
local function hideSkeleton(drawings)
    if drawings.Skeleton and drawings.Skeleton.Lines then
        for _, line in ipairs(drawings.Skeleton.Lines) do
            line.Visible = false
        end
    end
end

---------------------------Create ESP for Players
local trackedPlayers = {}

function createESP(player)
    local drawings = {
        Line = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Box = Drawing.new("Square"),
        Highlight = Instance.new("Highlight"),
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Text")
    }
    drawings.Skeleton = {
        Lines = {},
        Bones = {},
        RigType = nil
    }

    drawings.Line.Thickness = 1
    drawings.Line.Visible = false
    drawings.Line.Color = Color3.new(1,1,1)

    drawings.Name.Size = 13
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Visible = false
    drawings.Name.Color = Color3.new(1,1,1)
    
    drawings.Distance.Size = 13
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Visible = false
    drawings.Distance.Color = Color3.new(1,1,1)
    drawings._lastDist = nil
    drawings._lastDistUpdate = 0

    drawings.Box.Thickness = 1
    drawings.Box.Filled = false
    drawings.Box.Visible = false
    drawings.Box.Color = Color3.new(1,1,1)

    drawings.Highlight.Parent = CoreGui
    drawings.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    drawings.Highlight.Enabled = false
    drawings.Highlight.FillColor = Color3.new(1,1,1)
    drawings.Highlight.FillTransparency = espTransparency
    drawings.Highlight.OutlineColor = Color3.new(1,1,1)
    drawings.Highlight.OutlineTransparency = .5

    drawings.Health.Size = 13
    drawings.Health.Center = true
    drawings.Health.Outline = true
    drawings.Health.Visible = false
    drawings.Health.Color = Color3.new(1,1,1)
    drawings._lastHp = nil
    drawings._lastHpUpdate = 0

    espDrawings[player] = drawings
end
function removeESP(player)
    local drawings = espDrawings[player]
    if not drawings then return end

    if drawings.Skeleton and drawings.Skeleton.Lines then
        for _, line in ipairs(drawings.Skeleton.Lines) do
            line:Destroy()
        end
    end

    if drawings.Line then drawings.Line:Destroy() end
    if drawings.Name then drawings.Name:Destroy() end
    if drawings.Box then drawings.Box:Destroy() end
    if drawings.Highlight then drawings.Highlight:Destroy() end
    if drawings.Distance then drawings.Distance:Destroy() end
    if drawings.Health then drawings.Health:Destroy() end

    espDrawings[player] = nil
end

local function trackPlayer(player)
	if player == LocalPlayer then return end

    createESP(player)

	trackedPlayers[player] = {
		Player = player,
		Character = nil,
        Root = nil,
        RigType = nil,
        Humanoid = nil
	}

    local function onCharacter(char)
        trackedPlayers[player].Character = char
        trackedPlayers[player].Root = getRoot(char)
        trackedPlayers[player].RigType = getRigType(char)
        trackedPlayers[player].Humanoid = getHuman(char)

        local drawings = espDrawings[player]

        if drawings and drawings.Highlight then
            drawings.Highlight.Adornee = char
        end

        ------skeleton
        local rigType = getRigType(char)
        if not rigType then return end

        local bones = rigType == "R6" and R6Bones or R15Bones

        if drawings.Skeleton and drawings.Skeleton.Lines then
            for _, line in ipairs(drawings.Skeleton.Lines) do
                line:Destroy()
            end
        end
        drawings.Skeleton = {
            Lines = {},
            Bones = bones,
            RigType = rigType
        }

        for i = 1, #bones do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 1
            line.Color = Color3.new(1,1,1)

            drawings.Skeleton.Lines[i] = line
        end
    end

	if player.Character then
		onCharacter(player.Character)
	end

	local pcac = player.CharacterAdded:Connect(onCharacter)
    local pcrc = player.CharacterRemoving:Connect(function()
        if trackedPlayers[player] then
            trackedPlayers[player].Character = nil
            trackedPlayers[player].Root = nil
            trackedPlayers[player].RigType = nil
            trackedPlayers[player].Humanoid = nil
            local drawings = espDrawings[player]
            if drawings and drawings.Skeleton then
                hideSkeleton(drawings)
            end
        end
    end)
    table.insert(Connections, pcac)
    table.insert(Connections, pcrc)

    if chms then
        CHMS(player)
    end
end
local function untrackPlayer(player)
	trackedPlayers[player] = nil
    for _, c in CoreGui:GetChildren() do
        if c.Name == player.Name.."_CHMS" then
            c:Destroy()
        end
    end
    removeESP(player)
end

for _, p in ipairs(Players:GetPlayers()) do
	trackPlayer(p)
end

local ppac = Players.PlayerAdded:Connect(trackPlayer)
local pprc = Players.PlayerRemoving:Connect(untrackPlayer)
table.insert(Connections, ppac)
table.insert(Connections, pprc)

------------------------------WOAH IT'S THE RUN LOOP!

local lastUpdate = 0
local RATE = 1/20
local dSuffix = "Distance: "
local dRATE = 1/10
local hSuffix = "Health: "
local hRATE = 1/1

RunService:BindToRenderStep("ESP", Enum.RenderPriority.Camera.Value + 2, function()
    local now = tick()
    if now - lastUpdate < RATE then return end
    lastUpdate = now

    if not esp_enabled then
        for _, drawings in pairs(espDrawings) do
            drawings.Line.Visible = false
            drawings.Name.Visible = false
            drawings.Box.Visible = false
            drawings.Highlight.Enabled = false
            drawings.Distance.Visible = false
            drawings.Health.Visible = false
            hideSkeleton(drawings)
        end
        return
    end

    local cam = Camera or workspace.CurrentCamera
    local camCF = cam.CFrame
    local camPos = camCF.Position
    local viewport = cam.ViewportSize
    local screenBottom = Vector2.new(viewport.X / 2, viewport.Y)
    local screenCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local screenTop = Vector2.new(viewport.X / 2, 0)

    for player, data in pairs(trackedPlayers) do
        if player == LocalPlayer then continue end

        local char = data.Character
        local root = data.Root
        local rigType = data.RigType
        local h = data.Humanoid
        local drawings = espDrawings[player]
        local dist: number = root and math.floor((camPos - root.Position).Magnitude * 10 + .5) / 10

        if not drawings or not char or isDead(player) or not root or (root and dist > cutoffValue) then
            if drawings then
                drawings.Line.Visible = false
                drawings.Name.Visible = false
                drawings.Box.Visible = false
                drawings.Highlight.Enabled = false
                drawings.Distance.Visible = false
                drawings.Health.Visible = false
                hideSkeleton(drawings)
            end
            continue
        end

        local teamColor = player.Team and player.Team.TeamColor.Color or Color3.new(1,1,1)
        local bones = rigType == "R6" and R6Bones or R15Bones

        local rootPos, onScreen = cam:WorldToViewportPoint(root.Position)
        local screenPos = Vector2.new(rootPos.X, rootPos.Y)

        if not onScreen then
            drawings.Line.Visible = false
            drawings.Name.Visible = false
            drawings.Box.Visible = false
            drawings.Highlight.Enabled = false
            drawings.Distance.Visible = false
            drawings.Health.Visible = false
            hideSkeleton(drawings)
            continue
        end


        if esp_boxes then
            local cf, size = getBoundingBox(char)

            local corners = {
                Vector3.new(-1, -1, -1),
                Vector3.new(-1, -1,  1),
                Vector3.new(-1,  1, -1),
                Vector3.new(-1,  1,  1),
                Vector3.new( 1, -1, -1),
                Vector3.new( 1, -1,  1),
                Vector3.new( 1,  1, -1),
                Vector3.new( 1,  1,  1),
            }

            local minX, minY = math.huge, math.huge
            local maxX, maxY = -math.huge, -math.huge
            local anyOnScreen = false

            for _, corner in ipairs(corners) do
                local worldPoint = cf:PointToWorldSpace(corner * size * .5)
                local screenPoint, onScreen = cam:WorldToViewportPoint(worldPoint)

                if onScreen then
                    anyOnScreen = true
                end

                minX = math.min(minX, screenPoint.X)
                minY = math.min(minY, screenPoint.Y)
                maxX = math.max(maxX, screenPoint.X)
                maxY = math.max(maxY, screenPoint.Y)
            end

            if anyOnScreen then
                drawings.Box.Position = Vector2.new(minX, minY)
                drawings.Box.Size = Vector2.new(maxX - minX, maxY - minY)
                drawings.Box.Color = teamColor
                drawings.Box.Visible = true
            else
                drawings.Box.Visible = false
            end
        else
            drawings.Box.Visible = false
        end

        if esp_names then
            drawings.Name.Text = player.Name
            drawings.Name.Position = screenPos - Vector2.new(0, 50)
            drawings.Name.Color = teamColor
            drawings.Name.Visible = true
        else
            drawings.Name.Visible = false
        end

        if esp_tracers then
            if tracer_option == "From Bottom" then
               drawings.Line.From = screenBottom
            elseif tracer_option == "From Center" then
                drawings.Line.From = screenCenter
            elseif tracer_option == "From Top" then
                drawings.Line.From = screenTop
            elseif tracer_option == "From Mouse" then 
                drawings.Line.From = UserInputService:GetMouseLocation()
            elseif tracer_option == "From Character" then
                local r = getRoot(getChar(LocalPlayer))
                if r then
                    local rp, v = Camera:WorldToViewportPoint(r.Position)

                    if v then
                        drawings.Line.From = Vector2.new(rp.X, rp.Y)
                    else
                        local x = math.clamp(rp.X, 0, viewport.X)
                        local y = math.clamp(rp.Y, 0, viewport.Y)
                        drawings.Line.From = Vector2.new(x, y)
                    end
                end
            else
                drawings.Line.From = screenBottom
            end
            drawings.Line.To = screenPos
            drawings.Line.Color = teamColor
            drawings.Line.Visible = true
        else
            drawings.Line.Visible = false
        end

        if esp_hl then
            if not drawings.Highlight.Adornee then
                drawings.Highlight.Adornee = char
            end
            
            drawings.Highlight.FillColor = teamColor
            drawings.Highlight.FillTransparency = espTransparency

            if dist > cutoffValue/2 or dist < 15 then
                drawings.Highlight.Enabled = false
            end
            drawings.Highlight.Enabled = true
        else
            if drawings.Highlight.Adornee then
                drawings.Highlight.Adornee = nil
            end
            drawings.Highlight.Enabled = false
        end
        
        if esp_skeleton and drawings.Skeleton and drawings.Skeleton.Lines then
            if dist <= cutoffValue/2 and dist > 15 then
                local bones = drawings.Skeleton.Bones
                local lines = drawings.Skeleton.Lines

                for i, bone in ipairs(bones) do
                    local part0 = char:FindFirstChild(bone[1])
                    local part1 = char:FindFirstChild(bone[2])

                    local line = lines[i]
                    if part0 and part1 and line then
                        local p0, on0 = cam:WorldToViewportPoint(part0.Position)
                        local p1, on1 = cam:WorldToViewportPoint(part1.Position)

                       if on0 and on1 then
                            line.From = Vector2.new(p0.X, p0.Y)
                            line.To = Vector2.new(p1.X, p1.Y)
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    elseif line then
                        line.Visible = false
                    end
                end
            else
                hideSkeleton(drawings)
            end
        else
           hideSkeleton(drawings)
        end

        if esp_distance then
            local now = tick()
            if now - drawings._lastDistUpdate > dRATE then
                drawings._lastDistUpdate = now
                
                local newDist = math.floor((camPos - root.Position).Magnitude * 10 + .5) / 10

                if not drawings._lastDist or math.abs(drawings._lastDist - newDist) >= .1 then
                    drawings._lastDist = newDist
                    drawings.Distance.Text = dSuffix..newDist
                end
            end

            drawings.Distance.Position = screenPos - Vector2.new(0, 40)
            drawings.Distance.Color = teamColor
            drawings.Distance.Visible = true
        else
            drawings.Distance.Visible = false
        end

        if esp_health then
            local now = tick()
            if now - drawings._lastHpUpdate > hRATE then
                drawings._lastHpUpdate = now

                local newHp = math.floor(h.Health * 10 + .5) / 10

                if not drawings._lastHp or math.abs(drawings._lastHp - newHp) >= .1 then
                    drawings._lastHp = newHp
                    drawings.Health.Text = hSuffix..newHp
                end
            end

            drawings.Health.Position = screenPos - Vector2.new(0, 30)
            drawings.Health.Color = teamColor
            drawings.Health.Visible = true
        else
            drawings.Health.Visible = false
        end
    end
end)
RunService:BindToRenderStep("TRACEROPTION", Enum.RenderPriority.Last.Value, function()
    if tracer_option == "From Mouse" then
        mouseBtn.TextColor3 = Color3.new(0,1,0)
    else
        mouseBtn.TextColor3 = Color3.new(1,0,0)
    end
    if tracer_option == "From Character" then
        charBtn.TextColor3 = Color3.new(0,1,0)
    else
        charBtn.TextColor3 = Color3.new(1,0,0)
    end
    if tracer_option == "From Center" then
        centerBtn.TextColor3 = Color3.new(0,1,0)
    else
        centerBtn.TextColor3 = Color3.new(1,0,0)
    end
    if tracer_option == "From Bottom" then
        bottomBtn.TextColor3 = Color3.new(0,1,0)
    else
        bottomBtn.TextColor3 = Color3.new(1,0,0)
    end
    if tracer_option == "From Top" then
        topBtn.TextColor3 = Color3.new(0,1,0)
    else
        topBtn.TextColor3 = Color3.new(1,0,0)
    end
    ---------------holy peak
end)

--========================================================================================================================--

screenGui.Destroying:Connect(function()
    print("destroying...")

    local cn = 0
    for _, connection in Connections do
        connection:Disconnect()
        cn += 1
    end
    print("Disconnected "..cn.." connections")

    RunService:UnbindFromRenderStep("ESP")
    print("Unbinded ESP")

    RunService:UnbindFromRenderStep("TRACEROPTION")
    print("Unbinded TRACEROPTION")

    local n = 0
    for _, drawings in pairs(espDrawings) do
        if drawings then
            if drawings.Skeleton and drawings.Skeleton.Lines then
                for _, line in ipairs(drawings.Skeleton.Lines) do
                    pcall(function()
                        line:Destroy()
                        line = nil
                        n += 1
                    end)
                end
            end

            for _, d in pairs(drawings) do
                pcall(function()
                    d:Destroy()
                    d = nil
                    n += 1
                end)
            end
        end
    end

    local chn = 0
    for _, v in ipairs(Players:GetPlayers()) do
		local chmsplr = v

		for _, c in pairs(CoreGui:GetChildren()) do
			if c.Name:find("_CHMS") then
                c:Destroy()
                chn += 1
            end
		end
    end
    print("destroyed", n, "drawings")
    print("destroyed", chn, "box handles")
    print("esp fully off")

    print("destroyed")
end)

notif("AliESP Initialized.")
notif("Drag the ESP Text to drag the whole UI!")
notif(`Stop AliESP by running: \n"game:GetService("CoreGui").AliESP:Destroy()".`, "How to Stop ESP", 15, "Okay, got it!")