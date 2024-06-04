(import-macros {: flip} :mac.bool)
(local transform (love.math.newTransform))
(local Console (require :classes.console))
(var w nil)
(var h nil)
(var full? false)
(var dev? false)
;; TODO console aggregate seperate module
(local game {:console nil :canvas nil})
(local dev {:console nil :canvas nil})

(fn fullscreen []
  (if (not _G.web?)
    (love.window.setFullscreen (flip full?) :desktop)
    (let [(sw sh) (love.window.getMode)
          width        (if full? w sw)
          height       (if full? h sh)]
      (love.window.updateMode width height 
                              { :fullscreen (flip full?)
                                :fullscreentype :exclusive
                                :minwidth width 
                                :minheight height})
      (love.resize))))

(fn love.load [args] ;; TODO globals?
  ;; TODO depends on res
  (local font (love.graphics.newFont 12 :mono))
  (font:setFilter :nearest :nearest)
  (set _G.font font)
  (love.graphics.setFont font)
  (let [(width height _) (love.window.getMode)]
    (set w width) 
    (set h height))
  (set _G.web? (= :web (. args 1)))
  (let [file    :conf.fnl
        def :default
        info    (love.filesystem.getInfo file)
        title   (if info ((love.filesystem.lines file)) def)
        format  "%s"
        name    (format:format (title:lower))]
    (love.window.setTitle title)
    (set game.canvas (love.graphics.newCanvas w h))
    (set game.console (Console name :main))
    (game.canvas:setFilter :nearest :nearest)
    (set dev.canvas (love.graphics.newCanvas (/ w 2) h))
    (set dev.console (Console :default :repl))
    (dev.canvas:setFilter :nearest :nearest)))

(fn love.draw [] 
  (love.graphics.setCanvas game.canvas)
  (game.console:draw game.canvas)
  (love.graphics.setCanvas dev.canvas)
  (dev.console:draw dev.canvas)
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
        w       (if (or (not _G.web?) full?) sw w)
        h       (if (or (not _G.web?) full?) sh h)
        s (math.min (/ w w) (/ h h))
        mx (/ (- sw (* s w)) 2)
        my (/ (- h (* s h)) 2)]
    (transform:setTransformation mx my 0 s s 0 0 0 0)))

;(each [k _ (pairs love.handlers)] TODO pattern match
(fn love.keyreleased [...]
  (let [focus (if dev? dev game)]
    (focus.console:keyreleased ...)))
(fn love.textinput [...]
  (let [focus (if dev? dev game)]
    (focus.console:textinput ...)))

;; TODO pattern match without match-keys
(fn love.keypressed [key ...]
  (let [focus (if dev? dev game)]
    (match key
      :escape (love.event.quit)
      :lctrl (flip dev?)
      _ (focus.console:keypressed key ...))))

;; TODO pattern match without fullscreen option
(fn love.mousepressed [x y ...]
  (let [(tx ty) (transform:inverseTransformPoint x y)
        outer (or (< ty (/ h 18)) (> ty (* 17 (/ h 18))))]
    (when outer (fullscreen))
    (game.console:mousepressed tx ty ...)))
(fn love.mousereleased [x y ...]
  (let [(tx ty) (transform:inverseTransformPoint x y)]
    (game.console:mousereleased tx ty ...)))

(fn love.mousemoved [x y dx dy ...]
  (let [(tx ty)   (transform:inverseTransformPoint x y)
        (tdx tdy) (transform:inverseTransformPoint dx dy)]
    (game.console:mousemoved tx ty tdx tdy ...)))

;; TODO pattern match
(fn love.touchpressed [id x y dx dy ...]
  (let [(tx ty)   (transform:inverseTransformPoint x y)
        (tdx tdy) (transform:inverseTransformPoint dx dy)]
    (game.console:touchpressed id tx ty tdx tdy ...)))
(fn love.touchreleased [id x y dx dy ...]
  (let [(tx ty)   (transform:inverseTransformPoint x y)
        (tdx tdy) (transform:inverseTransformPoint dx dy)]
    (game.console:touchreleased id tx ty tdx tdy ...)))
(fn love.touchmoved [id x y dx dy ...]
  (let [(tx ty)   (transform:inverseTransformPoint x y)
        (tdx tdy) (transform:inverseTransformPoint dx dy)]
    (game.console:touchmoved id tx ty tdx tdy ...)))
