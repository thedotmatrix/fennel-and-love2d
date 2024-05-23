(import-macros {: flip} :mac.math)
(local transform (love.math.newTransform))
(local Console (require :classes.console))
(var width nil)
(var height nil)
(var console nil)
(var web? false)
(var fullscreen? false)

(fn love.load [args]
  (love.graphics.setFont (love.graphics.newFont 8 :mono))
  (let [(w h _) (love.window.getMode)] (set width w) (set height h))
  (set web? (= :web (. args 1)))
  (set console (Console width height web?)))

(fn love.draw [] (console:draw width height transform))

(fn love.update [dt] (console:update dt width height))

(fn love.resize [] ;; FIXME start menu option for web
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
    :f (if web?
          (let [(sw sh) (love.window.getMode)
                w       (if fullscreen? width sw)
                h       (if fullscreen? height sh)]
            (love.window.updateMode w h { :fullscreen (flip fullscreen?)
                                          :fullscreentype :exclusive
                                          :minwidth w 
                                          :minheight h})
            (love.event.push :resize))
          (love.window.setFullscreen (flip fullscreen?) :desktop))
    _ (console:keypressed key scancode repeat?)))

(fn love.keyreleased [key scancode] (console:keyreleased key scancode))

(fn love.textinput [text] (console:textinput text))

(fn love.mousemoved [x y dx dy istouch]
  (let [(tx ty) (transform:inverseTransformPoint x y)]
    (console:mousemoved tx ty dx dy istouch)))

(fn love.mousepressed [x y button istouch presses]
  (let [(tx ty) (transform:inverseTransformPoint x y)]
    (console:mousepressed tx ty button istouch presses)))
