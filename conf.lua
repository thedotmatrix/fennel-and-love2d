love.conf = function(t)
  t.version                 = "11.5"
  t.title, t.identity       = "RoChamBULLET", "fennel+love2d"
  t.gammacorrect            = true
  t.modules.joystick        = false
  t.modules.physics         = false
  t.window.width            = 800
  t.window.height           = 600
  t.window.resizable        = true
  t.window.minwidth         = 800
  t.window.minheight        = 600
  t.window.fullscreen       = false
  t.window.vsync            = true
end
