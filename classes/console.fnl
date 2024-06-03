(local fennel (require :lib.fennel))
(local Object (require :lib.classic))
(local Console (Object:extend))
;; TODO state object?
(local RAM (require :classes.RAM))
(local ROM (require :classes.ROM))
(local RST (require :classes.RST))

(fn Console.reload [self other]
  (set self.game    other.game)
  (set self.mode    other.mode)
  (set self.ram     (RAM other.ram))
  (set self.rom     (ROM.mix other.rom self.rom))
  (set self.rst     (RST.mix other.rst self.rst)))

(fn Console.unsafe [self msg trace]
  (set self.ram.msg msg)
  (set self.ram.trace trace)
  ((self:load :default) :error))

(fn Console.safely [self f]
  (when (xpcall f #(self:unsafe $ (fennel.traceback)))
    (when (or (~= self.game :default) (~= self.mode :error))
      (self.safe:reload self))))

(fn Console.load [self game] (when game (set self.game game))
  (fn [mode] (if mode
    (let [f1 (.. "src%s" self.game "%sroms%s" mode "%s")
          rompath (f1:format :/ :/ :/ :.fnl)
          rominfo (love.filesystem.getInfo rompath)
          romreq  #(require (f1:format :. :. :. ""))
          newrom  #(ROM.mix (romreq) self.rom self.ram)
          f2 (.. "src%s" self.game "%srsts%s" mode "%s")
          rstpath (f2:format :/ :/ :/ :.fnl)
          rstinfo (love.filesystem.getInfo rstpath)
          rstreq  #(require (f2:format :. :. :. ""))
          newrst  #(RST.mix (rstreq) self.rst)]
      (set self.mode mode)
      (when rominfo (set self.rom (newrom)))
      (when rstinfo (set self.rst (newrst))))
    (self:reload self.safe))))

(fn Console.new [self game mode]
  (set self.ram (RAM))
  (set self.rom (ROM:extend))
  (set self.rst (RST:extend))
  (when (and game mode) (do
    (set self.safe (Console))
    (self:safely #((self:load game) mode)))))

(fn Console.draw [self canvas]
  (when self.rst.draw 
    (self:safely #(self.rst.draw self.ram canvas))))

(fn Console.update [self dt]
  (when self.rom.update 
    (self:safely #(self.rom.update (self:load) self.ram dt))))

(fn Console.keypressed [self key scancode repeat?]
  (when self.rom.keypressed 
    (self:safely 
      #(self.rom.keypressed   (self:load) self.ram 
                              key scancode repeat?))))

(fn Console.keyreleased [self key scancode]
  (when self.rom.keyreleased 
    (self:safely 
      #(self.rom.keyreleased  (self:load) self.ram 
                              key scancode))))

(fn Console.textinput [self text]
  (when self.rom.textinput 
    (self:safely 
      #(self.rom.textinput    (self:load) self.ram text))))

(fn Console.mousemoved [self x y dx dy istouch]
  (when self.rom.mousemoved 
    (self:safely 
      #(self.rom.mousemoved   (self:load) self.ram 
                              x y dx dy istouch))))

(fn Console.mousepressed [self x y button istouch presses]
  (when self.rom.mousepressed 
    (self:safely 
      #(self.rom.mousepressed (self:load) self.ram 
                              x y button istouch presses))))

Console
