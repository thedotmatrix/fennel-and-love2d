(local Object (require :lib.classic))
(local ST8 (Object:extend))
(local RAM (require :src._.cls.RAM))
(local ROM (require :src._.cls.ROM))
(local RST (require :src._.cls.RST))

(fn ST8.new [self]
  (set self.ram (RAM))
  (set self.rom (ROM:extend))
  (set self.rst (RST:extend)))

(fn ST8.load [self game] (when game (set self.game game))
  (fn [mode]
    (let [f1 (.. "src%s" self.game "%srom%s" mode "%s")
          rompath (f1:format :/ :/ :/ :.fnl)
          rominfo (love.filesystem.getInfo rompath)
          romreq  #(require (f1:format :. :. :. ""))
          newrom  #(ROM.mix (romreq) self.rom self.ram)
          f2 (.. "src%s" self.game "%srst%s" mode "%s")
          rstpath (f2:format :/ :/ :/ :.fnl)
          rstinfo (love.filesystem.getInfo rstpath)
          rstreq  #(require (f2:format :. :. :. ""))
          newrst  #(RST.mix (rstreq) self.rst)]
      (set self.mode mode)
      (when rominfo (set self.rom (newrom)))
      (when rstinfo (set self.rst (newrst))))))

(fn ST8.reload [self other] (fn []
  (set self.game    other.game)
  (set self.mode    other.mode)
  (set self.ram     (RAM other.ram))
  (set self.rom     (ROM.mix other.rom self.rom))
  (set self.rst     (RST.mix other.rst self.rst))))

ST8
