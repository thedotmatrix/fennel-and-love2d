; main.fnl
(import-macros {: flip} :mac.bool)
(local MAT (require :src._.cls.MAT))
(local WIN (require :src._.cls.WIN))
(local CAB (require :src._.cls.CAB))
(var main nil)
(var (w h) (values nil nil))
(var transform nil)
(var fullscreen? false)
(local opt #{ :fullscreen (flip fullscreen?)
              :fullscreentype :exclusive
              :minwidth $1 :minheight $2})

(fn movewindow [] ;; TODO needs to be relative change
  (love.window.setPosition (love.mouse.getPosition)))

(fn fullwindow []
  (if (not _G.web?)
      (love.window.setFullscreen (flip fullscreen?) :desktop)
      (let [(sw sh) (love.window.getMode)
            width   (if fullscreen? w sw)
            height  (if fullscreen? h sh)
            opts    (opt width height)]
        (love.window.updateMode width height opts))))

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
        s       (/ (math.min ww wh) 1)]
    (love.window.setTitle title)
    (local m          (MAT nil 0 0 ww wh))
    (local t          (+ (WIN.t m) 1))
    (set main         (WIN {:mat m} :main ww wh))
    (set main.mat.repose  movewindow)
    (set main.mat.restore fullwindow)
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
