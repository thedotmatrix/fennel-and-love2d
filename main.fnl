(local CAB (require :src._.cls.CAB))
(var main nil)

(fn love.load [args] 
  (set _G.web? (= :web (. args 1)))
  ;; TODO resolution, filtering, font, for style + performance
  (love.graphics.setFont (love.graphics.newFont 24 :mono))
  (set main (CAB :_ :main))
  (each [e _ (pairs love.handlers)]
    (tset love.handlers e #(main:event e $...))))

(fn love.draw [] (main:draw))

(fn love.update [dt] (main:update dt))
