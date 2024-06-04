(import-macros {: flip} :mac.bool)
(local Object (require :lib.classic))
(local CAB (Object:extend))
(local CRT (require :src._.cls.CRT))

(fn CAB.new [self name w h]
  (set self.dev? false)
  (set self.dev {:cartridge nil :canvas nil})
  (set self.dev.cartridge (CRT :_ :repl))
  (set self.dev.canvas (love.graphics.newCanvas (/ w 2) h))
  (self.dev.canvas:setFilter :nearest :nearest)
  (set self.game {:cartridge nil :canvas nil})
  (set self.game.cartridge (CRT name :main))
  (set self.game.canvas (love.graphics.newCanvas w h))
  (self.game.canvas:setFilter :nearest :nearest))

(fn CAB.draw [self transform]
  (love.graphics.setCanvas self.game.canvas)
  (self.game.cartridge:draw self.game.canvas)
  (love.graphics.setCanvas self.dev.canvas)
  (self.dev.cartridge:draw self.dev.canvas)
  (love.graphics.setCanvas)
  (love.graphics.applyTransform transform)
  (love.graphics.draw self.game.canvas)
  (love.graphics.setColor 1 1 1 0.9)
  (when self.dev? (love.graphics.draw self.dev.canvas))
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.origin))
  
(fn CAB.update [self dt] 
  (self.game.cartridge:update dt)
  (self.dev.cartridge:update dt))

;; TODO no special cases, focus / check keys in event
(fn CAB.event [self e ...] (match e
  :keypressed     (self:keypressed ...)
  :textinput      (self:textinput ...)
  _               (self.game.cartridge:event e ...)))

(fn CAB.keypressed [self key ...] (match key
  :escape (love.event.quit)
  :lctrl (flip self.dev?)
  _ (let [focus (if self.dev? self.dev self.game)]
      (focus.cartridge:event :keypressed ...))))

(fn CAB.textinput [self ...]
  (let [focus (if self.dev? self.dev self.game)]
    (focus.cartridge:event :textinput ...)))

CAB
