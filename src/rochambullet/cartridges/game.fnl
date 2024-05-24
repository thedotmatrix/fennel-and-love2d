(import-macros {: decf : arctan} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Game (Cartridge:extend))

(fn update [self dt w h]
  (let [tx (- (/ w 2) self.player.x)
        ty (- (/ h 2) self.player.y)]
    (self.followplayer:setTransformation tx ty 0 1 1 0 0 0 0))
  ;; player
  (when (> (length self.player.dir) 0) (self.player:update dt self.board.px))
  (when (> self.player.attack 0) (decf self.player.attack dt))
  ;; enemies
  (var collision? false)
  (each [_ e (pairs self.enemies)] 
    (e:update dt self.board.px)
    ;; self.player collision
    (let [outer (self.player:collision? e.x e.y (* (+ self.player.size e.size) 1.5))
          inner (self.player:collision? e.x e.y (* (+ self.player.size e.size) 1))
          angle (arctan e.x e.y self.player.x self.player.y)]
      (when (and (~= self.player.threat 1) outer) (do
        (set self.player.threat 0)
        (when (< (math.abs (- angle self.player.aim)) (/ math.pi 2))
          (do (self.player:attacking) (set e.angle self.player.aim)))
        (when inner (set self.player.threat 1))))
      (set collision? (or collision? outer inner))))
  (when (not collision?) (set self.player.threat -1))
  ;; enemy collision
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
    (table.remove self.enemies (. collided i))))

(fn keypressed [self key scancode repeat?]
  (match key
    :left  (tset self.player.keys key true)
    :right (tset self.player.keys key true)
    :up    (tset self.player.keys key true)
    :down  (tset self.player.keys key true)
    :space (Cartridge.load self :src.rochambullet.cartridges.pregame))
  (self.player:moving))

(fn keyreleased [self key scancode]
  (match key
    :left  (tset self.player.keys key false)
    :right (tset self.player.keys key false)
    :up    (tset self.player.keys key false)
    :down  (tset self.player.keys key false))
  (self.player:moving))

(tset Game :new (fn [self w h old]
  (Game.super.new self old) ;; keep old state
  (tset self :update update)
  (tset self :keypressed keypressed)
  (tset self :keyreleased keyreleased)
  self))
Game
