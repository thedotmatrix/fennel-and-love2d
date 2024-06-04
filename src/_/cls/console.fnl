(local fennel (require :lib.fennel))
(local traceback fennel.traceback)
(local Object (require :lib.classic))
(local Console (Object:extend))
(local ST8 (require :src._.cls.ST8))

(fn Console.unsafe [self errormessage errortrace]
  (set self.live.ram.errormessage errormessage)
  (set self.live.ram.errortrace errortrace)
  (set self.callback (self.live:reload self.safe))
  ((self.live:load :_) :error))

(fn Console.safely [self f ...]
  (when (and f (xpcall f #(self:unsafe $ (traceback)) ...))
        (when (or (~= self.live.game :_) 
                  (~= self.live.mode :error))
              (do ((self.safe:reload self.live))
                  (set self.callback (self.live:load))))))

(fn Console.new [self game mode]
  (set self.live (ST8))
  (set self.safe (ST8))
  (self:safely (self.live:load game) mode))

(fn Console.draw [self canvas]
  (self:safely self.live.rst.draw self.live.ram canvas))

(fn Console.update [self dt] (self:safely 
  self.live.rom.update self.callback self.live.ram dt))

(fn Console.event [self e ...] (self:safely 
  (. self.live.rom e) self.callback self.live.ram ...))

Console
