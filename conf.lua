love.conf = function(t)
  t.gammacorrect = true
  t.title, t.identity = "untitled game", "fennel+love2d"
  t.modules.joystick = false
  t.modules.physics = false
  t.window.width = 1024
  t.window.height = 576
  t.window.resizable = true
  t.window.vsync = false
  t.version = "11.5"
end
