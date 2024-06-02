(import-macros {: flip} :mac.math)
(local transform (love.math.newTransform))
(local Console (require :classes.console))
(var width nil)
(var height nil)
(var fullscreen? false)
(var dev? false)
(local game {:console nil :canvas nil}) ;; TODO console aggregate seperate module
(local dev {:console nil :canvas nil})

(fn fullscreen []
  (if (not _G.web?)
    (love.window.setFullscreen (flip fullscreen?) :desktop)
    (let [(sw sh) (love.window.getMode)
          w       (if fullscreen? width sw)
          h       (if fullscreen? height sh)]
      (love.window.updateMode w h { :fullscreen (flip fullscreen?)
                                    :fullscreentype :exclusive
                                    :minwidth w 
                                    :minheight h})
      (love.resize))))

(fn love.load [args] ;; FIXME globals?
  (local font (love.graphics.newFont 12 :mono)) ;; TODO depends on res
  (font:setFilter :nearest :nearest)
  (set _G.font font)
  (love.graphics.setFont font)
  (let [(w h _) (love.window.getMode)] (set width w) (set height h))
  (set _G.web? (= :web (. args 1)))
  (let [file    :conf.fnl
        default :default
        info    (love.filesystem.getInfo file)
        title   (if info ((love.filesystem.lines file)) default)
        format  "%s"
        name    (format:format (title:lower))]
    (love.window.setTitle title)
    (set game.canvas (love.graphics.newCanvas width height))
    (set game.console (Console name :main game.canvas))
    (game.canvas:setFilter :nearest :nearest)
    (set dev.canvas (love.graphics.newCanvas (/ width 2) height))
    (set dev.console (Console :default :repl dev.canvas))
    (dev.canvas:setFilter :nearest :nearest)))

(fn love.draw [] 
  (love.graphics.setCanvas game.canvas)
  (game.console:draw)
  (love.graphics.setCanvas dev.canvas)
  (dev.console:draw)
  (love.graphics.setCanvas)
  (love.graphics.push)
  (love.graphics.applyTransform transform)
  (love.graphics.draw game.canvas)
  (love.graphics.setColor 1 1 1 0.9)
  (when dev? (love.graphics.draw dev.canvas))
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.pop))

(fn love.update [dt] 
  (game.console:update dt)
  (dev.console:update dt))

(fn love.resize [] ;; TODO start menu option for web
  (let [(sw sh) (love.window.getMode)
        w       (if (or (not _G.web?) fullscreen?) sw width)
        h       (if (or (not _G.web?) fullscreen?) sh height)
        scale (math.min (/ w width) (/ h height))
        mx (/ (- sw (* scale width)) 2)
        my (/ (- h (* scale height)) 2)]
    (transform:setTransformation mx my 0 scale scale 0 0 0 0)))

(fn love.keypressed [key scancode repeat?]
  (let [focus (if dev? dev game)]
    (match key
      :escape (love.event.quit)
      :lctrl (flip dev?)
      _ (focus.console:keypressed key scancode repeat?))))

(fn love.keyreleased [key scancode]
  (let [focus (if dev? dev game)]
    (focus.console:keyreleased key scancode)))

(fn love.textinput [text]
  (let [focus (if dev? dev game)]
    (focus.console:textinput text)))

(fn love.mousemoved [x y dx dy istouch]
  (let [(tx ty) (transform:inverseTransformPoint x y)]
    (game.console:mousemoved tx ty dx dy istouch)))

(fn love.mousepressed [x y button istouch presses]
  (let [(tx ty) (transform:inverseTransformPoint x y)] ;; TODO general fullscreen option
    (when (or (< ty (/ height 18)) (> ty (* 17 (/ height 18)))) (fullscreen))
    (game.console:mousepressed tx ty button istouch presses)))
