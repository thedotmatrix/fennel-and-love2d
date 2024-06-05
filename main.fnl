(import-macros {: flip} :mac.bool)

;; TODO how to make this junk a special case of WIN?
(var (w h) (values nil nil))
(local transform (love.math.newTransform))
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
    (set win (WIN name ww wh s s)))
  (each [e _ (pairs love.handlers)]
    (tset love.handlers e #(win:event e $...))))
(fn love.draw [] (win:draw transform))
(fn love.update [dt] (win:update dt))
