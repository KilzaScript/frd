--[[═════════════════════════════════════════════════════════════════════
    HATE UI  v1.0  —  complete rewrite
    An animation-first GUI library:
      · Quint/Back eased tweens everywhere (C++-style motion)
      · CanvasGroup fade+scale transitions on every popup
      · Modern pill toggles, live sliders, animated dropdowns
      · Toast notification stack, loader screen, sidebar-tab window
    ══════════════════════════════════════════════════════════════════════]]

local library = {}
library.__index = library

-- services
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer
local holder       = (gethui and gethui()) or game:GetService("CoreGui")

-- theme
library.Theme = {
	Accent      = Color3.fromRGB(220, 50, 75),
	Background  = Color3.fromRGB(14, 14, 19),
	Panel       = Color3.fromRGB(21, 21, 27),
	Card        = Color3.fromRGB(31, 31, 40),
	CardHover   = Color3.fromRGB(41, 41, 52),
	Stroke      = Color3.fromRGB(50, 50, 62),
	Text        = Color3.fromRGB(236, 236, 242),
	SubText     = Color3.fromRGB(139, 139, 152),
}
local T = library.Theme

-- easing presets — fast attack, long silky decel (the "C++ feel")
local Quint   = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local BackOut = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function tween(obj, props, info)
	return TweenService:Create(obj, info or Quint, props):Play()
end

function library:tween(obj, props, info)
	return tween(obj, props, info)
end

-- instance helper
local function mk(class, props, radius, stroked)
	local ins = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then
			ins[k] = v
		end
	end
	if radius then
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, radius)
		c.Parent = ins
	end
	if stroked then
		local s = Instance.new("UIStroke")
		s.Color = T.Stroke
		s.Thickness = 1
		s.Transparency = 0.25
		s.Parent = ins
	end
	if props.Parent then
		ins.Parent = props.Parent
	end
	return ins
end
library.mk = mk

-- create() — compatibility helper (auto-rounds real surfaces, skips strips)
function library:create(class, props)
	local ins = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then
			ins[k] = v
		end
	end
	pcall(function()
		local h = (typeof(props.Size) == "UDim2") and props.Size.Y.Offset or 99
		if h > 14 and (class == "Frame" or class == "CanvasGroup" or class == "TextButton"
			or class == "ImageButton" or class == "ImageLabel") then
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, 8)
			c.Parent = ins
		end
	end)
	if props.Parent then
		ins.Parent = props.Parent
	end
	return ins
end

