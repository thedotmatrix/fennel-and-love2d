(import-macros {: flip} :mac.bool)
(local Object (require :lib.classic))
(local WIN (require :src._.cls.WIN))
(local CAB (WIN:extend))
(local CRT (require :src._.cls.CRT))
(local scale 2)

(fn CAB.new [! parent name]
  (CAB.super.new ! parent name 1 1)
  (local w (/ (parent.inner:abs :w) scale))
  (local h (/ (parent.inner:abs :h) scale))
  (set !.dev? false)
  (set !.dev {:cartridge nil :canvas nil})
  (set !.dev.cartridge (CRT :_ :repl))
  (set !.dev.canvas (love.graphics.newCanvas (/ w 2) h))
  (!.dev.canvas:setFilter :nearest :nearest)
  (set !.game {:cartridge nil :canvas nil})
  (set !.game.cartridge (CRT name :main))
  (set !.game.canvas (love.graphics.newCanvas w h))
  (!.game.canvas:setFilter :nearest :nearest))

(fn CAB.draw [!]
  (love.graphics.push)
  (love.graphics.origin)
  (love.graphics.setCanvas !.game.canvas)
  (!.game.cartridge:draw !.game.canvas)
  (love.graphics.setCanvas !.dev.canvas)
  (!.dev.cartridge:draw !.dev.canvas)
  (love.graphics.setCanvas)
  (love.graphics.pop)
  (love.graphics.push)
  (love.graphics.scale scale)
  (love.graphics.draw !.game.canvas)
  (love.graphics.setColor 1 1 1 0.9)
  (when !.dev? (love.graphics.draw !.dev.canvas))
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.pop))
  
(fn CAB.update [! dt] 
  (!.game.cartridge:update dt)
  (!.dev.cartridge:update dt))

(fn CAB.event [! e ...] (match e
  :mousemoved     (!:mouse e ...)
  :mousepressed   (!:mouse e ...)
  :mousereleased  (!:mouse e ...)
  :keypressed     (!:keypressed ...)
  :textinput      (!:textinput ...)
  _               (!.game.cartridge:event e ...)))

(fn CAB.mouse [! e x y ...]
  (!.game.cartridge:event e (/ x scale) (/ y scale)))

(fn CAB.keypressed [! key ...] (match key
  :lctrl (flip !.dev?)
  _ (let [focus (if !.dev? !.dev !.game)]
      (focus.cartridge:event :keypressed key ...))))

(fn CAB.textinput [! ...]
  (let [focus (if !.dev? !.dev !.game)]
    (focus.cartridge:event :textinput ...)))

CAB
