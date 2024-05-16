(import-macros {: incf : decf : clamp} :macros.math)
(local title "sheepolution how to love")
(local navi "<---left-shift--- \t \t chapter %d \t \t ---right-shift--->")
(var chapter 1)
(var ENV {})

(fn draw1 [w h] (love.graphics.printf "Installation" 0 (/ h 2) w :center))
(fn init1 [] (print 123))

(fn draw2 [w h] (love.graphics.printf "Variables" 0 (/ h 2) w :center))
(fn init2 [] 
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

(fn draw3 [w h] (love.graphics.printf "Functions" 0 (/ h 2) w :center))
(fn init3 [] 
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

(fn draw4 [w h]
  (love.graphics.printf "What is LÖVE" 0 (/ h 2) w :center)
  (love.graphics.circle "fill" 10 10 100 25)
  (love.graphics.rectangle "line" 200 30 120 100)
  (love.graphics.rectangle "fill" 100 200 50 80))
(fn init4 [] (let [test (fn [a b] (+ a b))] (test 10 20)))

(fn draw5 [w h]
  (love.graphics.printf "Moving a rectangle" 0 (/ h 2) w :center)
  (love.graphics.rectangle "line" ENV.x 50 200 150))
(fn init5 [] (tset ENV :x 100))
(fn update5 [dt] (incf ENV.x (* 5 dt)) (print ENV.x))

(fn draw6 [w h]
  (love.graphics.printf "If Statements" 0 (/ h 2) w :center)
  (love.graphics.rectangle "line" ENV.x ENV.y 200 150))
(fn init6 [] 
  (tset ENV :x 100)
  (tset ENV :y 50)
  (if (and (< 5 9) (> 14 7)) (print "Both statements are true"))
  (if (or (< 20 9) (> 14 7) (= 5 10)) (print "One of these statements is true"))
  (if true (print 1))
  (if false (print 2))
  (if nil (print 3))
  (if 5 (print 4))
  (if "hello" (print 5)))
(fn update6 [dt] 
  (if (love.keyboard.isDown "left") (decf ENV.x (* 100 dt)))
  (if (love.keyboard.isDown "right") (incf ENV.x (* 100 dt)))
  (if (love.keyboard.isDown "up") (decf ENV.y (* 50 dt)))
  (if (love.keyboard.isDown "down") (incf ENV.y (* 50 dt)))
  (print (.. "( \t" ENV.x "\t , \t" ENV.y "\t )")))

(fn init [] 
  (set ENV {})
  (case chapter
      1 (init1)
      2 (init2)
      3 (init3)
      4 (init4)
      5 (init5)
      6 (init6)))

(fn draw [w h] (fn []
  (let [fh (: (love.graphics.getFont) :getHeight)]
    (love.graphics.clear 0.1 0.1 0.1 1)
    (love.graphics.setColor 0.9 0.9 0.9 1)
    (case chapter
      1 (draw1 w h)
      2 (draw2 w h)
      3 (draw3 w h)
      4 (draw4 w h)
      5 (draw5 w h)
      6 (draw6 w h))
    (love.graphics.printf title 0 0 w :center)
    (love.graphics.printf (: navi :format chapter) 0 (- h fh) w :center))))

(fn update [dt w h]
  (case chapter
    5 (update5 dt)
    6 (update6 dt)))

(fn keypressed [key]
  (local old chapter)
  (match key
    :lshift (do (decf chapter 1) (clamp chapter 1 24))
    :rshift (do (incf chapter 1) (clamp chapter 2 24)))
  (when (~= old chapter) (init)))

{: init : draw : update : keypressed}
