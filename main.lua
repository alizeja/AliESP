local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer


--===========================================================================--
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
	fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
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
	createUICorner(handle, 4)
	
	local currentVal = Instance.new("TextLabel")
	currentVal.Name = "CurrentVal"
	currentVal.Size = UDim2.new(0, 50, 0, 20)
	currentVal.Position = UDim2.new(0.5, 0, 0.5, 0)
	currentVal.AnchorPoint = Vector2.new(0.5, 0.5)
	currentVal.BackgroundTransparency = 1
	currentVal.Text = "1500"
	currentVal.TextColor3 = Color3.fromRGB(255, 255, 255)
	currentVal.TextSize = 14
	currentVal.Font = Enum.Font.GothamSSm
	currentVal.Parent = handle
	
	return track, fill, handle
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
	btn.Font = Enum.Font.GothamSSm
	btn.Parent = parent
	createUICorner(btn, 8)
	return btn
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
espLabel.Font = Enum.Font.GothamSSm
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
settingsBtn.Font = Enum.Font.GothamSSm
settingsBtn.Parent = scrollFrame
createUICorner(settingsBtn, 8)

local settings = Instance.new("Frame")
settings.Name = "Settings"
settings.Size = UDim2.new(0, 300, 0, 300)
settings.Position = UDim2.fromScale(0, 0)
settings.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
settings.BorderSizePixel = 0
settings.Visible = false
settings.Parent = esp
createUICorner(settings, 15)
local realSettingsPos = UDim2.new(1, 1, 0, 0)

local settingsLabel = Instance.new("TextLabel")
settingsLabel.Name = "Label"
settingsLabel.Size = UDim2.new(1, 0, 0, 20)
settingsLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
settingsLabel.BorderSizePixel = 0
settingsLabel.Text = "Settings"
settingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsLabel.TextSize = 14
settingsLabel.Font = Enum.Font.GothamSSm
settingsLabel.TextScaled = true
settingsLabel.Parent = settings
createUICorner(settingsLabel, 15)

local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Name = "ScrollingFrame"
settingsScroll.Size = UDim2.new(1, 0, 1, -30)
settingsScroll.Position = UDim2.new(0, 0, 0, 30)
settingsScroll.BackgroundTransparency = 1
settingsScroll.ScrollBarThickness = 5
settingsScroll.CanvasSize = UDim2.new(0, 0, 2, 0)
settingsScroll.Parent = settings

local maxDistSlider = Instance.new("Frame")
maxDistSlider.Name = "MaxDistSlider"
maxDistSlider.Size = UDim2.new(0, 280, 0, 60)
maxDistSlider.Position = UDim2.new(0.033, 0, 0, 5)
maxDistSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
maxDistSlider.BorderSizePixel = 1
maxDistSlider.BorderColor3 = Color3.fromRGB(0, 0, 0)
maxDistSlider.Parent = settingsScroll
createUICorner(maxDistSlider, 8)

local maxDistLabel = Instance.new("TextLabel")
maxDistLabel.Name = "Label"
maxDistLabel.Size = UDim2.new(1, 0, 0, 20)
maxDistLabel.BackgroundTransparency = 1
maxDistLabel.Text = "Max Detection Distance"
maxDistLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
maxDistLabel.TextSize = 14
maxDistLabel.Font = Enum.Font.GothamSSm
maxDistLabel.Parent = maxDistSlider

local maxDistValMin = Instance.new("TextLabel")
maxDistValMin.Name = "ValMin"
maxDistValMin.Size = UDim2.new(0, 50, 0, 20)
maxDistValMin.Position = UDim2.new(0, 10, 0.4, -10)
maxDistValMin.BackgroundTransparency = 1
maxDistValMin.Text = "500"
maxDistValMin.TextColor3 = Color3.fromRGB(255, 255, 255)
maxDistValMin.TextSize = 14
maxDistValMin.Font = Enum.Font.GothamSSm
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
maxDistValMax.Font = Enum.Font.GothamSSm
maxDistValMax.TextXAlignment = Enum.TextXAlignment.Right
maxDistValMax.Parent = maxDistSlider

local maxDistEnabled = Instance.new("BoolValue")
maxDistEnabled.Name = "Enabled"
maxDistEnabled.Value = true
maxDistEnabled.Parent = maxDistSlider

createSliderTrack(maxDistSlider)

local distCutoff = Instance.new("Frame")
distCutoff.Name = "DistCutoff"
distCutoff.Size = UDim2.new(0, 280, 0, 60)
distCutoff.Position = UDim2.new(0.033, 0, 0, 75)
distCutoff.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
distCutoff.BorderSizePixel = 1
distCutoff.BorderColor3 = Color3.fromRGB(0, 0, 0)
distCutoff.Parent = settingsScroll
createUICorner(distCutoff, 8)

