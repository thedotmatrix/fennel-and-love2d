(local Object (require :lib.classic))
(local MAT (Object:extend))
(local fit (fn [w h ww wh] (math.min (/ ww w) (/ wh w))))

(fn MAT.refresh [self]
  (self.transform:reset)
  (self.transform:apply self.trans)
  (self.transform:apply self.scale)
  (self.transform:apply self.centr))

(fn MAT.rearrange [self x y] 
  (set self.x x) (set self.y y) 
  (self.trans:setTransformation x y 0 1 1 0 0 0 0)
  (self:refresh))

(fn MAT.resize [self w h] 
  (set self.w w)  (set self.h h)
  (set self.s     (fit self.ow self.oh self.w self.h))
  (self.scale:setTransformation 0 0 0 self.s self.s 0 0 0 0)
  (set self.cx  (/ (- self.w (* self.s self.ow)) 2 self.os))
  (set self.cy  (/ (- self.h (* self.s self.oh)) 2 self.os))
  (self.centr:setTransformation self.cx self.cy 
    0 1 1 0 0 0 0)
  (self:refresh))

(fn MAT.restore [self]
  (if (and (= self.w self.ww) (= self.h self.wh))
      (do (self:resize self.ow self.oh)
          (self:rearrange (- self.mx (/ self.ow 2)) self.my))
      (do (self:resize self.ww self.wh)
          (self:rearrange 0 0)))
  (self:refresh))

(fn MAT.new [self ww wh w h]
  (set self.ww ww)    (set self.wh wh)
  (set self.os        (fit w h ww wh))
  (set self.ow w)     (set self.oh h)
  (set self.mx 0)     (set self.my 0)
  (set self.x 0)      (set self.y 0)
  (set self.cx 0)     (set self.cy 0)
  (set self.trans     (love.math.newTransform))
  (set self.scale     (love.math.newTransform))
  (set self.centr     (love.math.newTransform))
  (set self.transform (love.math.newTransform)))

(fn MAT.mousepressed [self t x y button touch? presses]
  (let [(tx ty) (self.transform:inverseTransformPoint x y)
        double  (= presses 2)
        lmin          self.x
        lmax          (+ self.x t)
        rmin          (- (+ self.x self.w) t)
        rmax          (+ self.x self.w)
        umin          self.y
        umax          (+ self.y t)
        dmin          (- (+ self.y self.h) t)
        dmax          (+ self.y self.h)
        lborder       (and  (> x lmin) (< x lmax) 
                            (> y umin) (< y dmax))
        rborder       (and  (> x rmin) (< x rmax) 
                            (> y umin) (< y dmax))
        uborder       (and  (> y umin) (< y umax) 
                            (> x lmin) (< x rmax))
        dborder       (and  (> y dmin) (< y dmax) 
                            (> x lmin) (< x rmax))
        borders       (or lborder rborder uborder dborder)]
    (when uborder (do 
      (set self.drag? true)
      (when double (self:restore))))
    (values tx ty button touch? presses)))

(fn MAT.mousereleased [self t x y ...]
  (let [(tx ty) (self.transform:inverseTransformPoint x y)]
    (set self.drag? false)
    (values tx ty ...)))

(fn MAT.mousemoved [self t x y dx dy ...]
  (let [(tx ty)   (self.transform:inverseTransformPoint x y)
        (tdx tdy) (self.scale:inverseTransformPoint dx dy)
        dmx       (+ self.x (- x self.mx)) ;;TODO dx?
        dmy       (+ self.y (- y self.my))]
    (when self.drag? (self:rearrange dmx dmy))
    (set self.mx x)
    (set self.my y)
    (values tx ty tdx tdy ...)))

MAT
