--[[
    Matcha-Inspired Universal GUI Library
    Professional design with smooth animations
    Optimized for GitHub hosting
    ─────────────────────────────────────────────────────────────────────────────
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- SERVICES & UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════
local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ═══════════════════════════════════════════════════════════════════════════
-- THEME CONFIGURATION (Matcha-Inspired)
-- ═══════════════════════════════════════════════════════════════════════════
local Theme = {
    -- Background colors
    Background = Color3.fromRGB(18, 18, 22),
    BackgroundLight = Color3.fromRGB(22, 22, 28),
    BackgroundDark = Color3.fromRGB(14, 14, 18),
    
    -- Accent colors
    Accent = Color3.fromRGB(220, 50, 80),
    AccentDark = Color3.fromRGB(180, 40, 65),
    AccentLight = Color3.fromRGB(255, 70, 100),
    
    -- UI element colors
    Border = Color3.fromRGB(40, 40, 48),
    BorderLight = Color3.fromRGB(55, 55, 65),
    
    -- Text colors
    Text = Color3.fromRGB(245, 245, 250),
    TextDark = Color3.fromRGB(160, 160, 170),
    TextMuted = Color3.fromRGB(120, 120, 130),
    
    -- Interactive states
    Hover = Color3.fromRGB(28, 28, 35),
    Active = Color3.fromRGB(32, 32, 40),
    
    -- Slider/Toggle colors
    SliderFill = Color3.fromRGB(35, 35, 42),
    ToggleEnabled = Color3.fromRGB(220, 50, 80),
    ToggleDisabled = Color3.fromRGB(35, 35, 42),
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ANIMATION CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════
local AnimConfig = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════
local Utility = {}

function Utility:Create(class, properties)
    local instance = Instance.new(class)
    for prop, val in pairs(properties) do
        instance[prop] = val
    end
    return instance
end

function Utility:Tween(instance, properties, duration)
    local info = duration or AnimConfig.Fast
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Utility:MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                Utility:Tween(frame, {
                    Position = UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                }, AnimConfig.Fast)
            end
        end
    end)
end

function Utility:AddCorner(instance, radius)
    local corner = Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = instance
    })
    return corner
end

function Utility:AddStroke(instance, color, thickness)
    local stroke = Utility:Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = instance
    })
    return stroke
end

function Utility:AddGradient(instance, colors, rotation)
    local gradient = Utility:Create("UIGradient", {
        Color = colors,
        Rotation = rotation or 90,
        Parent = instance
    })
    return gradient
end

