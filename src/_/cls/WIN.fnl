(local Object (require :lib.classic))
(local WIN (Object:extend))
(local CAB (require :src._.cls.CAB))
(local MAT (require :src._.cls.MAT))

(fn WIN.new [self name ww wh w h]
  (set self.t       (/ (math.min ww wh) 64))
  (set self.color   [0.4 0.4 0.4])
  (set self.cab     (CAB name w h))
  (set self.mat     (MAT ww wh w h))
  (self.mat:resize  (* w 2) (* h 2)))

(fn WIN.draw [self]
  (love.graphics.applyTransform self.mat.trans)
  (love.graphics.setColor self.color)
  (love.graphics.rectangle :fill 0 0 self.mat.w self.mat.h)
  (local stencil #(love.graphics.rectangle :fill 
    self.t self.t (- self.mat.w self.t self.t)
                  (- self.mat.h self.t self.t)))
  (love.graphics.stencil stencil :replace 1)
  (love.graphics.setStencilTest :greater 0)
  (love.graphics.setColor 0 0 0 1)
  (love.graphics.rectangle :fill 0 0 self.mat.w self.mat.h)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.origin)
  (self.cab:draw self.mat.transform)
  (love.graphics.setStencilTest))

(fn WIN.update [self dt] (self.cab:update dt))

(fn WIN.event [self e ...] (match e
  :mousepressed   (self.cab:event e 
                    (self.mat:mousepressed self.t ...))
  :mousereleased  (self.cab:event e
                    (self.mat:mousereleased self.t ...))
  :mousemoved     (self.cab:event e 
                    (self.mat:mousemoved self.t ...))
  _               (self.cab:event e ...)))
;TODO update window colors based on mat event
;(if borders (set self.color [0.8 0.8 0.8])
;                (set self.color [0.4 0.4 0.4]))
WIN
