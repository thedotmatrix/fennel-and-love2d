(local fennel (require :lib.fennel))
(local Object (require :lib.classic))
(local Console (Object:extend))
(local windows {:dev nil :game nil})
(var dev nil)
(var game nil)
(var web? nil)
(var dev? false)

(fn safely [self f w h] ;; FIXME traceback only surface level
  (xpcall f #(load self :game :cartridges.error w h $ (fennel.traceback))))

(fn new [self width height w?]
  (set dev (love.graphics.newCanvas (/ width 2) height))
  (dev:setFilter :nearest :nearest)
  (set game (love.graphics.newCanvas width height))
  (game:setFilter :nearest :nearest)
  (set web? w?)
  (let [file    :conf.fnl
        default :empty
        info    (love.filesystem.getInfo file)
        title   (if info ((love.filesystem.lines file)) default)
        def     "cartridges.%s"
        src     "src.%s.cartridges.main"
        format  (if (= title default) def src)
        name (format:format (title:lower))]
    (love.window.setTitle title)
    (safely self #(self:load :dev :cartridges.repl width height) width height)
    (safely self #(self:load :game name width height) width height))
  self)

(fn load [self window name w h ...]
  (local ld 
    (fn [window] 
      (fn [name oldcart]
        (let [Cart (require name)
              cart (if (= name :cartridges.repl)  (Cart w h web?)
                                                  (Cart w h oldcart))]
          (tset windows window {:cartridge cart :name name})
          cart))))
  (local oldname (?. (. windows window) :name))
  (local callback (ld window))
  (local cartridge (callback name))
  (cartridge:callback callback)
  (when cartridge.stacktrace
    (match (pcall cartridge.stacktrace oldname ...)
      (false msg) (print name "stacktrace error" msg))))

(fn draw [self width height transform] 
  (love.graphics.setCanvas dev)
  (love.graphics.clear 0 0 0 1)
  (safely self (windows.dev.cartridge:draw (/ width 2) height))
  (love.graphics.setCanvas game)
  (love.graphics.clear 0 0 0 1)
  (safely self (windows.game.cartridge:draw width height game))
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
  (safely self #(windows.dev.cartridge:update dt (/ w 2) h))
  (safely self #(windows.game.cartridge:update dt w h)))

(fn keypressed [self key scancode repeat?] (match key
  :lctrl (set dev? (not dev?))
  _ (let [g windows.game.cartridge
          d windows.dev.cartridge]
      (if (and dev? d.keypressed)
        (safely self #(d:keypressed key scancode repeat?))
        (when g.keypressed
          (safely self #(g:keypressed key scancode repeat?)))))))

(fn keyreleased [self key scancode] 
  (let [g windows.game.cartridge]
    (when g.keyreleased (safely self #(g:keyreleased key scancode)))))

(fn textinput [self text] 
  (let [d windows.dev.cartridge]
    (when (and d.textinput dev?) (safely self #(d:textinput text)))))

(fn mousemoved [self x y dx dy istouch] 
  (let [g windows.game.cartridge]
    (when g.mousemoved (safely self #(g:mousemoved x y dx dy istouch)))))

(fn mousepressed [self x y button istouch presses] 
  (let [g windows.game.cartridge]
    (when g.mousepressed 
      (safely self #(g:mousepressed x y button istouch presses)))))

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