-- ═══════════════════════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateLoader(callback)
    local LoaderGui = Utility:Create("ScreenGui", {
        Name = "HateLoader_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    -- Background with red glow
    local Background = Utility:Create("Frame", {
        Name = "Background",
        BackgroundColor3 = Color3.fromRGB(10, 10, 12),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = LoaderGui
    })
    
    -- Red glow effect (4 corner frames)
    local glowSize = 200
    local glowColor = Color3.fromRGB(220, 50, 80)
    
    local function createGlow(anchorPoint, position)
        local glow = Utility:Create("Frame", {
            AnchorPoint = anchorPoint,
            Position = position,
            Size = UDim2.new(0, glowSize, 0, glowSize),
            BackgroundColor3 = glowColor,
            BorderSizePixel = 0,
            BackgroundTransparency = 0.4,
            Parent = Background
        })
        Utility:AddCorner(glow, glowSize / 2)
        
        -- Pulse animation
        local pulseTween = TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            BackgroundTransparency = 0.7,
            Size = UDim2.new(0, glowSize * 1.3, 0, glowSize * 1.3)
        })
        pulseTween:Play()
    end
    
    createGlow(Vector2.new(0, 0), UDim2.new(0, -glowSize/2, 0, -glowSize/2))
    createGlow(Vector2.new(1, 0), UDim2.new(1, glowSize/2, 0, -glowSize/2))
    createGlow(Vector2.new(0, 1), UDim2.new(0, -glowSize/2, 1, glowSize/2))
    createGlow(Vector2.new(1, 1), UDim2.new(1, glowSize/2, 1, glowSize/2))
    
    -- Center container
    local Container = Utility:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 400, 0, 300),
        BackgroundTransparency = 1,
        Parent = Background
    })
    
    -- Hate Logo (text-based for now - you can replace with ImageLabel)
    local Logo = Utility:Create("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 30),
        Size = UDim2.new(0, 300, 0, 60),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "HATE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 48,
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = glowColor,
        Parent = Container
    })
    
    -- Image underneath logo
    local LogoImage = Utility:Create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 100),
        Size = UDim2.new(0, 120, 0, 120),
        BackgroundTransparency = 1,
        Image = "rbxassetid://74199950139770",
        ScaleType = Enum.ScaleType.Fit,
        ImageTransparency = 0,
        Parent = Container
    })
    Utility:AddCorner(LogoImage, 12)
    
    -- Progress bar background
    local ProgressBg = Utility:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -50),
        Size = UDim2.new(0, 350, 0, 4),
        BackgroundColor3 = Theme.BackgroundLight,
        BorderSizePixel = 0,
        Parent = Container
    })
    Utility:AddCorner(ProgressBg, 2)
    
    -- Progress bar fill
    local ProgressFill = Utility:Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = glowColor,
        BorderSizePixel = 0,
        Parent = ProgressBg
    })
    Utility:AddCorner(ProgressFill, 2)
    
    -- Progress percentage
    local ProgressText = Utility:Create("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -30),
        Size = UDim2.new(0, 200, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "0%",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Parent = Container
    })
    
    -- Status text
    local StatusText = Utility:Create("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -8),
        Size = UDim2.new(0, 300, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Initializing...",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        Parent = Container
    })
    
    -- Fade in animation
    Background.BackgroundTransparency = 1
    Logo.TextTransparency = 1
    LogoImage.ImageTransparency = 1
    ProgressBg.BackgroundTransparency = 1
    ProgressFill.BackgroundTransparency = 1
    ProgressText.TextTransparency = 1
    StatusText.TextTransparency = 1
    
    task.wait(0.1)
    
    Utility:Tween(Background, {BackgroundTransparency = 0}, AnimConfig.Medium)
    Utility:Tween(Logo, {TextTransparency = 0}, AnimConfig.Medium)
    Utility:Tween(LogoImage, {ImageTransparency = 0}, AnimConfig.Medium)
    Utility:Tween(ProgressBg, {BackgroundTransparency = 0}, AnimConfig.Medium)
    Utility:Tween(ProgressText, {TextTransparency = 0}, AnimConfig.Medium)
    Utility:Tween(StatusText, {TextTransparency = 0}, AnimConfig.Medium)
    
    task.wait(0.5)
    
    -- Fake loading stages
    local stages = {
        {pct = 20, text = "Loading modules...", time = 0.6},
        {pct = 45, text = "Initializing features...", time = 0.8},
        {pct = 70, text = "Setting up UI...", time = 0.9},
        {pct = 90, text = "Finalizing...", time = 1.2},
        {pct = 100, text = "Complete!", time = 0.5},
    }
    
    for _, stage in ipairs(stages) do
        StatusText.Text = stage.text
        local targetSize = UDim2.new(stage.pct / 100, 0, 1, 0)
        TweenService:Create(ProgressFill, TweenInfo.new(stage.time * 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
        
        -- Animate percentage
        local startPct = tonumber(ProgressText.Text:match("%d+")) or 0
        local step = (stage.pct - startPct) / (stage.time * 60)
        for i = 1, stage.time * 60 do
            ProgressText.Text = math.floor(startPct + step * i) .. "%"
            task.wait(stage.time / 60)
        end
    end
    
    task.wait(0.3)
    
    -- Fade out
    Utility:Tween(Background, {BackgroundTransparency = 1}, AnimConfig.Medium)
    Utility:Tween(Logo, {TextTransparency = 1}, AnimConfig.Medium)
    Utility:Tween(LogoImage, {ImageTransparency = 1}, AnimConfig.Medium)
    Utility:Tween(ProgressBg, {BackgroundTransparency = 1}, AnimConfig.Medium)
    Utility:Tween(ProgressFill, {BackgroundTransparency = 1}, AnimConfig.Medium)
    Utility:Tween(ProgressText, {TextTransparency = 1}, AnimConfig.Medium)
    Utility:Tween(StatusText, {TextTransparency = 1}, AnimConfig.Medium)
    
    task.wait(0.4)
    LoaderGui:Destroy()
    
    if callback then callback() end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MAIN WINDOW CREATION
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "Universal Hub"
    local AccentColor = config.Accent or Theme.Accent
    
    -- Update theme accent
    Theme.Accent = AccentColor
    
    local Window = {
        Tabs = {},
        Elements = {},
        Flags = {},
        ThemeObjects = {},
    }
    
    -- Create ScreenGui
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "HateHub_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    -- Main window frame
    local MainFrame = Utility:Create("Frame", {
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 650, 0, 500),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    Utility:AddCorner(MainFrame, 12)
    Utility:AddStroke(MainFrame, Theme.Border, 1)
    
    -- Top bar
    local TopBar = Utility:Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.BackgroundLight,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    Utility:AddCorner(TopBar, 12)
    
    -- Fix corner clipping
    local TopBarFix = Utility:Create("Frame", {
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = Theme.BackgroundLight,
        BorderSizePixel = 0,
        Parent = TopBar
    })
    
    -- Window title
    local Title = Utility:Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 300, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = WindowName,
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    
    -- Close button
    local CloseButton = Utility:Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Theme.BackgroundDark,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 20,
        Parent = TopBar
    })
    Utility:AddCorner(CloseButton, 6)
    
    CloseButton.MouseEnter:Connect(function()
        Utility:Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, AnimConfig.Fast)
    end)
    CloseButton.MouseLeave:Connect(function()
        Utility:Tween(CloseButton, {BackgroundColor3 = Theme.BackgroundDark}, AnimConfig.Fast)
    end)
    CloseButton.MouseButton1Click:Connect(function()
        Utility:Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, AnimConfig.Medium)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Tab container
    local TabContainer = Utility:Create("Frame", {
        Position = UDim2.new(0, 10, 0, 50),
        Size = UDim2.new(0, 140, 1, -60),
        BackgroundColor3 = Theme.BackgroundLight,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    Utility:AddCorner(TabContainer, 8)
    
    local TabList = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabContainer
    })
    
    Utility:Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = TabContainer
    })
    
    -- Content container
    local ContentContainer = Utility:Create("Frame", {
        Position = UDim2.new(0, 160, 0, 50),
        Size = UDim2.new(1, -170, 1, -60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    -- Make draggable
    Utility:MakeDraggable(MainFrame, TopBar)
    
    -- Toggle keybind
    local Visible = true
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            Visible = not Visible
            if Visible then
                MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                Utility:Tween(MainFrame, {Size = UDim2.new(0, 650, 0, 500)}, AnimConfig.Medium)
            else
                Utility:Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, AnimConfig.Medium)
            end
        end
    end)
    
    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.TabContainer = TabContainer
    Window.ContentContainer = ContentContainer
    
    return setmetatable(Window, {__index = Library})
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TAB CREATION
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateTab(config)
    config = config or {}
    local TabName = config.Name or "Tab"
    
    local Tab = {
        Sections = {},
        Active = false,
    }
    
    -- Tab button
    local TabButton = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Text = TabName,
        TextColor3 = Theme.TextDark,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TabContainer
    })
    Utility:AddCorner(TabButton, 6)
    
    Utility:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = TabButton
    })
    
    -- Tab content frame
    local TabContent = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.ContentContainer
    })
    
    local TabLayout = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabContent
    })
    
    -- Tab activation
    local function ActivateTab()
        for _, tab in pairs(self.Tabs) do
            if tab.Active then
                tab.Active = false
                Utility:Tween(tab.Button, {BackgroundColor3 = Theme.Background, TextColor3 = Theme.TextDark}, AnimConfig.Fast)
                tab.Content.Visible = false
            end
        end
        
        Tab.Active = true
        Utility:Tween(TabButton, {BackgroundColor3 = Theme.Hover, TextColor3 = Theme.Accent}, AnimConfig.Fast)
        TabContent.Visible = true
    end
    
    TabButton.MouseButton1Click:Connect(ActivateTab)
    
    TabButton.MouseEnter:Connect(function()
        if not Tab.Active then
            Utility:Tween(TabButton, {BackgroundColor3 = Theme.Hover}, AnimConfig.Fast)
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if not Tab.Active then
            Utility:Tween(TabButton, {BackgroundColor3 = Theme.Background}, AnimConfig.Fast)
        end
    end)
    
    Tab.Button = TabButton
    Tab.Content = TabContent
    Tab.Window = self
    table.insert(self.Tabs, Tab)
    
    -- Auto-activate first tab
    if #self.Tabs == 1 then
        ActivateTab()
    end
    
    return setmetatable(Tab, {__index = Library})
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION CREATION
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateSection(config)
    config = config or {}
    local SectionName = config.Name or "Section"
    local Side = config.Side or "Left"
    
    local Section = {
        Elements = {}
    }
    
    local SectionFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.BackgroundLight,
        BorderSizePixel = 0,
        Parent = self.Content
    })
    Utility:AddCorner(SectionFrame, 8)
    Utility:AddStroke(SectionFrame, Theme.Border, 1)
    
    local SectionTitle = Utility:Create("TextLabel", {
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBedium,
        Text = SectionName,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SectionFrame
    })
    
    local ContentFrame = Utility:Create("Frame", {
        Position = UDim2.new(0, 8, 0, 32),
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = SectionFrame
    })
    
    local ContentLayout = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ContentFrame
    })
    
    Utility:Create("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        Parent = ContentFrame
    })
    
    Section.Frame = SectionFrame
    Section.Content = ContentFrame
    Section.Tab = self
    table.insert(self.Sections, Section)
    
    return setmetatable(Section, {__index = Library})
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TOGGLE ELEMENT
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateToggle(config)
    config = config or {}
    local Name = config.Name or "Toggle"
    local Default = config.Default or false
    local Callback = config.Callback or function() end
    
    local Toggle = {
        Value = Default,
        Callback = Callback,
    }
    
    local ToggleFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = self.Content
    })
    Utility:AddCorner(ToggleFrame, 6)
    
    local ToggleLabel = Utility:Create("TextLabel", {
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = Name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ToggleFrame
    })
    
    -- Toggle switch background
    local ToggleSwitch = Utility:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 38, 0, 20),
        BackgroundColor3 = Default and Theme.ToggleEnabled or Theme.ToggleDisabled,
        BorderSizePixel = 0,
        Parent = ToggleFrame
    })
    Utility:AddCorner(ToggleSwitch, 10)
    
    -- Toggle circle
    local ToggleCircle = Utility:Create("Frame", {
        Position = Default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = ToggleSwitch
    })
    Utility:AddCorner(ToggleCircle, 8)
    
    local ToggleButton = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = ToggleFrame
    })
    
    local function UpdateToggle(value)
        Toggle.Value = value
        
        if value then
            Utility:Tween(ToggleSwitch, {BackgroundColor3 = Theme.ToggleEnabled}, AnimConfig.Fast)
            Utility:Tween(ToggleCircle, {Position = UDim2.new(1, -18, 0.5, 0)}, AnimConfig.Smooth)
        else
            Utility:Tween(ToggleSwitch, {BackgroundColor3 = Theme.ToggleDisabled}, AnimConfig.Fast)
            Utility:Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, 0)}, AnimConfig.Smooth)
        end
        
        pcall(Callback, value)
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        UpdateToggle(not Toggle.Value)
    end)
    
    ToggleButton.MouseEnter:Connect(function()
        Utility:Tween(ToggleFrame, {BackgroundColor3 = Theme.Hover}, AnimConfig.Fast)
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        Utility:Tween(ToggleFrame, {BackgroundColor3 = Theme.Background}, AnimConfig.Fast)
    end)
    
    Toggle.SetValue = UpdateToggle
    
    return Toggle
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SLIDER ELEMENT
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateSlider(config)
    config = config or {}
    local Name = config.Name or "Slider"
    local Min = config.Min or 0
    local Max = config.Max or 100
    local Default = config.Default or Min
    local Suffix = config.Suffix or ""
    local Callback = config.Callback or function() end
    
    local Slider = {
        Value = Default,
        Min = Min,
        Max = Max,
        Callback = Callback,
        Dragging = false,
    }
    
    local SliderFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = self.Content
    })
    Utility:AddCorner(SliderFrame, 6)
    
    local SliderLabel = Utility:Create("TextLabel", {
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -24, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = Name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SliderFrame
    })
    
    local SliderValue = Utility:Create("TextLabel", {
        Position = UDim2.new(1, -12, 0, 6),
        Size = UDim2.new(0, 60, 0, 16),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = tostring(Default) .. Suffix,
        TextColor3 = Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = SliderFrame
    })
    
    -- Slider track
    local SliderTrack = Utility:Create("Frame", {
        Position = UDim2.new(0, 12, 1, -14),
        Size = UDim2.new(1, -24, 0, 6),
        BackgroundColor3 = Theme.SliderFill,
        BorderSizePixel = 0,
        Parent = SliderFrame
    })
    Utility:AddCorner(SliderTrack, 3)
    
    -- Slider fill
    local SliderFill = Utility:Create("Frame", {
        Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = SliderTrack
    })
    Utility:AddCorner(SliderFill, 3)
    
    local function UpdateSlider(value)
        value = math.clamp(value, Min, Max)
        Slider.Value = value
        
        local percent = (value - Min) / (Max - Min)
        Utility:Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, AnimConfig.Fast)
        SliderValue.Text = tostring(math.floor(value)) .. Suffix
        
        pcall(Callback, value)
    end
    
    local function OnDrag(input)
        local pos = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
        local value = Min + (Max - Min) * math.clamp(pos, 0, 1)
        UpdateSlider(value)
    end
    
    SliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Slider.Dragging = true
            OnDrag(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            OnDrag(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Slider.Dragging = false
        end
    end)
    
    SliderFrame.MouseEnter:Connect(function()
        Utility:Tween(SliderFrame, {BackgroundColor3 = Theme.Hover}, AnimConfig.Fast)
    end)
    
    SliderFrame.MouseLeave:Connect(function()
        Utility:Tween(SliderFrame, {BackgroundColor3 = Theme.Background}, AnimConfig.Fast)
    end)
    
    Slider.SetValue = UpdateSlider
    UpdateSlider(Default)
    
    return Slider
end

-- ═══════════════════════════════════════════════════════════════════════════
-- DROPDOWN ELEMENT
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateDropdown(config)
    config = config or {}
    local Name = config.Name or "Dropdown"
    local Options = config.Options or {"Option 1", "Option 2"}
    local Default = config.Default or Options[1]
    local Callback = config.Callback or function() end
    
    local Dropdown = {
        Value = Default,
        Options = Options,
        Callback = Callback,
        Open = false,
    }
    
    local DropdownFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 2,
        Parent = self.Content
    })
    Utility:AddCorner(DropdownFrame, 6)
    
    local DropdownLabel = Utility:Create("TextLabel", {
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = Name,
        TextColor3 = Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = DropdownFrame
    })
    
    local DropdownValue = Utility:Create("TextLabel", {
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = Default,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = DropdownFrame
    })
    
    local DropdownArrow = Utility:Create("TextLabel", {
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "▼",
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        Parent = DropdownFrame
    })
    
    local OptionsContainer = Utility:Create("Frame", {
        Position = UDim2.new(0, 0, 1, 4),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.BackgroundLight,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 10,
        Parent = DropdownFrame
    })
    Utility:AddCorner(OptionsContainer, 6)
    Utility:AddStroke(OptionsContainer, Theme.Border, 1)
    
    local OptionsList = Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        Parent = OptionsContainer
    })
    
    Utility:Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        Parent = OptionsContainer
    })
    
    local function CreateOption(option)
        local OptionButton = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = option == Dropdown.Value and Theme.Hover or Color3.fromRGB(0, 0, 0, 0),
            BackgroundTransparency = option == Dropdown.Value and 0 or 1,
            BorderSizePixel = 0,
            Font = Enum.Font.Gotham,
            Text = option,
            TextColor3 = Theme.Text,
            TextSize = 12,
            ZIndex = 11,
            Parent = OptionsContainer
        })
        Utility:AddCorner(OptionButton, 4)
        
        OptionButton.MouseButton1Click:Connect(function()
            Dropdown.Value = option
            DropdownValue.Text = option
            
            -- Update all options
            for _, child in pairs(OptionsContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    if child.Text == option then
                        Utility:Tween(child, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Hover}, AnimConfig.Fast)
                    else
                        Utility:Tween(child, {BackgroundTransparency = 1}, AnimConfig.Fast)
                    end
                end
            end
            
            -- Close dropdown
            Dropdown.Open = false
            Utility:Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, AnimConfig.Fast)
            task.wait(0.15)
            OptionsContainer.Visible = false
            Utility:Tween(DropdownArrow, {Rotation = 0}, AnimConfig.Fast)
            
            pcall(Callback, option)
        end)
        
        OptionButton.MouseEnter:Connect(function()
            if Dropdown.Value ~= option then
                Utility:Tween(OptionButton, {BackgroundColor3 = Theme.Hover, BackgroundTransparency = 0.5}, AnimConfig.Fast)
            end
        end)
        
        OptionButton.MouseLeave:Connect(function()
            if Dropdown.Value ~= option then
                Utility:Tween(OptionButton, {BackgroundTransparency = 1}, AnimConfig.Fast)
            end
        end)
    end
    
    for _, option in ipairs(Options) do
        CreateOption(option)
    end
    
    local DropdownButton = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3,
        Parent = DropdownFrame
    })
    
    DropdownButton.MouseButton1Click:Connect(function()
        Dropdown.Open = not Dropdown.Open
        
        if Dropdown.Open then
            OptionsContainer.Visible = true
            OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
            Utility:Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, math.min(#Options * 28 + 8, 200))}, AnimConfig.Medium)
            Utility:Tween(DropdownArrow, {Rotation = 180}, AnimConfig.Fast)
        else
            Utility:Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, AnimConfig.Fast)
            Utility:Tween(DropdownArrow, {Rotation = 0}, AnimConfig.Fast)
            task.wait(0.15)
            OptionsContainer.Visible = false
        end
    end)
    
    DropdownFrame.MouseEnter:Connect(function()
        Utility:Tween(DropdownFrame, {BackgroundColor3 = Theme.Hover}, AnimConfig.Fast)
    end)
    
    DropdownFrame.MouseLeave:Connect(function()
        Utility:Tween(DropdownFrame, {BackgroundColor3 = Theme.Background}, AnimConfig.Fast)
    end)
    
    return Dropdown
