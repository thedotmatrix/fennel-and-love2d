(local fennel (require :lib.fennel))
(local traceback fennel.traceback)
(local Object (require :lib.classic))
(local CRT (Object:extend))
(local ST8 (require :src._.cls.ST8))

(fn CRT.unsafe [! errormessage errortrace]
  (set !.live.ram.errormessage errormessage)
  (set !.live.ram.errortrace errortrace)
  (set !.callback (!.live:reload !.safe))
  ((!.live:load :_) :error))

;; TODO this should be wrapping all the stuff above
(fn CRT.safely [! f ...]
  (when (and f (xpcall f #(!:unsafe $ (traceback)) ...))
        (when (or (~= !.live.game :_) (~= !.live.mode :error))
              (do ((!.safe:reload !.live))
                  (set !.callback (!.live:load))))))

(fn CRT.new [! game mode]
  (set !.live (ST8)) (set !.safe (ST8))
  (!:safely (!.live:load game) mode))

(fn CRT.draw [! canvas] (!:safely 
  !.live.rst.draw !.live.ram canvas))

(fn CRT.update [! dt] (!:safely 
  !.live.rom.update !.callback !.live.ram dt))

(fn CRT.event [! e ...] (!:safely 
  (. !.live.rom e) !.callback !.live.ram ...))

CRT
