love.conf = function(t)
  t.version                 = "11.5"
  t.identity                = "fennel+love2d game console"
  t.gammacorrect            = true
  t.modules.joystick        = false
  t.modules.physics         = false
  t.window.width            = 1024
  t.window.height           = 576
  t.window.resizable        = false
  t.window.minwidth         = 1024
  t.window.minheight        = 576
  t.window.fullscreen       = false
  t.window.vsync            = true
end
