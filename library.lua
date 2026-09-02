--[[
	HATE UI v2.0 - design system library
	Fixed palette. One animation system. Container-first layout.
]]

local library = {}
library.__index = library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HOLDER = (gethui and gethui()) or game:GetService("CoreGui")

library.Palette = {
	Background = Color3.fromRGB(12, 12, 17),
	Window = Color3.fromRGB(15, 15, 21),
	Panel = Color3.fromRGB(20, 19, 27),
	PanelHover = Color3.fromRGB(25, 24, 33),
	PanelSelected = Color3.fromRGB(31, 28, 42),
	TextPrimary = Color3.fromRGB(235, 233, 242),
	TextSecondary = Color3.fromRGB(145, 142, 158),
	TextMuted = Color3.fromRGB(95, 92, 108),
	Accent = Color3.fromRGB(130, 85, 255),
	AccentSoft = Color3.fromRGB(90, 60, 170),
	Border = Color3.fromRGB(38, 36, 48),
}
local P = library.Palette

library.Animations = {
	Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Normal = TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
}
local AX = library.Animations

function library.Animate(obj, props, anim)
	if type(anim) == "string" then
		anim = AX[anim]
	end
	return TweenService:Create(obj, anim or AX.Normal, props):Play()
end

function library:tween(obj, props, info)
	return library.Animate(obj, props, info)
end

local function new(class, props, opts)
	opts = opts or {}
	local i = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then
			i[k] = v
		end
	end
	if opts.Radius and opts.Radius > 0 then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, opts.Radius)
		corner.Parent = i
	end
	if opts.Border then
		local stroke = Instance.new("UIStroke")
		stroke.Color = P.Border
		stroke.Thickness = 1
		stroke.Transparency = 0.35
		stroke.Parent = i
	end
	if props.Parent then
		i.Parent = props.Parent
	end
	return i
end
library.new = new

function library:create(class, props)
	local h = (typeof(props.Size) == "UDim2") and props.Size.Y.Offset or 99
	local radius = 0
	if h > 14 and (class == "Frame" or class == "CanvasGroup" or class == "TextButton") then
		radius = h <= 44 and 7 or 10
	end
	return new(class, props, { Radius = radius })
end