-- draggify — drag `target` by `handle` (defaults to the handle itself)
function library:draggify(handle, target)
	target = target or handle
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- notifications — modern toast stack, top-right
do
	local gui = mk("ScreenGui", {Parent = holder, Name = "", DisplayOrder = 999990})
	local stack = mk("Frame", {
		Parent = gui,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.fromOffset(300, 2000),
		BackgroundTransparency = 1,
	})
	mk("UIListLayout", {Parent = stack, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})

	function library:Notification(cfg)
		cfg = cfg or {}
		local dur = cfg.Time or cfg.time or 4

		local toast = mk("CanvasGroup", {
			Parent = stack, Size = UDim2.new(1, 0, 0, 62),
			BackgroundColor3 = T.Panel, BorderSizePixel = 0,
			GroupTransparency = 1,
		}, 10, true)

		mk("Frame", {
			Parent = toast, Size = UDim2.new(0, 3, 1, -16),
			Position = UDim2.new(0, 8, 0, 8),
			BackgroundColor3 = T.Accent, BorderSizePixel = 0,
		})

		mk("TextLabel", {
			Parent = toast, Text = cfg.Title or "HATE",
			Font = Enum.Font.GothamBold, TextSize = 13,
			TextColor3 = T.Accent, BackgroundTransparency = 1,
			Position = UDim2.fromOffset(20, 8), Size = UDim2.new(1, -30, 0, 16),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		mk("TextLabel", {
			Parent = toast, Text = cfg.Text or cfg.text or "",
			Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = T.SubText, BackgroundTransparency = 1, TextWrapped = true,
			Position = UDim2.fromOffset(20, 26), Size = UDim2.new(1, -30, 0, 30),
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		local sc = mk("UIScale", {Parent = toast, Scale = 0.92})
		tween(toast, {GroupTransparency = 0})
		tween(sc, {Scale = 1}, BackOut)

		task.delay(dur, function()
			tween(toast, {GroupTransparency = 1})
			tween(sc, {Scale = 0.92})
			task.wait(0.3)
			toast:Destroy()
		end)
	end

	library.notification = library.Notification
end

-- loader — logo pop + progress bar, hands off to a callback
function library:Loader(cfg)
	cfg = cfg or {}
	local dur = cfg.Time or 1.2

	local gui = mk("ScreenGui", {Parent = holder, Name = "", DisplayOrder = 999999})
	local back = mk("Frame", {
		Parent = gui, Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(8, 8, 12),
		BorderSizePixel = 0, BackgroundTransparency = 1,
	})
	local logo = mk("ImageLabel", {
		Parent = gui, Image = cfg.Logo or "",
		BackgroundTransparency = 1, ImageTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.45, 0),
		Size = UDim2.fromOffset(190, 190),
	})
	local sc = mk("UIScale", {Parent = logo, Scale = 0.8})

	local barBg = mk("Frame", {
		Parent = gui, AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -70),
		Size = UDim2.fromOffset(260, 4),
		BackgroundColor3 = Color3.fromRGB(35, 35, 45),
		BorderSizePixel = 0, BackgroundTransparency = 1,
	}, 999)
	local bar = mk("Frame", {
		Parent = barBg, Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = T.Accent, BorderSizePixel = 0,
		BackgroundTransparency = 1,
	}, 999)

	tween(back, {BackgroundTransparency = 0.2})
	tween(logo, {ImageTransparency = 0, Size = UDim2.fromOffset(250, 250)}, BackOut)
	tween(sc, {Scale = 1}, BackOut)
	tween(barBg, {BackgroundTransparency = 0})
	tween(bar, {BackgroundTransparency = 0})
	tween(bar, {Size = UDim2.new(1, 0, 1, 0)},
		TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))

	task.delay(dur + 0.2, function()
		tween(logo, {ImageTransparency = 1, Size = UDim2.fromOffset(290, 290)},
			TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
		tween(back, {BackgroundTransparency = 1})
		tween(barBg, {BackgroundTransparency = 1})
		tween(bar, {BackgroundTransparency = 1})
		task.wait(0.35)
		gui:Destroy()
		if cfg.Callback then
			cfg.Callback()
		end
	end)
end

-- window — root container with sidebar tabs
function library:Window(cfg)
	cfg = cfg or {}
	local self = setmetatable({}, library)
	T.Accent = cfg.Accent or T.Accent

	local W = (cfg.Size and cfg.Size.X) or 560
	local H = (cfg.Size and cfg.Size.Y) or 380

	local gui = mk("ScreenGui", {
		Parent = holder, Name = "", DisplayOrder = 999998,
		IgnoreGuiInset = true, Enabled = false,
	})
	self.Gui = gui

	local root = mk("CanvasGroup", {
		Parent = gui, Size = UDim2.fromOffset(W, H),
		Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2),
		BackgroundColor3 = T.Background,
		GroupTransparency = 1, BorderSizePixel = 0,
	}, 12, true)
	local scale = mk("UIScale", {Parent = root, Scale = 0.94})
	self.Root = root

	-- topbar (drag handle)
	local top = mk("Frame", {
		Parent = root, Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = T.Panel, BorderSizePixel = 0,
	})
	if cfg.Logo then
		mk("ImageLabel", {
			Parent = top, Image = cfg.Logo, BackgroundTransparency = 1,
			Size = UDim2.fromOffset(24, 24), Position = UDim2.fromOffset(14, 11),
		})
	end
	mk("TextLabel", {
		Parent = top, Text = cfg.Title or "HATE",
		Font = Enum.Font.GothamBold, TextSize = 14,
		TextColor3 = T.Text, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(cfg.Logo and 48 or 16, 0),
		Size = UDim2.new(0, 220, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	if cfg.SubTitle then
		mk("TextLabel", {
			Parent = top, Text = cfg.SubTitle,
			Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = T.SubText, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, cfg.Logo and 49 or 17, 1, -8),
			Size = UDim2.new(0, 220, 0, 12),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	end

	local visible = true
	local function setVisible(v)
		visible = v
		if v then
			gui.Enabled = true
			root.GroupTransparency = 1
			scale.Scale = 0.94
			tween(root, {GroupTransparency = 0})
			tween(scale, {Scale = 1}, BackOut)
		else
			tween(root, {GroupTransparency = 1})
			tween(scale, {Scale = 0.94})
			task.delay(0.22, function()
				if not visible then
					gui.Enabled = false
				end
			end)
		end
	end
	self.SetVisible = setVisible

	local function topBtn(txt, off, cb)
		local b = mk("TextButton", {
			Parent = top, Text = txt, Font = Enum.Font.GothamBold, TextSize = 14,
			TextColor3 = T.SubText, BackgroundColor3 = T.Card,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, off, 0.5, 0),
			Size = UDim2.fromOffset(26, 22),
			AutoButtonColor = false, BorderSizePixel = 0,
		}, 6)
		b.MouseEnter:Connect(function()
			tween(b, {TextColor3 = T.Text, BackgroundColor3 = T.CardHover})
		end)
		b.MouseLeave:Connect(function()
			tween(b, {TextColor3 = T.SubText, BackgroundColor3 = T.Card})
		end)
		b.MouseButton1Click:Connect(cb)
	end

	topBtn("×", -12, function() gui:Destroy() end)
	topBtn("–", -42, function() setVisible(false) end)

	library:draggify(top, root)

	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift then
			setVisible(not visible)
		end
	end)

	-- sidebar + content
	local side = mk("Frame", {
		Parent = root, Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(0, 132, 1, -46),
		BackgroundColor3 = T.Panel, BorderSizePixel = 0,
	})
	mk("UIPadding", {
		Parent = side,
		PaddingTop = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	})
	mk("UIListLayout", {Parent = side, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})

	local content = mk("Frame", {
		Parent = root, Position = UDim2.new(0, 132, 0, 46),
		Size = UDim2.new(1, -132, 1, -46),
		BackgroundTransparency = 1, BorderSizePixel = 0,
	})

	local tabs = {}
	local current = 0
	local function select(idx)
		if current == idx then return end
		current = idx
		for i, tab in ipairs(tabs) do
			local active = (i == idx)
			tween(tab.Button, {BackgroundColor3 = active and T.Card or T.Background})
			tween(tab.Label, {TextColor3 = active and T.Text or T.SubText})
			tab.Ind.Visible = active
			if active then
				tab.Page.Visible = true
				tab.Page.GroupTransparency = 1
				tab.Page.Position = UDim2.fromOffset(0, 10)
				tween(tab.Page, {GroupTransparency = 0})
				tween(tab.Page, {Position = UDim2.fromOffset(0, 0)})
			else
				tab.Page.Visible = false
			end
		end
	end
	self.SelectTab = select

	-- tab constructor
	function self:Tab(name)
		self.TabCount = (self.TabCount or 0) + 1
		local idx = self.TabCount

		local btn = mk("TextButton", {
			Parent = side, Text = "", AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = T.Background, BorderSizePixel = 0,
		}, 8)
		local ind = mk("Frame", {
			Parent = btn, Size = UDim2.new(0, 3, 1, -10),
			Position = UDim2.new(0, 4, 0, 5),
			BackgroundColor3 = T.Accent, BorderSizePixel = 0,
			Visible = false,
		})
		local lbl = mk("TextLabel", {
			Parent = btn, Text = name, Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = T.SubText, BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -18, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		local page = mk("CanvasGroup", {
			Parent = content, Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Visible = false, GroupTransparency = 1,
		})
		local scroll = mk("ScrollingFrame", {
			Parent = page, Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3, ScrollBarImageColor3 = T.Accent,
			ScrollBarImageTransparency = 0.4,
		})
		mk("UIPadding", {
			Parent = scroll,
			PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
		})
		local list = mk("Frame", {
			Parent = scroll, Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		mk("UIListLayout", {Parent = list, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})

		local tab = {Button = btn, Label = lbl, Ind = ind, Page = page}
		tabs[idx] = tab
		btn.MouseButton1Click:Connect(function() select(idx) end)
		if idx == 1 then
			task.defer(function() select(1) end)
		end

		return setmetatable({_List = list, _Gui = gui}, library)
	end

	return self
end

-- shared element row
local function row(list, height)
	return mk("Frame", {
		Parent = list, Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = T.Card, BorderSizePixel = 0,
	}, 8)
end

-- section — a grouped card inside a tab
function library:Section(title)
	local card = mk("CanvasGroup", {
		Parent = self._List, Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = T.Panel, BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		GroupTransparency = 1,
	}, 10)
	local sc = mk("UIScale", {Parent = card, Scale = 0.98})
	tween(card, {GroupTransparency = 0})
	tween(sc, {Scale = 1})

	mk("TextLabel", {
		Parent = card, Text = string.upper(title or "Section"),
		Font = Enum.Font.GothamBold, TextSize = 11,
		TextColor3 = T.SubText, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -24, 0, 12),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	mk("Frame", {
		Parent = card, Size = UDim2.new(1, -20, 0, 1),
		Position = UDim2.new(0, 10, 0, 28),
		BackgroundColor3 = T.Stroke, BorderSizePixel = 0, Transparency = 0.4,
	})

	local list = mk("Frame", {
		Parent = card, Position = UDim2.new(0, 8, 0, 36),
		Size = UDim2.new(1, -16, 0, 0),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	mk("UIListLayout", {Parent = list, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
	mk("UIPadding", {Parent = card, PaddingBottom = UDim.new(0, 10)})

	return setmetatable({_List = list, _Gui = self._Gui}, library)
end

-- toggle — modern animated pill switch
function library:Toggle(cfg)
	cfg = cfg or {}
	local r = row(self._List, 34)
	mk("TextLabel", {
		Parent = r, Text = cfg.Name or "Toggle",
		Font = Enum.Font.Gotham, TextSize = 13,
		TextColor3 = T.Text, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -70, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local pill = mk("Frame", {
		Parent = r, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(36, 18),
		BackgroundColor3 = T.CardHover, BorderSizePixel = 0,
	}, 999)
	local knob = mk("Frame", {
		Parent = pill, Size = UDim2.fromOffset(12, 12),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = T.SubText, BorderSizePixel = 0,
	}, 999)

	local value = cfg.Default and true or false
	local function set(v, silent)
		value = v
		tween(pill, {BackgroundColor3 = v and T.Accent or T.CardHover})
		tween(knob, {
			Position = v and UDim2.new(1, -15, 0, 3) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = v and Color3.fromRGB(255, 255, 255) or T.SubText,
		})
		if not silent and cfg.Callback then
			cfg.Callback(v)
		end
	end

	local hit = mk("TextButton", {
		Parent = r, Text = "", BackgroundTransparency = 1,
		BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
	})
	hit.MouseButton1Click:Connect(function() set(not value) end)
	set(value, true)

	return {Set = set, Get = function() return value end}
end

-- slider — live fill + draggable knob
function library:Slider(cfg)
	cfg = cfg or {}
	local min = cfg.Min or 0
	local max = cfg.Max or 100
	local value = cfg.Default or min
	local suffix = cfg.Suffix or ""

	local r = row(self._List, 44)
	mk("TextLabel", {
		Parent = r, Text = cfg.Name or "Slider",
		Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T.Text,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 4), Size = UDim2.new(0, 160, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local valLabel = mk("TextLabel", {
		Parent = r, Text = "", Font = Enum.Font.Gotham, TextSize = 12,
		TextColor3 = T.SubText, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 4), Size = UDim2.new(0, 90, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	local track = mk("Frame", {
		Parent = r, Position = UDim2.new(0, 12, 1, -16),
		Size = UDim2.new(1, -24, 0, 4),
		BackgroundColor3 = T.CardHover, BorderSizePixel = 0,
	}, 999)
	local fill = mk("Frame", {
		Parent = track, Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = T.Accent, BorderSizePixel = 0,
	}, 999)
	local knob = mk("Frame", {
		Parent = track, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0, ZIndex = 2,
	}, 999)

	local function setVal(v, silent)
		v = math.clamp(math.floor(v + 0.5), min, max)
		local a = (v - min) / (max - min)
		fill.Size = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		valLabel.Text = tostring(v) .. suffix
		value = v
		if not silent and cfg.Callback then
			cfg.Callback(v)
		end
	end
	setVal(value, true)

	local dragging = false
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			local m = UIS:GetMouseLocation()
			local a = math.clamp((m.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			setVal(min + (max - min) * a)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local m = UIS:GetMouseLocation()
			local a = math.clamp((m.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			setVal(min + (max - min) * a)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	return {Set = setVal, Get = function() return value end}
end

-- button — hover + click flash
function library:Button(cfg)
	cfg = cfg or {}
	local r = mk("TextButton", {
		Parent = self._List, Text = "", AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = T.Card, BorderSizePixel = 0,
	}, 8)
	mk("TextLabel", {
		Parent = r, Text = cfg.Name or "Button",
		Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T.Text,
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
	})
	r.MouseEnter:Connect(function()
		tween(r, {BackgroundColor3 = T.CardHover})
	end)
	r.MouseLeave:Connect(function()
		tween(r, {BackgroundColor3 = T.Card})
	end)
	r.MouseButton1Click:Connect(function()
		tween(r, {BackgroundColor3 = T.Accent})
		task.delay(0.15, function()
			tween(r, {BackgroundColor3 = T.Card})
		end)
		if cfg.Callback then
			cfg.Callback()
		end
	end)
	return r
end

-- dropdown — animated CanvasGroup popup list
function library:Dropdown(cfg)
	cfg = cfg or {}
	local items = cfg.Items or {}
	local selected = cfg.Default or (items[1] or "Select...")

	local r = row(self._List, 34)
	mk("TextLabel", {
		Parent = r, Text = cfg.Name or "Dropdown",
		Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T.Text,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -150, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local sel = mk("TextLabel", {
		Parent = r, Text = tostring(selected), Font = Enum.Font.Gotham, TextSize = 12,
		TextColor3 = T.SubText, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -34, 0.5, 0), Size = UDim2.new(0, 90, 0, 14),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local chev = mk("TextLabel", {
		Parent = r, Text = "▾", Font = Enum.Font.GothamBold, TextSize = 12,
		TextColor3 = T.SubText, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(16, 14),
	})

	local popup = mk("CanvasGroup", {
		Parent = self._Gui, Size = UDim2.fromOffset(200, #items * 28 + 8),
		BackgroundColor3 = T.Panel, BorderSizePixel = 0,
		Visible = false, GroupTransparency = 1, ZIndex = 50,
	}, 8, true)
	local psc = mk("UIScale", {Parent = popup, Scale = 0.94})

	local open = false
	local function setOpen(v)
		open = v
		if v then
			popup.Size = UDim2.fromOffset(r.AbsoluteSize.X, #items * 28 + 8)
			popup.Position = UDim2.fromOffset(r.AbsolutePosition.X, r.AbsolutePosition.Y + r.AbsoluteSize.Y + 4)
			popup.Visible = true
			popup.GroupTransparency = 1
			psc.Scale = 0.95
			tween(popup, {GroupTransparency = 0})
			tween(psc, {Scale = 1})
			tween(chev, {Rotation = 180})
		else
			tween(popup, {GroupTransparency = 1})
			tween(psc, {Scale = 0.95})
			tween(chev, {Rotation = 0})
			task.delay(0.2, function()
				if not open then
					popup.Visible = false
				end
			end)
		end
	end

	for i, item in ipairs(items) do
		local b = mk("TextButton", {
			Parent = popup, Text = tostring(item),
			Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = T.Text, BackgroundColor3 = T.Card,
			Position = UDim2.new(0, 4, 0, 4 + (i - 1) * 28),
			Size = UDim2.new(1, -8, 0, 28),
			AutoButtonColor = false, BorderSizePixel = 0,
		}, 6)
		b.MouseEnter:Connect(function()
			tween(b, {BackgroundColor3 = T.CardHover, TextColor3 = T.Accent})
		end)
		b.MouseLeave:Connect(function()
			tween(b, {BackgroundColor3 = T.Card, TextColor3 = T.Text})
		end)
		b.MouseButton1Click:Connect(function()
			selected = item
			sel.Text = tostring(item)
			setOpen(false)
			if cfg.Callback then
				cfg.Callback(item)
			end
		end)
	end

	r.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setOpen(not open)
		end
	end)

	return {
		Set = function(v)
			selected = v
			sel.Text = tostring(v)
		end,
		Get = function() return selected end,
	}
end

-- label — simple subtext row
function library:Label(cfg)
	cfg = cfg or {}
	return mk("TextLabel", {
		Parent = self._List, Text = cfg.Text or cfg.Name or "",
		Font = Enum.Font.Gotham, TextSize = 12,
		TextColor3 = T.SubText, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end


-- ════════════════════════════════════════════════════════════════════
--  Launcher  —  FLOW-style game-selection screen
--  call:  library:Launcher({ Logo, Title, Author, Games })
--  each game:  { Name, Desc, Icon (asset id), Load = function() end }
-- ════════════════════════════════════════════════════════════════════
function library:Launcher(cfg)
	cfg = cfg or {}
	local games = cfg.Games or {}
	local accent = cfg.Accent or T.Accent

	local gui = mk("ScreenGui", { Parent = holder, Name = "", DisplayOrder = 999997, IgnoreGuiInset = true })
	local back = mk("Frame", {
		Parent = gui, Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(6, 6, 10), BorderSizePixel = 0,
		BackgroundTransparency = 1,
	})

	-- ── window ──
	local W, H = 760, 512
	local win = mk("CanvasGroup", {
		Parent = gui, Size = UDim2.fromOffset(W, H),
		Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2),
		BackgroundColor3 = T.Background, BorderSizePixel = 0, GroupTransparency = 1,
	}, 16, true)
	local wsc = mk("UIScale", { Parent = win, Scale = 0.92 })

	-- ── header ──
	local hd = mk("Frame", {
		Parent = win, Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = T.Panel, BorderSizePixel = 0,
	})
	if cfg.Logo then
		mk("ImageLabel", {
			Parent = hd, Image = cfg.Logo, BackgroundTransparency = 1,
			Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(16, 14),
		})
	end
	local tx = cfg.Logo and 54 or 18
	mk("TextLabel", {
		Parent = hd, Text = cfg.Title or "Launcher", Font = Enum.Font.GothamBold, TextSize = 15,
		TextColor3 = T.Text, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(tx, 8), Size = UDim2.fromOffset(320, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	mk("TextLabel", {
		Parent = hd, Text = "by " .. (cfg.Author or "guest"), Font = Enum.Font.Gotham, TextSize = 12,
		TextColor3 = T.SubText, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(tx, 28), Size = UDim2.fromOffset(320, 14),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local badge = mk("Frame", {
		Parent = hd, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(74, 22),
		BackgroundColor3 = accent, BorderSizePixel = 0,
	}, 999)
	mk("TextLabel", {
		Parent = badge, Text = "SECURE", Font = Enum.Font.GothamBold, TextSize = 11,
		TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	})

	-- ── body: sidebar + content ──
	local body = mk("Frame", {
		Parent = win, Position = UDim2.new(0, 0, 0, 56),
		Size = UDim2.new(1, 0, 1, -86), BackgroundTransparency = 1, BorderSizePixel = 0,
	})

	local sideW = 170
	local side = mk("Frame", {
		Parent = body, Size = UDim2.new(0, sideW, 1, 0),
		BackgroundColor3 = T.Panel, BorderSizePixel = 0,
	})
	mk("UIPadding", {
		Parent = side, PaddingTop = UDim.new(0, 14),
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8),
	})
	mk("UIListLayout", { Parent = side, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })

	local content = mk("Frame", {
		Parent = body, Position = UDim2.new(0, sideW, 0, 0),
		Size = UDim2.new(1, -sideW, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
	})

	-- page system
	local pages = {}
	local nav = {}
	local cur = 0
	local function showPage(i)
		if cur == i then return end
		cur = i
		for k, p in ipairs(pages) do
			local on = (k == i)
			tween(nav[k].B, { BackgroundColor3 = on and Color3.fromRGB(42, 42, 54) or T.Panel })
			tween(nav[k].L, { TextColor3 = on and T.Text or T.SubText })
			nav[k].Ind.Visible = on
			if on then
				p.Visible = true
				p.GroupTransparency = 1
				p.Position = UDim2.fromOffset(0, 10)
				tween(p, { GroupTransparency = 0 })
				tween(p, { Position = UDim2.fromOffset(0, 0) })
			else
				p.Visible = false
			end
		end
	end

	local function addNav(name, icon, badgeCount)
		local b = mk("TextButton", {
			Parent = side, Text = "", AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = T.Panel, BorderSizePixel = 0,
		}, 8)
		local ind = mk("Frame", {
			Parent = b, Size = UDim2.new(0, 3, 1, -12), Position = UDim2.new(0, 4, 0, 6),
			BackgroundColor3 = accent, BorderSizePixel = 0, Visible = false,
		})
		mk("TextLabel", {
			Parent = b, Text = icon, Font = Enum.Font.GothamBold, TextSize = 13,
			TextColor3 = T.SubText, BackgroundTransparency = 1,
			Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(20, 32),
		})
		local lbl = mk("TextLabel", {
			Parent = b, Text = name, Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = T.SubText, BackgroundTransparency = 1,
			Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -46, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		if badgeCount and badgeCount > 0 then
			mk("TextLabel", {
				Parent = b, Text = tostring(badgeCount), Font = Enum.Font.GothamBold, TextSize = 11,
				TextColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(20, 16),
				BackgroundColor3 = accent, BorderSizePixel = 0,
			}, 999)
		end
		b.MouseButton1Click:Connect(function()
			for k, nd in ipairs(nav) do
				if nd.B == b then showPage(k) end
			end
		end)
		nav[#nav + 1] = { B = b, L = lbl, Ind = ind }
	end

	local function makePage()
		local p = mk("CanvasGroup", {
			Parent = content, Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Visible = false, GroupTransparency = 1,
		})
		mk("UIPadding", {
			Parent = p, PaddingTop = UDim.new(0, 16),
			PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18),
			PaddingBottom = UDim.new(0, 16),
		})
		pages[#pages + 1] = p
		return p
	end

	-- reveal unhidden section marker (chunks appended below)
-- ═══ GAMES PAGE ═══
	local GPage = makePage()

	-- toolbar: title + search
	local tbTitle = mk("TextLabel", {
		Parent = GPage, Text = "Games", Font = Enum.Font.GothamBold, TextSize = 20,
		TextColor3 = T.Text, BackgroundTransparency = 1,
		Position = UDim2.new(0, 18, 0, 14), Size = UDim2.fromOffset(200, 22),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local searchBox = mk("TextBox", {
		Parent = GPage, Text = "", PlaceholderText = "Search games...",
		PlaceholderColor3 = T.SubText, Font = Enum.Font.Gotham, TextSize = 13,
		TextColor3 = T.Text, ClearTextOnFocus = false,
		BackgroundColor3 = T.Card, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 14), Size = UDim2.fromOffset(210, 30),
	}, 8, true)
	mk("UIPadding", { Parent = searchBox, PaddingLeft = UDim.new(0, 10) })

	-- count row + separator
	local countLbl = mk("TextLabel", {
		Parent = GPage, Text = "", Font = Enum.Font.Gotham, TextSize = 12,
		TextColor3 = T.SubText, BackgroundTransparency = 1,
		Position = UDim2.new(0, 18, 0, 40), Size = UDim2.fromOffset(300, 14),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	mk("Frame", {
		Parent = GPage, Size = UDim2.new(1, -36, 0, 1),
		Position = UDim2.new(0, 18, 0, 62),
		BackgroundColor3 = T.Stroke, BorderSizePixel = 0, Transparency = 0.4,
	})

	-- scrollable game list
	local scroll = mk("ScrollingFrame", {
		Parent = GPage, Position = UDim2.new(0, 18, 0, 72),
		Size = UDim2.new(1, -36, 1, -88),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3, ScrollBarImageColor3 = accent,
		ScrollBarImageTransparency = 0.35,
	})
	local list = mk("Frame", {
		Parent = scroll, Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	mk("UIListLayout", { Parent = list, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

	-- game card builder
	local cards = {}
	local function buildCard(gameDef, gi)
		local card = mk("CanvasGroup", {
			Parent = list, Size = UDim2.new(1, 0, 0, 66),
			BackgroundColor3 = T.Card, BorderSizePixel = 0, GroupTransparency = 1,
			ClipsDescendants = true,
		}, 10, true)
		local sc = mk("UIScale", { Parent = card, Scale = 0.98 })

		-- icon (asset id or placeholder monogram)
		if gameDef.Icon and gameDef.Icon ~= "" then
			mk("ImageLabel", {
				Parent = card, Image = gameDef.Icon, BackgroundTransparency = 1,
				Size = UDim2.fromOffset(42, 42), Position = UDim2.fromOffset(12, 12),
			})
		else
			local mono = mk("Frame", {
				Parent = card, Size = UDim2.fromOffset(42, 42), Position = UDim2.fromOffset(12, 12),
				BackgroundColor3 = accent, BorderSizePixel = 0,
			}, 8)
			mono.BackgroundColor3 = Color3.fromRGB(60, 60, 76)
			mk("TextLabel", {
				Parent = mono, Text = string.sub(gameDef.Name or "?", 1, 1):upper(),
				Font = Enum.Font.GothamBold, TextSize = 18,
				TextColor3 = T.SubText, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
			})
		end

		mk("TextLabel", {
			Parent = card, Text = gameDef.Name or "Game",
			Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = T.Text,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(66, 8), Size = UDim2.new(1, -150, 0, 20),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		mk("TextLabel", {
			Parent = card, Text = gameDef.Desc or "", Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = T.SubText, BackgroundTransparency = 1,
			Position = UDim2.fromOffset(66, 30), Size = UDim2.new(1, -160, 0, 16),
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local play = mk("TextButton", {
			Parent = card, Text = "LOAD", Font = Enum.Font.GothamBold, TextSize = 11,
			TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.fromOffset(68, 28), BackgroundColor3 = accent, BorderSizePixel = 0,
		}, 8)
		local stripe = mk("Frame", {
			Parent = card, Size = UDim2.new(0, 3, 1, 0),
			BackgroundColor3 = accent, BorderSizePixel = 0, Visible = false,
		})

		-- entrance animation (staggered)
		task.delay(gi * 0.04, function()
			tween(card, { GroupTransparency = 0 })
			tween(sc, { Scale = 1 })
		end)

		-- states
		card.MouseEnter:Connect(function()
			tween(card, { BackgroundColor3 = T.CardHover })
			tween(stripe, { Visible = true })
		end)
		card.MouseLeave:Connect(function()
			tween(card, { BackgroundColor3 = T.Card })
			tween(stripe, { Visible = false })
		end)
		play.MouseButton1Click:Connect(function()
			tween(play, { BackgroundColor3 = T.Card, TextColor3 = T.Accent })
			task.delay(0.1, function()
				tween(play, { BackgroundColor3 = accent, TextColor3 = Color3.new(1, 1, 1) })
			end)
			if gameDef.Load then
				task.spawn(gameDef.Load)
			end
			if library.Notification then
				library.Notification({ Title = "Loaded", Text = gameDef.Name .. " injected.", Time = 3 })
			end
		end)

		cards[#cards + 1] = { Card = card, Name = gameDef.Name or "" }
	end

	for gi, g in ipairs(games) do
		buildCard(g, gi)
	end

	-- search filter
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = string.lower(searchBox.Text)
		for _, c in ipairs(cards) do
			local match = (q == "") or string.find(string.lower(c.Name), q, 1, true) ~= nil
			c.Card.Visible = match
		end
	end)

	countLbl.Text = #games .. " script" .. (#games == 1 and "" or "s") .. " loaded"
	addNav("Games", "◉", #games)

	-- marker: about/settings + footer + entrance appended below
-- ═══ ABOUT PAGE ═══
	local APage = makePage()
	mk("TextLabel", {
		Parent = APage, Text = "About", Font = Enum.Font.GothamBold, TextSize = 20,
		TextColor3 = T.Text, BackgroundTransparency = 1,
		Position = UDim2.new(0, 18, 0, 12), Size = UDim2.fromOffset(200, 22),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local aboutCard = mk("Frame", {
		Parent = APage, Position = UDim2.new(0, 18, 0, 46),
		Size = UDim2.new(1, -36, 0, 0), BackgroundColor3 = T.Card, BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, 10, true)
	mk("UIPadding", { Parent = aboutCard, PaddingTop = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) })
	mk("UIListLayout", { Parent = aboutCard, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
	mk("TextLabel", { Parent = aboutCard, Text = "HATE", Font = Enum.Font.GothamBold, TextSize = 18,
		TextColor3 = accent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20) })
	mk("TextLabel", { Parent = aboutCard, Text = cfg.About or "A high-quality universal script library.",
		Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T.SubText, BackgroundTransparency = 1, TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 34) })
	mk("TextLabel", { Parent = aboutCard, Text = "Cloaked · Executor friendly · Works across games",
		Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = T.Text, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18) })
	addNav("About", "ℹ", nil)

	-- ═══ SETTINGS PAGE ═══
	local SPage = makePage()
	mk("TextLabel", { Parent = SPage, Text = "Settings", Font = Enum.Font.GothamBold, TextSize = 20,
		TextColor3 = T.Text, BackgroundTransparency = 1,
		Position = UDim2.new(0, 18, 0, 12), Size = UDim2.fromOffset(200, 22),
		TextXAlignment = Enum.TextXAlignment.Left })
	local setList = mk("Frame", { Parent = SPage, Position = UDim2.new(0, 18, 0, 46),
		Size = UDim2.new(1, -36, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0 })
	mk("UIListLayout", { Parent = setList, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
	local st1 = mk("Frame", { Parent = setList, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = T.Card, BorderSizePixel = 0 }, 8)
	mk("TextLabel", { Parent = st1, Text = "Smooth mode", Font = Enum.Font.Gotham, TextSize = 13,
		TextColor3 = T.Text, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -70, 1, 0), TextXAlignment = Enum.TextXAlignment.Left })
	local pill = mk("Frame", { Parent = st1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(36, 18), BackgroundColor3 = T.CardHover, BorderSizePixel = 0 }, 999)
	local knob = mk("Frame", { Parent = pill, Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = T.SubText, BorderSizePixel = 0 }, 999)
	local on = true
	local function setOn(v)
		on = v
		tween(pill, { BackgroundColor3 = v and accent or T.CardHover })
		tween(knob, { Position = v and UDim2.new(1, -15, 0, 3) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = v and Color3.new(1, 1, 1) or T.SubText })
	end
	local st1hit = mk("TextButton", { Parent = st1, Text = "", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1), AutoButtonColor = false })
	st1hit.MouseButton1Click:Connect(function() setOn(not on) end)
	setOn(true)
	addNav("Settings", "◎", nil)

	-- ── footer / status bar ──
	local foot = mk("Frame", { Parent = win, Position = UDim2.new(0, 0, 1, -30),
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = T.Panel, BorderSizePixel = 0 })
	mk("Frame", { Parent = foot, Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Stroke,
		BorderSizePixel = 0, Transparency = 0.4 })
	mk("TextLabel", { Parent = foot, Text = "CLOAKED · READY", Font = Enum.Font.GothamBold, TextSize = 10,
		TextColor3 = accent, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 0), Size = UDim2.new(0, 140, 1, 0) })
	mk("TextLabel", { Parent = foot, Text = "HATE v7.2", Font = Enum.Font.Gotham, TextSize = 11,
		TextColor3 = T.SubText, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0), Size = UDim2.fromOffset(100, 14) })

	-- default page (Games is index 1)
	showPage(1)

	-- entrance transition (loader hands off here)
	tween(back, { BackgroundTransparency = 0.4 })
	tween(win, { GroupTransparency = 0 }, BackOut)
	tween(wsc, { Scale = 1 }, BackOut)

	-- close / destroy
	local function close()
		tween(win, { GroupTransparency = 1 })
		tween(wsc, { Scale = 0.92 })
		tween(back, { BackgroundTransparency = 1 })
		task.delay(0.25, function() gui:Destroy() end)
	end

	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift then
			close()
		end
	end)

	return { Gui = gui, Window = win, Close = close }
end

return library
