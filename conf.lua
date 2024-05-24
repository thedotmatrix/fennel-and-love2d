love.conf = function(t)
  t.version                 = "11.5"
  t.identity                = "fennel+love2d game console"
  t.gammacorrect            = true
  t.modules.joystick        = false
  t.modules.physics         = false
  t.window.width            = 800
  t.window.height           = 450
  t.window.resizable        = true
  t.window.minwidth         = 512
  t.window.minheight        = 288
  t.window.fullscreen       = false
  t.window.vsync            = true
end
