(import-macros {: flip} :mac.bool)
(local BOX (require :src._.cls.BOX))
(local CAB (require :src._.cls.CAB))
(local RST (require :src._.cls.RST))
(local WIN (require :src._.cls.WIN))
(local Main (RST:extend))

(fn Main.load [!]
  (local w (BOX nil 0 0 (love.window.getMode)))
  (set !.win (WIN {:inner w :depth -1 :subs []} :main 1 1))
  (set !.win.outer.repose  Main.move)
  (set !.win.outer.restore Main.full)
  (set !.win.outer.reshape #nil)
  (let [info  (love.filesystem.getInfo :conf.fnl)
        conf (if info ((love.filesystem.lines :conf.fnl)) :__)
        name  (conf:lower)]
    (local parent     (WIN !.win :parent 0.75 1))
    (local child      (WIN parent :child 0.75 1))
    (local grandchild (CAB child name))))

(fn Main.draw [! canvas] 
  (love.graphics.applyTransform !.win.outer.parent.t)
  (!.win:draw) (when (and !.mx !.my) 
    (love.graphics.circle :line !.mx !.my 4)))

(fn Main.move [! dx dy ...] (when (and dx dy)
  (let [(wx wy) (love.window.getPosition)]
    (love.window.setPosition (+ wx dx) (+ wy dy)))))

(fn Main.full [! ...]
  (local opt #{ :fullscreen (flip !.fs?) 
                :fullscreentype :exclusive
                :minwidth $1 :minheight $2})
  (if (not _G.web?)
    (love.window.setFullscreen (flip !.fs?) :desktop)
    (let [(sw sh) (love.window.getMode)
          [w h]   [!.parent.ow !.parent.oh]
          [nw nh] [(if !.fs? w sw) (if !.fs? h sh)]]
      (love.window.updateMode nw nh (opt nw nh))))
  (!.parent:restore (love.window.getMode)))

Main