end

-- ═══════════════════════════════════════════════════════════════════════════
-- BUTTON ELEMENT
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateButton(config)
    config = config or {}
    local Name = config.Name or "Button"
    local Callback = config.Callback or function() end
    
    local ButtonFrame = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Text = Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Parent = self.Content
    })
    Utility:AddCorner(ButtonFrame, 6)
    
    ButtonFrame.MouseButton1Click:Connect(function()
        Utility:Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentDark}, AnimConfig.Fast)
        task.wait(0.1)
        Utility:Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, AnimConfig.Fast)
        pcall(Callback)
    end)
    
    ButtonFrame.MouseEnter:Connect(function()
        Utility:Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentLight}, AnimConfig.Fast)
    end)
    
    ButtonFrame.MouseLeave:Connect(function()
        Utility:Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, AnimConfig.Fast)
    end)
    
    return ButtonFrame
end

-- ═══════════════════════════════════════════════════════════════════════════
-- COLOR PICKER ELEMENT
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateColorPicker(config)
    config = config or {}
    local Name = config.Name or "Color"
    local Default = config.Default or Color3.fromRGB(220, 50, 80)
    local Callback = config.Callback or function() end
    
    local ColorPicker = {
        Value = Default,
        Callback = Callback,
    }
    
    local PickerFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = self.Content
    })
    Utility:AddCorner(PickerFrame, 6)
    
    local PickerLabel = Utility:Create("TextLabel", {
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = Name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = PickerFrame
    })
    
    local ColorDisplay = Utility:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 20),
        BackgroundColor3 = Default,
        BorderSizePixel = 0,
        Parent = PickerFrame
    })
    Utility:AddCorner(ColorDisplay, 4)
    Utility:AddStroke(ColorDisplay, Theme.Border, 1)
    
    local function UpdateColor(color)
        ColorPicker.Value = color
        ColorDisplay.BackgroundColor3 = color
        pcall(Callback, color)
    end
    
    ColorPicker.SetValue = UpdateColor
    
    return ColorPicker
