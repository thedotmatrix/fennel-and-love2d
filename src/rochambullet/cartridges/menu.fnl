(import-macros {: incf : decf : coin} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Menu (Cartridge:extend))
(local Board (require :src.rochambullet.classes.board))
(local Player (require :src.rochambullet.classes.player))

(local board (Board 8 128))
(var player nil)
(var canvas nil)
(local centercanvas (love.math.newTransform))
(local followplayer (love.math.newTransform))
(local shader (love.graphics.newShader "src/rochambullet/assets/sphere.glsl"))
(local music (love.audio.newSource "src/rochambullet/assets/brothers_and_sisters_SLOWED+REVERB.mp3" "stream"))

(var time 0)
(var left 1)
(var right 1)
(local filesl [])
(var fl 1)
(var framel nil)
(local filesr [])
(var fr 1)
(var framer nil)

(fn load [w h]
  (music:setVolume 0)
  (music:setLooping true)
  (set player   (Player (coin (/ board.tilepx -2) (/ board.tilepx 2))
                        (coin (/ board.tilepx -2) (/ board.tilepx 2))))
  (let [csize (* w (+ (/ 1 16) 1.0))]
    (set canvas (love.graphics.newCanvas csize csize)))
  (let [tx    (/ (- (canvas:getWidth) w) 2)
        ty    (/ (- (canvas:getHeight) h) 2)]
    (centercanvas:setTransformation tx ty 0 1 1 0 0 0 0))
  (shader:send :manual_amount 1.5)
  (shader:send :fx -0.4)
  (local dirl "src/rochambullet/assets/choose/")
  (each [_ file (ipairs (love.filesystem.getDirectoryItems dirl))]
    (table.insert filesl (.. dirl file)))
  (local dirr "src/rochambullet/assets/attack/")
  (each [_ file (ipairs (love.filesystem.getDirectoryItems dirr))]
    (table.insert filesr (.. dirr file))))

(fn overlay [self w h]
  ;; FIXME tutorial description of aiming, choosing, attacking with gifs!
  (love.graphics.printf  "Click/Tap Here to Enter/Exit Fullscreen"
                          0 0 (/ w 2) :center 0 2 2)
  (_G.font:setFilter "linear" "linear")
  (love.graphics.setColor 0 0 0 1)
  (love.graphics.printf ["Ro" "Cham" "BULLET"] 
                          0 (+ 0 (/ h 36)) (/ w 8) :center 0 8 8)
  (love.graphics.printf "Double-Click/Tap to Start" 
                          0 (+ 0 (/ h 4.5)) (/ w 4) :center 0 4 4)
  (love.graphics.setColor 1 1 1 1)
  (_G.font:setFilter "nearest" "nearest")
  (love.graphics.printf [[1 0 1 1] "Ro" [0 1 0 1] "Cham" [0 1 1 1] "BULLET"] 
                          0 (+ 0 (/ h 36)) (/ w 8) :center 0 8 8)
  (love.graphics.printf "Double-Click/Tap to Start" 
                          0 (+ 0 (/ h 4.5)) (/ w 4) :center 0 4 4)
  (love.graphics.printf  "Click/Tap Here to Enter/Exit Fullscreen"
                          0 (- h (/ h 18)) (/ w 2) :center 0 2 2)
  (when framel (love.graphics.draw framel (* 0.035 w) (* 0.35 h) 0 1.4 1.4 0 0))
  (when framer (love.graphics.draw framer (* 0.615 w) (* 0.35 h) 0 1.4 1.4 0 0))
  (_G.font:setFilter "linear" "linear")
  (love.graphics.setColor 0 0 0 0.8)
  (love.graphics.rectangle "fill" 0 (* 0.70 h) (* w 0.45) (/ h 4) (/ h 16))
  (love.graphics.rectangle "fill" (* w 0.55) (* 0.70 h) (* w 0.45) (/ h 4) (/ h 16))
  (love.graphics.setColor 0 0 0 1)
  (love.graphics.printf 
      "CHOOSE TURN
      \n4 seconds, 3 choices, 1 deep breath
      \nclick/tap to change your player type
      \nchoose wisely based on the enemies around you"   
    (* -0.035 w) (* 0.70 h) (/ w 1.11 2) :center 0 1.11 1.11)
  (love.graphics.printf 
      "ATTACK TURN
      \naim with mouse/touch, you move where you aim
      \nwhen player/enemy collide, win/lose/draw by type
      \nwins destroy, losses hurt, draws bounce enemies"   
    (* 0.535 w) (* 0.70 h) (/ w 1.11 2) :center 0 1.11 1.11)
  (love.graphics.setColor 1 1 1 1)
  (_G.font:setFilter "nearest" "nearest")
  (love.graphics.printf 
      "CHOOSE TURN
      \n4 seconds, 3 choices, 1 deep breath
      \nclick/tap to change your player type
      \nchoose wisely based on the enemies around you"   
    (* -0.035 w) (* 0.70 h) (/ w 1.11 2) :center 0 1.11 1.11)
  (love.graphics.printf 
      "ATTACK TURN
      \naim with mouse/touch, you move where you aim
      \nwhen player/enemy collide, win/lose/draw by type
      \nwins destroy, losses hurt, draws bounce enemies"   
    (* 0.535 w) (* 0.70 h) (/ w 1.11 2) :center 0 1.11 1.11))

