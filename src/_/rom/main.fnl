(local ROM (require :src._.cls.ROM))
(local Main (ROM:extend))

(fn Main.update [!! ! dt] (!.win:update dt))

(fn Main.event [!! ! rom e ...]
  (if (. rom e) ((. rom e) !! ! ...) (!.win:event e ...)))

(fn Main.keypressed [!! ! key ...]
  (when (= key :escape) (love.event.quit))
  (!.win:event :keypressed ...))

;; TODO CAB/RAM anti-pattern?
(fn Main.mousemoved [!! ! x y dx dy ...] 
  (when (not (and !.mx !.my)) (set [!.mx !.my] [x y]))
  (let [w       !.win.live.ram.outer.parent.w 
        h       !.win.live.ram.outer.parent.h
        mxin?   (and (> !.mx 0) (< !.mx (- w 0)))
        myin?   (and (> !.my 0) (< !.my (- h 0)))
        within? (and mxin? myin?)
        relate? (love.mouse.getRelativeMode)]
    (when (and relate? (not !.win.live.ram.drag?)) 
      (if within? 
        (set [!.mx !.my] [(+ !.mx dx) (+ !.my dy)])
        (do (set !.win.live.ram.drag? true) 
            (Main.mousereleased !! ! x y dx dy ...))))
    (when (not relate?) (set [!.mx !.my] [x y]))
    (when within? (love.mouse.setRelativeMode true))
    (!.win:event :mousemoved !.mx !.my dx dy ...)))

(fn Main.mousereleased [!! ! x y dx dy ...]
  (when !.win.live.ram.drag? (do 
    (love.mouse.setRelativeMode false)
    (love.mouse.setPosition !.mx !.my)
    (set !.win.live.ram.drag? false)))
  (!.win:event :mousereleased x y dx dy ...))

Main
