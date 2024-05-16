(import-macros {: incf : decf : clamp} :macros.math)
(local header "sheepolution how to love")
(local navi "<---left-shift--- \t \t chapter %d \t \t ---right-shift--->")
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

(fn load [] 
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
      9 (load9)))
(fn draw [w h] (fn []
  (let [fh (: (love.graphics.getFont) :getHeight)]
    (love.graphics.clear 0.1 0.1 0.1 1)
    (love.graphics.setColor 0.9 0.9 0.9 1)
    (love.graphics.printf header 0 0 w :center)
    (love.graphics.printf title 0 (/ h 2) w :center)
    (case chapter
      4 (draw4 w h)
      5 (draw5 w h)
      6 (draw6 w h)
      7 (draw7 w h)
      8 (draw8 w h))
    (love.graphics.printf (: navi :format chapter) 0 (- h fh) w :center))))
(fn update [dt w h]
  (case chapter
    5 (update5 dt)
    6 (update6 dt)
    8 (update8 dt)))
(fn keypressed [key]
  (local old chapter)
  (match key
    :lshift (do (decf chapter 1) (clamp chapter 1 24))
    :rshift (do (incf chapter 1) (clamp chapter 2 24)))
  (when (~= old chapter) (load)))
{: load : draw : update : keypressed}