(fn draw [self w h supercanvas]
  (love.graphics.setCanvas self.canvas)
  (love.graphics.push)
  (love.graphics.applyTransform self.followplayer)
  (love.graphics.applyTransform self.centercanvas)
  (self.board:draw*)
  (when self.enemies (each [_ e (pairs self.enemies)] (e:draw* self.board.px)))
  (self.player:draw)
  (love.graphics.pop)
  (love.graphics.setCanvas supercanvas)
  (love.graphics.setShader self.shader)
  (love.graphics.push)
  (love.graphics.applyTransform (self.centercanvas:inverse))
  (love.graphics.clear 1 1 1 1)
  (love.graphics.draw self.canvas)
  (love.graphics.pop)
  (love.graphics.setShader)
  (love.graphics.setColor 0 0 0 1)
  (when self.crop! (for [i 0 8 1]
    (love.graphics.circle "line" (/ w 2) (/ h 2) 
                          (- (* w 0.5325 self.crop!) (/ i 2)))))
  (love.graphics.setColor 0 0 0 1)
  (love.graphics.rectangle "fill" 0 0 w (/ h 18))
  (love.graphics.rectangle "fill" 0 (- h (/ h 18)) w (/ h 18))
  (love.graphics.setColor 1 1 1 1)
  (when self.overlay (self:overlay w h)))

(fn update [self dt w h]
  (when (not (self.music:isPlaying)) (self.music:play))
  (when (< (self.music:getVolume) 0.5) (self.music:setVolume (+ (self.music:getVolume) (* dt 0.1))))
  (when (>= (self.player:anim dt self.board) 1.0) 
            (self.player:reset self.board))
  ;; TODO class since duped across every update
  (let [tx (- (/ w 2) self.player.x)
        ty (- (/ h 2) self.player.y)]
    (self.followplayer:setTransformation tx ty 0 1 1 0 0 0 0))
  (incf time dt)
  (when (> time (/ 1 6))
    (incf fl (math.floor (/ time 0.04)))
    (when (not (. filesl fl)) (set fl 1))
    (set framel (love.graphics.newImage (. filesl fl)))
    (incf fr (math.floor (/ time 0.04)))
    (when (not (. filesr fr)) (set fr 1))
    (set framer (love.graphics.newImage (. filesr fr)))
    (set time 0)))

(fn mousepressed [self x y button istouch presses]
  (when (and (or (= button 1) istouch) (> presses 1)) (do
    (music:setVolume 0.5)
    (Cartridge.load self :src.rochambullet.cartridges.pregame))))

(tset Menu :new (fn [self w h old]
  (Menu.super.new self) ;; discard old state
  (when (not self.caller) (load w h))
  (tset self :wins 0)
  (tset self :losses 0)
  (when (not self.music) (tset self :music music))
  (when (not self.board) (tset self :board board))
  (when (not self.player) (tset self :player player))
  (when (not self.canvas) (tset self :canvas canvas))
  (when (not self.centercanvas) (tset self :centercanvas centercanvas))
  (when (not self.followplayer) (tset self :followplayer followplayer))
  (when (not self.shader) (tset self :shader shader))
  (tset self :overlay overlay)
  (tset self :draw draw)
  (tset self :update update)
  (tset self :mousepressed mousepressed)
  self))
Menu