local cutoffLabel = Instance.new("TextLabel")
cutoffLabel.Name = "Label"
cutoffLabel.Size = UDim2.new(1, 0, 0, 20)
cutoffLabel.BackgroundTransparency = 1
cutoffLabel.Text = "Cutoff Distance"
cutoffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cutoffLabel.TextSize = 14
cutoffLabel.Font = Enum.Font.GothamSSm
cutoffLabel.Parent = distCutoff

local cutoffValMin = Instance.new("TextLabel")
cutoffValMin.Name = "ValMin"
cutoffValMin.Size = UDim2.new(0, 50, 0, 20)
cutoffValMin.Position = UDim2.new(0, 10, 0.4, -10)
cutoffValMin.BackgroundTransparency = 1
cutoffValMin.Text = "750"
cutoffValMin.TextColor3 = Color3.fromRGB(255, 255, 255)
cutoffValMin.TextSize = 14
cutoffValMin.Font = Enum.Font.GothamSSm
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
cutoffValMax.Font = Enum.Font.GothamSSm
cutoffValMax.TextXAlignment = Enum.TextXAlignment.Right
cutoffValMax.Parent = distCutoff

local cutoffEnabled = Instance.new("BoolValue")
cutoffEnabled.Name = "Enabled"
cutoffEnabled.Value = true
cutoffEnabled.Parent = distCutoff

createSliderTrack(distCutoff)

local chmsTrans = Instance.new("Frame")
chmsTrans.Name = "CHMSTransparency"
chmsTrans.Size = UDim2.new(0, 280, 0, 60)
chmsTrans.Position = UDim2.new(0.033, 0, 0, 145)
chmsTrans.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
chmsTrans.BorderSizePixel = 1
chmsTrans.BorderColor3 = Color3.fromRGB(0, 0, 0)
chmsTrans.Parent = settingsScroll
createUICorner(chmsTrans, 8)

local chmsLabel = Instance.new("TextLabel")
chmsLabel.Name = "Label"
chmsLabel.Size = UDim2.new(1, 0, 0, 20)
chmsLabel.BackgroundTransparency = 1
chmsLabel.Text = "CHAMS Transparency"
chmsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
chmsLabel.TextSize = 14
chmsLabel.Font = Enum.Font.GothamSSm
chmsLabel.Parent = chmsTrans

local chmsValMin = Instance.new("TextLabel")
chmsValMin.Name = "ValMin"
chmsValMin.Size = UDim2.new(0, 50, 0, 20)
chmsValMin.Position = UDim2.new(0, 10, 0.4, -10)
chmsValMin.BackgroundTransparency = 1
chmsValMin.Text = "0"
chmsValMin.TextColor3 = Color3.fromRGB(255, 255, 255)
chmsValMin.TextSize = 14
chmsValMin.Font = Enum.Font.GothamSSm
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
chmsValMax.Font = Enum.Font.GothamSSm
chmsValMax.TextXAlignment = Enum.TextXAlignment.Right
chmsValMax.Parent = chmsTrans

local chmsEnabled = Instance.new("BoolValue")
chmsEnabled.Name = "Enabled"
chmsEnabled.Value = true
chmsEnabled.Parent = chmsTrans

createSliderTrack(chmsTrans)

local tracerSettings = Instance.new("Frame")
tracerSettings.Name = "TracerSettings"
tracerSettings.Size = UDim2.new(0, 280, 0, 180)
tracerSettings.Position = UDim2.new(0.033, 0, 0, 215)
tracerSettings.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tracerSettings.BorderSizePixel = 0
tracerSettings.Parent = settingsScroll
createUICorner(tracerSettings, 8)

local tracerLabel = Instance.new("TextLabel")
tracerLabel.Name = "Label"
tracerLabel.Size = UDim2.new(1, 0, 0, 20)
tracerLabel.BackgroundTransparency = 1
tracerLabel.Text = "Tracer Settings"
tracerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
tracerLabel.TextSize = 14
tracerLabel.Font = Enum.Font.GothamSSm
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
mouseBtn.Font = Enum.Font.GothamSSm
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
charBtn.Font = Enum.Font.GothamSSm
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
centerBtn.Font = Enum.Font.GothamSSm
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
bottomBtn.Font = Enum.Font.GothamSSm
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
topBtn.Font = Enum.Font.GothamSSm
topBtn.TextWrapped = true
topBtn.Parent = tracerSettings
createUICorner(topBtn, 8)

local reloadBtn = Instance.new("TextButton")
reloadBtn.Name = "Reload"
reloadBtn.Size = UDim2.new(0, 200, 0, 50)
reloadBtn.Position = UDim2.new(0.15, 0, 0.85, 0)
reloadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
reloadBtn.BorderSizePixel = 0
reloadBtn.Text = "Reload ESP"
reloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
reloadBtn.TextSize = 25
reloadBtn.Font = Enum.Font.GothamSSm
reloadBtn.Parent = settingsScroll
createUICorner(reloadBtn, 8)

settingsBtn.MouseButton1Click:Connect(function()
	settings.Visible = not settings.Visible
end)