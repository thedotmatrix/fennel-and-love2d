(local fennel (require :lib.fennel))
(local Object (require :lib.classic))
(local Console (Object:extend))
(local ST8 (require :classes.ST8))

(fn Console.unsafe [self msg trace]
  (set self.live.ram.msg msg)
  (set self.live.ram.trace trace)
  (set self.callback (self.live:reload self.safe))
  ((self.live:load :default) :error))

(fn Console.safely [self f]
  (when   (xpcall f #(self:unsafe $ (fennel.traceback)))
          (when   (or (~= self.live.game :default) 
                      (~= self.live.mode :error))
                  (do ((self.safe:reload self.live))
                      (set self.callback (self.live:load))))))

(fn Console.new [self game mode]
  (set self.live (ST8))
  (set self.safe (ST8))
  (self:safely #((self.live:load game) mode)))

(fn Console.draw [self canvas]
  (self:safely #(self.live.rst.draw self.live.ram canvas)))

;; TODO cleanup messy duplicate call patterns below
(fn Console.update [self dt]
  (when self.live.rom.update (self:safely 
    #(self.live.rom.update self.callback self.live.ram 
      dt))))

(fn Console.keypressed [self key scancode repeat?]
  (when self.live.rom.keypressed (self:safely 
    #(self.live.rom.keypressed  self.callback 
      self.live.ram 
                                key scancode repeat?))))

(fn Console.keyreleased [self key scancode]
  (when self.live.rom.keyreleased (self:safely 
    #(self.live.rom.keyreleased self.callback 
      self.live.ram 
                                key scancode))))

(fn Console.textinput [self text]
  (when self.live.rom.textinput (self:safely 
    #(self.live.rom.textinput self.callback self.live.ram 
                              text))))

(fn Console.mousemoved [self x y dx dy istouch]
  (when self.live.rom.mousemoved (self:safely 
    #(self.live.rom.mousemoved  self.callback 
      self.live.ram 
                                x y dx dy istouch))))

(fn Console.mousepressed [self x y button istouch presses]
  (when self.live.rom.mousepressed (self:safely 
    #(self.live.rom.mousepressed  self.callback 
      self.live.ram 
                          x y button istouch presses))))

Console
