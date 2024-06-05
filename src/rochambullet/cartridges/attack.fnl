(import-macros {: incf : decf : clamp : digital : arctan} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Attack (Cartridge:extend))
(local HitMarker (require "src.rochambullet.classes.hitmarker"))

(local sources [])

(local hits [])
(fn hit [! x1 y1 x2 y2]
  (table.insert !.enemies (HitMarker (/ (+ x1 x2) 2) (/ (+ y1 y2) 2))))

(fn overlay [! w h]
  (local help "wins\tI\tlosses\tI\tremaining")
  (local stats [!.wins "\tI\t" !.losses "\tI\t" (length !.enemies)])
  (love.graphics.printf stats 0 0 (/ w 2) :center 0 2 2)
  (love.graphics.printf help 0 (- h (/ h 18)) (/ w 2) :center 0 2 2))

(fn anim [! dt w h]
  (!.player:anim dt !.board)
  (each [_ e (pairs !.enemies)] (e:anim dt !.board))
  (let [tx (- (/ w 2) !.player.x)
        ty (- (/ h 2) !.player.y)]
    (!.followplayer:setTransformation tx ty 0 1 1 0 0 0 0)))

(fn PvE [! dt w h]
  (var collision? false)
  (for [i (length !.enemies) 1 -1] 
    (let [e     (. !.enemies i)
          outer (!.player:check e.x e.y (* (+ !.player.size e.size) 1.5))
          inner (!.player:check e.x e.y (* (+ !.player.size e.size) 1))
          angle (math.abs (- (% (+ e.angle math.pi) (* 2 math.pi)) math.pi));(arctan e.x e.y !.player.x !.player.y)
          diffs (math.abs (- (% (+ !.player.aim math.pi) (* 2 math.pi)) math.pi));(math.abs (+ angle !.player.aim))
          oppos (math.abs (- math.pi (+ angle diffs)))];(math.abs (- (% (+ diffs math.pi) (* 2 math.pi)) math.pi))]
      (when (and (~= !.player.threat 1) outer) (do
        (set !.player.threat 0)
        (when (<= oppos (* math.pi 0.66)) (do
          (when (or (and (= !.player.type "paper")     (= e.type "rock"))
                    (and (= !.player.type "scissors")  (= e.type "paper"))
                    (and (= !.player.type "rock")      (= e.type "scissors")))
                (do (incf !.wins 1) 
                    (local source (love.audio.newSource "src/rochambullet/assets/hithigh.mp3" :static))
                    (source:setRelative true)
                    (source:setPosition (/ (- e.x !.player.x) w) (/ (- e.y !.player.y) h) 0)
                    (source:play)
                    (table.insert sources source)
                    (!:hit e.x e.y !.player.x !.player.y)
                    (table.remove !.enemies i)))
          (when (= !.player.type e.type) (do
            (set e.played true)
            (set e.angle !.player.daim)
            (local source (love.audio.newSource "src/rochambullet/assets/bouncehigh.mp3" :static))
            (source:play)
            (table.insert sources source)
            (e:reset !.board 2)))))
        (when inner 
          (when (or (and (= e.type "paper")     (= !.player.type "rock"))
                    (and (= e.type "scissors")  (= !.player.type "paper"))
                    (and (= e.type "rock")      (= !.player.type "scissors")))
                (local source (love.audio.newSource "src/rochambullet/assets/loss.mp3" :static))
                (source:setRelative true)
                (source:setPosition (/ (- e.x !.player.x) w) (/ (- e.y !.player.y) h) 0)
                (source:play)
                (table.insert sources source)
                (set !.player.threat 1)))))
      (set collision? (or collision? outer inner))))
  (when (not collision?) (set !.player.threat -1)))

