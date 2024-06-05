(local Object (require :lib.classic))
(local WIN (Object:extend))
;; TODO cab or window, inteface?
(local CAB (require :src._.cls.CAB)) 
(local MAT (require :src._.cls.MAT))

(fn WIN.new [! name ww wh w h]
  (set !.t       (/ (math.min ww wh) 64))
  (set !.color   [0.4 0.4 0.4])
  (set !.cab     (CAB name w h))
  (set !.mat     (MAT ww wh 1 !.t w h)))

(fn WIN.draw [!]
  (love.graphics.applyTransform !.mat.trans)
  (love.graphics.setColor !.color)
  (let [(x y) (values -1 (* -1 !.t))
        (iw ih) (values !.mat.w !.mat.h)
        (ow oh) (values (+ iw (* -2 x)) (+ ih (* -2 y)))
        stencil #(love.graphics.rectangle :fill 0 0 iw ih)]
    (love.graphics.rectangle :fill x y ow oh)
    (love.graphics.stencil stencil :replace 1)
    (love.graphics.setStencilTest :greater 0)
    (love.graphics.setColor 0 0 0 1)
    (love.graphics.rectangle :fill 0 0 iw ih)
    (love.graphics.setColor 1 1 1 1))
  (love.graphics.origin)
  (!.cab:draw !.mat.t)
  (love.graphics.setStencilTest))

(fn WIN.update [! dt] (!.cab:update dt))

(fn WIN.decor8 [! e x y ...]
  (if (or (= e :mousepressed) (= e :mousemoved))
    (let [(wmin wmax) (values !.mat.x (+ !.mat.x !.mat.w))
          topmin      (- !.mat.y !.t) 
          topmax      !.mat.y
          botmin      (+ !.mat.y !.mat.h)
          botmax      (+ (+ !.mat.y !.mat.h) !.t)
          top?        (and  (> y topmin) (< y topmax) 
                            (> x wmin) (< x wmax))
          bot?        (and  (> y botmin) (< y botmax) 
                            (> x wmin) (< x wmax))]
      (values top? bot? x y ...))
      (values x y ...)))

(fn WIN.event [! e ...]
  (let [apply #((. !.mat e) !.mat (!:decor8 e $...))
        transform  (if (. !.mat e) apply #$)]
    (!.cab:event e (transform ...))))

WIN
