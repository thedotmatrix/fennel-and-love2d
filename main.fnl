(import-macros {: flip} :mac.math)
(local transform (love.math.newTransform))
(local Console (require :classes.console))
(var width nil)
(var height nil)
(var console nil)
(var fullscreen? false)

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
      (love.event.push :resize))))

(fn love.load [args]
  (local font (love.graphics.newFont 12 :mono))
  (font:setFilter "linear" "nearest")
  (love.graphics.setFont font)
  (let [(w h _) (love.window.getMode)] (set width w) (set height h))
  (set _G.web? (= :web (. args 1)))
  (set console (Console width height)))

(fn love.draw [] (console:draw width height transform))

(fn love.update [dt] (console:update dt width height))

(fn love.resize [] ;; TODO start menu option for web
  (let [(sw sh) (love.window.getMode)
        w       (if (or (not _G.web?) fullscreen?) sw width)
        h       (if (or (not _G.web?) fullscreen?) sh height)
        scale (math.min (/ w width) (/ h height))
        mx (/ (- sw (* scale width)) 2)
        my (/ (- h (* scale height)) 2)]
    (transform:setTransformation mx my 0 scale scale 0 0 0 0)))

(fn love.keypressed [key scancode repeat?]
  (match key
    :escape (love.event.quit)
    :f11 (fullscreen)
    _ (console:keypressed key scancode repeat? width height)))

(fn love.keyreleased [key scancode] 
  (console:keyreleased key scancode width height))

(fn love.textinput [text] 
  (console:textinput text width height))

(fn love.mousemoved [x y dx dy istouch]
  (let [(tx ty) (transform:inverseTransformPoint x y)]
    (console:mousemoved tx ty dx dy istouch width height)))

(fn love.mousepressed [x y button istouch presses]
  (let [(tx ty) (transform:inverseTransformPoint x y)]
    (console:mousepressed tx ty button istouch presses width height)))