-- â•â•â• notifications â•â•â•
do
	local toastGui = new("ScreenGui", { Parent = HOLDER, Name = "", DisplayOrder = 999990 })
	local stack = new("Frame", {
		Parent = toastGui,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 18),
		Size = UDim2.fromOffset(300, 2000),
		BackgroundTransparency = 1,
	})
	new("UIListLayout", { Parent = stack, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

	function library.Notification(cfg)
		cfg = cfg or {}
		local dur = cfg.Time or cfg.time or 3.5

		local toast = new("CanvasGroup", {
			Parent = stack,
			Size = UDim2.new(1, 0, 0, 54),
			BackgroundColor3 = P.Window,
			BorderSizePixel = 0,
			GroupTransparency = 1,
		}, { Radius = 8, Border = true })

		new("Frame", {
			Parent = toast,
			Size = UDim2.new(0, 3, 1, -16),
			Position = UDim2.new(0, 8, 0.5, 8),
			BackgroundColor3 = P.Accent,
			BorderSizePixel = 0,
		})

		new("TextLabel", {
			Parent = toast, Text = cfg.Title or "HATE",
			Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = P.TextPrimary, BackgroundTransparency = 1,
			Position = UDim2.new(0, 22, 0.5, -14),
			Size = UDim2.new(1, -34, 0, 14),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		new("TextLabel", {
			Parent = toast, Text = cfg.Text or "",
			Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = P.TextSecondary, BackgroundTransparency = 1,
			Position = UDim2.new(0, 22, 0.5, 2),
			Size = UDim2.new(1, -34, 0, 14),
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		local sc = new("UIScale", { Parent = toast, Scale = 0.94 })
		library.Animate(toast, { GroupTransparency = 0 }, "Smooth")
		library.Animate(sc, { Scale = 1 }, "Smooth")

		task.delay(dur, function()
			library.Animate(toast, { GroupTransparency = 1 }, "Smooth")
			library.Animate(sc, { Scale = 0.94 }, "Smooth")
			task.wait(0.35)
			toast:Destroy()
		end)
	end
end

library.notification = library.Notification-- â•â•â• loader â•â•â•
function library.CreateLoader(cfg)
	cfg = cfg or {}
	local dur = cfg.Time or 1.4
	local logoId = cfg.Logo or ""

	local gui = new("ScreenGui", { Parent = HOLDER, Name = "", DisplayOrder = 999999 })

	local backdrop = new("Frame", {
		Parent = gui, Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = P.Background,
		BorderSizePixel = 0,
		BackgroundTransparency = 0,
	})

	local scale = new("UIScale", { Parent = backdrop, Scale = 1 })

	local center = new("Frame", {
		Parent = backdrop, Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, BorderSizePixel = 0,
	})
	new("UIListLayout", {
		Parent = center, Padding = UDim.new(0, 18),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local logo = new("ImageLabel", {
		Parent = center, Image = logoId,
		BackgroundTransparency = 1, BorderSizePixel = 0,
		ImageTransparency = 1,
		Size = UDim2.fromOffset(180, 180),
		LayoutOrder = 1,
	})

	local barHolder = new("Frame", {
		Parent = center,
		Size = UDim2.fromOffset(220, 4),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		LayoutOrder = 2,
	})
	local barBg = new("Frame", {
		Parent = barHolder, Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = P.Panel, BorderSizePixel = 0,
	}, { Radius = 2 })
	new("UIPadding", { Parent = barHolder, PaddingBottom = UDim.new(0, 24) })
	local fill = new("Frame", {
		Parent = barBg, Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = P.Accent, BorderSizePixel = 0,
	}, { Radius = 2 })

	local status = new("TextLabel", {
		Parent = center, Text = "Loading",
		Font = Enum.Font.Gotham, TextSize = 12,
		TextColor3 = P.TextMuted, BackgroundTransparency = 1,
		TextTransparency = 0.4,
		Size = UDim2.new(0, 200, 0, 16),
		LayoutOrder = 3,
	})

	library.Animate(logo, { ImageTransparency = 0 }, "Smooth")
	library.Animate(scale, { Scale = 1 }, "Smooth")
	library.Animate(fill, { Size = UDim2.new(1, 0, 1, 0) },
		TweenInfo.new(dur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
	library.Animate(status, { TextTransparency = 0 },
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true))

	task.delay(dur + 0.25, function()
		library.Animate(logo, { ImageTransparency = 1 }, "Smooth")
		library.Animate(backdrop, { BackgroundTransparency = 1 }, "Smooth")
		library.Animate(scale, { Scale = 0.97 }, "Smooth")
		task.wait(0.35)
		gui:Destroy()
		if cfg.Callback then
			task.spawn(cfg.Callback)
		end
	end)

	return gui
end-- â•â•â• window â•â•â•
function library.CreateWindow(cfg)
	cfg = cfg or {}
	local accent = cfg.Accent or P.Accent
	local doClose = nil

	local W, H = 880, 580

	local gui = new("ScreenGui", {
		Parent = HOLDER, Name = "", DisplayOrder = 999996, IgnoreGuiInset = true,
	})

	local root = new("Frame", {
		Parent = gui, Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = P.Background, BorderSizePixel = 0,
	})
	local dim = new("Frame", {
		Parent = root, Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(4, 4, 7),
		BorderSizePixel = 0, BackgroundTransparency = 0.45,
	})

	local scale = new("UIScale", { Parent = root, Scale = 0.96 })
	local win = new("CanvasGroup", {
		Parent = scale,
		Size = UDim2.fromOffset(W, H),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = P.Window,
		BorderSizePixel = 0,
		GroupTransparency = 1,
	}, { Radius = 12, Border = true })

	-- â•â•â• header â•â•â•
	local header = new("Frame", {
		Parent = win, Size = UDim2.new(1, 0, 0, 64),
		BackgroundColor3 = P.Window, BorderSizePixel = 0,
	})
	do
		if cfg.Logo then
			new("ImageLabel", {
				Parent = header, Image = cfg.Logo,
				BackgroundTransparency = 1, BorderSizePixel = 0,
				Size = UDim2.fromOffset(36, 36),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, 30, 0.5, 0),
			})
		end
		local tb = new("Frame", {
			Parent = header, Size = UDim2.new(0, 240, 1, -24),
			Position = UDim2.new(0, 66, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1, BorderSizePixel = 0,
		})
		new("UIListLayout", { Parent = tb, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
		new("TextLabel", {
			Parent = tb, Text = cfg.Title or "FLOW",
			Font = Enum.Font.GothamBold, TextSize = 16,
			TextColor3 = P.TextPrimary, BackgroundTransparency = 1,
			Size = UDim2.new(0, 240, 0, 18),
		})
		new("TextLabel", {
			Parent = tb, Text = cfg.SubTitle or "Universal launcher",
			Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = P.TextSecondary, BackgroundTransparency = 1,
			Size = UDim2.new(0, 240, 0, 14),
		})

		local userArea = new("Frame", {
			Parent = header, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -64, 0.5, 0),
			Size = UDim2.new(0, 120, 0, 34),
			BackgroundTransparency = 1, BorderSizePixel = 0,
		})
		local avatar = new("Frame", {
			Parent = userArea, Size = UDim2.fromOffset(26, 26),
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = P.Panel, BorderSizePixel = 0,
		}, { Radius = 13 })
		new("TextLabel", {
			Parent = avatar, Text = string.sub(cfg.Author or LocalPlayer.Name, 1, 1):upper(),
			Font = Enum.Font.GothamBold, TextSize = 12,
			TextColor3 = P.TextSecondary, BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		})
		new("TextLabel", {
			Parent = userArea, Text = cfg.Author or LocalPlayer.Name,
			Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = P.TextSecondary, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 32, 0.5, 0),
			Size = UDim2.fromOffset(70, 14), TextXAlignment = Enum.TextXAlignment.Left,
		})

		local close = new("TextButton", {
			Parent = header, Text = "x", Font = Enum.Font.GothamBold, TextSize = 15,
			TextColor3 = P.TextMuted, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(26, 26),
			BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false,
		})
		close.MouseEnter:Connect(function() library.Animate(close, { TextColor3 = P.TextPrimary }, "Fast") end)
		close.MouseLeave:Connect(function() library.Animate(close, { TextColor3 = P.TextMuted }, "Fast") end)
		close.MouseButton1Click:Connect(function() if doClose then doClose() end end)

		new("Frame", {
			Parent = header, Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = P.Border, BorderSizePixel = 0, BackgroundTransparency = 0.6,
		})
	end-- â•â•â• navigation â•â•â•
	local nav = new("Frame", {
		Parent = win, Position = UDim2.new(0, 0, 0, 64),
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = P.Window, BorderSizePixel = 0,
	})
	new("UIPadding", {
		Parent = nav, PaddingLeft = UDim.new(0, 20),
		PaddingRight = UDim.new(0, 20), PaddingTop = UDim.new(0, 10),
	})
	new("UIListLayout", {
		Parent = nav, Padding = UDim.new(0, 8),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local content = new("Frame", {
		Parent = win, Position = UDim2.new(0, 0, 0, 116),
		Size = UDim2.new(1, 0, 1, -152),
		BackgroundTransparency = 1, BorderSizePixel = 0,
	})

	local footer = new("Frame", {
		Parent = win, Position = UDim2.new(0, 0, 1, -36),
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = P.Window, BorderSizePixel = 0,
	})
	new("UIPadding", {
		Parent = footer, PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20),
	})

	-- â•â•â• primitives â•â•â•
	local function attachPress(target, inputSource)
		local sc = new("UIScale", { Parent = target, Scale = 1 })
		local src = inputSource or target
		src.MouseButton1Down:Connect(function() library.Animate(sc, { Scale = 0.97 }, "Fast") end)
		src.MouseButton1Up:Connect(function() library.Animate(sc, { Scale = 1 }, "Fast") end)
		src.MouseLeave:Connect(function() library.Animate(sc, { Scale = 1 }, "Fast") end)
	end

	-- â•â•â• page system â•â•â•
	local pages = {}
	local navButtons = {}
	local currentPage = 0

	local function transition(dest)
		if currentPage == dest then return end
		local old = pages[currentPage]
		local newPage = pages[dest]
		currentPage = dest

		if old then
			library.Animate(old.Page, { GroupTransparency = 1, Position = UDim2.fromOffset(-14, 0) }, "Smooth")
			task.delay(0.15, function() old.Page.Visible = false end)
		end

		if newPage then
			newPage.Page.Visible = true
			newPage.Page.GroupTransparency = 1
			newPage.Page.Position = UDim2.fromOffset(14, 0)
			library.Animate(newPage.Page, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) }, "Smooth")
		end

		for i, nb in ipairs(navButtons) do
			local active = (i == dest)
			library.Animate(nb.B, { BackgroundColor3 = active and P.PanelSelected or P.Panel }, "Normal")
			library.Animate(nb.L, { TextColor3 = active and accent or P.TextSecondary }, "Normal")
			library.Animate(nb.I, { BackgroundTransparency = active and 0 or 1 }, "Normal")
		end
	end

	local function addPage(name, icon)
		local b = new("Frame", {
			Parent = nav, Size = UDim2.new(0, 120, 0, 30),
			BackgroundColor3 = P.Panel, BorderSizePixel = 0,
		}, { Radius = 7 })
		new("TextLabel", {
			Parent = b, Text = icon, Font = Enum.Font.GothamBold, TextSize = 13,
			TextColor3 = P.TextSecondary, BackgroundTransparency = 1,
			Size = UDim2.fromOffset(18, 30), Position = UDim2.fromOffset(10, 0),
		})
		local lbl = new("TextLabel", {
			Parent = b, Text = name, Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = P.TextSecondary, BackgroundTransparency = 1,
			Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -44, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		local ind = new("Frame", {
			Parent = b, Size = UDim2.new(0, 3, 0, 3),
			AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -12, 1, -6),
			BackgroundColor3 = accent, BorderSizePixel = 0, BackgroundTransparency = 1,
		})

		local hit = new("TextButton", {
			Parent = b, Text = "", AutoButtonColor = false,
			BackgroundColor3 = P.Panel, BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
		}, { Radius = 7 })
		attachPress(hit)

		local page = new("CanvasGroup", {
			Parent = content, Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Visible = false, GroupTransparency = 1,
		})
		new("UIPadding", {
			Parent = page, PaddingTop = UDim.new(0, 20),
			PaddingBottom = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20),
		})
		local list = new("Frame", {
			Parent = page, Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1, BorderSizePixel = 0,
		})
		new("UIListLayout", { Parent = list, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })

		local idx = #pages + 1
		pages[idx] = { Page = page, List = list }
		navButtons[idx] = { B = b, L = lbl, I = ind }

		hit.MouseButton1Click:Connect(function() transition(idx) end)

		return { Page = page, List = list, Index = idx, NavButton = b }
	end-- â•â•â• pages â•â•â•
	local homeChild = addPage("Home", "v")
	local gamesChild = addPage("Games", "#")

	-- home hero
	do
		local hero = new("Frame", {
			Parent = homeChild.List, Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = P.Panel, BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
		}, { Radius = 10, Border = true })
		new("UIPadding", { Parent = hero, PaddingTop = UDim.new(0, 18),
			PaddingBottom = UDim.new(0, 18), PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20) })
		new("UIListLayout", { Parent = hero, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })

		new("TextLabel", {
			Parent = hero, Text = "Welcome",
			Font = Enum.Font.GothamBold, TextSize = 20,
			TextColor3 = P.TextPrimary, BackgroundTransparency = 1,
			Size = UDim2.new(0, 300, 0, 24),
		})
		new("TextLabel", {
			Parent = hero, Text = "Select a game from the Supported Games page to load its script.",
			Font = Enum.Font.Gotham, TextSize = 14,
			TextColor3 = P.TextSecondary, BackgroundTransparency = 1,
			TextWrapped = true, Size = UDim2.new(1, 0, 0, 36),
		})
	end

	-- games page: search Â· count Â· list
	local searchBox, countLabel, rowsContainer
	local rowRegistry = {}
	do
		local searchBar = new("Frame", {
			Parent = gamesChild.List, Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = P.Panel, BorderSizePixel = 0,
		}, { Radius = 7 })
		local searchStroke = new("UIStroke", {
			Parent = searchBar, Color = P.Border, Thickness = 1, Transparency = 0.35,
		})

		local ring = new("Frame", {
			Parent = searchBar, Size = UDim2.fromOffset(12, 12),
			Position = UDim2.new(0, 14, 0, 13),
			BackgroundTransparency = 1, BorderSizePixel = 0,
		})
		new("UICorner", { Parent = ring, CornerRadius = UDim.new(1, 0) })
		new("UIStroke", { Parent = ring, Color = P.TextMuted, Thickness = 1.2 })
		new("Frame", {
			Parent = searchBar, Size = UDim2.fromOffset(6, 1.5),
			Position = UDim2.new(0, 24, 0, 25), Rotation = -45,
			BackgroundColor3 = P.TextMuted, BorderSizePixel = 0,
		})

		searchBox = new("TextBox", {
			Parent = searchBar, Text = "", PlaceholderText = "Search supported games",
			PlaceholderColor3 = P.TextMuted, Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = P.TextPrimary, ClearTextOnFocus = false,
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.new(0, 38, 0, 0), Size = UDim2.new(1, -50, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		searchBox.Focused:Connect(function()
			library.Animate(searchStroke, { Transparency = 0.05 }, "Smooth")
			library.Animate(searchStroke, { Color = P.Accent }, "Smooth")
		end)
		searchBox.FocusLost:Connect(function()
			library.Animate(searchStroke, { Transparency = 0.35 }, "Smooth")
			library.Animate(searchStroke, { Color = P.Border }, "Smooth")
		end)

		countLabel = new("TextLabel", {
			Parent = gamesChild.List, Text = "0 scripts",
			Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = P.TextSecondary, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		local gamesList = new("ScrollingFrame", {
			Parent = gamesChild.List, Size = UDim2.new(1, 0, 0, 296),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3, ScrollBarImageColor3 = accent,
			ScrollBarImageTransparency = 0.35,
		})
		rowsContainer = new("Frame", {
			Parent = gamesList, Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		new("UIListLayout", { Parent = rowsContainer, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })

		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			local q = string.lower(searchBox.Text)
			local visible = 0
			for _, rec in ipairs(rowRegistry) do
				local show = (q == "") or string.find(string.lower(rec.Name), q, 1, true) ~= nil
				rec.Row.Visible = show
				if show then visible = visible + 1 end
			end
			countLabel.Text = visible .. " script" .. (visible == 1 and "" or "s")
		end)
	end-- â•â•â• component primitives â•â•â•
	local function attachHover(b, leaveCol)
		b.MouseEnter:Connect(function() library.Animate(b, { BackgroundColor3 = P.PanelHover }, "Fast") end)
		b.MouseLeave:Connect(function() library.Animate(b, { BackgroundColor3 = leaveCol or P.Panel }, "Fast") end)
	end

	local function labelRow(list, text)
		return new("TextLabel", {
			Parent = list, Text = text,
			Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = P.TextSecondary, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left,
		})
	end

	local function buttonRow(list, cfg2)
		local b = new("TextButton", {
			Parent = list, Text = "", AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = P.Panel, BorderSizePixel = 0,
		}, { Radius = 7 })
		attachHover(b)
		attachPress(b)
		new("TextLabel", {
			Parent = b, Text = cfg2.Name or "Button",
			Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = P.TextPrimary, BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		})
		b.MouseButton1Click:Connect(function()
			if cfg2.Callback then cfg2.Callback() end
		end)
		return b
	end

	local function toggleRow(list, cfg2)
		local r = new("Frame", {
			Parent = list, Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = P.Panel, BorderSizePixel = 0,
		}, { Radius = 7 })
		new("TextLabel", {
			Parent = r, Text = cfg2.Name or "Toggle",
			Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = P.TextPrimary, BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -70, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		local pill = new("Frame", {
			Parent = r, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(38, 18),
			BackgroundColor3 = P.PanelSelected, BorderSizePixel = 0,
		}, { Radius = 999 })
		local knob = new("Frame", {
			Parent = pill, Size = UDim2.fromOffset(12, 12),
			Position = UDim2.fromOffset(3, 3),
			BackgroundColor3 = P.TextMuted, BorderSizePixel = 0,
		}, { Radius = 999 })
		local value = cfg2.Default and true or false
		local function set(v)
			value = v
			library.Animate(pill, { BackgroundColor3 = v and P.Accent or P.PanelSelected }, "Normal")
			library.Animate(knob, {
				Position = v and UDim2.new(1, -15, 0, 3) or UDim2.fromOffset(3, 3),
				BackgroundColor3 = v and Color3.fromRGB(255, 255, 255) or P.TextMuted,
			}, "Smooth")
			if cfg2.Callback then cfg2.Callback(v) end
		end
		local hit = new("TextButton", {
			Parent = r, Text = "", BackgroundTransparency = 1,
			BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		})
		hit.MouseButton1Click:Connect(function() set(not value) end)
		set(value)
		return { Set = set, Get = function() return value end }
	end
	local function sliderRow(list, cfg2)
		local min = cfg2.Min or 0
		local max = cfg2.Max or 100
		local r = new("Frame", {
			Parent = list, Size = UDim2.new(1, 0, 0, 42),
			BackgroundColor3 = P.Panel, BorderSizePixel = 0,
		}, { Radius = 7 })
		local valLbl = new("TextLabel", {
			Parent = r, Text = "", Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = P.TextSecondary, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 6),
			Size = UDim2.new(0, 80, 0, 14), TextXAlignment = Enum.TextXAlignment.Right,
		})
		new("TextLabel", {
			Parent = r, Text = cfg2.Name or "Slider",
			Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = P.TextPrimary, BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 4), Size = UDim2.new(0, 180, 0, 16),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		local track = new("Frame", {
			Parent = r, Position = UDim2.new(0, 12, 1, -14),
			Size = UDim2.new(1, -24, 0, 4),
			BackgroundColor3 = P.PanelSelected, BorderSizePixel = 0,
		}, { Radius = 2 })
		local fill = new("Frame", {
			Parent = track, Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = P.Accent, BorderSizePixel = 0,
		}, { Radius = 2 })
		local value = cfg2.Default or min
		local function setVal(v)
			v = math.clamp(v, min, max)
			local a = (max == min) and 0 or (v - min) / (max - min)
			fill.Size = UDim2.new(a, 0, 1, 0)
			valLbl.Text = tostring(math.floor(v)) .. (cfg2.Suffix or "")
			value = v
			if cfg2.Callback then cfg2.Callback(v) end
		end
		local dragging = false
		local function update(px)
			local a = math.clamp((px - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			setVal(min + (max - min) * a)
		end
		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				update(UserInputService:GetMouseLocation().X)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				update(UserInputService:GetMouseLocation().X)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		setVal(value)
		return { Set = setVal, Get = function() return value end }
	end

	-- â•â•â• game rows â•â•â•
	local function addGame(cfg2)
		local row = new("Frame", {
			Parent = rowsContainer, Size = UDim2.new(1, 0, 0, 54),
			BackgroundColor3 = P.Panel, BorderSizePixel = 0,
		}, { Radius = 7 })
		attachHover(row)

		if cfg2.Icon and cfg2.Icon ~= "" then
			new("ImageLabel", {
				Parent = row, Image = cfg2.Icon, BackgroundTransparency = 1,
				BorderSizePixel = 0, Size = UDim2.fromOffset(38, 38),
				AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0),
			})
		else
			local tile = new("Frame", {
				Parent = row, Size = UDim2.fromOffset(38, 38),
				AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0),
				BackgroundColor3 = P.PanelSelected, BorderSizePixel = 0,
			}, { Radius = 7 })
			new("TextLabel", {
				Parent = tile, Text = string.sub(cfg2.Name or "?", 1, 1):upper(),
				Font = Enum.Font.GothamBold, TextSize = 15,
				TextColor3 = P.Accent, BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			})
		end

		new("TextLabel", {
			Parent = row, Text = cfg2.Name or "Game",
			Font = Enum.Font.Gotham, TextSize = 14,
			TextColor3 = P.TextPrimary, BackgroundTransparency = 1,
			Position = UDim2.new(0, 58, 0, 8), Size = UDim2.new(1, -140, 0, 18),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		new("TextLabel", {
			Parent = row, Text = cfg2.Desc or "",
			Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = P.TextMuted, BackgroundTransparency = 1,
			Position = UDim2.new(0, 58, 0, 28), Size = UDim2.new(1, -150, 0, 16),
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		local arrow = new("TextLabel", {
			Parent = row, Text = "->", Font = Enum.Font.Gotham, TextSize = 16,
			TextColor3 = P.TextMuted, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0),
			Size = UDim2.fromOffset(22, 20),
		})
		row.MouseEnter:Connect(function() library.Animate(arrow, { TextColor3 = P.Accent }, "Fast") end)
		row.MouseLeave:Connect(function() library.Animate(arrow, { TextColor3 = P.TextMuted }, "Fast") end)

		local hit = new("TextButton", {
			Parent = row, Text = "", BackgroundTransparency = 1,
			BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		})
		attachPress(row, hit)
		hit.MouseButton1Click:Connect(function()
			library.Animate(row, { BackgroundColor3 = P.PanelSelected }, "Fast")
			task.delay(0.15, function() library.Animate(row, { BackgroundColor3 = P.Panel }, "Fast") end)
			if cfg2.Load then task.spawn(cfg2.Load) end
			library.Notification({ Title = cfg2.Name or "Game", Text = "Loaded.", Time = 3 })
		end)

		rowRegistry[#rowRegistry + 1] = { Row = row, Name = cfg2.Name or "" }
		countLabel.Text = #rowRegistry .. " script" .. (#rowRegistry == 1 and "" or "s")
		return row
	end-- â•â•â• footer labels â•â•â•
	do
		new("TextLabel", {
			Parent = footer, Text = "Ready",
			Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = P.TextSecondary, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 200, 0, 14), TextXAlignment = Enum.TextXAlignment.Left,
		})
		new("TextLabel", {
			Parent = footer, Text = "HATE " .. (cfg.Version or "v2.0"),
			Font = Enum.Font.Gotham, TextSize = 12,
			TextColor3 = P.TextMuted, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0),
			Size = UDim2.new(0, 120, 0, 14), TextXAlignment = Enum.TextXAlignment.Right,
		})
	end

	-- â•â•â• open / close â•â•â•
	local function open()
		win.GroupTransparency = 1
		scale.Scale = 0.96
		library.Animate(win, { GroupTransparency = 0 }, "Smooth")
		library.Animate(scale, { Scale = 1 }, "Smooth")
		library.Animate(dim, { BackgroundTransparency = 0.45 }, "Smooth")
		task.defer(function()
			if pages[1] then transition(1) end
		end)
	end

	local function close()
		library.Animate(win, { GroupTransparency = 1 }, "Smooth")
		library.Animate(scale, { Scale = 0.96 }, "Smooth")
		library.Animate(dim, { BackgroundTransparency = 1 }, "Smooth")
		task.delay(0.35, function() gui:Destroy() end)
	end
	doClose = close

	-- â•â•â• consumer API â•â•â•
	local function pageAPI(list)
		return {
			AddLabel = function(cfg2) return labelRow(list, cfg2.Text or cfg2.Name or "") end,
			AddButton = function(cfg2) return buttonRow(list, cfg2) end,
			AddToggle = function(cfg2) return toggleRow(list, cfg2) end,
			AddSlider = function(cfg2) return sliderRow(list, cfg2) end,
		}
	end

	local winHandle = {
		Gui = gui,
		Window = win,
		Home = pageAPI(homeChild.List),
		Games = pageAPI(gamesChild.List),
		AddGame = function(cfg2) return addGame(cfg2) end,
		Open = open,
		Close = close,
		Transition = transition,
	}

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift then
			if gui.Parent then close() end
		end
	end)

	open()
	return winHandle
end

return library
