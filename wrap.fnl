(local fennel (require :lib.fennel))
(local (w h) (love.window.getMode))
(var (sw sh) (love.window.getMode))
(var scale 1)
(var fs? false)
(local windows {:console nil :game nil})
(local console (love.graphics.newCanvas (/ w 2) h))
(local game (love.graphics.newCanvas w h))
(var dev? true)

(fn enter-monad [window name ...]
  (let [monad (require name)]
    (tset windows window {:monad monad :name name})
    (when monad.activate
      (match (pcall monad.activate ...)
        (false msg) (print name "activate error" msg)))))
(fn safely [func name] 
  (xpcall func #(enter-monad :monads.error name $ (fennel.traceback))))

(fn love.load [args]
  (love.graphics.setFont (love.graphics.newFont 12 "mono")) ;; 12pt*64=512px
  (enter-monad :console :monads.repl)
  (enter-monad :game :monads.rochambullet)
  (console:setFilter "nearest" "nearest")
  (game:setFilter "nearest" "nearest")
  (safely (windows.console.monad.load (= :web (. args 1))) windows.console.name)
  (safely (windows.game.monad.load w h) windows.game.name))

(fn love.draw []
  (let [mx (/ (- sw (* scale w)) 2)
        my (/ (- sh (* scale h)) 2)]
    (love.graphics.setCanvas console)
    (safely (windows.console.monad.draw (/ w 2) h) windows.console.name)
    (love.graphics.setCanvas game)
    (safely (windows.game.monad.draw w h) windows.game.name)
    (love.graphics.setCanvas)
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.draw game mx my 0 scale scale)
    (love.graphics.setColor 1 1 1 0.88)
    (if dev? (love.graphics.draw console mx my 0 scale scale))
    (love.graphics.setColor 1 1 1 1)))

(fn love.update [dt]
  (when windows.console.monad.update 
    (safely #(windows.console.monad.update dt) windows.console.name))
  (when windows.game.monad.update 
    (safely #(windows.game.monad.update dt w h) windows.game.name)))

(fn love.keypressed [key scancode repeat?]
  (match key
    :escape (love.event.quit)
    :lctrl (set dev? (not dev?))
    "f11" (love.window.setFullscreen (do (set fs? (not fs?)) fs?) "desktop")
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

(fn love.mousemoved [x y dx dy istouch]
  (let [gamefunc windows.game.monad.mousemoved
        gamename windows.game.name]
      (when gamefunc (safely #(gamefunc x y dx dy istouch) gamename))))

(fn love.mousepressed [x y button istouch presses]
  (let [gamefunc windows.game.monad.mousepressed
        gamename windows.game.name]
      (when gamefunc (safely #(gamefunc x y button istouch presses) gamename))))

(fn love.textinput [text]
  (when (and dev? windows.console.monad.textinput)
    (safely #(windows.console.monad.textinput text) windows.console.name)))

(fn love.resize []
  (set (sw sh) (love.window.getMode))
  (set scale (math.min (/ sw w) (/ sh h))))
