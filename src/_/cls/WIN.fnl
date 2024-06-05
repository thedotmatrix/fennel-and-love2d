(local Object (require :lib.classic))
(local WIN (Object:extend))
(local CAB (require :src._.cls.CAB))
(local MAT (require :src._.cls.MAT))

;; TODO self renamed to single special character in all files
(fn WIN.new [self name ww wh w h]
  (set self.t       (/ (math.min ww wh) 64))
  (set self.color   [0.4 0.4 0.4])
  (set self.cab     (CAB name w h))
  (set self.mat     (MAT ww wh w h)))

(fn WIN.draw [self]
  (love.graphics.applyTransform self.mat.trans)
  (love.graphics.setColor self.color)
  (let [(x y) (values -1 (* -1 self.t))
        (iw ih) (values self.mat.w self.mat.h)
        (ow oh) (values (+ iw (* -2 x)) (+ ih (* -2 y)))
        stencil #(love.graphics.rectangle :fill 0 0 iw ih)]
    (love.graphics.rectangle :fill x y ow oh)
    (love.graphics.stencil stencil :replace 1)
    (love.graphics.setStencilTest :greater 0)
    (love.graphics.setColor 0 0 0 1)
    (love.graphics.rectangle :fill 0 0 iw ih)
    (love.graphics.setColor 1 1 1 1))
  (love.graphics.origin)
  (self.cab:draw self.mat.transform)
  (love.graphics.setStencilTest))

(fn WIN.update [self dt] (self.cab:update dt))

(fn WIN.decor8 [self e x y ...]
  (if (or (= e :mousepressed) (= e :mousemoved))
    (let [lmin          self.mat.x ;; TODO minimize
          lmax          (+ self.mat.x self.t)
          rmin          (- (+ self.mat.x self.mat.w) self.t)
          rmax          (+ self.mat.x self.mat.w)
          umin          self.mat.y
          umax          (+ self.mat.y self.t)
          dmin          (- (+ self.mat.y self.mat.h) self.t)
          dmax          (+ self.mat.y self.mat.h)
          lborder       (and  (> x lmin) (< x lmax) 
                              (> y umin) (< y dmax))
          rborder       (and  (> x rmin) (< x rmax) 
                              (> y umin) (< y dmax))
          uborder       (and  (> y umin) (< y umax) 
                              (> x lmin) (< x rmax))
          dborder       (and  (> y dmin) (< y dmax) 
                              (> x lmin) (< x rmax))
          borders       (or lborder rborder uborder dborder)]
      ;; TODO fast mouse moves -> border=false
      (values uborder dborder x y ...))
      (values x y ...)))

(fn WIN.event [self e ...]
  (let [apply #((. self.mat e) self.mat (self:decor8 e $...))
        hook  (if (. self.mat e) apply #$)]
    (self.cab:event e (hook ...))))

WIN
