(import-macros {: flip} :mac.bool)
(local MAT (require :src._.cls.MAT))

;; TODO how to make this junk a special case of WIN?
(var (w h) (values nil nil))
(var transform nil)
(var full? false)
(fn resize []
  (let [(sw sh) (love.window.getMode)
        width   (if (or (not _G.web?) full?) sw w)
        height  (if (or (not _G.web?) full?) sh h)
        s       (math.min (/ width w) (/ height h))
        mx      (/ (- sw (* s w)) 2)
        my      (/ (- sh (* s h)) 2)]
    (transform:setTransformation mx my 0 s s 0 0 0 0)))
(fn fullscreen [] ;; TODO clean up nasty table def
  (if (not _G.web?)
      (love.window.setFullscreen (flip full?) :desktop)
      (let [(sw sh)       (love.window.getMode)
            width         (if full? w sw)
            height        (if full? h sh)]
        (love.window.updateMode width height {
                                :fullscreen (flip full?)
                                :fullscreentype :exclusive
                                :minwidth width 
                                :minheight height})))
  (resize))

;; TODO good for now... breakdown???
(local CAB (require :src._.cls.CAB)) 
(local WIN (require :src._.cls.WIN))
(var win nil)
(fn love.load [args]
  (let [(ww wh) (love.window.getMode)] (set w ww) (set h wh))
  ;; TODO depends on res
  (local font (love.graphics.newFont 12 :mono))
  (font:setFilter :nearest :nearest)
  (love.graphics.setFont font)
  ;; TODO globals?
  (set _G.font font)
  (set _G.web? (= :web (. args 1)))
  (let [file    :conf.fnl
        info    (love.filesystem.getInfo file)
        title   (if info ((love.filesystem.lines file)) :_)
        format  "%s"
        name    (format:format (title:lower))
        (ww wh) (love.window.getMode)
        s       (/ (math.min ww wh) 2)]
    (love.window.setTitle title)
    (set transform (MAT ww wh 0 0 ww wh))
    (set win
      (WIN ww wh "parent" s s
        (WIN s s "child" (/ s 2) (/ s 2)
          (CAB (/ s 2) (/ s 2) name (/ s 2) (/ s 2) nil))))
  )
  (each [e _ (pairs love.handlers)]
    (tset love.handlers e #(win:event e $...))))
(fn love.draw [] (win:draw transform.t))
(fn love.update [dt] (win:update dt))
