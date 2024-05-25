(import-macros {: decf : clamp : digital : arctan} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Attack (Cartridge:extend))

(fn anim [self dt w h]
  (self.player:anim dt self.board)
  (each [_ e (pairs self.enemies)] (e:anim dt self.board))
  (let [tx (- (/ w 2) self.player.x)
        ty (- (/ h 2) self.player.y)]
    (self.followplayer:setTransformation tx ty 0 1 1 0 0 0 0)))

(fn PvE [self dt w h]
  ;; FIXME consider enemy type
  (var collision? false)
  (each [_ e (pairs self.enemies)] 
    (let [outer (self.player:check e.x e.y (* (+ self.player.size e.size) 1.5))
          inner (self.player:check e.x e.y (* (+ self.player.size e.size) 0.75))
          angle (arctan e.x e.y self.player.x self.player.y)]
      (when (and (~= self.player.threat 1) outer) (do
        (set self.player.threat 0)
        (when (<= (math.abs (- angle self.player.aim)) (/ math.pi 2))
              (do
                (set e.angle self.player.daim)
                (e:reset self.board 2)))
        (when inner (do (set self.player.threat 1)
                        (print [(math.abs (- self.player.x e.x)) "\t" (math.abs (- self.player.y e.y))])))))
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
        (table.remove self.enemies collision.i))))
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
        (oth:reset self.board 1))))))

(fn tick [self dt w h]
  (anim self dt w h)
  (PvE self dt w h)
  (EvE self dt w h))

(fn reset [self dt w h]
  (self.player:reset self.board)
  (each [_ e (pairs self.enemies)] (e:reset self.board)))

(fn update [self dt w h]
  (if self.turn?
    (if self.tick? (tick self dt w h) (reset self dt w h))
    (if (~= self.caller.name :src.rochambullet.cartridges.turn)
      (Cartridge.load self :src.rochambullet.cartridges.turn true)
      (do
        (Cartridge.load self :src.rochambullet.cartridges.choose true)))))

(tset Attack :new (fn [self w h old]
  (Attack.super.new self old) ;; keep old state
  (tset self :update update)
  (tset self :overlay nil)
  self))
Attack
