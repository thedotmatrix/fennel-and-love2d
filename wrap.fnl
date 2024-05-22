(import-macros {: flip} :macros.math)
(local fennel (require :lib.fennel))
(local transform (love.math.newTransform))
(local windows {:console nil :game nil})
(var console nil)
(var game nil)
(var width nil)
(var height nil)
(var fullscreen? false)
(var dev? false)
(var web? false)

(fn enter-monad [window name ...]
  (let [monad (require name)]
    (tset windows window {:monad monad :name name})
    (when monad.activate
      (match (pcall monad.activate ...)
        (false msg) (print name "activate error" msg)))))
(fn safely [func name] 
  (xpcall func #(enter-monad :monads.error name $ (fennel.traceback))))

(fn love.load [args]
  (let [(w h _) (love.window.getMode)]
    (set width w)
    (set height h))
  (set console (love.graphics.newCanvas (/ width 2) height))
  (set game (love.graphics.newCanvas width height))
  (set web? (= :web (. args 1)))
  (love.graphics.setFont (love.graphics.newFont 8 "mono"))
  (enter-monad :console :monads.repl)
  (enter-monad :game :games.rochambullet.monad)
  (console:setFilter "nearest" "nearest")
  (game:setFilter "nearest" "nearest")
  (safely (windows.console.monad.load web?) windows.console.name)
  (safely (windows.game.monad.load width height) windows.game.name))

(fn love.draw []
  (love.graphics.setCanvas console)
  (safely (windows.console.monad.draw (/ width 2) height) windows.console.name)
  (love.graphics.setCanvas game)
  (love.graphics.clear 0 0 0 1)
  (safely (windows.game.monad.draw width height game) windows.game.name)
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.push)
  (love.graphics.applyTransform transform)
  (love.graphics.draw game 0 0 0 1 1)
  (love.graphics.setColor 1 1 1 0.88)
  (if dev? (love.graphics.draw console 0 0 0 1 1))
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.pop))

(fn love.update [dt]
  (when windows.console.monad.update 
    (safely #(windows.console.monad.update dt) windows.console.name))
  (when windows.game.monad.update 
    (safely #(windows.game.monad.update dt width height) windows.game.name)))

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
          (love.window.setFullscreen (flip fullscreen? "desktop")))
    _ (let [consolefunc windows.console.monad.keypressed
            consolename windows.console.name
            gamefunc windows.game.monad.keypressed
            gamename windows.game.name]
        (when (and dev? consolefunc) (safely #(consolefunc key) consolename))
        (when gamefunc (safely #(gamefunc key scancode repeat?) gamename)))))

(fn love.keyreleased [key scancode]
  (let [gamefunc windows.game.monad.keyreleased
        gamename windows.game.name]
    (when gamefunc (safely #(gamefunc key scancode) gamename))))

(fn love.textinput [text]
  (when (and dev? windows.console.monad.textinput)
    (safely #(windows.console.monad.textinput text) windows.console.name)))

(fn love.mousemoved [x y dx dy istouch]
  (let [gamefunc windows.game.monad.mousemoved
        gamename windows.game.name
        (tx ty) (transform:inverseTransformPoint x y)]
    (when gamefunc (safely #(gamefunc tx ty dx dy istouch) gamename))))

(fn love.mousepressed [x y button istouch presses]
  (let [gamefunc windows.game.monad.mousepressed
        gamename windows.game.name
        (tx ty) (transform:inverseTransformPoint x y)]
    (when gamefunc (safely #(gamefunc tx ty button istouch presses) gamename))))
