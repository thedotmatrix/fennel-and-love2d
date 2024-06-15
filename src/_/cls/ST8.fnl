(local Object (require :lib.classic))
(local ST8 (Object:extend))
(local RAM (require :src._.cls.RAM))
(local ROM (require :src._.cls.ROM))
(local RST (require :src._.cls.RST))

(fn ST8.new [!]
  (set !.ram (RAM))
  (set !.rom (ROM:extend))
  (set !.rst (RST:extend)))

(fn ST8.load [! game] (when game (set !.game game))
  (fn [mode]
    (let [f1 (.. "src%s" !.game "%srom%s" mode "%s")
          rompath (f1:format :/ :/ :/ :.fnl)
          rominfo (love.filesystem.getInfo rompath)
          romreq  #(require (f1:format :. :. :. ""))
          newrom  #(ROM.mix (romreq) !.rom)
          f2 (.. "src%s" !.game "%srst%s" mode "%s")
          rstpath (f2:format :/ :/ :/ :.fnl)
          rstinfo (love.filesystem.getInfo rstpath)
          rstreq  #(require (f2:format :. :. :. ""))
          newrst  #(RST.mix (rstreq) !.rst !.ram mode)]
      (set !.mode mode)
      (when rominfo (set !.rom (newrom)))
      (when rstinfo (set !.rst (newrst))))))

(fn ST8.reload [! other] (fn []
  (set !.game    other.game)
  (set !.mode    other.mode)
  (set !.ram     (RAM other.ram))
  (set !.rom     (ROM.mix other.rom !.rom))
  (set !.rst     (RST.mix other.rst !.rst))))

ST8
