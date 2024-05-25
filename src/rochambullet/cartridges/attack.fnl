(import-macros {: arctan} :mac.math)
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
                (e:reset self.board true)))
        (when inner (set self.player.threat 1))))
      (set collision? (or collision? outer inner))))
  (when (not collision?) (set self.player.threat -1)))

(fn EvE [self dt w h]
  ;; FIXME consider enemy type
  (local collided [])
  ;; TODO spatial hashmap avoid polynomial checks
  (for [i 1 (length self.enemies)]
    (for [j 1 (length self.enemies)]
      (when (~= i j)
        (let [a (. self.enemies i)
              b (. self.enemies j)
              c (a:check b.x b.y (/ (+ a.size b.size) 2))]
          (when c (do
            (table.insert collided i)))))))
  (for [i (length collided) 1 -1]
    (table.remove self.enemies (. collided i))))

(fn tick [self dt w h]
  (anim self dt w h)
  (PvE self dt w h))
  ;(EvE self dt w h))

(fn reset [self]
  (self.player:reset self.board)
  (each [_ e (pairs self.enemies)] (e:reset self.board)))

(fn update [self dt w h]
  (if self.turn?
    (if self.tick? (tick self dt w h) (reset self))
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