end

-- ═══════════════════════════════════════════════════════════════════════════
-- KEYBIND ELEMENT
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateKeybind(config)
    config = config or {}
    local Name = config.Name or "Keybind"
    local Default = config.Default or Enum.KeyCode.E
    local Callback = config.Callback or function() end
    
    local Keybind = {
        Value = Default,
        Callback = Callback,
        Binding = false,
    }
    
    local KeybindFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = self.Content
    })
    Utility:AddCorner(KeybindFrame, 6)
    
    local KeybindLabel = Utility:Create("TextLabel", {
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -90, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = Name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = KeybindFrame
    })
    
    local KeybindButton = Utility:Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 70, 0, 24),
        BackgroundColor3 = Theme.BackgroundDark,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Text = Default.Name,
        TextColor3 = Theme.Text,
        TextSize = 11,
        Parent = KeybindFrame
    })
    Utility:AddCorner(KeybindButton, 4)
    
    KeybindButton.MouseButton1Click:Connect(function()
        Keybind.Binding = true
        KeybindButton.Text = "..."
        Utility:Tween(KeybindButton, {BackgroundColor3 = Theme.Accent}, AnimConfig.Fast)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if Keybind.Binding and input.UserInputType == Enum.UserInputType.Keyboard then
            Keybind.Value = input.KeyCode
            KeybindButton.Text = input.KeyCode.Name
            Keybind.Binding = false
            Utility:Tween(KeybindButton, {BackgroundColor3 = Theme.BackgroundDark}, AnimConfig.Fast)
            pcall(Callback, input.KeyCode)
        end
    end)
    
    return Keybind
end

return Library
