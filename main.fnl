(import-macros {: flip} :mac.bool)
(local BOX (require :src._.cls.BOX))
(local CAB (require :src._.cls.CAB))
(local WIN (require :src._.cls.WIN))
(var [main mx my w h fs?] [nil nil nil nil nil false])
(local opt #{:fullscreen (flip fs?) :fullscreentype :exclusive
             :minwidth $1 :minheight $2})

(fn windowmouse [mousemoved] (fn [! x y dx dy ...]
  (when (not (and mx my)) (set [mx my] [x y]))
  (let [[w h]     [!.outer.parent.w !.outer.parent.h]
        mxin?     (and (> mx 0) (< mx (- w 0)))
        myin?     (and (> my 0) (< my (- h 0)))
        within?   (and mxin? myin?)
        relate? (love.mouse.getRelativeMode)]
    (when (and relate? (not !.drag?)) (if within? 
      (set [mx my] [(+ mx dx) (+ my dy)])
      (do (love.mouse.setRelativeMode false))
          (love.mouse.setPosition mx my)))
    (when (not relate?) (set [mx my] [x y]))
    (when within? (love.mouse.setRelativeMode true))
    (mousemoved ! mx my dx dy ...)))) ;; TODO block children

(fn windowmove [] (fn [! dx dy] (when (and dx dy)
  (let [(wx wy) (love.window.getPosition)]
    (love.window.setPosition (+ wx dx) (+ wy dy))))))

(fn windowfull [] (fn [!]
  (if (not _G.web?)
    (love.window.setFullscreen (flip fs?) :desktop)
    (let [(sw sh) (love.window.getMode)
          [w h]   [!.parent.ow !.parent.oh]
          [nw nh] [(if fs? w sw) (if fs? h sh)]]
      (love.window.updateMode nw nh (opt nw nh))))
  (!.parent:restore (love.window.getMode))))

(fn load []
  (let [info  (love.filesystem.getInfo :conf.fnl)
        title (if info ((love.filesystem.lines :conf.fnl)) :_)
        name  (title:lower)]
    (local parent     (WIN main :parent 0.75 1))
    (local child      (WIN parent :child 0.75 1))
    (local grandchild (CAB child name))))

(fn love.load [args]
  (love.graphics.setDefaultFilter :nearest :nearest)
  (love.graphics.setFont (love.graphics.newFont 16 :mono))
  (set _G.web? (= :web (. args 1)))
  (local win (BOX nil 0 0 (love.window.getMode)))
  (set main (WIN {:inner win :depth -1 :subs []} :main 1 1))
  (local mousemoved       main.mousemoved)
  (set main.mousemoved    (windowmouse mousemoved))
  (set main.outer.repose  (windowmove))
  (set main.outer.restore (windowfull))
  (set main.outer.reshape #nil)
  (each [e _ (pairs love.handlers)]
    (tset love.handlers e #(main:event e $...)))
  (load))

(fn love.draw [] 
  (love.graphics.applyTransform main.outer.parent.t)
  (main:draw) 
  (when (and mx my) (love.graphics.circle :line mx my 4)))

(fn love.update [dt] (main:update dt))
