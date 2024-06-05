(local Object (require :lib.classic))
(local MAT (Object:extend))
(local fit (fn [w h ww wh] (math.min (/ ww w) (/ wh w))))
(local transset (fn [t ...] (t:setTransformation ...)))

(fn MAT.refresh [self]
  (self.transform:reset)
  (self.transform:apply self.trans)
  (self.transform:apply self.scale)
  (self.transform:apply self.centr))

(fn MAT.rearrange [self x y] 
  (set self.x x) (set self.y y) 
  (transset self.trans x y 0 1 1 0 0 0 0)
  (self:refresh))

(fn MAT.resize [self w h]
  (set self.w w)  (set self.h h)
  (set self.s     (fit self.ow self.oh self.w self.h))
  (transset self.scale 0 0 0 self.s self.s 0 0 0 0)
  (set self.cx  (/ (- self.w (* self.s self.ow)) 2 self.os))
  (set self.cy  (/ (- self.h (* self.s self.oh)) 2 self.os))
  (transset self.centr self.cx self.cy 0 1 1 0 0 0 0)
  (self:refresh))

(fn MAT.restore [self mx my]
  (let [max?  (and (= self.w self.ww) (= self.h self.wh))
        (w h) (if max?  (values self.ow self.oh) 
                        (values self.ww self.wh))
        (x y) (if max?  (values (- mx (/ self.ow 2)) my) 
                        (values 0 0))]
    (self:resize w h)
    (self:rearrange x y)))

(fn MAT.new [self ww wh w h]
  (set self.ww ww)    (set self.wh wh)
  (set self.os        (fit w h ww wh))
  (set self.ow w)     (set self.oh h)
  (set self.x 0)      (set self.y 0)
  (set self.cx 0)     (set self.cy 0)
  (set self.trans     (love.math.newTransform))
  (set self.scale     (love.math.newTransform))
  (set self.centr     (love.math.newTransform))
  (set self.transform (love.math.newTransform)))

(fn MAT.mousepressed [self top? x y button touch? presses]
  (let [(tx ty) (self.transform:inverseTransformPoint x y)]
    (when top? (set self.drag? true))
    (when (and top? (= presses 2)) (self:restore x y))
    (values tx ty button touch? presses)))

(fn MAT.mousereleased [self x y ...]
  (let [(tx ty) (self.transform:inverseTransformPoint x y)]
    (set self.drag? false)
    (values tx ty ...)))

(fn MAT.mousemoved [self x y dx dy ...]
  (let [(tx ty)   (self.transform:inverseTransformPoint x y)
        (tdx tdy) (self.scale:inverseTransformPoint dx dy)
        (dmx dmy) (values (+ self.x dx) (+ self.y dy))]
    (when self.drag? (self:rearrange dmx dmy))
    (values tx ty tdx tdy ...)))

MAT
