(import-macros {: incf : decf : clamp} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Book (Cartridge:extend))
(local header "sheepolution how to love")
(local navi "<---left-alt--- \t \t chapter %d \t \t ---right-alt--->")
(var chapter 1)
(var title nil)
(var ENV {})

(fn load1 [] (set title "Installation") (print 123))

(fn load2 [] (set title "Variables")
  (print (+ 3 4))
  (let [a 5 b 3] (print (+ a b)))
  (let [X 5 Y 3 Z (+ X Y) X 2 Y 40] (print Z))
  (let [name "Daniel" 
        age 25
        text (.. "Hello, my name is " name ", and I'm " age " years old.")]
      (print text))
  (var coins 0)
  (set coins (+ coins 1))
  (incf coins 1))

(fn load3 [] (set title "Functions")
  (let [example (fn [] (print "Hello World!"))] (example))
  (do (fn example [] (print "Hello World!")) (example)) ;; use let, avoid do
  (let [sayNumber (fn [num] (print (.. "I like the number " num)))]
    ;; (print num) -- lua would print nil, fennel has a compiler error
    (sayNumber 15)
    (sayNumber 2)
    (sayNumber 44)
    (sayNumber 100))
  (let [giveMeFive (fn [] 5) a (giveMeFive)] (print a))
  (let [sum (fn [a b] (+ a b))] (print (sum 200 95))))

(fn load4 [] (set title "What is LÖVE")
  (let [test (fn [a b] (+ a b))] (test 10 20)))
(fn draw4 [w h]
  (love.graphics.circle "fill" 10 10 100 25)
  (love.graphics.rectangle "line" 200 30 120 100)
  (love.graphics.rectangle "fill" 100 200 50 80))

(fn load5 [] (set title "Moving a rectangle") (tset ENV :x 100))
(fn draw5 [w h] (love.graphics.rectangle "line" ENV.x 50 200 150))
(fn update5 [dt] (incf ENV.x (* 5 dt)) (print ENV.x))

(fn load6 [] (set title "If Statements (use arrow keys to move)")
  (tset ENV :x 100)
  (tset ENV :y 50)
  (if (and (< 5 9) (> 14 7)) (print "Both statements are true"))
  (if (or (< 20 9) (> 14 7) (= 5 10)) (print "One of these statements is true"))
  (if true (print 1))
  (if false (print 2))
  (if nil (print 3))
  (if 5 (print 4))
  (if "hello" (print 5)))
(fn draw6 [w h] (love.graphics.rectangle "line" ENV.x ENV.y 200 150))
(fn update6 [dt] 
  (if (love.keyboard.isDown "left") (decf ENV.x (* 100 dt)))
  (if (love.keyboard.isDown "right") (incf ENV.x (* 100 dt)))
  (if (love.keyboard.isDown "up") (decf ENV.y (* 50 dt)))
  (if (love.keyboard.isDown "down") (incf ENV.y (* 50 dt)))
  (print (.. "( \t" ENV.x "\t , \t" ENV.y "\t )")))

