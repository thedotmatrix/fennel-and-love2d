(local fennel (require :lib.fennel))
(local traceback fennel.traceback)
(local Object (require :lib.classic))
(local CRT (Object:extend))
(local ST8 (require :src._.cls.ST8))

(fn CRT.unsafe [self errormessage errortrace]
  (set self.live.ram.errormessage errormessage)
  (set self.live.ram.errortrace errortrace)
  (set self.callback (self.live:reload self.safe))
  ((self.live:load :_) :error))

(fn CRT.safely [self f ...]
  (when (and f (xpcall f #(self:unsafe $ (traceback)) ...))
        (when (or (~= self.live.game :_) 
                  (~= self.live.mode :error))
              (do ((self.safe:reload self.live))
                  (set self.callback (self.live:load))))))

(fn CRT.new [self game mode]
  (set self.live (ST8))
  (set self.safe (ST8))
  (self:safely (self.live:load game) mode))

(fn CRT.draw [self canvas]
  (self:safely self.live.rst.draw self.live.ram canvas))

(fn CRT.update [self dt] (self:safely 
  self.live.rom.update self.callback self.live.ram dt))

(fn CRT.event [self e ...] (self:safely 
  (. self.live.rom e) self.callback self.live.ram ...))

CRT