(fn EvE [! dt w h]
  (local ones [])
  (local twos [])
  ;; TODO spatial hashmap avoid polynomial checks
  (for [i 1 (length !.enemies)]
    (for [j 1 (length !.enemies)]
      (when (~= i j)
        (let [a (. !.enemies i)
              b (. !.enemies j)
              c (a:check b.x b.y (/ (+ a.size b.size) (/ !.board.tilepx 2)))]
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
          (when (or ent.played oth.played) (incf !.wins 1))
          (!:hit ent.x ent.y oth.x oth.y)
          (local source (love.audio.newSource "src/rochambullet/assets/hitlow.mp3" :static))
          (source:setRelative true)
          (source:setPosition (/ (- ent.x !.player.x) w) (/ (- ent.y !.player.y) h) 0)
          (source:play)
          (table.insert sources source)
          (table.remove !.enemies collision.i)))))
  (for [c (length ones) 1 -1]
    (let [collision (. ones c)
          oth       collision.b
          ent       collision.a]
      (when (and (= ent.type oth.type) (~= ent.type "hitmarker")) (do
        (local source (love.audio.newSource "src/rochambullet/assets/bouncelow.mp3" :static))
        (source:setRelative true)
        (source:setPosition (/ (- ent.x !.player.x) w) (/ (- ent.y !.player.y) h) 0)
        (source:play)
        (table.insert sources source)       
        (set ent.angle (math.abs (- (% (+ ent.angle math.pi) (* 2 math.pi)) 0)))
        (set ent.angle (math.atan2  (+  (math.cos ent.angle)
                                        (math.cos collision.ba))
                                    (+  (math.sin ent.angle) 
                                        (math.sin collision.ba))))
        (set ent.angle (digital ent.angle))
        (set oth.angle (math.abs (- (% (+ oth.angle math.pi) (* 2 math.pi)) 0)))
        (set oth.angle (math.atan2  (+  (math.cos oth.angle)
                                        (math.cos collision.aa))
                                    (+  (math.sin oth.angle) 
                                        (math.sin collision.aa))))
        (set oth.angle (digital oth.angle))
        (ent:reset !.board 1)
        (oth:reset !.board 1)
        (when (or ent.played oth.played)
              (do (set ent.played true) (set oth.played true))))))))

(fn tick [! dt w h]
  (anim ! dt w h)
  (PvE ! dt w h)
  (EvE ! dt w h))

(fn reset [! dt w h]
  (for [s (length sources) 1 -1]
    (local source (. sources s))
    (source:stop)
    (source:release)
    (table.remove sources s))
  (for [e (length !.enemies) 1 -1] 
    (when (= (. (. !.enemies e) :type) "hitmarker") (table.remove !.enemies e)))
  (when (= !.player.threat 1) (incf !.losses 1))
  (!.player:reset !.board)
  (each [_ e (pairs !.enemies)] (e:reset !.board)))

(fn update [! dt w h]
  (if !.turn?
    (if !.tick? (tick ! dt w h) (reset ! dt w h))
    (if (= (length !.enemies ) 0)
      (Cartridge.load ! :src.rochambullet.cartridges.postgame true)
      (if (~= !.caller.name :src.rochambullet.cartridges.turn)
        (Cartridge.load ! :src.rochambullet.cartridges.turn true)
        (do
          (Cartridge.load ! :src.rochambullet.cartridges.choose true))))))

(tset Attack :new (fn [! w h old]
  (Attack.super.new ! old) ;; keep old state
  (tset ! :hits hits)
  (tset ! :hit hit)
  (tset ! :update update)
  (tset ! :mousepressed nil)
  (tset ! :overlay overlay)
  (love.audio.setEffect "fg" {:type "flanger" :rate 1 :depth 0})
  (!.music:setEffect "fg")
  (love.audio.setEffect "eq" {:type "equalizer"
                              :lowgain 0.125
                              :lowmidgain 0.25
                              :highmidgain 0.5
                              :highgain 1})
  (!.music:setEffect "eq")
  !))
Attack
