(local fennel (require :lib.fennel))
(local traceback fennel.traceback)
(local Object (require :lib.classic))
(local CAB (Object:extend))
(local ST8 (require :src._.cls.ST8))

(fn CAB.unsafe [! errormessage errortrace]
  (set !.live.ram.errormessage errormessage)
  (set !.live.ram.errortrace errortrace)
  (set !.callback (!.live:reload !.safe))
  ((!.live:load :_) :error))

(fn CAB.safely [! f ...]
  (when (and f (xpcall f #(!:unsafe $ (traceback)) ...))
        (when (or (~= !.live.game :_) (~= !.live.mode :error))
              (do ((!.safe:reload !.live))
                  (set !.callback (!.live:load))))))

(fn CAB.new [! game mode ...]
  (set !.live (ST8)) (set !.safe (ST8))
  (!:safely (!.live:load game) mode ! ...))

(fn CAB.draw [! w h] (!:safely
  !.live.rst.draw !.live.ram w h))

(fn CAB.update [! dt] (!:safely
  !.live.rom.update !.callback !.live.ram dt))

(fn CAB.event [! e ...] (if !.live.rom.event (!:safely 
  !.live.rom.event !.callback !.live.ram !.live.rom e ...)
  (!:safely (. !.live.rom e) !.callback !.live.ram ...)))

CAB
