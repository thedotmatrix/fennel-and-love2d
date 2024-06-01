local x,y = nil,nil
local mx,my = nil,nil
local plate = nil
local record = nil
record = nil
local logo = nil
local t = nil
local title = nil
local track,data = nil,nil
local drawn,graphed = nil,nil
local specrate,insrate,samrate = nil,nil,nil
local spectrum,instant = nil,nil
local canvas = nil

function load(w, h)
	x,y=w,h
	mx,my = x*0.2,y*0.2
	plate = {x=x*9/13,y=y/2,r=y*10/22,r1=y*9/22,r2=y*8/22,r3=y*7/22,r4=y*6/22,r5=y*4/22,r6=y*3.75/22,a=0}
	record = {s=y/11*10.5}
	record = {s=record.s,x=x*4/13-record.s/2,y=y/2-record.s/2,w=record.s,h=record.s}
	logo = {a=15}
	t = 0
	title = {}
	track,data = nil,nil
	drawn,graphed = false,false
	specrate,insrate,samrate = 8,4096,nil
	spectrum,instant = {},nil
	canvas = love.graphics.newCanvas(w,h)
	font = love.graphics.newFont(32)
	title.main = love.graphics.newText(font,"[SH01] - Brothers & Sisters")
	font = love.graphics.newFont(16)
	title.l1 = love.graphics.newText(font, "Brothers")
	title.l2 = love.graphics.newText(font, "Sisters")
	font = love.graphics.newFont(24)
	title.l3 = love.graphics.newText(font, "&")
	track = love.audio.newSource("src/sweetheat/assets/brothers_and_sisters_FINAL.mp3", "stream")
end

function update(dt) 
	if (drawn and data~=nil and graphed) then
		t = t + dt
		plate.a=360*(t/60*45)
	else 
		if drawn then
			if data~=nil then
				samrate = data:getSampleRate()/insrate
				for i=1,data:getSampleCount(),samrate do
					local left,right = data:getSample(i,1),data:getSample(i,2)
					table.insert(spectrum,{l=left,r=right})
					graphed=true
				end
				graphed = true
				track:play()
				t=0
			else
				data = love.sound.newSoundData("src/sweetheat/assets/brothers_and_sisters_FINAL.mp3")
			end
		else
			drawn = true
		end
	end
end

function draw(w, h, supercanvas)
	love.graphics.setCanvas({canvas, stencil=true})
	love.graphics.clear(0.12,0.13,0.15)

	love.graphics.translate(plate.x, plate.y)
	logo.w=plate.r*1/2
	logo.h=plate.r*1/4
	logo.x=-logo.w*0.1
	logo.y=-logo.h*0.08
	love.graphics.rotate(math.rad(plate.a))
	drawplate()
	drawlabel()
	logo.colora = {0.2,0.1,0.4,1}
	logo.colorb = {0.2,0.1,0.4,1}
	logo.ink = 0.5
	logo.margin = 2
	logostencil()
	love.graphics.stencil(logostencil,"increment")
	love.graphics.setStencilTest("less",1)
	logo.colora = {0,0,0,1}
	logo.colorb = {0,0,0,1}
	logo.margin = 0
	logostencil()
	love.graphics.setStencilTest()
	love.graphics.setColor(1,1,1,1)
	love.graphics.origin()

	love.graphics.translate(record.x,record.y)
	drawrecord()
	local jitter = 0
	if graphed then jitter = drawspectrum() end
	logo.x=record.w*.475+jitter/2
	logo.y=record.h/5+jitter/2
	logo.w=record.w*2/3+jitter
	logo.h=record.h*1/3+jitter
	love.graphics.setColor(0.33,0.22,0.11,1)
	love.graphics.draw(title.main,record.w/2-title.main:getWidth()/2+jitter/4,record.h*.4+jitter/4)
	love.graphics.shear(math.cos(math.rad(270-logo.a+0.1*jitter)),math.sin(math.rad(0.01*jitter)))
	logo.colora = {1.00,0.75,0.50,1}
	logo.colorb = {0.88,0.44,0.22,1}
	logo.ink = 1
	logo.margin = 8
	logostencil()
	love.graphics.stencil(logostencil,"increment")
	love.graphics.setStencilTest("less",1)
	logo.colora = {0.75,0.50,0.25,1}
	logo.colorb = {0.44,0.22,0.11,1}
	logo.margin = 0
	logostencil()
	love.graphics.setStencilTest()
	love.graphics.setColor(1,1,1,1)
	love.graphics.origin()
	love.graphics.setCanvas(supercanvas)
	love.graphics.draw(canvas)
