(import-macros {: incf : decf : clamp} :macros.math)
(local title "sheepolution how to love")
(local navi "<-- \t \t chapter %d \t \t -->")
(var chapter 1)

(fn draw1 [w h] (love.graphics.printf "Installation" 0 (/ h 2) w :center))
(fn init1 [] (print 123))

(fn draw2 [w h] (love.graphics.printf "Variables" 0 (/ h 2) w :center))
(fn init2 [] 
  (print (+ 3 4))
  (let [a 5 b 3] (print (+ a b)))
  (let [sheep 3 test 20 PANTS 1040 asdfghjkl 42] nil)
  (let [sheep 3 SHEEP 10 sHeEp 200] nil)
  (let [a (- 20 10) b (* 20 10) c (/ 20 10) d (^ 20 10)] nil)
  (let [a 10.4 b 2.63 c 0.1 pi 3.141592] nil)
  (let [X 5 Y 3 Z (+ X Y) X 2 Y 40] (print Z))
  (let [text "Hello World!"] nil)
  (let [name "Daniel" 
        age 25
        text (.. "Hello, my name is " name ", and I'm " age " years old.")]
      (print text))
  ;; test8 te8st -- Good
  ;; 8test -- Bad, error!
  ;; and      break   do    else      elseif
  ;; end      false   for   function  if
  ;; in       local   nil   not       or
  ;; repeat   return  then  true      until   while
  ;; -- keywords, don't overload ever
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

(fn init [] 
  (case chapter
      1 (init1)
      2 (init2)
      3 (init3)))

(fn draw [w h] (fn []
  (let [fh (: (love.graphics.getFont) :getHeight)]
    (love.graphics.clear 0.22 0.22 0.22 1)
    (love.graphics.setColor 1 1 1 1)
    (case chapter
      1 (draw1 w h)
      2 (draw2 w h)
      3 (draw3 w h))
    (love.graphics.printf title 0 0 w :center)
    (love.graphics.printf (: navi :format chapter) 0 (- h fh) w :center))))

(fn update [dt])

(fn keypressed [key]
  (match key
    :left (do (decf chapter 1) (clamp chapter 1 24))
    :right (do (incf chapter 1) (clamp chapter 2 24)))
  (init))

{: init : draw : update : keypressed}
