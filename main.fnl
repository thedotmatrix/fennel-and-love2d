(import-macros {: flip} :mac.math)
(local fennel (require :lib.fennel))
(local transform (love.math.newTransform))
(local windows {:dev nil :game nil})
(var width nil)
(var height nil)
(var dev nil)
(var game nil)
(var name nil)
(var web? false)
(var fullscreen? false)
(var dev? false)

(fn boot-cartridge [window name ...]
  (let [cartridge (require name)]
    (tset windows window {:cartridge cartridge :name name})
    (when cartridge.activate
      (match (pcall cartridge.activate ...)
        (false msg) (print name "activate error" msg)))))
(fn safely [func name] 
  (xpcall func #(boot-cartridge :cartridges.error name $ (fennel.traceback))))

(fn love.load [args]
  (let [(w h _) (love.window.getMode)]
    (set width w)
    (set height h))
  (set dev (love.graphics.newCanvas (/ width 2) height))
  (set game (love.graphics.newCanvas width height))
  (let [file    "conf.fnl"
        default :empty
        info    (love.filesystem.getInfo file)
        title   (if info ((love.filesystem.lines file)) default)
        def     "cartridges.%s"
        src     "src.%s.cartridges.main"
        format  (if (= title default) def src)]
    (set name (format:format (title:lower)))
    (love.window.setTitle title))
  (set web? (= :web (. args 1)))
  (love.graphics.setFont (love.graphics.newFont 8 "mono"))
  (boot-cartridge :dev :cartridges.repl)
  (boot-cartridge :game name)
  (dev:setFilter "nearest" "nearest")
  (game:setFilter "nearest" "nearest")
  (safely (windows.dev.cartridge.load web?) windows.dev.name)
  (safely (windows.game.cartridge.load width height) windows.game.name))

(fn love.draw []
  (love.graphics.setCanvas dev)
  (safely (windows.dev.cartridge.draw (/ width 2) height) windows.dev.name)
  (love.graphics.setCanvas game)
  (love.graphics.clear 0 0 0 1)
  (safely (windows.game.cartridge.draw width height game) windows.game.name)
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.push)
  (love.graphics.applyTransform transform)
  (love.graphics.draw game 0 0 0 1 1)
  (love.graphics.setColor 1 1 1 0.88)
  (if dev? (love.graphics.draw dev 0 0 0 1 1))
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.pop))

(fn love.update [dt]
  (when windows.dev.cartridge.update 
    (safely #(windows.dev.cartridge.update dt) windows.dev.name))
  (when windows.game.cartridge.update 
    (safely #(windows.game.cartridge.update dt width height) windows.game.name)))

(fn love.resize [] ;; TODO start menu option for web
  (let [(sw sh) (love.window.getMode)
        w       (if (or (not web?) fullscreen?) sw width)
        h       (if (or (not web?) fullscreen?) sh height)
        scale (math.min (/ w width) (/ h height))
        mx (/ (- sw (* scale width)) 2)
        my (/ (- h (* scale height)) 2)]
    (transform:setTransformation mx my 0 scale scale 0 0 0 0)))

(fn love.keypressed [key scancode repeat?]
  (match key
    :escape (love.event.quit)
    :lctrl (set dev? (not dev?))
    "f" (if web?
          (let [  (sw sh) (love.window.getMode)
                  w       (if fullscreen? width sw)
                  h       (if fullscreen? height sh)]
            (love.window.updateMode w h { :fullscreen (flip fullscreen?)
                                          :fullscreentype "exclusive"
                                          :minwidth w 
                                          :minheight h})
            (love.event.push "resize"))
          (love.window.setFullscreen (flip fullscreen?) "desktop"))
    _ (let [devfunc windows.dev.cartridge.keypressed
            devname windows.dev.name
            gamefunc windows.game.cartridge.keypressed
            gamename windows.game.name]
        (when (and dev? devfunc) (safely #(devfunc key) devname))
        (when gamefunc (safely #(gamefunc key scancode repeat?) gamename)))))

(fn love.keyreleased [key scancode]
  (let [gamefunc windows.game.cartridge.keyreleased
        gamename windows.game.name]
    (when gamefunc (safely #(gamefunc key scancode) gamename))))

(fn love.textinput [text]
  (when (and dev? windows.dev.cartridge.textinput)
    (safely #(windows.dev.cartridge.textinput text) windows.dev.name)))

(fn love.mousemoved [x y dx dy istouch]
  (let [gamefunc windows.game.cartridge.mousemoved
        gamename windows.game.name
        (tx ty) (transform:inverseTransformPoint x y)]
    (when gamefunc (safely #(gamefunc tx ty dx dy istouch) gamename))))

(fn love.mousepressed [x y button istouch presses]
  (let [gamefunc windows.game.cartridge.mousepressed
        gamename windows.game.name
        (tx ty) (transform:inverseTransformPoint x y)]
    (when gamefunc (safely #(gamefunc tx ty button istouch presses) gamename))))