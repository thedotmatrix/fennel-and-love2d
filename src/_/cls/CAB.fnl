(import-macros {: flip} :mac.bool)
(local Object (require :lib.classic))
(local CAB (Object:extend))
(local CRT (require :src._.cls.CRT))

(fn CAB.new [! name w h]
  (set !.dev? false)
  (set !.dev {:cartridge nil :canvas nil})
  (set !.dev.cartridge (CRT :_ :repl))
  (set !.dev.canvas (love.graphics.newCanvas (/ w 2) h))
  (!.dev.canvas:setFilter :nearest :nearest)
  (set !.game {:cartridge nil :canvas nil})
  (set !.game.cartridge (CRT name :main))
  (set !.game.canvas (love.graphics.newCanvas w h))
  (!.game.canvas:setFilter :nearest :nearest))

(fn CAB.draw [! transform]
  (love.graphics.setCanvas !.game.canvas)
  (!.game.cartridge:draw !.game.canvas)
  (love.graphics.setCanvas !.dev.canvas)
  (!.dev.cartridge:draw !.dev.canvas)
  (love.graphics.setCanvas)
  (love.graphics.applyTransform transform)
  (love.graphics.draw !.game.canvas)
  (love.graphics.setColor 1 1 1 0.9)
  (when !.dev? (love.graphics.draw !.dev.canvas))
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.origin))
  
(fn CAB.update [! dt] 
  (!.game.cartridge:update dt)
  (!.dev.cartridge:update dt))

(fn CAB.event [! e ...] (match e
  :keypressed     (!:keypressed ...)
  :textinput      (!:textinput ...)
  _               (!.game.cartridge:event e ...)))

(fn CAB.keypressed [! key ...] (match key
  ;; TODO if window open, window resize; otherwise quit
  :escape (love.event.quit)
  :lctrl (flip !.dev?)
  _ (let [focus (if !.dev? !.dev !.game)]
      (focus.cartridge:event :keypressed key ...))))

(fn CAB.textinput [! ...]
  (let [focus (if !.dev? !.dev !.game)]
    (focus.cartridge:event :textinput ...)))

CAB
