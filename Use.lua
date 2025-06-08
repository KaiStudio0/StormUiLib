local Storm = require(path.to.StormLib)
-- Crea la ventana (loader aparece automáticamente)
local win = Storm.new("Mi Aplicación Storm")

-- Actualiza & oculta la carga
for i=1,100 do
  task.wait(0.02)
  win.Loader:update(i/100)
end
win.Loader:hide()

-- Añade pestañas con iconos (Material Icons)
local t1 = win:addTab("Home",     "rbxassetid://6023426915")
local t2 = win:addTab("Settings", "rbxassetid://6023424051")

-- Dentro de "Home"
t1:addButton("Saludar", function() print("¡Hola!") end)
t1:addSlider("Volumen", 0, 100, 30, function(v) print("Vol:",v) end)

-- Dentro de "Settings"
t2:addToggle("Modo Oscuro", false, function(s) print("Dark:",s) end)
t2:addDropdown("Opciones", {"A","B","C"}, 1, function(opt) print("Eligió:",opt) end)
t2:addColorPicker("Color Favorito", Color3.fromRGB(255,200,0), function(c) print("Color:",c) end)
