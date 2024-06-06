; main.fnl
(import-macros {: flip} :mac.bool)
(local MAT (require :src._.cls.MAT))
(local WIN (require :src._.cls.WIN))
(local CAB (require :src._.cls.CAB))
(var (main mx my w h) (values nil nil nil nil nil))
(var fullscreen? false)
(local opt #{ :fullscreen (flip fullscreen?)
              :fullscreentype :exclusive
              :minwidth $1 :minheight $2})

(fn windowmouse [mousemoved] (fn [! top? bot? x y dx dy ...]
  (when (not (and mx my)) (set (mx my) (values x y)))
  (let [(ww wh)   (love.window.getMode)
        mxin?     (and (> mx 0) (< mx (- ww 0)))
        myin?     (and (> my 0) (< my (- wh 0)))
        within?   (and mxin? myin?)
        relative? (love.mouse.getRelativeMode)]
    (when (and relative? (not !.drag?)) (if within? 
      (set (mx my) (values (+ mx dx) (+ my dy)))
      (do (love.mouse.setRelativeMode false))
          (love.mouse.setPosition mx my)))
    (when (not relative?) (set (mx my) (values x y)))
    (when within? (love.mouse.setRelativeMode true))
    (mousemoved ! top? bot? x y dx dy ...))))

(fn windowmove [! _ _ dx dy]
  (let [(wx wy) (love.window.getPosition)]
    (love.window.setPosition (+ wx dx) (+ wy dy))))

(fn windowfull [] ;; TODO maximize/minimize instead?
  (if (not _G.web?)
      (love.window.setFullscreen (flip fullscreen?) :desktop)
      (let [(sw sh) (love.window.getMode)
            width   (if fullscreen? w sw)
            height  (if fullscreen? h sh)
            opts    (opt width height)]
        (love.window.updateMode width height opts))))

(fn load []
  (let [file    :conf.fnl
        info    (love.filesystem.getInfo file)
        title   (if info ((love.filesystem.lines file)) :_)
        format  "%s"
        name    (format:format (title:lower))
        s       (/ (math.min w h) 1)]
    (love.window.setTitle title)
    (local parent     (WIN main :parent s s))
    (local child      (WIN parent :child (/ s 2) (/ s 2)))
    (local grandchild (CAB child name (/ s 2) (/ s 2)))
    (main.child parent)
    (parent.child child)
    (child.child grandchild)))

(fn love.load [args]
  (set (w h) (love.window.getMode))
  (local font (love.graphics.newFont 12 :mono)) ; TODO dynamic
  (font:setFilter :nearest :nearest)
  (love.graphics.setFont font)
  (set _G.font font) ; TODO globals?
  (set _G.web? (= :web (. args 1)))
  (set main (WIN {:mat (MAT nil 0 0 w h)} :main w h))
  (local mousemoved         main.mat.mousemoved)
  (set main.mat.mousemoved  (windowmouse mousemoved))
  (set main.mat.repose      windowmove)
  (set main.mat.restore     windowfull)
  (each [e _ (pairs love.handlers)]
    (tset love.handlers e #(main:event e $...)))
  (load))

(fn love.draw [] 
  (love.graphics.push) (main:draw) (love.graphics.pop)
  (when (and mx my) (love.graphics.circle :line mx my 4)))

(fn love.update [dt] (main:update dt))
