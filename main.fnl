(import-macros {: flip} :mac.bool)
;; TODO transform  -> translate (x y) + scale (x y dx dy)
(local transform (love.math.newTransform))
(local CAB (require :src._.cls.CAB))
(var cab nil)
(var (w h) (values nil nil))
(var canvas nil)
(var full? false)

;; TODO main window fullscreen full res
;; TODO CAB virtual windows translate/scaled up to full res
;; TODO game/dev low res canvases scale to CAB

(fn resize []
  (let [(sw sh) (love.window.getMode)
        width   (if (or (not _G.web?) full?) sw w)
        height  (if (or (not _G.web?) full?) sh h)
        s       (math.min (/ width w) (/ height h))
        mx      (/ (- sw (* s w)) 2)
        my      (/ (- sh (* s h)) 2)]
    (transform:setTransformation mx my 0 s s 0 0 0 0)))

(fn fullscreen [] ;; TODO clean up nasty table def
  (if (not _G.web?)
      (love.window.setFullscreen (flip full?) :desktop)
      (let [(sw sh)       (love.window.getMode)
            width         (if full? w sw)
            height        (if full? h sh)]
        (love.window.updateMode width height {
                                :fullscreen (flip full?)
                                :fullscreentype :exclusive
                                :minwidth width 
                                :minheight height})))
  (resize))

(fn mouse [e x y ...]
  (let [(tx ty)   (transform:inverseTransformPoint x y)
        moved     (= e :mousemoved)
        (dx dy)   (if moved (pick-values 2 ...) (values 0 0))
        (tdx tdy) (transform:inverseTransformPoint dx dy)
        outer     (or (< ty (/ h 18)) (> ty (* 17 (/ h 18))))]
    (when (and (= e :mousepressed) outer) (fullscreen))
    (if moved (cab:event e tx ty tdx tdx ...)
              (cab:event e tx ty ...))))

(fn touch [e id x y dx dy ...]
  (let [(tx ty)   (transform:inverseTransformPoint x y)
        (tdx tdy) (transform:inverseTransformPoint dx dy)]
    (cab:event e id tx ty tdx tdy ...)))

(fn event [e ...] (match e ;; TODO substring case matching?
  :mousepressed   (mouse e ...)
  :mousereleased  (mouse e ...)
  :mousemoved     (mouse e ...)
  :touchpressed   (touch e ...)
  :touchreleased  (touch e ...)
  :touchmoved     (touch e ...)
  :resize         (resize ...)
  _               (cab:event e ...)))

(fn love.load [args]
  (let [(ww wh) (love.window.getMode)] (set w ww) (set h wh))
  (set canvas (love.graphics.newCanvas w h))
  (canvas:setFilter :nearest :nearest)
  ;; TODO depends on res
  (local font (love.graphics.newFont 12 :mono))
  (font:setFilter :nearest :nearest)
  (love.graphics.setFont font)
  ;; TODO globals?
  (set _G.font font)
  (set _G.web? (= :web (. args 1)))
  (let [file    :conf.fnl
        info    (love.filesystem.getInfo file)
        title   (if info ((love.filesystem.lines file)) :_)
        format  "%s"
        name    (format:format (title:lower))]
    (love.window.setTitle title)
    (set cab (CAB name w h)))
  (each [e _ (pairs love.handlers)]
    (tset love.handlers e #(event e $...))))

(fn love.draw []
  (love.graphics.setCanvas canvas)
  (love.graphics.clear)
  (cab:draw canvas)
  (love.graphics.applyTransform transform)
  (love.graphics.setCanvas)
  (love.graphics.draw canvas))

(fn love.update [dt] (cab:update dt))