end

function drawplate()
	plate.color={0,0,0,1}
	love.graphics.setColor(plate.color)
	love.graphics.circle("fill",0,0,plate.r+plate.r/100)
	plate.color={0.05,0.01,0.05,1}
	love.graphics.setColor(plate.color)
	love.graphics.circle("fill",0,0,plate.r)
	plate.color={0.04,0.01,0.05,1}
	love.graphics.setColor(plate.color)
	love.graphics.circle("fill",0,0,plate.r1)
	plate.color={0.04,0.01,0.04,1}
	love.graphics.setColor(plate.color)
	love.graphics.circle("fill",0,0,plate.r2)
	plate.color={0.03,0.01,0.04,1}
	love.graphics.setColor(plate.color)
	love.graphics.circle("fill",0,0,plate.r3)
	plate.color={0.03,0.01,0.03,1}
	love.graphics.setColor(plate.color)
	love.graphics.circle("fill",0,0,plate.r4)
	plate.color={0.88,0.77,0.99}
	love.graphics.setColor(plate.color)
	love.graphics.circle("fill",0,0,plate.r5)
	plate.color={0.08,0.04,0.16,1}
	love.graphics.setColor(plate.color)
	love.graphics.circle("fill",0,0,plate.r6)
	plate.color={0,0,0,1}
	love.graphics.setColor(plate.color)
	love.graphics.circle("fill",0,0,plate.r/50)
end
function drawrecord()
	love.graphics.setColor(0.88,0.99,0.88)
	love.graphics.rectangle("fill",0,0,record.w,record.h)
end
function drawlabel()
	love.graphics.setColor(0.88,0.99,0.88)
	love.graphics.draw(title.l1,title.l1:getWidth()/-2,title.l1:getHeight()*1.25)
	love.graphics.draw(title.l3,title.l3:getWidth()/-2,title.l3:getHeight()*1.5)
	love.graphics.rotate(math.rad(180))
	love.graphics.setColor(0.88,0.99,0.88)
	love.graphics.draw(title.l2,title.l2:getWidth()/-2,title.l2:getHeight()*1.25)
	love.graphics.draw(title.l3,title.l3:getWidth()/-2,title.l3:getHeight()*1.5)
	love.graphics.rotate(math.rad(180))
