-- ModuleScript: StormLib.lua

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local StormLib = {}
StormLib.__index = StormLib

-- ──────────────────────────────────────────
-- TEMA GLOBAL
-- ──────────────────────────────────────────
local Theme = {
  WindowBG    = Color3.fromRGB(30,  30,  30),
  TitleBG     = Color3.fromRGB(40,  40,  40),
  SectionBG   = Color3.fromRGB(50,  50,  50),
  ButtonBG    = Color3.fromRGB(60,  60,  60),
  TextColor   = Color3.fromRGB(230, 230, 230),
  Accent      = Color3.fromRGB(255, 200,   0),
  GlowAccent  = Color3.fromRGB(230, 180,   0),
  Padding     = UDim.new(0, 8),
  CornerR     = UDim.new(0, 6),
  GlowSize    = 2,
  Animation   = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

-- ──────────────────────────────────────────
-- HELPERS
-- ──────────────────────────────────────────

-- Crea un Frame con UICorner y UIStroke (glow) SIEMPRE
function StormLib:_createFrame(name, parent, props)
  local f = Instance.new("Frame", parent)
  f.Name = name
  for k,v in pairs(props) do f[k] = v end
  local cr = Instance.new("UICorner", f)
  cr.CornerRadius = Theme.CornerR
  local st = Instance.new("UIStroke", f)
  st.Color        = Theme.GlowAccent
  st.Thickness    = Theme.GlowSize
  st.Transparency = 0.5
  return f
end

-- Anima propiedades con TweenService
function StormLib:_tween(obj, props, onComplete)
  local tw = TweenService:Create(obj, Theme.Animation, props)
  if onComplete then tw.Completed:Connect(onComplete) end
  tw:Play()
  return tw
end

-- Monta la pantalla de carga y la devuelve
function StormLib:_createLoader()
  -- Parent de la Loader = mismo que la StormLib.Gui.Parent
  local lg = Instance.new("ScreenGui", self._parent)
  lg.Name           = "StormLoading"
  lg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

  local back = Instance.new("Frame", lg)
  back.Name               = "Back"
  back.Size               = UDim2.new(1,0,1,0)
  back.BackgroundColor3   = Theme.WindowBG
  back.BackgroundTransparency = 0.3

  local logo = Instance.new("ImageLabel", back)
  logo.Name               = "Logo"
  logo.Size               = UDim2.new(0,150,0,150)
  logo.Position           = UDim2.new(0.5,-75,0.2,0)
  logo.BackgroundTransparency = 1
  logo.Image              = "rbxassetid://116206028290344"
  logo.ImageColor3        = Theme.Accent

  local track = Instance.new("Frame", back)
  track.Name             = "Track"
  track.Size             = UDim2.new(0,300,0,20)
  track.Position         = UDim2.new(0.5,-150,0.6,0)
  track.BackgroundColor3 = Theme.TitleBG
  Instance.new("UICorner", track).CornerRadius = UDim.new(0,10)

  local fill = Instance.new("Frame", track)
  fill.Name             = "Fill"
  fill.Size             = UDim2.new(0,0,1,0)
  fill.BackgroundColor3 = Theme.Accent
  Instance.new("UICorner", fill).CornerRadius = UDim.new(0,10)

  local perc = Instance.new("TextLabel", back)
  perc.Name               = "Percent"
  perc.Size               = UDim2.new(0,100,0,30)
  perc.Position           = UDim2.new(0.5,-50,0.65,0)
  perc.BackgroundTransparency = 1
  perc.Font               = Enum.Font.GothamBold
  perc.TextSize           = 18
  perc.TextColor3         = Theme.TextColor
  perc.Text               = "0%"

  local loader = {}
  function loader:update(p)
    local c = math.clamp(p,0,1)
    TweenService:Create(fill, TweenInfo.new(0.3), {Size = UDim2.new(c,0,1,0)}):Play()
    perc.Text = ("%d%%"):format(c*100)
  end
  function loader:hide()
    TweenService:Create(back, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(logo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    TweenService:Create(track, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(fill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(perc, TweenInfo.new(0.5), {TextTransparency = 1}):Play().Completed:Wait()
    lg:Destroy()
  end

  return loader
end

-- ──────────────────────────────────────────
-- CONSTRUCTOR
-- ──────────────────────────────────────────
function StormLib.new(title, parent)
  parent = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")
  local self = setmetatable({}, StormLib)
  self._parent   = parent
  self.Tabs      = {}
  self.ActiveTab = nil

  -- ScreenGui principal
  self.Gui = Instance.new("ScreenGui", parent)
  self.Gui.Name         = "StormLib"
  self.Gui.ResetOnSpawn = false

  -- Ventana draggable con glow y corner
  self.Window = self:_createFrame("Window", self.Gui, {
    Size             = UDim2.new(0,400,0,500),
    Position         = UDim2.new(0.5,-200,0.5,-250),
    BackgroundColor3 = Theme.WindowBG,
  })
  self.Window.Active    = true
  self.Window.Draggable = true

  -- Fade-in inicial de la ventana
  self.Window.BackgroundTransparency = 1
  self:_tween(self.Window, {BackgroundTransparency = 0})

  -- TopBar (visual)
  self.TopBar = self:_createFrame("TopBar", self.Window, {
    Size             = UDim2.new(1,0,0,40),
    BackgroundColor3 = Theme.TitleBG,
  })

  -- Título
  local titleLbl = Instance.new("TextLabel", self.TopBar)
  titleLbl.Name               = "Title"
  titleLbl.BackgroundTransparency = 1
  titleLbl.Size               = UDim2.new(1,-80,1,0)
  titleLbl.Position           = UDim2.new(0,10,0,0)
  titleLbl.Font               = Enum.Font.GothamBold
  titleLbl.TextSize           = 18
  titleLbl.TextColor3         = Theme.Accent
  titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
  titleLbl.Text               = title

  -- Botón Cerrar
  local closeBtn = Instance.new("ImageButton", self.TopBar)
  closeBtn.Name               = "Close"
  closeBtn.Size               = UDim2.new(0,24,0,24)
  closeBtn.Position           = UDim2.new(1,-30,0,8)
  closeBtn.BackgroundTransparency = 1
  closeBtn.Image              = "rbxassetid://6031094678"
  closeBtn.ImageColor3        = Theme.TextColor
  closeBtn.MouseButton1Click:Connect(function()
    self.Gui:Destroy()
  end)

  -- Barra de pestañas
  self.TabBar = Instance.new("Frame", self.Window)
  self.TabBar.Name               = "TabBar"
  self.TabBar.Size               = UDim2.new(1,0,0,30)
  self.TabBar.Position           = UDim2.new(0,0,0,40)
  self.TabBar.BackgroundTransparency = 1
  local tabLayout = Instance.new("UIListLayout", self.TabBar)
  tabLayout.FillDirection       = Enum.FillDirection.Horizontal
  tabLayout.Padding             = UDim.new(0,4)
  tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

  -- Contenedor de contenido de pestañas
  self.TabContainer = Instance.new("Frame", self.Window)
  self.TabContainer.Name               = "TabContainer"
  self.TabContainer.Size               = UDim2.new(1,0,1,-70)
  self.TabContainer.Position           = UDim2.new(0,0,0,70)
  self.TabContainer.BackgroundTransparency = 1

  -- Crea loader por defecto
  self.Loader = self:_createLoader()

  return self
end

-- ──────────────────────────────────────────
-- API: AÑADIR PESTAÑA
-- ──────────────────────────────────────────
function StormLib:addTab(name, iconAssetId)
  local btnCount = #self.TabBar:GetChildren()
  local btn = Instance.new("TextButton", self.TabBar)
  btn.Name               = "Tab_"..name
  btn.BackgroundTransparency = 1
  btn.AutoButtonColor    = false
  btn.Size               = UDim2.new(0,120,1,0)
  btn.LayoutOrder        = btnCount + 1

  -- Glow & corner en el botón
  Instance.new("UICorner", btn).CornerRadius = Theme.CornerR
  do local st=Instance.new("UIStroke", btn)
    st.Color, st.Thickness, st.Transparency =
      Theme.GlowAccent, Theme.GlowSize, 0.5
  end

  -- Icono
  local icon = Instance.new("ImageLabel", btn)
  icon.Name               = "Icon"
  icon.Size               = UDim2.new(0,16,0,16)
  icon.Position           = UDim2.new(0,12,0.5,-8)
  icon.BackgroundTransparency = 1
  icon.Image              = iconAssetId or ""
  icon.ImageColor3        = Theme.TextColor

  -- Etiqueta
  local label = Instance.new("TextLabel", btn)
  label.Name               = "Label"
  label.BackgroundTransparency = 1
  label.Size               = UDim2.new(1,-40,1,0)
  label.Position           = UDim2.new(0,36,0,0)
  label.Font               = Enum.Font.Gotham
  label.TextSize           = 16
  label.TextColor3         = Theme.TextColor
  label.TextXAlignment     = Enum.TextXAlignment.Left
  label.Text               = name

  -- Contenedor de la pestaña
  local content = Instance.new("Frame", self.TabContainer)
  content.Name               = "Content_"..name
  content.BackgroundTransparency = 1
  content.Size               = UDim2.new(1,0,1,0)
  content.Visible            = false
  local layout = Instance.new("UIListLayout", content)
  layout.SortOrder           = Enum.SortOrder.LayoutOrder
  layout.Padding             = Theme.Padding
  layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

  -- Al hacer click, fade‐in del contenido
  btn.MouseButton1Click:Connect(function()
    self:_selectTab(name)
  end)

  self.Tabs[name] = { Button = btn, Content = content }
  if not self.ActiveTab then
    self:_selectTab(name)
  end

  -- Devuelve handler para añadir controles
  local handler = {}
  setmetatable(handler, {
    __index = function(_, method)
      return function(_, ...)
        return StormLib[method](self, content, ...)
      end
    end
  })
  return handler
end

-- Selecciona y anima pestaña
function StormLib:_selectTab(name)
  for k,tab in pairs(self.Tabs) do
    local active = (k == name)
    tab.Content.Visible            = active
    tab.Button.Icon.ImageColor3    = active and Theme.Accent or Theme.TextColor
    tab.Button.Label.TextColor3    = active and Theme.Accent or Theme.TextColor
    if active then
      tab.Content.BackgroundTransparency = 1
      self:_tween(tab.Content, {BackgroundTransparency = 0})
    end
  end
  self.ActiveTab = name
end

-- ──────────────────────────────────────────
-- API: BOTÓN
-- ──────────────────────────────────────────
function StormLib:addButton(frame, text, callback)
  local f = self:_createFrame("Btn_"..text, frame, {
    Size             = UDim2.new(1,-30,0,40),
    BackgroundColor3 = Theme.ButtonBG,
  })
  f.LayoutOrder = #frame:GetChildren()

  local lbl = Instance.new("TextLabel", f)
  lbl.Name               = "Label"
  lbl.BackgroundTransparency = 1
  lbl.Size               = UDim2.new(1,-60,1,0)
  lbl.Position           = UDim2.new(0,10,0,0)
  lbl.Font               = Enum.Font.Gotham
  lbl.TextSize           = 16
  lbl.TextColor3         = Theme.TextColor
  lbl.TextXAlignment     = Enum.TextXAlignment.Left
  lbl.Text               = text

  local btn = Instance.new("TextButton", f)
  btn.Name               = "Btn"
  btn.BackgroundTransparency = 1
  btn.Size               = UDim2.new(0,30,0,30)
  btn.Position           = UDim2.new(1,-40,0.5,-15)
  btn.Font               = Enum.Font.GothamBold
  btn.TextSize           = 20
  btn.TextColor3         = Theme.Accent
  btn.Text               = "▶"
  btn.MouseButton1Click:Connect(function() pcall(callback) end)

  return f
end

-- ──────────────────────────────────────────
-- API: TOGGLE
-- ──────────────────────────────────────────
function StormLib:addToggle(frame, text, default, callback)
  local state = default and true or false
  local f = self:_createFrame("Toggle_"..text, frame, {
    Size             = UDim2.new(1,-30,0,40),
    BackgroundColor3 = Theme.ButtonBG,
  })
  f.LayoutOrder = #frame:GetChildren()

  local lbl = Instance.new("TextLabel", f)
  lbl.Name="Label"; lbl.BackgroundTransparency=1
  lbl.Size=UDim2.new(1,-80,1,0); lbl.Position=UDim2.new(0,10,0,0)
  lbl.Font=Enum.Font.Gotham; lbl.TextSize=16
  lbl.TextColor3=Theme.TextColor; lbl.TextXAlignment=Enum.TextXAlignment.Left
  lbl.Text=text

  local bg = Instance.new("Frame", f)
  bg.Name="Bg"; bg.Size=UDim2.new(0,50,0,24)
  bg.Position=UDim2.new(1,-60,0.5,-12); bg.BackgroundColor3=Theme.TitleBG
  Instance.new("UICorner", bg).CornerRadius = UDim.new(0,12)
  Instance.new("UIStroke", bg).Color = Theme.GlowAccent

  local ind = Instance.new("Frame", bg)
  ind.Name="Indicator"; ind.Size=UDim2.new(0,22,0,22)
  ind.Position=UDim2.new(state and 1 or 0, state and -22 or 0,0,0)
  ind.BackgroundColor3=Theme.Accent
  Instance.new("UICorner", ind).CornerRadius = UDim.new(1,0)
  Instance.new("UIStroke", ind).Color = Theme.GlowAccent

  bg.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
      state = not state
      ind.Position = UDim2.new(state and 1 or 0, state and -22 or 0,0,0)
      pcall(callback, state)
    end
  end)
  return f
end

-- ──────────────────────────────────────────
-- API: SLIDER
-- ──────────────────────────────────────────
function StormLib:addSlider(frame, text, minVal, maxVal, default, callback)
  local range = maxVal - minVal
  default = math.clamp(default, minVal, maxVal)
  local f = self:_createFrame("Slider_"..text, frame, {
    Size                   = UDim2.new(1,-30,0,50),
    BackgroundTransparency = 1,
  })
  f.LayoutOrder = #frame:GetChildren()

  local lbl = Instance.new("TextLabel", f)
  lbl.Name="Label"; lbl.BackgroundTransparency=1
  lbl.Size=UDim2.new(1,-20,0,20); lbl.Position=UDim2.new(0,10,0,0)
  lbl.Font=Enum.Font.Gotham; lbl.TextSize=16
  lbl.TextColor3=Theme.TextColor; lbl.TextXAlignment=Enum.TextXAlignment.Left
  lbl.Text=text

  local track = Instance.new("Frame", f)
  track.Name="Track"; track.Size=UDim2.new(1,-20,0,8)
  track.Position=UDim2.new(0,10,1,-18); track.BackgroundColor3=Theme.TitleBG
  Instance.new("UICorner", track).CornerRadius = UDim.new(0,4)
  Instance.new("UIStroke", track).Color = Theme.GlowAccent

  local fill = Instance.new("Frame", track)
  fill.Name="Fill"; fill.Size=UDim2.new((default-minVal)/range,0,1,0)
  fill.BackgroundColor3=Theme.Accent
  Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)
  Instance.new("UIStroke", fill).Color = Theme.GlowAccent

  local thumb = Instance.new("Frame", track)
  thumb.Name="Thumb"; thumb.Size=UDim2.new(0,18,0,18)
  thumb.Position=UDim2.new(fill.Size.X.Scale,0,0.5,-9)
  thumb.BackgroundColor3=Theme.GlowAccent
  Instance.new("UICorner", thumb).CornerRadius = UDim.new(1,0)
  Instance.new("UIStroke", thumb).Color = Theme.GlowAccent

  local dragging = false
  thumb.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
  end)
  thumb.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
      dragging=false
      local v = minVal + fill.Size.X.Scale*range
      pcall(callback, v)
    end
  end)
  track.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
      local rel = math.clamp(
        (i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0,1
      )
      fill.Size      = UDim2.new(rel,0,1,0)
      thumb.Position = UDim2.new(rel,0,0.5,-9)
    end
  end)

  return f
end

-- ──────────────────────────────────────────
-- API: DROPDOWN
-- ──────────────────────────────────────────
function StormLib:addDropdown(frame, text, options, defaultIdx, callback)
  defaultIdx = math.clamp(defaultIdx or 1,1,#options)
  local f = self:_createFrame("Dropdown_"..text, frame, {
    Size             = UDim2.new(1,-30,0,40),
    BackgroundColor3 = Theme.ButtonBG,
  })
  f.LayoutOrder = #frame:GetChildren()

  local lbl = Instance.new("TextLabel", f)
  lbl.Name="Label"; lbl.BackgroundTransparency=1
  lbl.Size=UDim2.new(1,-60,1,0); lbl.Position=UDim2.new(0,10,0,0)
  lbl.Font=Enum.Font.Gotham; lbl.TextSize=16
  lbl.TextColor3=Theme.TextColor; lbl.TextXAlignment=Enum.TextXAlignment.Left
  lbl.Text=text..": "..options[defaultIdx]

  local arrow = Instance.new("ImageButton", f)
  arrow.Name="Arrow"; arrow.Size=UDim2.new(0,24,0,24)
  arrow.Position=UDim2.new(1,-30,0.5,-12); arrow.BackgroundTransparency=1
  arrow.Image="rbxassetid://6031094678"; arrow.ImageColor3=Theme.TextColor

  local list = Instance.new("Frame", f)
  list.Name="Options"; list.Visible=false
  list.Size=UDim2.new(1,0,0,#options*30)
  list.Position=UDim2.new(0,0,1,4); list.BackgroundColor3=Theme.SectionBG
  Instance.new("UICorner", list).CornerRadius = Theme.CornerR
  Instance.new("UIStroke", list).Color = Theme.GlowAccent

  local layout = Instance.new("UIListLayout", list)
  layout.SortOrder = Enum.SortOrder.LayoutOrder

  for i,opt in ipairs(options) do
    local it = Instance.new("TextButton", list)
    it.Name="Opt"..i; it.Size=UDim2.new(1,0,0,30)
    it.Position=UDim2.new(0,0,0,(i-1)*30)
    it.BackgroundTransparency=1
    it.Font=Enum.Font.Gotham; it.TextSize=16
    it.TextColor3=Theme.TextColor; it.Text=opt
    it.TextXAlignment=Enum.TextXAlignment.Left; it.Position=UDim2.new(0,10,0,(i-1)*30)
    it.MouseButton1Click:Connect(function()
      defaultIdx = i
      lbl.Text = text..": "..opt
      -- animación cierre
      self:_tween(list, {BackgroundTransparency = 1}, function() list.Visible = false end)
      pcall(callback, opt, i)
    end)
  end

  arrow.MouseButton1Click:Connect(function()
    list.Visible = true
    list.BackgroundTransparency = 1
    -- animación apertura
    self:_tween(list, {BackgroundTransparency = 0})
  end)

  return f
end

-- ──────────────────────────────────────────
-- API: COLOR PICKER (rueda en código)
-- ──────────────────────────────────────────
function StormLib:addColorPicker(frame, text, defaultColor, callback, size, res)
  defaultColor = defaultColor or Color3.fromHSV(0,0,1)
  size  = size or 200
  res   = res  or 60

  local f = self:_createFrame("ColorPicker_"..text, frame, {
    Size             = UDim2.new(1,-30,0,40+size),
    BackgroundColor3 = Theme.ButtonBG,
  })
  f.LayoutOrder = #frame:GetChildren()

  local lbl = Instance.new("TextLabel", f)
  lbl.Name="Label"; lbl.BackgroundTransparency=1
  lbl.Size=UDim2.new(1,-60,0,20); lbl.Position=UDim2.new(0,10,0,0)
  lbl.Font=Enum.Font.Gotham; lbl.TextSize=16
  lbl.TextColor3=Theme.TextColor; lbl.TextXAlignment=Enum.TextXAlignment.Left
  lbl.Text=text

  local preview = Instance.new("Frame", f)
  preview.Name="Preview"; preview.Size=UDim2.new(0,30,0,30)
  preview.Position=UDim2.new(1,-50,0,0); preview.BackgroundColor3=defaultColor
  Instance.new("UICorner", preview).CornerRadius=UDim.new(1,0)
  Instance.new("UIStroke", preview).Color=Theme.GlowAccent

  local open = Instance.new("TextButton", f)
  open.Name="OpenWheel"; open.BackgroundTransparency=1
  open.Size=UDim2.new(0,24,0,24); open.Position=UDim2.new(1,-20,0,0)
  open.Font=Enum.Font.GothamBold; open.TextSize=20
  open.TextColor3=Theme.TextColor; open.Text="🎨"

  local wheel = Instance.new("Frame", self.Gui)
  wheel.Name               = "ColorWheel"
  wheel.Size               = UDim2.new(0,size,0,size)
  wheel.Position           = UDim2.new(0.5,-size/2,0.5,-size/2)
  wheel.BackgroundTransparency = 1
  wheel.Visible            = false
  wheel.ZIndex             = 50

  local tileSize = size/res
  for i=0,res-1 do
    for j=0,res-1 do
      local dx = (i+0.5)/res - 0.5
      local dy = (j+0.5)/res - 0.5
      local dist = math.sqrt(dx*dx + dy*dy)
      if dist<=0.5 then
        local hue = (math.atan2(dy,dx)+math.pi)/(2*math.pi)
        local sat = math.clamp(dist/0.5,0,1)
        local col = Color3.fromHSV(hue,sat,1)
        local t = Instance.new("Frame", wheel)
        t.Size             = UDim2.new(0,tileSize,0,tileSize)
        t.Position         = UDim2.new(0,i*tileSize,0,j*tileSize)
        t.BackgroundColor3 = col
        t.BorderSizePixel  = 0
      end
    end
  end

  local function pick(p)
    local abs = wheel.AbsolutePosition
    local x,y = p.X-abs.X, p.Y-abs.Y
    local dx,dy = x-size/2, y-size/2
    local dist = math.sqrt(dx*dx+dy*dy)
    if dist<=size/2 then
      local hue = (math.atan2(dy,dx)+math.pi)/(2*math.pi)
      local sat = math.clamp(dist/(size/2),0,1)
      local col = Color3.fromHSV(hue,sat,1)
      preview.BackgroundColor3 = col
      pcall(callback,col)
    end
  end

  wheel.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then pick(i.Position) end
  end)
  wheel.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement
      and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
      pick(i.Position)
    end
  end)

  open.MouseButton1Click:Connect(function()
    wheel.Visible = not wheel.Visible
  end)

  return f
end

return StormLib
