(import-macros {: incf : decf : clamp : digital : arctan} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Attack (Cartridge:extend))

(fn overlay [self w h]
  (local help "kills\tI\tdeaths\tI\tremaining")
  (local stats [self.kills "\tI\t" self.deaths "\tI\t" (length self.enemies)])
  (love.graphics.printf stats 0 0 (/ w 2) :center 0 2 2)
  (love.graphics.printf help 0 (- h (/ h 18)) (/ w 2) :center 0 2 2))

(fn anim [self dt w h]
  (self.player:anim dt self.board)
  (each [_ e (pairs self.enemies)] (e:anim dt self.board))
  (let [tx (- (/ w 2) self.player.x)
        ty (- (/ h 2) self.player.y)]
    (self.followplayer:setTransformation tx ty 0 1 1 0 0 0 0)))

(fn PvE [self dt w h]
  (var collision? false)
  (for [i (length self.enemies) 1 -1] 
    (let [e     (. self.enemies i)
          outer (self.player:check e.x e.y (* (+ self.player.size e.size) 1.5))
          inner (self.player:check e.x e.y (* (+ self.player.size e.size) 1))
          angle (arctan e.x e.y self.player.x self.player.y)
          oppos (% (math.abs (- angle self.player.aim)) (* math.pi 2))]
      (when (and (~= self.player.threat 1) outer) (do
        (set self.player.threat 0)
        (when (> oppos (/ math.pi 2)) (print oppos))
        (when (<= oppos (* math.pi 0.5)) (do
          (when (or (and (= self.player.type "paper")     (= e.type "rock"))
                    (and (= self.player.type "scissors")  (= e.type "paper"))
                    (and (= self.player.type "rock")      (= e.type "scissors")))
                (do (incf self.kills 1) (table.remove self.enemies i)))
          (when (= self.player.type e.type) (do
            (set e.played true)
            (set e.angle self.player.daim)
            (e:reset self.board 2)))))
        (when inner 
          (when (or (and (= e.type "paper")     (= self.player.type "rock"))
                    (and (= e.type "scissors")  (= self.player.type "paper"))
                    (and (= e.type "rock")      (= self.player.type "scissors")))
                (set self.player.threat 1)))))
      (set collision? (or collision? outer inner))))
  (when (not collision?) (set self.player.threat -1)))

(fn EvE [self dt w h]
  (local ones [])
  (local twos [])
  ;; TODO spatial hashmap avoid polynomial checks
  (for [i 1 (length self.enemies)]
    (for [j 1 (length self.enemies)]
      (when (~= i j)
        (let [a (. self.enemies i)
              b (. self.enemies j)
              c (a:check b.x b.y (/ (+ a.size b.size) 2))]
          (when c (do 
            (table.insert twos {:i i :a a :b b :aa a.angle :ba b.angle})
            (when (< i j)
              (table.insert ones {:i i :a a :b b :aa a.angle :ba b.angle}))))))))
  ;; TODO fun?
  (for [c (length twos) 1 -1]
    (let [collision (. twos c)
          oth       collision.b
          ent       collision.a]
      (when (or   (and  (= ent.type "rock")     (= oth.type "paper"))
                  (and  (= ent.type "paper")    (= oth.type "scissors"))
                  (and  (= ent.type "scissors") (= oth.type "rock")))
        (do
          (when (or ent.played oth.played) (incf self.kills 1))
          (table.remove self.enemies collision.i)))))
  (for [c (length ones) 1 -1]
    (let [collision (. ones c)
          oth       collision.b
          ent       collision.a]
      (when (= ent.type oth.type) (do         
        (set ent.angle (% (+ ent.angle math.pi) (* 2 math.pi)))
        (set ent.angle (math.atan2  (+  (math.cos ent.angle)
                                        (math.cos collision.ba))
                                    (+  (math.sin ent.angle) 
                                        (math.sin collision.ba))))
        (set ent.angle (digital ent.angle))
        (set oth.angle (% (+ oth.angle math.pi) (* 2 math.pi)))
        (set oth.angle (math.atan2  (+  (math.cos oth.angle)
                                        (math.cos collision.aa))
                                    (+  (math.sin oth.angle) 
                                        (math.sin collision.aa))))
        (set oth.angle (digital oth.angle))
        (ent:reset self.board 1)
        (oth:reset self.board 1)
        (when (or ent.played oth.played)
              (do (set ent.played true) (set oth.played true))))))))

(fn tick [self dt w h]
  (anim self dt w h)
  (PvE self dt w h)
  (EvE self dt w h))

(fn reset [self dt w h]
  (when (= self.player.threat 1) (incf self.deaths 1))
  (self.player:reset self.board)
  (each [_ e (pairs self.enemies)] (e:reset self.board)))

(fn update [self dt w h]
  (if self.turn?
    (if self.tick? (tick self dt w h) (reset self dt w h))
    (if (= (length self.enemies ) 0)
      (Cartridge.load self :src.rochambullet.cartridges.menu true)
      (if (~= self.caller.name :src.rochambullet.cartridges.turn)
        (Cartridge.load self :src.rochambullet.cartridges.turn true)
        (do
          (Cartridge.load self :src.rochambullet.cartridges.choose true))))))

(tset Attack :new (fn [self w h old]
  (Attack.super.new self old) ;; keep old state
  (tset self :update update)
  (tset self :mousepressed nil)
  (tset self :overlay overlay)
  self))
Attack
