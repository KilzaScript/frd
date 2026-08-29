--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║              HATE Universal — GUI Library v2.0                       ║
    ║         Professional Matcha-quality design system                    ║
    ║         Top-bar navigation · Two-column layout · Full animations     ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════════════
local Library = {}
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local Players         = game:GetService("Players")
local CoreGui         = game:GetService("CoreGui")
local HttpService     = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse  = Player:GetMouse()

-- ═══════════════════════════════════════════════════════════════════════════
-- THEME  (Hate Universal — dark red accent, Matcha density)
-- ═══════════════════════════════════════════════════════════════════════════
local Theme = {
    -- Backgrounds
    BG          = Color3.fromRGB(15, 15, 18),       -- window background
    BGPanel     = Color3.fromRGB(20, 20, 24),       -- panel / section bg
    BGElement   = Color3.fromRGB(25, 25, 30),       -- individual element row bg
    BGDark      = Color3.fromRGB(11, 11, 14),       -- top bar / darker areas
    BGHover     = Color3.fromRGB(30, 30, 37),       -- hover state
    BGActive    = Color3.fromRGB(35, 35, 43),       -- active/pressed

    -- Accent (red)
    Accent      = Color3.fromRGB(220, 50,  75),
    AccentDark  = Color3.fromRGB(170, 38,  58),
    AccentLight = Color3.fromRGB(255, 75, 100),
    AccentGlow  = Color3.fromRGB(220, 50,  75),

    -- Borders
    Border      = Color3.fromRGB(38, 38, 46),
    BorderLight = Color3.fromRGB(52, 52, 62),

    -- Text
    Text        = Color3.fromRGB(242, 242, 248),
    TextSub     = Color3.fromRGB(165, 165, 178),
    TextMuted   = Color3.fromRGB(108, 108, 120),
    TextDisabled= Color3.fromRGB(72,  72,  82),

    -- Toggle
    ToggleOn    = Color3.fromRGB(220, 50,  75),
    ToggleOff   = Color3.fromRGB(38,  38,  48),
    ToggleDot   = Color3.fromRGB(255, 255, 255),

    -- Slider
    SliderTrack = Color3.fromRGB(32,  32,  40),
    SliderFill  = Color3.fromRGB(220, 50,  75),

    -- Tab bar
    TabBar      = Color3.fromRGB(13, 13, 16),
    TabActive   = Color3.fromRGB(220, 50,  75),
    TabInactive = Color3.fromRGB(108, 108, 120),
    TabBg       = Color3.fromRGB(13, 13, 16),

    -- Notification
    NotifBg     = Color3.fromRGB(22, 22, 28),
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ANIMATION PRESETS
-- ═══════════════════════════════════════════════════════════════════════════
local Anim = {
    Instant  = TweenInfo.new(0.08,  Enum.EasingStyle.Linear),
    Fast     = TweenInfo.new(0.14,  Enum.EasingStyle.Quad,   Enum.EasingDirection.Out),
    Medium   = TweenInfo.new(0.22,  Enum.EasingStyle.Quad,   Enum.EasingDirection.Out),
    Slow     = TweenInfo.new(0.32,  Enum.EasingStyle.Quad,   Enum.EasingDirection.Out),
    Sine     = TweenInfo.new(0.28,  Enum.EasingStyle.Sine,   Enum.EasingDirection.Out),
    Spring   = TweenInfo.new(0.38,  Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
    SineIn   = TweenInfo.new(0.22,  Enum.EasingStyle.Sine,   Enum.EasingDirection.In),
    Toggle   = TweenInfo.new(0.18,  Enum.EasingStyle.Sine,   Enum.EasingDirection.Out),
    Window   = TweenInfo.new(0.30,  Enum.EasingStyle.Quint,  Enum.EasingDirection.Out),
}

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITY
-- ═══════════════════════════════════════════════════════════════════════════
local U = {}

function U.New(class, props, children)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do i[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = i end
    return i
end

function U.Tween(inst, props, info)
    local t = TweenService:Create(inst, info or Anim.Fast, props)
    t:Play()
    return t
end

function U.Corner(inst, r)
    return U.New("UICorner", {CornerRadius = UDim.new(0, r or 6), Parent = inst})
end

function U.Stroke(inst, col, thick)
    return U.New("UIStroke", {
        Color            = col   or Theme.Border,
        Thickness        = thick or 1,
        Transparency     = 0,
        ApplyStrokeMode  = Enum.ApplyStrokeMode.Border,
        Parent           = inst
    })
end

function U.Pad(inst, t, b, l, r)
    return U.New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
        Parent        = inst
    })
end

function U.List(inst, pad, dir)
    return U.New("UIListLayout", {
        Padding           = UDim.new(0, pad or 0),
        SortOrder         = Enum.SortOrder.LayoutOrder,
        FillDirection     = dir or Enum.FillDirection.Vertical,
        Parent            = inst
    })
end

function U.Gradient(inst, seq, rot)
    return U.New("UIGradient", {ColorSequence = seq, Rotation = rot or 90, Parent = inst})
end

function U.MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateLoader(callback)
    local gui = U.New("ScreenGui", {
        Name            = "HateLoader_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset  = true,
        Parent          = CoreGui,
    })

    -- Full-screen dark background
    local bg = U.New("Frame", {
        Size                = UDim2.new(1, 0, 1, 0),
        BackgroundColor3    = Color3.fromRGB(8, 8, 10),
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        Parent              = gui,
    })

    -- ── Red edge vignette (4 gradient panels) ────────────────────────────
    local function edgeGlow(ap, pos, rot)
        local f = U.New("Frame", {
            AnchorPoint          = ap,
            Position             = pos,
            Size                 = UDim2.new(0.55, 0, 0.55, 0),
            BackgroundColor3     = Color3.fromRGB(220, 50, 75),
            BackgroundTransparency = 0.72,
            BorderSizePixel      = 0,
            Parent               = bg,
        })
        U.Corner(f, 999)
        U.Gradient(f, ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 50, 75)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8,  8,  10)),
        }, rot)
        -- pulse
        TweenService:Create(f, TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            BackgroundTransparency = 0.88,
        }):Play()
        return f
    end
    edgeGlow(Vector2.new(0, 0), UDim2.new(0,  0, 0,  0), 135)
    edgeGlow(Vector2.new(1, 0), UDim2.new(1,  0, 0,  0), 225)
    edgeGlow(Vector2.new(0, 1), UDim2.new(0,  0, 1,  0),  45)
    edgeGlow(Vector2.new(1, 1), UDim2.new(1,  0, 1,  0), 315)

    -- ── Centre container ─────────────────────────────────────────────────
    local centre = U.New("Frame", {
        AnchorPoint          = Vector2.new(0.5, 0.5),
        Position             = UDim2.new(0.5, 0, 0.5, 0),
        Size                 = UDim2.new(0, 340, 0, 320),
        BackgroundTransparency = 1,
        Parent               = bg,
    })

    -- HATE wordmark
    local logo = U.New("TextLabel", {
        AnchorPoint          = Vector2.new(0.5, 0),
        Position             = UDim2.new(0.5, 0, 0, 0),
        Size                 = UDim2.new(0, 340, 0, 64),
        BackgroundTransparency = 1,
        Font                 = Enum.Font.GothamBold,
        Text                 = "HATE",
        TextColor3           = Color3.fromRGB(255, 255, 255),
        TextSize             = 54,
        TextStrokeColor3     = Color3.fromRGB(220, 50, 75),
        TextStrokeTransparency = 0.55,
        TextTransparency     = 1,
        Parent               = centre,
    })

    -- "Universal" subtitle
    local sub = U.New("TextLabel", {
        AnchorPoint          = Vector2.new(0.5, 0),
        Position             = UDim2.new(0.5, 0, 0, 60),
        Size                 = UDim2.new(0, 340, 0, 22),
        BackgroundTransparency = 1,
        Font                 = Enum.Font.GothamMedium,
        Text                 = "UNIVERSAL",
        TextColor3           = Color3.fromRGB(220, 50, 75),
        TextSize             = 13,
        TextTransparency     = 1,
        Parent               = centre,
    })

    -- Divider line
    local divider = U.New("Frame", {
        AnchorPoint          = Vector2.new(0.5, 0),
        Position             = UDim2.new(0.5, 0, 0, 90),
        Size                 = UDim2.new(0, 180, 0, 1),
        BackgroundColor3     = Color3.fromRGB(220, 50, 75),
        BackgroundTransparency = 0.6,
        BorderSizePixel      = 0,
        Parent               = centre,
    })

    -- Asset image (rbxassetid://74199950139770)
    local img = U.New("ImageLabel", {
        AnchorPoint          = Vector2.new(0.5, 0),
        Position             = UDim2.new(0.5, 0, 0, 102),
        Size                 = UDim2.new(0, 110, 0, 110),
        BackgroundTransparency = 1,
        Image                = "rbxassetid://74199950139770",
        ScaleType            = Enum.ScaleType.Fit,
        ImageTransparency    = 1,
        Parent               = centre,
    })
    U.Corner(img, 10)

    -- Status text
    local statusTxt = U.New("TextLabel", {
        AnchorPoint          = Vector2.new(0.5, 0),
        Position             = UDim2.new(0.5, 0, 0, 224),
        Size                 = UDim2.new(0, 300, 0, 18),
        BackgroundTransparency = 1,
        Font                 = Enum.Font.Gotham,
        Text                 = "Initializing...",
        TextColor3           = Theme.TextMuted,
        TextSize             = 12,
        TextTransparency     = 1,
        Parent               = centre,
    })

    -- Progress track
    local pTrack = U.New("Frame", {
        AnchorPoint          = Vector2.new(0.5, 0),
        Position             = UDim2.new(0.5, 0, 0, 248),
        Size                 = UDim2.new(0, 300, 0, 3),
        BackgroundColor3     = Color3.fromRGB(32, 32, 40),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        Parent               = centre,
    })
    U.Corner(pTrack, 2)

    -- Progress fill
    local pFill = U.New("Frame", {
        Size                 = UDim2.new(0, 0, 1, 0),
        BackgroundColor3     = Color3.fromRGB(220, 50, 75),
        BorderSizePixel      = 0,
        Parent               = pTrack,
    })
    U.Corner(pFill, 2)

    -- Progress glow on fill
    U.New("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 50, 75)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 90, 110)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 50, 75)),
        },
        Rotation = 0,
        Parent = pFill,
    })

    -- Percentage label
    local pctTxt = U.New("TextLabel", {
        AnchorPoint          = Vector2.new(0.5, 0),
        Position             = UDim2.new(0.5, 0, 0, 258),
        Size                 = UDim2.new(0, 300, 0, 18),
        BackgroundTransparency = 1,
        Font                 = Enum.Font.GothamMedium,
        Text                 = "0%",
        TextColor3           = Theme.Text,
        TextSize             = 13,
        TextTransparency     = 1,
        Parent               = centre,
    })

    -- ── Fade everything in ────────────────────────────────────────────────
    task.wait(0.05)
    U.Tween(bg,        {BackgroundTransparency = 0},   Anim.Medium)
    U.Tween(logo,      {TextTransparency = 0},         Anim.Medium)
    U.Tween(sub,       {TextTransparency = 0},         Anim.Medium)
    U.Tween(img,       {ImageTransparency = 0},        Anim.Slow)
    U.Tween(statusTxt, {TextTransparency = 0},         Anim.Medium)
    U.Tween(pTrack,    {BackgroundTransparency = 0},   Anim.Medium)
    U.Tween(pctTxt,    {TextTransparency = 0},         Anim.Medium)
    task.wait(0.45)

    -- ── Animated loading stages ───────────────────────────────────────────
    local stages = {
        { pct = 18,  text = "Loading core modules...",     dur = 0.55 },
        { pct = 36,  text = "Setting up aimbot...",        dur = 0.45 },
        { pct = 54,  text = "Initialising ESP system...",  dur = 0.50 },
        { pct = 72,  text = "Building interface...",       dur = 0.40 },
        { pct = 88,  text = "Applying theme...",           dur = 0.38 },
        { pct = 100, text = "Done.",                       dur = 0.30 },
    }

    local currentPct = 0
    for _, stage in ipairs(stages) do
        statusTxt.Text = stage.text

        -- Smooth fill tween
        TweenService:Create(pFill, TweenInfo.new(stage.dur * 0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(stage.pct / 100, 0, 1, 0)
        }):Play()

        -- Smooth percentage counter
        local from = currentPct
        local to   = stage.pct
        local steps = math.floor(stage.dur * 60)
        for s = 1, steps do
            task.wait(stage.dur / steps)
            local v = math.floor(from + (to - from) * (s / steps))
            pctTxt.Text = v .. "%"
        end
        pctTxt.Text = stage.pct .. "%"
        currentPct  = stage.pct
    end

    task.wait(0.4)

    -- ── Fade out ──────────────────────────────────────────────────────────
    U.Tween(bg,        {BackgroundTransparency = 1},  Anim.Slow)
    U.Tween(logo,      {TextTransparency = 1},        Anim.Medium)
    U.Tween(sub,       {TextTransparency = 1},        Anim.Medium)
    U.Tween(img,       {ImageTransparency = 1},       Anim.Medium)
    U.Tween(statusTxt, {TextTransparency = 1},        Anim.Medium)
    U.Tween(pTrack,    {BackgroundTransparency = 1},  Anim.Medium)
    U.Tween(pFill,     {BackgroundTransparency = 1},  Anim.Medium)
    U.Tween(pctTxt,    {TextTransparency = 1},        Anim.Medium)
    task.wait(0.38)
    gui:Destroy()

    if callback then callback() end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════
