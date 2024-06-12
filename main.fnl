(import-macros {: flip} :mac.bool)
(local BOX (require :src._.cls.BOX))
(local CAB (require :src._.cls.CAB))
(local WIN (require :src._.cls.WIN))
(var (main mx my w h fs?) (values nil nil nil nil nil false))
(local opt #{:fullscreen (flip fs?) :fullscreentype :exclusive
             :minwidth $1 :minheight $2})

(fn windowmouse [mousemoved] (fn [! x y dx dy ...]
  (when (not (and mx my)) (set (mx my) (values x y)))
  (let [(ww wh)   (love.window.getMode)
        mxin?     (and (> mx 0) (< mx (- ww 0)))
        myin?     (and (> my 0) (< my (- wh 0)))
        within?   (and mxin? myin?)
        relate? (love.mouse.getRelativeMode)]
    (when relate? (if within? 
      (set (mx my) (values (+ mx dx) (+ my dy)))
      (do (love.mouse.setRelativeMode false))
          (love.mouse.setPosition mx my)))
    (when (not relate?) (set (mx my) (values x y)))
    (when within? (love.mouse.setRelativeMode true))
    (mousemoved ! mx my dx dy ...)))) ;; TODO block children

(fn windowmove [repose] (fn [! tx ty dx dy repose?] 
  (when (and dx dy) (let [(wx wy) (love.window.getPosition)]
    (love.window.setPosition (+ wx dx) (+ wy dy))))
  (when repose? (repose ! tx ty))))

(fn windowfull [restore] (fn [!] (if (not _G.web?)
  (love.window.setFullscreen (flip fs?) :desktop)
  (let [(sw sh) (love.window.getMode)
        width   (if fs? w sw)
        height  (if fs? h sh)
        opts    (opt width height)]
    (love.window.updateMode width height opts)))
  ;; TODO call restore when parent matrix problem fixed
  (let [(pw ph) (love.window.getMode)
        maxw    (- pw 2)
        maxh    (- ph (* 2 (!.parent:border false)))
        max?    (and (>= !.sw maxw) (>= !.sh maxh))
        (x y)   (values 1 (!.parent:border false))
        (w h)   (if max? (values !.w !.h) (values maxw maxh))]
    (!:repose x y) 
    (!:rescale w h))))

(fn load []
  (let [file    :conf.fnl
        info    (love.filesystem.getInfo file)
        title   (if info ((love.filesystem.lines file)) :_)
        format  "%s"
        name    (format:format (title:lower))
        s       (/ (math.min w h) 1)]
    (love.window.setTitle title)
    (local parent     (WIN main :parent 0.75 1))
    (local child      (WIN parent :child 0.75 1))
    (local grandchild (CAB child name))))

(fn love.load [args]
  (set (w h) (love.window.getMode))
  (local font (love.graphics.newFont 12 :mono)) ; TODO dynamic
  (font:setFilter :nearest :nearest)
  (love.graphics.setFont font)
  (set _G.font font) ; TODO globals?
  (set _G.web? (= :web (. args 1)))
  (set main (WIN {:inner (BOX) :depth -1} :main 1 1))
  (local mousemoved     main.mousemoved)
  (local repose         main.repose)
  (local restore        main.restore)
  (set main.mousemoved  (windowmouse mousemoved))
  ;(set main.repose         (windowmove repose))
  ;(set main.restore        (windowfull restore))
  (each [e _ (pairs love.handlers)]
    (tset love.handlers e #(main:event e $...)))
  (load))

(fn love.draw [] (main:draw)
  (when (and mx my) (love.graphics.circle :line mx my 4)))

(fn love.update [dt] (main:update dt))
