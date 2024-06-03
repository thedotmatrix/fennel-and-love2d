(local fennel (require :lib.fennel))
(local Object (require :lib.classic))
(local Console (Object:extend))
(local RAM (require :classes.RAM))
(local ROM (require :classes.ROM))
(local RST (require :classes.RST))

(fn Console.unsafe [self msg trace]
  (set self.ram.msg msg)
  (set self.ram.trace trace)
  ((self:load :default) :error))

(fn Console.safely [self f]
  (when (xpcall f #(self:unsafe $ (fennel.traceback)))
    (when (or (~= self.game :default) (~= self.module :error))
      (set self.safe [self.game self.module self.rom self.rst]))))

(fn Console.load [self game] (when game (set self.game game)) (fn [module]
  (let [loadrom (fn [rom]
                  (rom:implement self.rom)
                  (set self.rom rom)
                  (self.rom.load self.ram))
        loadrst (fn [rst]
                  (rst:implement self.rst)
                  (set self.rst rst))]
    (if module
      (let [rompath (.. "src%s" self.game "%sroms%s" module "%s")
            rominfo (love.filesystem.getInfo (rompath:format :/ :/ :/ :.fnl))
            rstpath (.. "src%s" self.game "%srsts%s" module "%s")
            rstinfo (love.filesystem.getInfo (rstpath:format :/ :/ :/ :.fnl))]
        (when rominfo (loadrom (require (rompath:format :. :. :. ""))))
        (when rstinfo (loadrst (require (rstpath:format :. :. :. ""))))
        (set self.module module))
      (let [game    (. self.safe 1)
            module  (. self.safe 2)
            rom     (. self.safe 3)
            rst     (. self.safe 4)]
        (loadrom rom)
        (loadrst rst)
        (set self.game game)
        (set self.module module))))))

(fn Console.new [self game module canvas]
  (set self.canvas canvas)
  (set self.ram (RAM:extend))
  (set self.rom (ROM:extend))
  (set self.rst (RST:extend))
  (self:safely #((self:load game) module)))

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
