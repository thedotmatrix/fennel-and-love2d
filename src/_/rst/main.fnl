(import-macros {: flip} :mac.bool)
(local BOX (require :src._.cls.BOX))
(local CAB (require :src._.cls.CAB))
(local RST (require :src._.cls.RST))
(local Main (RST:extend))

;; TODO live.ram/cab anti-pattern?
(fn Main.load [!]
  (local b (BOX nil 0 0 (love.window.getMode)))
  ;TODO no box here put in pane
  (local w {:live {:ram {:inner b :depth -1 :subs []}}})
  (set !.win (CAB :_ :pane w :main 0 0 1 1))
  (set !.win.live.ram.outer.repose  Main.move)
  (set !.win.live.ram.outer.restore Main.full)
  (set !.win.live.ram.outer.reshape #nil)
  (let [info (love.filesystem.getInfo :conf.fnl)
        conf (if info ((love.filesystem.lines :conf.fnl)) :__)
        name (conf:lower)]
    (local dp   (CAB :_ :pane !.win :dev 0 0 0.5 1))
    (local gp   (CAB :_ :pane !.win :game 1 1 0.5 1))
    (local dev  (CAB :_ :repl))
    (local game (CAB name :main))
    (table.insert dp.live.ram.subs dev)
    (table.insert gp.live.ram.subs game)
    ))

(fn Main.draw [!]
  (love.graphics.applyTransform !.win.live.ram.outer.parent.t)
  (!.win:draw !.win.live.ram.inner.aw !.win.live.ram.inner.ah)
  (when (and !.mx !.my)
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
