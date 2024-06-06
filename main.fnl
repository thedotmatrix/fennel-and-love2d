; main.fnl
(import-macros {: flip} :mac.bool)
(local MAT (require :src._.cls.MAT))
(local WIN (require :src._.cls.WIN))
(local CAB (require :src._.cls.CAB))
(var main nil)
(var (w h) (values nil nil))
(var transform nil)
(var full? false)

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

(fn love.load [args]
  (let [(ww wh) (love.window.getMode)] (set w ww) (set h wh))
  (local font (love.graphics.newFont 12 :mono)) ; TODO dynamic
  (font:setFilter :nearest :nearest)
  (love.graphics.setFont font)
  (set _G.font font) ; TODO globals?
  (set _G.web? (= :web (. args 1)))
  (let [file    :conf.fnl
        info    (love.filesystem.getInfo file)
        title   (if info ((love.filesystem.lines file)) :_)
        format  "%s"
        name    (format:format (title:lower))
        (ww wh) (love.window.getMode)
        s       (/ (math.min ww wh) 2)]
    (love.window.setTitle title)
    (local m          (MAT nil 0 0 ww wh))
    (local t          (+ (WIN.t m) 1))
    (set main         (WIN {:mat m} :main (- ww 2) (- wh t)))
    (local parent     (WIN main :parent s s))
    (local child      (WIN parent :child (/ s 2) (/ s 2)))
    (local grandchild (CAB child name (/ s 2) (/ s 2)))
    (main.child parent)
    (parent.child child)
    (child.child grandchild))
  (each [e _ (pairs love.handlers)]
    (tset love.handlers e #(main:event e $...))))

(fn love.draw [] (main:draw))

(fn love.update [dt] (main:update dt))
