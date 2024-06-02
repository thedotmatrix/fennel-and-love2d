(local fennel (require :lib.fennel))
(local Object (require :lib.classic))
(local Console (Object:extend))
(local RAM (require :classes.RAM))
(local ROM (require :classes.ROM))
(local RST (require :classes.RST))

(fn Console.unsafe [self msg trace]
  (set self.ram.msg msg)
  (set self.ram.trace trace)
  ((self:load) [:default :error]))

(fn Console.safely [self f]
  (when (xpcall f #(self:unsafe $ (fennel.traceback)))
    (when (or (~= self.game :default) (~= self.module :error))
      (set self.ram.safe [self.game :main])))) ; TODO cant reload last module?

(fn Console.load [self] (fn [gamemodule]
  (let [game    (. gamemodule 1)
        module  (. gamemodule 2)
        rompath (.. "src%s" game "%sroms%s" module "%s")
        rominfo (love.filesystem.getInfo (rompath:format :/ :/ :/ :.fnl))
        loadrom (fn []
          (set self.rom (ROM:extend))
          (self.rom:implement (require (rompath:format :. :. :. "")))
          (self.rom.load self.ram))
        rstpath (.. "src%s" game "%srsts%s" module "%s")
        rstinfo (love.filesystem.getInfo (rstpath:format :/ :/ :/ :.fnl))
        loadrst (fn []
          (set self.rst (RST:extend))
          (self.rst:implement (require (rstpath:format :. :. :. ""))))]
    (when rominfo (loadrom))
    (when rstinfo (loadrst))
    (set self.game game)
    (set self.module module))))

(fn Console.new [self game module canvas]
  (set self.canvas canvas)
  (set self.ram (RAM:extend))
  (self:safely #((self:load) [game module])))

(fn Console.draw [self]
  (when self.rst.draw 
    (self:safely #(self.rst.draw self.ram self.canvas))))

(fn Console.update [self dt]
  (when self.rom.update 
    (self:safely #(self.rom.update (self:load) self.ram dt))))

(fn Console.keypressed [self key scancode repeat?]
  (when self.rom.keypressed 
    (self:safely 
      #(self.rom.keypressed (self:load) self.ram key scancode repeat?))))

(fn Console.keyreleased [self key scancode]
  (when self.rom.keyreleased 
    (self:safely 
      #(self.rom.keyreleased (self:load) self.ram key scancode))))

(fn Console.textinput [self text]
  (when self.rom.textinput 
    (self:safely 
      #(self.rom.textinput (self:load) self.ram text))))

(fn Console.mousemoved [self x y dx dy istouch]
  (when self.rom.mousemoved 
    (self:safely 
      #(self.rom.mousemoved (self:load) self.ram x y dx dy istouch))))

(fn Console.mousepressed [self x y button istouch presses]
  (when self.rom.mousepressed 
    (self:safely 
      #(self.rom.mousepressed (self:load) self.ram x y button istouch presses))))

Console
