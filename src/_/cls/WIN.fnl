(local Object (require :lib.classic))
(local WIN (Object:extend))
(local MAT (require :src._.cls.MAT))
(local t #(/ (math.min $1 $2) 64))
(local (border fill) (values [0.4 0.4 0.4] [0.2 0.2 0.2]))

(fn WIN.new [! parentw parenth name w h win]
  (set !.mat (MAT parentw parenth 1 (t parentw parenth) w h))
  (when (and win win.is (win:is WIN)) (set !.child win)))

(fn WIN.draw [!]
  (love.graphics.applyTransform !.mat.trans)
  (let [(x y) (values 1 (t !.mat.parentw !.mat.parenth))
        (iw ih) (values !.mat.sw !.mat.sh)
        (ow oh) (values (+ iw (* 2 x)) (+ ih (* 2 y)))
        stencil #(love.graphics.rectangle :fill 0 0 iw ih)]
    (love.graphics.setColor border)
    (love.graphics.rectangle :fill (* -1 x) (* -1 y) ow oh)
    (love.graphics.stencil stencil :increment 1)
    (love.graphics.setStencilTest :greater 0)
    (love.graphics.setColor fill)
    (love.graphics.rectangle :fill 0 0 iw ih)
    (love.graphics.setColor 1 1 1 1))
  (love.graphics.applyTransform !.mat.scale)
  (when !.child (!.child:draw))
  (love.graphics.setStencilTest))

(fn WIN.update [! dt] (when !.child (!.child:update dt)))

(fn WIN.decor8 [! e x y ...]
  (if (or (= e :mousepressed) (= e :mousemoved))
    (let [(wmin wmax) (values !.mat.x (+ !.mat.x !.mat.sw))
          thickness   (t !.mat.parentw !.mat.parenth)
          topmin      (- !.mat.y thickness) 
          topmax      !.mat.y
          botmin      (+ !.mat.y !.mat.sh)
          botmax      (+ (+ !.mat.y !.mat.sh) thickness)
          top?        (and  (> y topmin) (< y topmax) 
                            (> x wmin) (< x wmax))
          bot?        (and  (> y botmin) (< y botmax) 
                            (> x wmin) (< x wmax))]
      (values top? bot? x y ...))
      (values x y ...)))

(fn WIN.event [! e ...]
  (let [apply     #((. !.mat e) !.mat (!:decor8 e $...))
        transform (if (. !.mat e) apply #$)]
    (when !.child (!.child:event e (transform ...)))))

WIN
