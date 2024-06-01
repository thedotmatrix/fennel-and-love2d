(local fennel (require :lib.fennel))
(local Object (require :lib.classic))
(local Console (Object:extend))
(local windows {:dev nil :game nil})
(var dev nil)
(var game nil)
(var dev? false)

(fn safely [self window f w h] ;; TODO stacktraces awful from callback loop + reload broken
  (xpcall f #(self:load window :cartridges.error w h $ (fennel.traceback))))

(fn new [self w h]
  (set dev (love.graphics.newCanvas (/ w 2) h))
  (dev:setFilter :nearest :nearest)
  (set game (love.graphics.newCanvas w h))
  (game:setFilter :nearest :nearest)
  (let [file    :conf.fnl
        default :empty
        info    (love.filesystem.getInfo file)
        title   (if info ((love.filesystem.lines file)) default)
        def     "cartridges.%s"
        src     "src.%s.cartridges.main"
        format  (if (= title default) def src)
        name (format:format (title:lower))]
    (love.window.setTitle title)
    (safely self :dev #(self:load :dev :cartridges.repl w h) w h)
    (safely self :game #(self:load :game name w h) w h))
  self)

(fn load [self window name w h ...]
  (local ld (fn [window] (fn [name oldcart]
    (let [Cart (require name)
          cart (Cart w h oldcart)]
      (tset windows window {:cartridge cart :name name})
      cart))))
  (local callback (ld window))
  (local cartridge (callback name))
  (cartridge:callback callback)
  (when cartridge.stacktrace
    (match (pcall cartridge.stacktrace cartridge.caller ...)
      (false msg) (print name "stacktrace error" msg))))

(fn draw [self w h transform] 
  (love.graphics.setCanvas dev)
  (love.graphics.clear 0 0 0 1)
  (safely self :dev #(windows.dev.cartridge:draw (/ w 2) h dev) w h)
  (love.graphics.setCanvas game)
  (love.graphics.clear 0 0 0 1)
  (safely self :game #(windows.game.cartridge:draw w h game) w h)
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.push)
  (love.graphics.applyTransform transform)
  (love.graphics.draw game 0 0 0 1 1)
  (love.graphics.setColor 1 1 1 0.88)
  (if dev? (love.graphics.draw dev 0 0 0 1 1))
  (love.graphics.pop)
  (love.graphics.setColor 1 1 1 1))

(fn update [self dt w h]
  (safely self :dev #(windows.dev.cartridge:update dt (/ w 2) h) w h)
  (safely self :game #(windows.game.cartridge:update dt w h) w h))

(fn keypressed [self key scancode repeat? w h] (match key
  :lctrl (set dev? (not dev?))
  _ (let [g windows.game.cartridge
          d windows.dev.cartridge]
      (if (and dev? d.keypressed)
        (safely self :dev #(d:keypressed key scancode repeat?) w h)
        (when g.keypressed
          (safely self :game #(g:keypressed key scancode repeat?) w h))))))

(fn keyreleased [self key scancode repeat? w h] 
  (let [g windows.game.cartridge]
    (when g.keyreleased 
      (safely self :game #(g:keyreleased key scancode repeat?) w h))))

(fn textinput [self text w h] 
  (let [d windows.dev.cartridge]
    (when (and d.textinput dev?) 
      (safely self :dev #(d:textinput text) w h))))

(fn mousemoved [self x y dx dy istouch w h] 
  (let [g windows.game.cartridge]
    (when g.mousemoved
      (safely self :game #(g:mousemoved x y dx dy istouch) w h))))

(fn mousepressed [self x y button istouch presses w h] 
  (let [g windows.game.cartridge]
    (when g.mousepressed 
      (safely self :game #(g:mousepressed x y button istouch presses) w h))))

(tset Console :new          new)
(tset Console :load         load)
(tset Console :draw         draw)
(tset Console :update       update)
(tset Console :keypressed   keypressed)
(tset Console :keyreleased  keyreleased)
(tset Console :textinput    textinput)
(tset Console :mousemoved   mousemoved)
(tset Console :mousepressed mousepressed)
Console