local NotifGui
local NotifList
local function ensureNotifGui()
    if NotifGui and NotifGui.Parent then return end
    NotifGui = U.New("ScreenGui", {
        Name           = "HateNotif",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = CoreGui,
    })
    local container = U.New("Frame", {
        AnchorPoint   = Vector2.new(1, 1),
        Position      = UDim2.new(1, -18, 1, -18),
        Size          = UDim2.new(0, 280, 1, -36),
        BackgroundTransparency = 1,
        Parent        = NotifGui,
    })
    NotifList = U.New("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding           = UDim.new(0, 8),
        SortOrder         = Enum.SortOrder.LayoutOrder,
        Parent            = container,
    })
    NotifList.Parent = container
end

function Library:Notify(config)
    config = config or {}
    local title    = config.Title   or "Hate Universal"
    local message  = config.Message or ""
    local duration = config.Duration or 4
    local ntype    = config.Type    or "info"   -- "info", "success", "error", "warning"

    ensureNotifGui()

    local accentCol = ({
        info    = Theme.Accent,
        success = Color3.fromRGB(60, 200, 100),
        error   = Color3.fromRGB(220, 60,  60),
        warning = Color3.fromRGB(230, 170,  30),
    })[ntype] or Theme.Accent

    local card = U.New("Frame", {
        Size                 = UDim2.new(1, 0, 0, 68),
        BackgroundColor3     = Theme.NotifBg,
        BackgroundTransparency = 0,
        BorderSizePixel      = 0,
        ClipsDescendants     = true,
        Parent               = NotifList.Parent,
    })
    U.Corner(card, 8)
    U.Stroke(card, Theme.Border, 1)

    -- Accent left bar
    U.New("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accentCol,
        BorderSizePixel  = 0,
        Parent           = card,
    })

    U.New("TextLabel", {
        Position             = UDim2.new(0, 14, 0, 10),
        Size                 = UDim2.new(1, -18, 0, 18),
        BackgroundTransparency = 1,
        Font                 = Enum.Font.GothamBold,
        Text                 = title,
        TextColor3           = Theme.Text,
        TextSize             = 13,
        TextXAlignment       = Enum.TextXAlignment.Left,
        Parent               = card,
    })

    U.New("TextLabel", {
        Position             = UDim2.new(0, 14, 0, 30),
        Size                 = UDim2.new(1, -18, 0, 30),
        BackgroundTransparency = 1,
        Font                 = Enum.Font.Gotham,
        Text                 = message,
        TextColor3           = Theme.TextSub,
        TextSize             = 12,
        TextWrapped          = true,
        TextXAlignment       = Enum.TextXAlignment.Left,
        TextYAlignment       = Enum.TextYAlignment.Top,
        Parent               = card,
    })

    -- Slide in
    card.Position = UDim2.new(1, 10, 0, 0)
    U.Tween(card, {Position = UDim2.new(0, 0, 0, 0)}, Anim.Spring)

    task.delay(duration, function()
        U.Tween(card, {Position = UDim2.new(1, 10, 0, 0)}, Anim.Sine)
        task.wait(0.35)
        U.Tween(card, {Size = UDim2.new(1, 0, 0, 0)}, Anim.Fast)
        task.wait(0.18)
        card:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MAIN WINDOW
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateWindow(config)
    config = config or {}
    local wName      = config.Name    or "Hate Universal"
    local wAccent    = config.Accent  or Theme.Accent
    local wToggleKey = config.Key     or Enum.KeyCode.RightShift
    local wSize      = config.Size    or {720, 500}

    Theme.Accent      = wAccent
    Theme.AccentDark  = Color3.fromRGB(
        math.clamp(wAccent.R * 255 * 0.78, 0, 255),
        math.clamp(wAccent.G * 255 * 0.78, 0, 255),
        math.clamp(wAccent.B * 255 * 0.78, 0, 255)
    )
    Theme.AccentLight = Color3.fromRGB(
        math.clamp(wAccent.R * 255 * 1.18, 0, 255),
        math.clamp(wAccent.G * 255 * 1.18, 0, 255),
        math.clamp(wAccent.B * 255 * 1.18, 0, 255)
    )
    Theme.ToggleOn    = wAccent
    Theme.SliderFill  = wAccent
    Theme.TabActive   = wAccent

    local Window = {
        Tabs        = {},
        ActiveTab   = nil,
        Visible     = true,
        ToggleKey   = wToggleKey,
        Flags       = {},
    }

    -- ── Screen gui ────────────────────────────────────────────────────────
    local ScreenGui = U.New("ScreenGui", {
        Name            = "HateHub_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset  = true,
        Parent          = CoreGui,
    })

    -- ── Main frame ────────────────────────────────────────────────────────
    local W = wSize[1]
    local H = wSize[2]

    local MainFrame = U.New("Frame", {
        Name                 = "MainWindow",
        AnchorPoint          = Vector2.new(0.5, 0.5),
        Position             = UDim2.new(0.5, 0, 0.5, 0),
        Size                 = UDim2.new(0, 0, 0, 0),   -- starts at 0 for open anim
        BackgroundColor3     = Theme.BG,
        BorderSizePixel      = 0,
        ClipsDescendants     = true,
        Parent               = ScreenGui,
    })
    U.Corner(MainFrame, 10)
    U.Stroke(MainFrame, Theme.Border, 1)

    -- Outer drop shadow simulation
    local Shadow = U.New("ImageLabel", {
        AnchorPoint          = Vector2.new(0.5, 0.5),
        Position             = UDim2.new(0.5, 0, 0.5, 0),
        Size                 = UDim2.new(1, 60, 1, 60),
        BackgroundTransparency = 1,
        Image                = "rbxassetid://6014261993",
        ImageColor3          = Color3.fromRGB(0, 0, 0),
        ImageTransparency    = 0.5,
        ScaleType            = Enum.ScaleType.Slice,
        SliceCenter          = Rect.new(49, 49, 450, 450),
        ZIndex               = -1,
        Parent               = MainFrame,
    })

    -- ── Top bar ───────────────────────────────────────────────────────────
    -- Height: 38px logo area + 34px tab strip = 72px total header
    local Header = U.New("Frame", {
        Name             = "Header",
        Size             = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = Theme.BGDark,
        BorderSizePixel  = 0,
        Parent           = MainFrame,
    })
    -- bottom border line on header
    U.New("Frame", {
        AnchorPoint      = Vector2.new(0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        Parent           = Header,
    })

    -- Logo row (top 38px)
    local LogoRow = U.New("Frame", {
        Size             = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        Parent           = Header,
    })

    -- Logo text
    U.New("TextLabel", {
        Position         = UDim2.new(0, 16, 0, 0),
        Size             = UDim2.new(0, 200, 1, 0),
        BackgroundTransparency = 1,
        Font             = Enum.Font.GothamBold,
        Text             = "HATE",
        TextColor3       = Theme.Text,
        TextSize         = 17,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = LogoRow,
    })
    U.New("TextLabel", {
        Position         = UDim2.new(0, 63, 0, 0),
        Size             = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Font             = Enum.Font.GothamMedium,
        Text             = "Universal",
        TextColor3       = Theme.TextMuted,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = LogoRow,
    })

    -- Close / minimise buttons
    local function makeHeaderBtn(text, apX, offX, hoverCol, clickFn)
        local btn = U.New("TextButton", {
            AnchorPoint          = Vector2.new(apX, 0.5),
            Position             = UDim2.new(1, offX, 0.5, 0),
            Size                 = UDim2.new(0, 26, 0, 20),
            BackgroundColor3     = Theme.BGElement,
            BorderSizePixel      = 0,
            Font                 = Enum.Font.GothamBold,
            Text                 = text,
            TextColor3           = Theme.TextMuted,
            TextSize             = 14,
            Parent               = LogoRow,
        })
        U.Corner(btn, 4)
        btn.MouseEnter:Connect(function()
            U.Tween(btn, {BackgroundColor3 = hoverCol, TextColor3 = Theme.Text}, Anim.Fast)
        end)
        btn.MouseLeave:Connect(function()
            U.Tween(btn, {BackgroundColor3 = Theme.BGElement, TextColor3 = Theme.TextMuted}, Anim.Fast)
        end)
        btn.MouseButton1Click:Connect(clickFn)
        return btn
    end

    makeHeaderBtn("×", 1, -10, Color3.fromRGB(200, 50, 50), function()
        U.Tween(MainFrame, {Size = UDim2.new(0, W, 0, 0)}, Anim.Sine)
        task.wait(0.25)
        ScreenGui:Destroy()
    end)

    makeHeaderBtn("−", 1, -42, Theme.BGHover, function()
        Window.Visible = false
        U.Tween(MainFrame, {Size = UDim2.new(0, W, 0, 0)}, Anim.Sine)
    end)

    -- ── Tab strip (bottom 34px of header) ────────────────────────────────
    local TabStrip = U.New("Frame", {
        Position         = UDim2.new(0, 0, 0, 38),
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent           = Header,
    })

    local TabStripList = U.New("UIListLayout", {
        FillDirection     = Enum.FillDirection.Horizontal,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding           = UDim.new(0, 0),
        Parent            = TabStrip,
    })
    U.Pad(TabStrip, 0, 0, 14, 14)

    -- Tab indicator bar (slides under active tab)
    local TabIndicator = U.New("Frame", {
        AnchorPoint      = Vector2.new(0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        Size             = UDim2.new(0, 60, 0, 2),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = TabStrip,
    })
    U.Corner(TabIndicator, 1)

    -- ── Content area ──────────────────────────────────────────────────────
    local ContentArea = U.New("Frame", {
        Position         = UDim2.new(0, 0, 0, 72),
        Size             = UDim2.new(1, 0, 1, -72),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = MainFrame,
    })

    -- ── Draggable ─────────────────────────────────────────────────────────
    U.MakeDraggable(MainFrame, LogoRow)

    -- ── Open animation ────────────────────────────────────────────────────
    task.spawn(function()
        task.wait(0.02)
        U.Tween(MainFrame, {Size = UDim2.new(0, W, 0, H)}, Anim.Window)
    end)

    -- ── Toggle keybind ────────────────────────────────────────────────────
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Window.ToggleKey then
            Window.Visible = not Window.Visible
            if Window.Visible then
                MainFrame.Visible = true
                U.Tween(MainFrame, {Size = UDim2.new(0, W, 0, H)}, Anim.Window)
            else
                U.Tween(MainFrame, {Size = UDim2.new(0, W, 0, 0)}, Anim.Sine)
                task.delay(0.3, function() MainFrame.Visible = false end)
            end
        end
    end)

    -- ── Store references ──────────────────────────────────────────────────
    Window.ScreenGui    = ScreenGui
    Window.MainFrame    = MainFrame
    Window.ContentArea  = ContentArea
    Window.TabStrip     = TabStrip
    Window.TabIndicator = TabIndicator
    Window.W            = W
    Window.H            = H

    -- ── CreateTab ─────────────────────────────────────────────────────────
    function Window:CreateTab(cfg)
        cfg = cfg or {}
        local tName = cfg.Name or "Tab"

        local Tab = {
            Sections = {},
            Buttons  = {},
            Active   = false,
            Window   = self,
        }

        -- Tab button
        local btn = U.New("TextButton", {
            Size                 = UDim2.new(0, 0, 1, 0),
            AutomaticSize        = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            Font                 = Enum.Font.GothamMedium,
            Text                 = tName,
            TextColor3           = Theme.TabInactive,
            TextSize             = 13,
            Parent               = self.TabStrip,
        })
        U.Pad(btn, 0, 0, 16, 16)

        -- Tab content page (full content area)
        local page = U.New("ScrollingFrame", {
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel       = 0,
            ScrollBarThickness    = 3,
            ScrollBarImageColor3  = Theme.Accent,
            ScrollBarImageTransparency = 0.5,
            CanvasSize            = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize   = Enum.AutomaticSize.Y,
            Visible               = false,
            Parent                = self.ContentArea,
        })
        U.Pad(page, 14, 14, 14, 14)

        -- Two-column layout inside page
        -- Uses UITableLayout for reliable 50/50 split
        local columns = U.New("Frame", {
            Size          = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent        = page,
        })
        U.New("UITableLayout", {
            FillDirection        = Enum.FillDirection.Horizontal,
            FillEmptySpaceColumns = true,
            SortOrder            = Enum.SortOrder.LayoutOrder,
            Padding              = UDim2.new(0, 10, 0, 0),
            Parent               = columns,
        })

        -- Left column
        local colL = U.New("Frame", {
            Size          = UDim2.new(0, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder   = 1,
            Parent        = columns,
        })
        U.List(colL, 10)

        -- Right column
        local colR = U.New("Frame", {
            Size          = UDim2.new(0, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder   = 2,
            Parent        = columns,
        })
        U.List(colR, 10)

        local function Activate()
            -- Deactivate all tabs
            for _, t in ipairs(Window.Tabs) do
                if t.Active then
                    t.Active = false
                    U.Tween(t.Btn, {TextColor3 = Theme.TabInactive}, Anim.Fast)
                    t.Page.Visible = false
                end
            end

            Tab.Active = true
            U.Tween(btn, {TextColor3 = Theme.Text}, Anim.Fast)
            page.Visible = true

            -- Slide indicator to this tab button
            task.spawn(function()
                task.wait()
                local bPos = btn.AbsolutePosition.X - self.TabStrip.AbsolutePosition.X
                local bW   = btn.AbsoluteSize.X
                U.Tween(self.TabIndicator, {
                    Position = UDim2.new(0, bPos, 1, 0),
                    Size     = UDim2.new(0, bW, 0, 2),
                }, Anim.Sine)
            end)
        end

        btn.MouseButton1Click:Connect(Activate)
        btn.MouseEnter:Connect(function()
            if not Tab.Active then
                U.Tween(btn, {TextColor3 = Theme.TextSub}, Anim.Fast)
            end
        end)
        btn.MouseLeave:Connect(function()
            if not Tab.Active then
                U.Tween(btn, {TextColor3 = Theme.TabInactive}, Anim.Fast)
            end
        end)

        Tab.Btn     = btn
        Tab.Page    = page
        Tab.Columns = columns
        Tab.ColL    = colL
        Tab.ColR    = colR
        Tab.Activate = Activate

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            task.spawn(function()
                task.wait(0.35)   -- wait for open anim
                Activate()
            end)
        end

        -- ── CreateSection ─────────────────────────────────────────────────
        function Tab:CreateSection(scfg)
            scfg = scfg or {}
            local sName = scfg.Name  or "Section"
            local sSide = scfg.Side  or "Left"     -- "Left" | "Right" | "Full"

            local Section = { Elements = {} }

            -- Choose parent column
            local parentCol
            if sSide == "Right" then
                parentCol = Tab.ColR
            elseif sSide == "Full" then
                -- Full-width section: insert into left column (columns layout handles width)
                -- Caller should use Side="Left" for full-width by convention, or we
                -- create a dedicated full-width row frame underneath columns
                local fullRow = U.New("Frame", {
                    Size          = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Parent        = Tab.Page,
                })
                U.List(fullRow, 0)
                parentCol = fullRow
            else
                parentCol = Tab.ColL
            end

            -- Section card
            local card = U.New("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.BGPanel,
                BorderSizePixel  = 0,
                Parent           = parentCol,
            })
            U.Corner(card, 8)
            U.Stroke(card, Theme.Border, 1)

            -- Section header
            local headerRow = U.New("Frame", {
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundTransparency = 1,
                Parent           = card,
            })

            U.New("TextLabel", {
                Position         = UDim2.new(0, 12, 0, 0),
                Size             = UDim2.new(1, -24, 1, 0),
                BackgroundTransparency = 1,
                Font             = Enum.Font.GothamBold,
                Text             = sName,
                TextColor3       = Theme.Text,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = headerRow,
            })

            -- Thin accent line under section title
            U.New("Frame", {
                AnchorPoint      = Vector2.new(0, 1),
                Position         = UDim2.new(0, 0, 1, 0),
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel  = 0,
                Parent           = headerRow,
            })

            -- Content frame inside card
            local content = U.New("Frame", {
                Position         = UDim2.new(0, 0, 0, 34),
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent           = card,
            })
            U.Pad(content, 6, 10, 10, 10)
            U.List(content, 6)

            Section.Card    = card
            Section.Content = content

            table.insert(Tab.Sections, Section)

            -- ── CreateToggle ───────────────────────────────────────────────
            function Section:CreateToggle(ecfg)
                ecfg = ecfg or {}
                local eName     = ecfg.Name     or "Toggle"
                local eDefault  = ecfg.Default  or false
                local eCallback = ecfg.Callback or function() end
                local eTooltip  = ecfg.Tooltip

                local Tog = { Value = eDefault }

                local row = U.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.BGElement,
                    BorderSizePixel  = 0,
                    Parent           = Section.Content,
                })
                U.Corner(row, 6)

                U.New("TextLabel", {
                    Position         = UDim2.new(0, 10, 0, 0),
                    Size             = UDim2.new(1, -58, 1, 0),
                    BackgroundTransparency = 1,
                    Font             = Enum.Font.Gotham,
                    Text             = eName,
                    TextColor3       = Theme.Text,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = row,
                })

                -- Switch track
                local track = U.New("Frame", {
                    AnchorPoint      = Vector2.new(1, 0.5),
                    Position         = UDim2.new(1, -10, 0.5, 0),
                    Size             = UDim2.new(0, 36, 0, 20),
                    BackgroundColor3 = eDefault and Theme.ToggleOn or Theme.ToggleOff,
                    BorderSizePixel  = 0,
                    Parent           = row,
                })
                U.Corner(track, 10)

                -- Switch dot
                local dot = U.New("Frame", {
                    AnchorPoint      = Vector2.new(0, 0.5),
                    Position         = eDefault and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    Size             = UDim2.new(0, 16, 0, 16),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel  = 0,
                    Parent           = track,
                })
                U.Corner(dot, 8)

                local function setVal(v)
                    Tog.Value = v
                    U.Tween(track, {BackgroundColor3 = v and Theme.ToggleOn or Theme.ToggleOff}, Anim.Toggle)
                    U.Tween(dot,   {Position = v and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, Anim.Toggle)
                    pcall(eCallback, v)
                end

                local clickZone = U.New("TextButton", {
                    Size                 = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                 = "",
                    Parent               = row,
                })
                clickZone.MouseButton1Click:Connect(function() setVal(not Tog.Value) end)

                clickZone.MouseEnter:Connect(function()
                    U.Tween(row, {BackgroundColor3 = Theme.BGHover}, Anim.Fast)
                end)
                clickZone.MouseLeave:Connect(function()
                    U.Tween(row, {BackgroundColor3 = Theme.BGElement}, Anim.Fast)
                end)

                Tog.SetValue = setVal
                return Tog
            end

            -- ── CreateSlider ───────────────────────────────────────────────
            function Section:CreateSlider(ecfg)
                ecfg = ecfg or {}
                local eName     = ecfg.Name     or "Slider"
                local eMin      = ecfg.Min      or 0
                local eMax      = ecfg.Max      or 100
                local eDefault  = ecfg.Default  or eMin
                local eSuffix   = ecfg.Suffix   or ""
                local eCallback = ecfg.Callback or function() end
                local eStep     = ecfg.Step     or 1

                local Slid = { Value = eDefault, Dragging = false }

                local row = U.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 50),
                    BackgroundColor3 = Theme.BGElement,
                    BorderSizePixel  = 0,
                    Parent           = Section.Content,
                })
                U.Corner(row, 6)

                -- Label
                U.New("TextLabel", {
                    Position         = UDim2.new(0, 10, 0, 7),
                    Size             = UDim2.new(1, -20, 0, 16),
                    BackgroundTransparency = 1,
                    Font             = Enum.Font.Gotham,
                    Text             = eName,
                    TextColor3       = Theme.Text,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = row,
                })

                -- Value display
                local valLabel = U.New("TextLabel", {
                    Position         = UDim2.new(1, -10, 0, 7),
                    Size             = UDim2.new(0, 80, 0, 16),
                    AnchorPoint      = Vector2.new(1, 0),
                    BackgroundTransparency = 1,
                    Font             = Enum.Font.GothamMedium,
                    Text             = tostring(eDefault) .. eSuffix,
                    TextColor3       = Theme.Accent,
                    TextSize         = 12,
                    TextXAlignment   = Enum.TextXAlignment.Right,
                    Parent           = row,
                })

                -- Track bg
                local trackBg = U.New("Frame", {
                    Position         = UDim2.new(0, 10, 1, -16),
                    Size             = UDim2.new(1, -20, 0, 5),
                    BackgroundColor3 = Theme.SliderTrack,
                    BorderSizePixel  = 0,
                    Parent           = row,
                })
                U.Corner(trackBg, 3)

                -- Track fill
                local fill = U.New("Frame", {
                    Size             = UDim2.new((eDefault - eMin) / (eMax - eMin), 0, 1, 0),
                    BackgroundColor3 = Theme.SliderFill,
                    BorderSizePixel  = 0,
                    Parent           = trackBg,
                })
                U.Corner(fill, 3)

                -- Thumb dot
                local thumb = U.New("Frame", {
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new((eDefault - eMin) / (eMax - eMin), 0, 0.5, 0),
                    Size             = UDim2.new(0, 11, 0, 11),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel  = 0,
                    Parent           = trackBg,
                    ZIndex           = 3,
                })
                U.Corner(thumb, 6)

                local function snapValue(v)
                    if eStep and eStep > 0 then
                        v = math.floor((v - eMin) / eStep + 0.5) * eStep + eMin
                    end
                    return math.clamp(v, eMin, eMax)
                end

                local function setVal(v)
                    v = snapValue(v)
                    Slid.Value = v
                    local pct = (v - eMin) / (eMax - eMin)
                    U.Tween(fill,  {Size     = UDim2.new(pct, 0, 1, 0)}, Anim.Instant)
                    U.Tween(thumb, {Position = UDim2.new(pct, 0, 0.5, 0)}, Anim.Instant)
                    valLabel.Text = tostring(math.floor(v * 100 + 0.5) / 100) .. eSuffix
                    pcall(eCallback, v)
                end

                -- Input handling
                local function onDrag(inp)
                    local rel = (inp.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X
                    setVal(eMin + (eMax - eMin) * math.clamp(rel, 0, 1))
                end

                trackBg.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        Slid.Dragging = true
                        onDrag(inp)
                        U.Tween(thumb, {Size = UDim2.new(0, 13, 0, 13)}, Anim.Fast)
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if Slid.Dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        onDrag(inp)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 and Slid.Dragging then
                        Slid.Dragging = false
                        U.Tween(thumb, {Size = UDim2.new(0, 11, 0, 11)}, Anim.Fast)
                    end
                end)

                row.MouseEnter:Connect(function()
                    U.Tween(row, {BackgroundColor3 = Theme.BGHover}, Anim.Fast)
                end)
                row.MouseLeave:Connect(function()
                    U.Tween(row, {BackgroundColor3 = Theme.BGElement}, Anim.Fast)
                end)

                setVal(eDefault)
                Slid.SetValue = setVal
                return Slid
            end

            -- ── CreateDropdown ─────────────────────────────────────────────
            function Section:CreateDropdown(ecfg)
                ecfg = ecfg or {}
                local eName     = ecfg.Name     or "Dropdown"
                local eOptions  = ecfg.Options  or {}
                local eDefault  = ecfg.Default  or (eOptions[1] or "")
                local eCallback = ecfg.Callback or function() end

                local DD = { Value = eDefault, Open = false }

                local wrapper = U.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex           = 10,
                    Parent           = Section.Content,
                })

                local row = U.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.BGElement,
                    BorderSizePixel  = 0,
                    ZIndex           = 10,
                    Parent           = wrapper,
                })
                U.Corner(row, 6)

                -- Label
                U.New("TextLabel", {
                    Position         = UDim2.new(0, 10, 0, 0),
                    Size             = UDim2.new(0.5, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Font             = Enum.Font.Gotham,
                    Text             = eName,
                    TextColor3       = Theme.TextSub,
                    TextSize         = 12,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 11,
                    Parent           = row,
                })

                -- Current value
                local valLabel = U.New("TextLabel", {
                    Position         = UDim2.new(1, -36, 0, 0),
                    Size             = UDim2.new(0.5, -14, 1, 0),
                    AnchorPoint      = Vector2.new(1, 0),
                    BackgroundTransparency = 1,
                    Font             = Enum.Font.GothamMedium,
                    Text             = eDefault,
                    TextColor3       = Theme.Text,
                    TextSize         = 12,
                    TextXAlignment   = Enum.TextXAlignment.Right,
                    TextTruncate     = Enum.TextTruncate.AtEnd,
                    ZIndex           = 11,
                    Parent           = row,
                })

                -- Arrow
                local arrow = U.New("TextLabel", {
                    AnchorPoint      = Vector2.new(1, 0.5),
                    Position         = UDim2.new(1, -10, 0.5, 0),
                    Size             = UDim2.new(0, 14, 0, 14),
                    BackgroundTransparency = 1,
                    Font             = Enum.Font.GothamBold,
                    Text             = "▾",
                    TextColor3       = Theme.TextMuted,
                    TextSize         = 12,
                    ZIndex           = 11,
                    Parent           = row,
                })

                -- Options panel (drops below)
                local optPanel = U.New("Frame", {
                    Position         = UDim2.new(0, 0, 1, 4),
                    Size             = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = Theme.BGPanel,
                    BorderSizePixel  = 0,
                    ClipsDescendants = true,
                    Visible          = false,
                    ZIndex           = 20,
                    Parent           = wrapper,
                })
                U.Corner(optPanel, 6)
                U.Stroke(optPanel, Theme.BorderLight, 1)

                local optList = U.New("UIListLayout", {
                    Padding   = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent    = optPanel,
                })
                U.Pad(optPanel, 4, 4, 4, 4)

                local optHeight = math.min(#eOptions * 28 + 8, 180)

                local function buildOption(opt)
                    local ob = U.New("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = opt == DD.Value and Theme.BGHover or Theme.BGPanel,
                        BackgroundTransparency = opt == DD.Value and 0 or 1,
                        BorderSizePixel  = 0,
                        Font             = Enum.Font.Gotham,
                        Text             = opt,
                        TextColor3       = opt == DD.Value and Theme.Text or Theme.TextSub,
                        TextSize         = 12,
                        ZIndex           = 21,
                        Parent           = optPanel,
                    })
                    U.Corner(ob, 4)

                    ob.MouseButton1Click:Connect(function()
                        DD.Value      = opt
                        valLabel.Text = opt
                        for _, c in ipairs(optPanel:GetChildren()) do
                            if c:IsA("TextButton") then
                                local sel = c.Text == opt
                                U.Tween(c, {
                                    BackgroundTransparency = sel and 0 or 1,
                                    BackgroundColor3       = Theme.BGHover,
                                    TextColor3             = sel and Theme.Text or Theme.TextSub,
                                }, Anim.Fast)
                            end
                        end
                        -- close
                        DD.Open = false
                        U.Tween(optPanel, {Size = UDim2.new(1, 0, 0, 0)}, Anim.Fast)
                        U.Tween(arrow,    {Rotation = 0},                   Anim.Fast)
                        task.delay(0.15, function() optPanel.Visible = false end)
                        pcall(eCallback, opt)
                    end)
                    ob.MouseEnter:Connect(function()
                        if opt ~= DD.Value then
                            U.Tween(ob, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.BGHover}, Anim.Fast)
                        end
                    end)
                    ob.MouseLeave:Connect(function()
                        if opt ~= DD.Value then
                            U.Tween(ob, {BackgroundTransparency = 1}, Anim.Fast)
                        end
                    end)
                end

                for _, o in ipairs(eOptions) do buildOption(o) end

                local openBtn = U.New("TextButton", {
                    Size                 = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                 = "",
                    ZIndex               = 12,
                    Parent               = row,
                })

                openBtn.MouseButton1Click:Connect(function()
                    DD.Open = not DD.Open
                    if DD.Open then
                        optPanel.Visible = true
                        optPanel.Size    = UDim2.new(1, 0, 0, 0)
                        U.Tween(optPanel, {Size = UDim2.new(1, 0, 0, optHeight)}, Anim.Medium)
                        U.Tween(arrow,    {Rotation = 180},                        Anim.Fast)
                        wrapper.Size = UDim2.new(1, 0, 0, 32 + optHeight + 4)
                    else
                        U.Tween(optPanel, {Size = UDim2.new(1, 0, 0, 0)}, Anim.Fast)
                        U.Tween(arrow,    {Rotation = 0},                   Anim.Fast)
                        task.delay(0.15, function()
                            optPanel.Visible = false
                            wrapper.Size = UDim2.new(1, 0, 0, 32)
                        end)
                    end
                end)

                row.MouseEnter:Connect(function()
                    U.Tween(row, {BackgroundColor3 = Theme.BGHover}, Anim.Fast)
                end)
                row.MouseLeave:Connect(function()
                    U.Tween(row, {BackgroundColor3 = Theme.BGElement}, Anim.Fast)
                end)

                DD.SetOptions = function(newOpts)
                    DD.Options = newOpts
                    for _, c in ipairs(optPanel:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for _, o in ipairs(newOpts) do buildOption(o) end
                    optHeight = math.min(#newOpts * 28 + 8, 180)
                end
                return DD
            end

            -- ── CreateButton ───────────────────────────────────────────────
            function Section:CreateButton(ecfg)
                ecfg = ecfg or {}
                local eName     = ecfg.Name     or "Button"
                local eCallback = ecfg.Callback or function() end
                local eSub      = ecfg.Sub      or nil

                local btn2 = U.New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, eSub and 42 or 32),
                    BackgroundColor3 = Theme.BGActive,
                    BorderSizePixel  = 0,
                    Font             = Enum.Font.GothamMedium,
                    Text             = "",
                    Parent           = Section.Content,
                })
                U.Corner(btn2, 6)
                U.Stroke(btn2, Theme.Border, 1)

                U.New("TextLabel", {
                    Position         = UDim2.new(0.5, 0, eSub and 0.2 or 0.5, 0),
                    Size             = UDim2.new(0.9, 0, 0, 18),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Font             = Enum.Font.GothamMedium,
                    Text             = eName,
                    TextColor3       = Theme.Text,
                    TextSize         = 13,
                    Parent           = btn2,
                })

                if eSub then
                    U.New("TextLabel", {
                        Position         = UDim2.new(0.5, 0, 0.72, 0),
                        Size             = UDim2.new(0.9, 0, 0, 14),
                        AnchorPoint      = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Font             = Enum.Font.Gotham,
                        Text             = eSub,
                        TextColor3       = Theme.TextMuted,
                        TextSize         = 11,
                        Parent           = btn2,
                    })
                end

                -- Accent bar on left
                local accentBar = U.New("Frame", {
                    Size             = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel  = 0,
                    Parent           = btn2,
                })
                U.Corner(accentBar, 6)

                btn2.MouseButton1Click:Connect(function()
                    U.Tween(accentBar, {Size = UDim2.new(0, 3, 1, 0)}, Anim.Fast)
                    U.Tween(btn2, {BackgroundColor3 = Theme.BGHover}, Anim.Fast)
                    pcall(eCallback)
                    task.delay(0.18, function()
                        U.Tween(accentBar, {Size = UDim2.new(0, 0, 1, 0)}, Anim.Medium)
                        U.Tween(btn2, {BackgroundColor3 = Theme.BGActive}, Anim.Medium)
                    end)
                end)
                btn2.MouseEnter:Connect(function()
                    U.Tween(btn2, {BackgroundColor3 = Theme.BGHover}, Anim.Fast)
                end)
                btn2.MouseLeave:Connect(function()
                    U.Tween(btn2, {BackgroundColor3 = Theme.BGActive}, Anim.Fast)
                end)
                return btn2
            end

            -- ── CreateColorPicker ──────────────────────────────────────────
            function Section:CreateColorPicker(ecfg)
                ecfg = ecfg or {}
                local eName     = ecfg.Name     or "Color"
                local eDefault  = ecfg.Default  or Color3.fromRGB(220, 50, 75)
                local eCallback = ecfg.Callback or function() end

                local CP = { Value = eDefault }

                local row = U.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.BGElement,
                    BorderSizePixel  = 0,
                    Parent           = Section.Content,
                })
                U.Corner(row, 6)

                U.New("TextLabel", {
                    Position         = UDim2.new(0, 10, 0, 0),
                    Size             = UDim2.new(1, -56, 1, 0),
                    BackgroundTransparency = 1,
                    Font             = Enum.Font.Gotham,
                    Text             = eName,
                    TextColor3       = Theme.Text,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = row,
                })

                local swatch = U.New("Frame", {
                    AnchorPoint      = Vector2.new(1, 0.5),
                    Position         = UDim2.new(1, -10, 0.5, 0),
                    Size             = UDim2.new(0, 32, 0, 20),
                    BackgroundColor3 = eDefault,
                    BorderSizePixel  = 0,
                    Parent           = row,
                })
                U.Corner(swatch, 5)
                U.Stroke(swatch, Theme.BorderLight, 1)

                local function setVal(c)
                    CP.Value = c
                    swatch.BackgroundColor3 = c
                    pcall(eCallback, c)
                end

                CP.SetValue = setVal
                return CP
            end

            -- ── CreateKeybind ──────────────────────────────────────────────
            function Section:CreateKeybind(ecfg)
                ecfg = ecfg or {}
                local eName     = ecfg.Name     or "Keybind"
                local eDefault  = ecfg.Default  or Enum.KeyCode.Unknown
                local eCallback = ecfg.Callback or function() end

                local KB = { Value = eDefault, Binding = false }

                local row = U.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.BGElement,
                    BorderSizePixel  = 0,
                    Parent           = Section.Content,
                })
                U.Corner(row, 6)

                U.New("TextLabel", {
                    Position         = UDim2.new(0, 10, 0, 0),
                    Size             = UDim2.new(1, -100, 1, 0),
                    BackgroundTransparency = 1,
                    Font             = Enum.Font.Gotham,
                    Text             = eName,
                    TextColor3       = Theme.Text,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = row,
                })

                local kbBtn = U.New("TextButton", {
                    AnchorPoint      = Vector2.new(1, 0.5),
                    Position         = UDim2.new(1, -10, 0.5, 0),
                    Size             = UDim2.new(0, 72, 0, 22),
                    BackgroundColor3 = Theme.BGDark,
                    BorderSizePixel  = 0,
                    Font             = Enum.Font.GothamMedium,
                    Text             = eDefault == Enum.KeyCode.Unknown and "None" or eDefault.Name,
                    TextColor3       = Theme.TextSub,
                    TextSize         = 11,
                    Parent           = row,
                })
                U.Corner(kbBtn, 4)
                U.Stroke(kbBtn, Theme.Border, 1)

                kbBtn.MouseButton1Click:Connect(function()
                    KB.Binding = true
                    kbBtn.Text = "..."
                    U.Tween(kbBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text}, Anim.Fast)
                end)

                UserInputService.InputBegan:Connect(function(inp, gp)
                    if KB.Binding and inp.UserInputType == Enum.UserInputType.Keyboard then
                        KB.Value    = inp.KeyCode
                        kbBtn.Text  = inp.KeyCode.Name
                        KB.Binding  = false
                        U.Tween(kbBtn, {BackgroundColor3 = Theme.BGDark, TextColor3 = Theme.TextSub}, Anim.Fast)
                        pcall(eCallback, inp.KeyCode)
                    end
                end)

                row.MouseEnter:Connect(function()
                    U.Tween(row, {BackgroundColor3 = Theme.BGHover}, Anim.Fast)
                end)
                row.MouseLeave:Connect(function()
                    U.Tween(row, {BackgroundColor3 = Theme.BGElement}, Anim.Fast)
                end)

                KB.SetValue = function(k)
                    KB.Value   = k
                    kbBtn.Text = k == Enum.KeyCode.Unknown and "None" or k.Name
                end
                return KB
            end

            -- ── CreateLabel ────────────────────────────────────────────────
            function Section:CreateLabel(ecfg)
                ecfg = ecfg or {}
                local eText  = ecfg.Text  or ""
                local eColor = ecfg.Color or Theme.TextMuted
                local eSize  = ecfg.Size  or 12

                local lbl = U.New("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    Font             = Enum.Font.Gotham,
                    Text             = eText,
                    TextColor3       = eColor,
                    TextSize         = eSize,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    TextWrapped      = true,
                    Parent           = Section.Content,
                })
                U.Pad(lbl, 0, 0, 10, 0)

                local L = {}
                L.SetText = function(t) lbl.Text = t end
                return L
            end

            -- ── CreateInput ────────────────────────────────────────────────
            function Section:CreateInput(ecfg)
                ecfg = ecfg or {}
                local eName        = ecfg.Name        or "Input"
                local ePlaceholder = ecfg.Placeholder or "Type here..."
                local eDefault     = ecfg.Default     or ""
                local eCallback    = ecfg.Callback    or function() end

                local row = U.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 52),
                    BackgroundColor3 = Theme.BGElement,
                    BorderSizePixel  = 0,
                    Parent           = Section.Content,
                })
                U.Corner(row, 6)

                U.New("TextLabel", {
                    Position         = UDim2.new(0, 10, 0, 5),
                    Size             = UDim2.new(1, -20, 0, 16),
                    BackgroundTransparency = 1,
                    Font             = Enum.Font.Gotham,
                    Text             = eName,
                    TextColor3       = Theme.TextSub,
                    TextSize         = 12,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = row,
                })

                local inputField = U.New("TextBox", {
                    Position         = UDim2.new(0, 10, 0, 26),
                    Size             = UDim2.new(1, -20, 0, 20),
                    BackgroundColor3 = Theme.BGDark,
                    BorderSizePixel  = 0,
                    Font             = Enum.Font.Gotham,
                    Text             = eDefault,
                    PlaceholderText  = ePlaceholder,
                    PlaceholderColor3 = Theme.TextMuted,
                    TextColor3       = Theme.Text,
                    TextSize         = 12,
                    ClearTextOnFocus = false,
                    Parent           = row,
                })
                U.Corner(inputField, 4)
                U.Pad(inputField, 0, 0, 6, 6)

                inputField.FocusLost:Connect(function(ep)
                    if ep then pcall(eCallback, inputField.Text) end
                end)

                row.MouseEnter:Connect(function()
                    U.Tween(row, {BackgroundColor3 = Theme.BGHover}, Anim.Fast)
                end)
                row.MouseLeave:Connect(function()
                    U.Tween(row, {BackgroundColor3 = Theme.BGElement}, Anim.Fast)
                end)

                local IN = { Value = eDefault }
                IN.SetValue = function(v)
                    IN.Value = v
                    inputField.Text = v
                end
                return IN
            end

            -- ── CreateDivider ──────────────────────────────────────────────
            function Section:CreateDivider()
                local f = U.New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Theme.Border,
                    BorderSizePixel  = 0,
                    Parent           = Section.Content,
                })
                return f
            end

            return Section
        end -- CreateSection

        return Tab
    end -- CreateTab

    return Window
end -- CreateWindow

return Library