end
function drawspectrum()
	local linel,liner = {},{}
	local position = track:tell("samples")
	local a = 0.5
	local zoom = 16
	local jitter = 0
	for i=math.floor(position/samrate)+1,math.floor(position/samrate)+1+insrate/zoom,1 do
		table.insert(linel,(i-math.floor(position/samrate)-1)/insrate*record.w*zoom)
		table.insert(linel,record.h/2+title.main:getHeight()*1.5+spectrum[i].l*title.main:getHeight()*2)
		table.insert(liner,(i-math.floor(position/samrate)-1)/insrate*record.w*zoom)
		table.insert(liner,record.h/2+title.main:getHeight()*1.5+spectrum[i].r*title.main:getHeight()*2)
		jitter = jitter + (spectrum[i].l + spectrum[i].r)
	end
	love.graphics.setColor(0.22,0.11,0.33,a)
	love.graphics.line(linel)
	love.graphics.setColor(0.33,0.11,0.22,a)
	love.graphics.line(liner)
	a = 0.33
	for i=1,#spectrum,insrate/specrate do
		if (i>position/samrate) then a = 0.1 end
		love.graphics.setColor(0.22,0.11,0.33,a)
		love.graphics.line(i*record.w/#spectrum+2,record.h/2+title.main:getHeight()*4.2+jitter/16,i*record.w/#spectrum+2,record.h/2+title.main:getHeight()*4.2+spectrum[i].l*title.main:getHeight()+jitter/16)
		love.graphics.setColor(0.33,0.11,0.22,a)
		love.graphics.line(i*record.w/#spectrum+2,record.h/2+title.main:getHeight()*4.2+jitter/16,i*record.w/#spectrum+2,record.h/2+title.main:getHeight()*4.2+spectrum[i].r*title.main:getHeight()+jitter/16)
	end
	return math.max(math.min(1,jitter),-1)
end
function logostencil() drawlogo(logo.x-logo.w*2/5,logo.y-logo.h/2,logo.w,logo.h) end
function drawlogo(x,y,w,h)
	-- s1 w2 e3 e4 t5
	love.graphics.setColor(logo.colora)
	s0(x+w*0/5,y+h*0/2,w/5,h/2)
	w0(x+w*1/5,y+h*0/2,w/5,h/2)
	e0(x+w*2/5,y+h*0/2,w/5,h/2)
	e0(x+w*3/5,y+h*0/2,w/5,h/2)
	t0(x+w*4/5,y+h*0/2,w/5,h/2)
	-- h1 e2 e3 t4
	love.graphics.setColor(logo.colorb)
	h0(x+w*1/5,y+h*1/2,w/5,h/2)
	e0(x+w*2/5,y+h*1/2,w/5,h/2)
	a0(x+w*3/5,y+h*1/2,w/5,h/2)
	t0(x+w*4/5,y+h*1/2,w/5,h/2)
end

function s0(x,y,w,h) 
	s1(x,y+h*0/3,w,h*2/3)
	s2(x,y+h*1/3,w,h*2/3)
	s3(x,y+h*2/3,w,h*2/3)
end
function s1(x,y,w,h) 
	stroke(x,y,w,h/2)
	stroke(x,y,w/2,h)
end
function s2(x,y,w,h) 
	stroke(x,y,w,h/2)
	stroke(x+w/2,y,w/2,h)
end
function s3(x,y,w,h) 
	stroke(x,y,w,h/2)
end

function w0(x,y,w,h)
	w1(x+w*0/3,y+h*1/3,w*2/3,h*2/3)
	w2(x+w*1/3,y+h*1/3,w*2/3,h*2/3)
	w3(x+w*2/3,y+h*1/3,w*2/3,h*2/3)
end
function w1(x,y,w,h)
	stroke(x,y,w/2,h)
	stroke(x,y+h/2,w,h/2)
end
function w2(x,y,w,h)
	stroke(x,y+h/2,w,h/2)
	stroke(x,y,w/2,h)
	stroke(x-w/2,y+h/2,w,h/2)
end
function w3(x,y,w,h)
	stroke(x-w/2,y+h/2,w,h/2)
	stroke(x,y,w/2,h)
end

function e0(x,y,w,h)
	e1(x,y+h*2/6,w,h*1/3)
	e2(x,y+h*3/6,w,h*1/3)
	e3(x,y+h*4/6,w,h*1/3)
end
function e1(x,y,w,h)
	stroke(x,y,w,h/2)
	stroke(x,y,w*1/3,h)
	stroke(x+w*2/3,y,w/3,h)
end
function e2(x,y,w,h)
	stroke(x,y,w,h/2)
	stroke(x,y,w*1/3,h)
end
function e3(x,y,w,h)
	stroke(x,y,w,h)
end

function t0(x,y,w,h)
	t1(x+w*1/4,y+h*1/3,w*1/2,h*2/3)
	t2(x,y+h*1/3,w,h*1/3)
end
function t1(x,y,w,h)
	stroke(x,y,w,h)
end
function t2(x,y,w,h)
	stroke(x,y,w,h)
end

function h0(x,y,w,h)
	h1(x,y+h*0/3,w,h*2/3)
	h2(x,y+h*1/3,w,h*2/3)
	h3(x,y+h*2/3,w,h*2/3)
end
function h1(x,y,w,h) 
	stroke(x,y,w/2,h)
	stroke(x+w/2,y,w/2,h)
end
function h2(x,y,w,h) 
	stroke(x,y,w/2,h)
	stroke(x,y,w,h/2)
	stroke(x+w/2,y,w/2,h)
end
function h3(x,y,w,h) 
	stroke(x,y,w/2,h/2)
	stroke(x+w/2,y,w/2,h/2)
end

function a0(x,y,w,h)
	a1(x,y+h*2/6,w,h*1/3)
	a2(x,y+h*3/6,w,h*1/3)
	a3(x,y+h*4/6,w,h*1/3)
end
function a1(x,y,w,h)
	stroke(x,y,w,h/2)
	stroke(x,y,w*1/3,h)
	stroke(x+w*2/3,y,w/3,h)
end
function a2(x,y,w,h)
	stroke(x,y,w,h/2)
	stroke(x,y,w*1/3,h)
	stroke(x+w*2/3,y,w/3,h)
end
function a3(x,y,w,h)
	stroke(x,y,w/3,h)
	stroke(x+w*2/3,y,w/3,h)
end

function stroke(x,y,w,h)
	love.graphics.rectangle("fill",x+logo.margin/2,y+logo.margin/2,w-logo.margin,h-logo.margin,logo.ink*2,logo.ink*2)
end

return {load=load, draw=draw, update=update}