(fn load7 [] (set title "Tables and loops")
  (tset ENV :fruits ["apple" "banana"])
  (print (# ENV.fruits))
  (table.insert ENV.fruits "pear")
  (print (# ENV.fruits))
  (table.insert ENV.fruits "pineapple")
  (for [i 1 (# ENV.fruits)] (print (. ENV.fruits i)))
  (table.remove ENV.fruits 2)
  (tset ENV.fruits 1 "tomato")
  (each [i v (ipairs ENV.fruits)] (print (.. i ", " v))))
(fn draw7 [w h]
  (each [i frt (ipairs ENV.fruits)] 
    (love.graphics.print frt 100 (+ 100 (* 50 i)))))

(fn load8 [] (set title "Objects (press space to rectangle)")
  (tset ENV :listOfRectangles [])
  (tset ENV :pressed? false))
(fn draw8 [w h]
  (each [i rect (ipairs ENV.listOfRectangles)]
    (love.graphics.rectangle "line" rect.x rect.y rect.w rect.h)))
(fn update8 [dt]
  (when (and (not ENV.pressed?) (love.keyboard.isDown "space"))
    (let [rect {}
        createRect (fn []
          (set rect.x 100)
          (set rect.y 100)
          (set rect.w 70)
          (set rect.h 90)
          (set rect.speed 100)
          (table.insert ENV.listOfRectangles rect))]
        (createRect)))
  (tset ENV :pressed? (love.keyboard.isDown "space"))
  (each [i rect (ipairs ENV.listOfRectangles)]
    (incf rect.x (* rect.speed dt))))

(fn load9 [] (set title "Multiple files and scope (TBD)"))

(fn load10 [] (set title "Libraries (... wait for it, then press space!)")
  (tset ENV :tick (require "lib.tick"))
  (tset ENV :drawRectangle? false)
  (tset ENV :x 30)
  (tset ENV :y 50)
  (tset ENV :pressed? false)
  (ENV.tick.delay (fn [] (tset ENV :drawRectangle? true)) 2))
(fn draw10 [w h]
  (if ENV.drawRectangle? (love.graphics.rectangle "fill" ENV.x ENV.y 300 200)))
(fn update10 [dt] 
  (when (and (not ENV.pressed?) (love.keyboard.isDown "space"))
    (tset ENV :x (math.random 100 500))
    (tset ENV :y (math.random 100 500)))
  (tset ENV :pressed? (love.keyboard.isDown "space"))
  (ENV.tick.update dt))

(fn load11 [] (set title "Classes")
  (tset ENV :Object (require "lib.classic"))
  (tset ENV :Shape (ENV.Object:extend))
  (tset ENV.Shape :new (fn [self x y]
    (tset self :x x)
    (tset self :y y)
    (tset self :s 100)))
  (tset ENV.Shape :update (fn [self dt] (incf self.x (* self.s dt))))
  (tset ENV :Rectangle (ENV.Shape:extend))
  (tset ENV.Rectangle :new (fn [self x y w h] 
    (ENV.Rectangle.super.new self x y)
    (tset self :w w)
    (tset self :h h)))
  (tset ENV.Rectangle :draw (fn [self]
    (love.graphics.rectangle "line" self.x self.y self.w self.h)))
  (tset ENV :Circle (ENV.Shape:extend))
  (tset ENV.Circle :new (fn [self x y r]
    (ENV.Circle.super.new self x y)
    (tset self :r r)))
  (tset ENV.Circle :draw (fn [self]
    (love.graphics.circle "line" self.x self.y self.r)))
  (tset ENV :s1 (ENV.Rectangle 100 100 200 50))
  (tset ENV :s2 (ENV.Circle 350 80 40)))
(fn draw11 [w h] (ENV.s1:draw) (ENV.s2:draw))
(fn update11 [dt] (ENV.s1:update dt) (ENV.s2:update dt))

(fn load12 [] (set title "Images")
  (tset ENV :myImage (love.graphics.newImage "src/howtolove/assets/sheep.png")))
(fn draw12 [w h] 
  (let [iw (ENV.myImage:getWidth)
        ih (ENV.myImage:getHeight)
        r1 (/ math.pi 4)
        r2 (/ math.pi 2)]
      (love.graphics.setColor 1 0.78 0.15 0.5)
      (love.graphics.draw ENV.myImage 100 100 r1 2 2 (/ iw 2) (/ ih 2))
      (love.graphics.setColor 1 1 1)
      (love.graphics.draw ENV.myImage 200 100 r2 2 2 (/ iw 2) (/ ih 2))))

(fn load13 [] (set title "Detecting collision")
  (tset ENV :r1 {:x 10 :y 100 :w 100 :h 100})
  (tset ENV :r2 {:x 250 :y 120 :w 150 :h 120})
  (tset ENV :checkCollision (fn [a b]
    (let [al a.x ar (+ a.x a.w) at a.y ab (+ a.y a.h)
          bl b.x br (+ b.x b.w) bt b.y bb (+ b.y b.h)]
        (and (> ar bl) (< al br) (> ab bt) (< at bb))))))
(fn draw13 [w h]
  (let [mode (if (ENV.checkCollision ENV.r1 ENV.r2) "fill" "line")]
    (love.graphics.rectangle mode ENV.r1.x ENV.r1.y ENV.r1.w ENV.r1.h)
    (love.graphics.rectangle mode ENV.r2.x ENV.r2.y ENV.r2.w ENV.r2.h)))
(fn update13 [dt]
  (incf ENV.r1.x (* 100 dt)))

(fn load14 [] (set title "Game: Shoot the enemy")
  (tset ENV :pressed? false)
  (tset ENV :Object (require "lib.classic"))
  (tset ENV :Player (ENV.Object:extend))
  (tset ENV.Player :new (fn [self]
    (tset self :image (love.graphics.newImage "src/howtolove/assets/panda.png"))
    (tset self :x 300)
    (tset self :y 20)
    (tset self :s 500)
    (tset self :w (self.image:getWidth))
    (tset self :h (self.image:getHeight))))
  (tset ENV.Player :draw (fn [self] 
    (love.graphics.draw self.image self.x self.y)))
  (tset ENV.Player :update (fn [self dt w h]
    (when (love.keyboard.isDown "left") (decf self.x (* self.s dt)))
    (when (love.keyboard.isDown "right") (incf self.x (* self.s dt)))
    (clamp self.x 0 (- w self.w))))
  (tset ENV :Enemy (ENV.Object:extend))
  (tset ENV.Enemy :new (fn [self]
    (tset self :image (love.graphics.newImage "src/howtolove/assets/snake.png"))
    (tset self :x 325)
    (tset self :y 450)
    (tset self :s 100)
    (tset self :w (self.image:getWidth))
    (tset self :h (self.image:getHeight))))
  (tset ENV.Enemy :draw (fn [self w h]
    (love.graphics.draw self.image self.x self.y)))
  (tset ENV.Enemy :update (fn [self dt w h]
    (incf self.x (* self.s dt))
    (when (clamp self.x 0 (- w self.w)) (set self.s (* self.s -1)))))
  (tset ENV :Bullet (ENV.Object:extend))
  (tset ENV.Bullet :new (fn [self x y]
    (tset self :image (love.graphics.newImage "src/howtolove/assets/bullet.png"))
    (tset self :x x) 
    (tset self :y y)
    (tset self :s 700)
    (tset self :w (self.image:getWidth))
    (tset self :h (self.image:getHeight))))
  (tset ENV.Bullet :draw (fn [self w h]
    (love.graphics.draw self.image self.x self.y)))
  (tset ENV.Bullet :update (fn [self dt w h]
    (incf self.y (* self.s dt))))
  (tset ENV :player (ENV.Player))
  (tset ENV :enemy (ENV.Enemy))
  (tset ENV :shots {})
  (tset ENV :checkCollision (fn [a b]
    (let [al a.x ar (+ a.x a.w) at a.y ab (+ a.y a.h)
          bl b.x br (+ b.x b.w) bt b.y bb (+ b.y b.h)]
        (and (> ar bl) (< al br) (> ab bt) (< at bb))))))
(fn draw14 [w h] 
  (ENV.player:draw) 
  (ENV.enemy:draw)
  (each [i v (ipairs ENV.shots)] (v:draw)))
(fn update14 [dt w h]
  (ENV.player:update dt w h)
  (ENV.enemy:update dt w h)
  (when (and (not ENV.pressed?) (love.keyboard.isDown "space"))
    (let [b (ENV.Bullet 0 0)
          bx (+ ENV.player.x (- (/ ENV.player.w 2) (/ b.w 2)))
          by (+ ENV.player.y (/ ENV.player.h 2))]
        (table.insert ENV.shots (ENV.Bullet bx by))))
  (tset ENV :pressed? (love.keyboard.isDown "space"))
  (each [i v (ipairs ENV.shots)] 
    (v:update dt)
    (when (ENV.checkCollision v ENV.enemy) (do
      (if (> ENV.enemy.s 0) (incf ENV.enemy.s 50) (decf ENV.enemy.s 50))
      (table.remove ENV.shots i)))
    (when (> v.y h) (load14))))

(fn load15 [] (set title "Sharing your game (TBD)"))

(fn load16 [] (set title "Angles and distance")
  (tset ENV :circle {})
  (tset ENV.circle :x 100)
  (tset ENV.circle :y 100)
  (tset ENV.circle :r 25)
  (tset ENV.circle :s 200)
  (tset ENV.circle :a 0)
  (tset ENV :distance (fn [x1 y1 x2 y2]
    (math.sqrt (+ (^ (- x1 x2) 2) (^ (- y1 y2) 2)))))
  (tset ENV :arrow {})
  (tset ENV.arrow :x 200)
  (tset ENV.arrow :y 200)
  (tset ENV.arrow :s 300)
  (tset ENV.arrow :a 0)
  (tset ENV.arrow :i (love.graphics.newImage "src/howtolove/assets/arrow_right.png"))
  (tset ENV.arrow :ox (/ (ENV.arrow.i:getWidth) 2))
  (tset ENV.arrow :oy (/ (ENV.arrow.i:getHeight) 2)))
(fn draw16 [w h]
  (love.graphics.circle "line" ENV.circle.x ENV.circle.y ENV.circle.r)
  (love.graphics.print (.. "angle: " ENV.circle.a) 10 10)
  (love.graphics.line ENV.circle.x ENV.circle.y ENV.mx ENV.my)
  (love.graphics.line ENV.circle.x ENV.circle.y ENV.mx ENV.circle.y)
  (love.graphics.line ENV.mx ENV.my ENV.mx ENV.circle.y)
  (love.graphics.circle "line" ENV.circle.x ENV.circle.y ENV.cd)
  (love.graphics.draw ENV.arrow.i ENV.arrow.x ENV.arrow.y ENV.arrow.a 1 1 
                      ENV.arrow.ox ENV.arrow.oy)
  (love.graphics.circle "fill" ENV.mx ENV.my 5))
(fn update16 [dt]
  (let [(mx my) (love.mouse.getPosition)
        cangle (math.atan2 (- my ENV.circle.y) (- mx ENV.circle.x))
        cdist (ENV.distance ENV.circle.x ENV.circle.y mx my)
        aangle (math.atan2 (- my ENV.arrow.y) (- mx ENV.arrow.x))
        adist (ENV.distance ENV.arrow.x ENV.arrow.y mx my)
        agap (ENV.distance 0 ENV.arrow.oy ENV.arrow.ox ENV.arrow.oy)]
    (tset ENV :mx mx)
    (tset ENV :my my)
    (tset ENV.circle :a cangle)
    (tset ENV :cd cdist)
    (when (< cdist 400)
      (incf ENV.circle.x (* ENV.circle.s (math.cos cangle) (/ cdist 100) dt))
      (incf ENV.circle.y (* ENV.circle.s (math.sin cangle) (/ cdist 100) dt)))
    (tset ENV.arrow :a aangle)
    (when (> adist agap)
      (incf ENV.arrow.x (* ENV.arrow.s (math.cos aangle) dt))
      (incf ENV.arrow.y (* ENV.arrow.s (math.sin aangle) dt)))))

(fn load17 [] (set title "Animation")
  (tset ENV :anim0 {})
  (tset ENV :anim1 {})
  (tset ENV :anim2 {})
  (tset ENV :anim3 {})
  (tset ENV :frame 1)
  (tset ENV :image1 (love.graphics.newImage "src/howtolove/assets/jump.png"))
  (tset ENV :image2 (love.graphics.newImage "src/howtolove/assets/jump_2.png"))
  (tset ENV :image3 (love.graphics.newImage "src/howtolove/assets/jump_3.png"))
  (let [fw 117 fh 233
        w1 (ENV.image1:getWidth) h1 (ENV.image1:getHeight) 
        w2 (ENV.image2:getWidth) h2 (ENV.image2:getHeight)
        w3 (ENV.image3:getWidth) h3 (ENV.image3:getHeight)]
    (for [f 1 5 1]
      (table.insert ENV.anim0
        (love.graphics.newImage (.. "src/howtolove/assets/jump" f ".png")))
      (table.insert ENV.anim1
        (love.graphics.newQuad (* (- f 1) fw) 0 fw fh w1 h1))
      (let [j (% (- f 1) 3) i (math.floor (/ (- f 1) 3))]
        (print (.. j "," i))
        (table.insert ENV.anim2
          (love.graphics.newQuad (* j fw) (* i fh) fw fh w2 h2))
        (table.insert ENV.anim3
          (love.graphics.newQuad  (+ 1 (* j (+ fw 2))) 
                                  (+ 1 (* i (+ fh 2)))
                                  fw fh w3 h3))))))
(fn draw17 []
  (love.graphics.draw (. ENV.anim0 (math.floor ENV.frame)) 0 100)
  (love.graphics.draw ENV.image1 (. ENV.anim1 (math.floor ENV.frame)) 100 100)
  (love.graphics.draw ENV.image2 (. ENV.anim2 (math.floor ENV.frame)) 200 100)
  (love.graphics.draw ENV.image3 (. ENV.anim3 (math.floor ENV.frame)) 300 100))
(fn update17 [dt]
  (incf ENV.frame (* 10 dt))
  (when (clamp ENV.frame 1 5) (tset ENV :frame 1)))

(fn load18 [] (set title "Tiles")
  (tset ENV :tilemap [1 0 0 1 1 0 1 1 1 0])
  (tset ENV :tilemap2 [ [1 1 1 1 1 1 1 1 1 1]
                        [1 0 0 0 0 0 0 0 0 1]
                        [1 0 0 1 1 1 1 0 0 1]
                        [1 0 0 0 0 0 0 0 0 1]
                        [1 1 1 1 1 1 1 1 1 1] ])
  (tset ENV :tilemap3 [ [1 1 1 1 1 1 1 1 1 1]
                        [1 2 2 2 2 2 2 2 2 1]
                        [1 2 3 4 5 5 4 3 2 1]
                        [1 2 2 2 2 2 2 2 2 1]
                        [1 1 1 1 1 1 1 1 1 1] ])
  (tset ENV :tilemap4 [ [1 6 6 2 1 6 6 2]
                        [3 0 0 4 5 0 0 3]
                        [3 0 0 0 0 0 0 3]
                        [4 2 0 0 0 0 1 5]
                        [1 5 0 0 0 0 4 2]
                        [3 0 0 0 0 0 0 3]
                        [3 0 0 1 2 0 0 3]
                        [4 6 6 5 4 6 6 5] ])
  (tset ENV :colors [ [1 1 1] [1 0 0] [1 0 1] [0 0 1] [0 1 1] ])
  (tset ENV :image (love.graphics.newImage "src/howtolove/assets/tile.png"))
  (tset ENV :image2 (love.graphics.newImage "src/howtolove/assets/tileset.png"))
  (tset ENV :tw (ENV.image:getWidth))
  (tset ENV :th (ENV.image:getHeight))
  (tset ENV :iw (ENV.image2:getWidth))
  (tset ENV :ih (ENV.image2:getHeight))
  (tset ENV :w (- (/ ENV.iw 3) 2))
  (tset ENV :h (- (/ ENV.ih 2) 2))
  (tset ENV :pc { :image (love.graphics.newImage "src/howtolove/assets/player.png") 
                  :x 2 :y 2})
  (tset ENV :pressed? false)
  (tset ENV :quads {})
  (for [i 0 1]
    (for [j 0 2]
      (table.insert ENV.quads (love.graphics.newQuad 
        (+ 1 (* j (+ ENV.w 2))) (+ 1 (* i (+ ENV.h 2))) 
        ENV.w ENV.h ENV.iw ENV.ih)))))
(fn draw18 []
  (each [i v (ipairs ENV.tilemap)]
    (when (= v 1) (love.graphics.rectangle "line" (* i 25) 50 25 25)))
  (each [i row (ipairs ENV.tilemap2)]
    (each [j tile (ipairs row)]
      (when (= tile 1) 
        (love.graphics.rectangle "line" (* j 25) (+ 100 (* i 25)) 25 25))))
  (each [i row (ipairs ENV.tilemap3)]
    (each [j tile (ipairs row)]
      (when (~= tile 0)
        (love.graphics.setColor (. ENV.colors tile)) 
        (love.graphics.rectangle "fill" (* j 25) (+ 300 (* i 25)) 25 25)
        (love.graphics.draw ENV.image (+ (* j ENV.tw) 300) 
                                      (+ 300 (* i ENV.th))))))
  (love.graphics.setColor 1 1 1 1)
  (each [i row (ipairs ENV.tilemap4)]
    (each [j tile (ipairs row)]
      (when (~= tile 0) 
        (love.graphics.draw ENV.image2 (. ENV.quads tile) (+ 600 (* j ENV.w)) 
                                                          (+ 0 (* i ENV.h))))))
  (love.graphics.draw ENV.pc.image  (+ 600 (* ENV.pc.x ENV.w)) 
                                    (+ 0 (* ENV.pc.y ENV.h))))
(fn update18 [dt]
  (let [l (love.keyboard.isDown "left")
        r (love.keyboard.isDown "right")
        u (love.keyboard.isDown "up")
        d (love.keyboard.isDown "down")
        ox ENV.pc.x
        oy ENV.pc.y]
      (when (not ENV.pressed?)
        (when l (decf ENV.pc.x 1))
        (when r (incf ENV.pc.x 1))
        (when u (decf ENV.pc.y 1))
        (when d (incf ENV.pc.y 1)))
      (when (~= (. (. ENV.tilemap4 ENV.pc.y) ENV.pc.x) 0)
        (tset ENV.pc :x ox)
        (tset ENV.pc :y oy))
      (tset ENV :pressed? (or l r u d))))

(fn load19 [] (set title "Audio")
  (tset ENV :song (love.audio.newSource "src/howtolove/assets/song.ogg" "stream"))
  (ENV.song:setLooping true)
  (ENV.song:play)
  (tset ENV :sfx (love.audio.newSource "src/howtolove/assets/sfx.ogg" "static"))
  (tset ENV :pressed? false))
(fn update19 [dt]
  (when (and (not ENV.pressed?) (love.keyboard.isDown "space")) (ENV.sfx:play))
  (tset ENV :pressed? (love.keyboard.isDown "space")))

(fn load20 [] (set title "Debugging (TBD)"))

(fn load21 [] (set title "Saving and loading (press space to save, resets on no coins")
  (tset ENV :pc { :x 100 :y 100 :s 25 })
  (tset ENV :pcimage (love.graphics.newImage "src/howtolove/assets/face.png"))
  (tset ENV :coins {})
  (for [i 1 25]
    (table.insert ENV.coins 
      { :x (love.math.random 50 650) :y (love.math.random 50 450)}))
  (tset ENV :coinsize 10)
  (tset ENV :coinimage (love.graphics.newImage "src/howtolove/assets/dollar.png"))
  (tset ENV :checkCollision (fn [p1 p2 s1 s2]
    (let [d (math.sqrt (+ (^ (- p1.x p2.x) 2) (^ (- p1.y p2.y) 2)))
          s (+ s1 s2)]
        (< d s))))
  (tset ENV :lume (require "lib.lume"))
  (tset ENV :pressed? false)
  (when (love.filesystem.getInfo "savedata.txt")
    (tset ENV :data (ENV.lume.deserialize
      (love.filesystem.read "savedata.txt")))
    (tset ENV :pc ENV.data.pc)
    (tset ENV :coins ENV.data.coins)))
(fn draw21 [] 
  (love.graphics.setColor 0 0 0 1)
  (love.graphics.circle "fill" ENV.pc.x ENV.pc.y ENV.pc.s)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.circle "line" ENV.pc.x ENV.pc.y ENV.pc.s)
  (love.graphics.draw ENV.pcimage ENV.pc.x ENV.pc.y 0 1 1 
                      (/ (ENV.pcimage:getWidth) 2) 
                      (/ (ENV.pcimage:getHeight) 2))
  (each [i v (ipairs ENV.coins)]
    (love.graphics.setColor 0 0 0 1)
    (love.graphics.circle "fill" v.x v.y ENV.coinsize)
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.circle "line" v.x v.y ENV.coinsize)
    (love.graphics.draw ENV.coinimage v.x v.y 0 1 1
                        (/ (ENV.coinimage:getWidth) 2) 
                        (/ (ENV.coinimage:getHeight) 2))))
(fn update21 [dt]
  (when (love.keyboard.isDown "left") (decf ENV.pc.x (* 200 dt)))
  (when (love.keyboard.isDown "right") (incf ENV.pc.x (* 200 dt)))
  (when (love.keyboard.isDown "up") (decf ENV.pc.y (* 200 dt)))
  (when (love.keyboard.isDown "down") (incf ENV.pc.y (* 200 dt)))
  (for [i (length ENV.coins) 1 -1]
    (when (ENV.checkCollision ENV.pc (. ENV.coins i) ENV.pc.s ENV.coinsize)
        (table.remove ENV.coins i)
        (incf ENV.pc.s 1)))
  (when (and (not ENV.pressed?) (love.keyboard.isDown "space"))
    (love.filesystem.write "savedata.txt" 
      (ENV.lume.serialize {:pc ENV.pc :coins ENV.coins})))
  (tset ENV :pressed? (love.keyboard.isDown "space"))
  (when (= (length ENV.coins) 0) (love.filesystem.remove "savedata.txt")))

(fn load22 [] (set title "Camera and Canvases")
  (tset ENV :pc { :x 300 :y 100 :s 25 })
  (tset ENV :pcimage (love.graphics.newImage "src/howtolove/assets/face.png"))
  (tset ENV :coins {})
  (for [i 1 25]
    (table.insert ENV.coins 
      { :x (love.math.random 50 650) :y (love.math.random 50 450)}))
  (tset ENV :coinsize 10)
  (tset ENV :coinimage (love.graphics.newImage "src/howtolove/assets/dollar.png"))
  (tset ENV :checkCollision (fn [p1 p2 s1 s2]
    (let [d (math.sqrt (+ (^ (- p1.x p2.x) 2) (^ (- p1.y p2.y) 2)))
          s (+ s1 s2)]
        (< d s))))
  (tset ENV :score 0)
  (tset ENV :shake 0)
  (tset ENV :wait 0)
  (tset ENV :sox 0)
  (tset ENV :soy 0))
(fn draw22 [w h] 
  (love.graphics.push)
  (love.graphics.translate (- (/ w 2) ENV.pc.x) (- (/ h 2) ENV.pc.y))
  (when (> ENV.shake 0) (love.graphics.translate ENV.sox ENV.soy))
  (love.graphics.setColor 0 0 0 1)
  (love.graphics.circle "fill" ENV.pc.x ENV.pc.y ENV.pc.s)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.circle "line" ENV.pc.x ENV.pc.y ENV.pc.s)
  (love.graphics.draw ENV.pcimage ENV.pc.x ENV.pc.y 0 1 1 
                      (/ (ENV.pcimage:getWidth) 2) 
                      (/ (ENV.pcimage:getHeight) 2))
  (each [i v (ipairs ENV.coins)]
    (love.graphics.setColor 0 0 0 1)
    (love.graphics.circle "fill" v.x v.y ENV.coinsize)
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.circle "line" v.x v.y ENV.coinsize)
    (love.graphics.draw ENV.coinimage v.x v.y 0 1 1
                        (/ (ENV.coinimage:getWidth) 2) 
                        (/ (ENV.coinimage:getHeight) 2)))
  (love.graphics.pop)
  (love.graphics.print ENV.score 10 10))
(fn update22 [dt] 
  (let [oldcoins (length ENV.coins)]
    (when (> ENV.shake 0)
      (decf ENV.shake dt)
      (if (> ENV.wait 0)
        (decf ENV.wait dt)
        (do
          (tset ENV :sox (love.math.random -5 5))
          (tset ENV :soy (love.math.random -5 5))
          (tset ENV :wait 0.05))))
    (when (love.keyboard.isDown "left") (decf ENV.pc.x (* 200 dt)))
    (when (love.keyboard.isDown "right") (incf ENV.pc.x (* 200 dt)))
    (when (love.keyboard.isDown "up") (decf ENV.pc.y (* 200 dt)))
    (when (love.keyboard.isDown "down") (incf ENV.pc.y (* 200 dt)))
    (for [i (length ENV.coins) 1 -1]
      (when (ENV.checkCollision ENV.pc (. ENV.coins i) ENV.pc.s ENV.coinsize)
          (table.remove ENV.coins i)
          (incf ENV.pc.s 1)))
    (when (~= oldcoins (length ENV.coins))
      (incf ENV.score (- oldcoins (length ENV.coins)))
      (tset ENV :shake 0.3))))

(fn load []
  (when ENV.song (ENV.song:stop))
  (when ENV.sfx (ENV.sfx:stop))
  (set ENV {})
  (case chapter
      1 (load1)
      2 (load2)
      3 (load3)
      4 (load4)
      5 (load5)
      6 (load6)
      7 (load7)
      8 (load8)
      9 (load9)
      10 (load10)
      11 (load11)
      12 (load12)
      13 (load13)
      14 (load14)
      15 (load15)
      16 (load16)
      17 (load17)
      18 (load18)
      19 (load19)
      20 (load20)
      21 (load21)
      22 (load22)))
(fn draw [self w h] (fn []
  (let [fh (: (love.graphics.getFont) :getHeight)]
    (love.graphics.clear 0.1 0.1 0.1 1)
    (love.graphics.setColor 0.9 0.9 0.9 1)
    (love.graphics.printf (.. header "\n" title) 0 0 w :center)
    (love.graphics.printf (: navi :format chapter) 0 (- h fh) w :center)
    (case chapter
      4 (draw4 w h)
      5 (draw5 w h)
      6 (draw6 w h)
      7 (draw7 w h)
      8 (draw8 w h)
      10 (draw10 w h)
      11 (draw11 w h)
      12 (draw12 w h)
      13 (draw13 w h)
      14 (draw14 w h)
      16 (draw16 w h)
      17 (draw17 w h)
      18 (draw18 w h)
      21 (draw21 w h)
      22 (draw22 w h)))))
(fn update [self dt w h]
  (case chapter
    5 (update5 dt)
    6 (update6 dt)
    8 (update8 dt)
    10 (update10 dt)
    11 (update11 dt)
    13 (update13 dt)
    14 (update14 dt w h)
    16 (update16 dt)
    17 (update17 dt)
    18 (update18 dt)
    19 (update19 dt)
    21 (update21 dt)
    22 (update22 dt)))
(fn keypressed [self key]
  (local old chapter)
  (match key
    :lalt (do (decf chapter 1) (clamp chapter 1 24))
    :ralt (do (incf chapter 1) (clamp chapter 1 24)))
  (when (~= old chapter) (load)))

;; FIXME break each chapter into its own cartridge
(tset Book :new (fn [self w h old]
  (self.super.new self) ;; discard old state
  (tset self :draw draw)
  (tset self :update update)
  (tset self :keypressed keypressed)
  (load)
  self))
Book
