(import-macros {: decf : arctan} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Attack (Cartridge:extend))

(fn anim [self dt w h]
  (self.player:anim dt self.board)
  (each [_ e (pairs self.enemies)] (e:anim dt self.board))
  (var collision? false)
  (each [_ e (pairs self.enemies)] 
    ;; self.player collision FIXME consider enemy type
    (let [outer (self.player:collision? e.x e.y (* (+ self.player.size e.size) 1.5))
          inner (self.player:collision? e.x e.y (* (+ self.player.size e.size) 1))
          angle (arctan e.x e.y self.player.x self.player.y)]
      (when (and (~= self.player.threat 1) outer) (do
        (set self.player.threat 0)
        (when (< (math.abs (- angle self.player.aim)) (/ math.pi 2))
              (do
                (set e.angle self.player.aim)
                (set e.speed 2))) ;; FIXME lerp enemy from current pos to fixed grid bounce
        (when inner (set self.player.threat 1))))
      (set collision? (or collision? outer inner))))
  (when (not collision?) (set self.player.threat -1))
  ;; enemy collision FIXME consider enemy type
  (local collided [])
  (for [i 1 (length self.enemies)] ;; FIXME spatial hashmap avoid polynomial checks
    (for [j 1 (length self.enemies)]
      (when (~= i j)
        (let [a (. self.enemies i)
              b (. self.enemies j)
              c (a:collision? b.x b.y (/ (+ a.size b.size) 2))]
          (when c (do
            (table.insert collided i)))))))
  (for [i (length collided) 1 -1]
    (table.remove self.enemies (. collided i)))
  ;; transform
  (let [tx (- (/ w 2) self.player.x)
        ty (- (/ h 2) self.player.y)]
    (self.followplayer:setTransformation tx ty 0 1 1 0 0 0 0)))

(fn tick [self dt w h]
  (self.player:tick self.board)
  (each [_ e (pairs self.enemies)] (e:tick self.board)))

(fn update [self dt w h]
  (if self.turn?
    (if self.tick?
        (anim self dt w h)
        (tick self dt w h))
    (if (~= self.caller.name :src.rochambullet.cartridges.turn)
      (Cartridge.load self :src.rochambullet.cartridges.turn true)
      (do
        (each [_ e (pairs self.enemies)] (e:digital self.board))
        (Cartridge.load self :src.rochambullet.cartridges.choose true)))))

(tset Attack :new (fn [self w h old]
  (Attack.super.new self old) ;; keep old state
  (tset self :update update)
  self))
Attack
