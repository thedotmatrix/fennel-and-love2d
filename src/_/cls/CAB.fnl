(import-macros {: flip} :mac.bool)
(local Object (require :lib.classic))
(local CAB (Object:extend))
(local CRT (require :src._.cls.CRT))

(fn CAB.transform [self x y w h ww wh]
  ;; window.new
  (when (not self.scale)
    (set self.ww ww)
    (set self.wh wh)
    (set self.ow w)
    (set self.oh h)
    (set self.t (/ (math.min ww wh) 64))
    (set self.color [0.4 0.4 0.4])
    (set self.mx 0)
    (set self.my 0)
    (set self.trans (love.math.newTransform))
    (set self.x 0)
    (set self.y 0)
    (set self.scale (love.math.newTransform))
    (set self.os (/ (math.min self.ww self.wh) (math.min self.ow self.oh)))
    (set self.centr (love.math.newTransform))
    (set self.cx 0)
    (set self.cy 0))
  (if (and w h)
      ;; window.scale
      (do (set self.w w) (set self.h h) (set self.x x) (set self.y y))
      ;; window.max/min-imize
      (if (and (= self.w self.ww) (= self.h self.wh))
          (do (set self.w self.ow) (set self.h self.oh) (set self.x x) (set self.y y))
          (do (set self.w self.ww) (set self.h self.wh) (set self.x 0) (set self.y 0))))
  ;; window.update
  (set self.s   (/ (math.min self.w self.h) (math.min self.ow self.oh)))
  (set self.cx  (/ (- self.w (* self.s self.ow)) 2 self.os))
  (set self.cy  (/ (- self.h (* self.s self.oh)) 2 self.os))
  (self.trans:setTransformation self.x self.y 0 1 1 0 0 0 0)
  (self.scale:setTransformation 0 0 0 self.s self.s 0 0 0 0)
  (self.centr:setTransformation self.cx self.cy 0 1 1 0 0 0 0))

(fn CAB.new [self name ww wh]
  (self:transform 0 0 (/ (math.min ww wh) 2) (/ (math.min ww wh) 2) ww wh)
  (set self.dev? false)
  (set self.dev {:cartridge nil :canvas nil})
  (set self.dev.cartridge (CRT :_ :repl))
  (set self.dev.canvas (love.graphics.newCanvas (/ self.w 2) self.h))
  (self.dev.canvas:setFilter :nearest :nearest)
  (set self.game {:cartridge nil :canvas nil})
  (set self.game.cartridge (CRT name :main))
  (set self.game.canvas (love.graphics.newCanvas self.w self.h))
  (self.game.canvas:setFilter :nearest :nearest)
  (self:transform self.x self.y (/ (math.min ww wh) 1) (/ (math.min ww wh) 1)))

(fn CAB.draw [self transform]
  (love.graphics.setCanvas self.game.canvas)
  (self.game.cartridge:draw self.game.canvas)
  (love.graphics.setCanvas self.dev.canvas)
  (self.dev.cartridge:draw self.dev.canvas)
  (love.graphics.setCanvas)
  
  (love.graphics.push)
  (love.graphics.applyTransform transform)
  (love.graphics.applyTransform self.trans)
  (love.graphics.setColor self.color)
  (love.graphics.rectangle "fill" 0 0 self.w self.h)
  
  (local stencil #(love.graphics.rectangle 
    "fill" self.t self.t (- self.w self.t self.t) (- self.h self.t self.t)))
  (love.graphics.stencil stencil :replace 1)
  (love.graphics.setStencilTest :greater 0)
  (love.graphics.setColor 0 0 0 1)
  (love.graphics.rectangle "fill" 0 0 self.w self.h)
  (love.graphics.setColor 1 1 1 1)

  (love.graphics.push)
  (love.graphics.applyTransform self.scale)
  (love.graphics.applyTransform self.centr)
  (love.graphics.draw self.game.canvas)
  (love.graphics.setColor 1 1 1 0.9)
  (when self.dev? (love.graphics.draw self.dev.canvas))
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.pop)

  (love.graphics.setStencilTest)
  (love.graphics.pop))

(fn CAB.update [self dt] 
  (self.game.cartridge:update dt)
  (self.dev.cartridge:update dt))

;; TODO no special cases, focus / check keys in event
(fn CAB.event [self e ...] (match e
  :keypressed     (self:keypressed ...)
  :textinput      (self:textinput ...)
  :mousepressed   (self:mouse e ...)
  :mousereleased  (self:mouse e ...)
  :mousemoved     (self:mouse e ...)
  _               (self.game.cartridge:event e ...)))

(fn CAB.keypressed [self key ...] (match key
  :escape (love.event.quit)
  :lctrl (flip self.dev?)
  _ (let [focus (if self.dev? self.dev self.game)]
      (focus.cartridge:event :keypressed ...))))

(fn CAB.textinput [self ...]
  (let [focus (if self.dev? self.dev self.game)]
    (focus.cartridge:event :textinput ...)))

(fn CAB.mouse [self e x y ...]
  (let [(tx ty)       (self.centr:inverseTransformPoint 
                        (self.scale:inverseTransformPoint 
                          (self.trans:inverseTransformPoint x y)))
        pressed       (= e :mousepressed)
        released      (= e :mousereleased)
        moved         (= e :mousemoved)
        (_ _ clicks)  (if pressed (pick-values 3 ...) (values 0 0 0))
        dclicked      (= clicks 2)
        (dx dy)       (if moved (pick-values 2 ...) (values 0 0))
        (tdx tdy)     (self.scale:inverseTransformPoint dx dy)
        lmin          self.x
        lmax          (+ self.x self.t)
        rmin          (- (+ self.x self.w) self.t)
        rmax          (+ self.x self.w)
        umin          self.y
        umax          (+ self.y self.t)
        dmin          (- (+ self.y self.h) self.t)
        dmax          (+ self.y self.h)
        lborder       (and (> x lmin) (< x lmax) (> y umin) (< y dmax))
        rborder       (and (> x rmin) (< x rmax) (> y umin) (< y dmax))
        uborder       (and (> y umin) (< y umax) (> x lmin) (< x rmax))
        dborder       (and (> y dmin) (< y dmax) (> x lmin) (< x rmax))
        borders       (or lborder rborder uborder dborder)]
    (when released                (set self.drag? false))
    (when (and pressed uborder)   (set self.drag? true))
    (when (and dclicked uborder)  (self:transform (- x (/ self.ow 2)) y))
    (when (and self.drag? moved)  (self:transform (+ self.x (- x self.mx)) (+ self.y (- y self.my)) self.w self.h))
    (when moved (do (set self.mx x) (set self.my y)))
    (if borders (set self.color [0.8 0.8 0.8])
                (set self.color [0.4 0.4 0.4]))
    (if moved (self.game.cartridge:event e tx ty tdx tdx ...)
              (self.game.cartridge:event e tx ty ...))))
CAB
