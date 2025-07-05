local pd <const> = playdate
local gfx <const> = pd.graphics

class('Explosion').extends(gfx.sprite)

local scaleTimer = nil 
local circleImage  
-- local radius = 10
local x = 0
local y = 0
local spriteRadius = 0

function Explosion:init(x, y, r)
	Explosion.super.init(self)
	self:moveTo(x, y)
	self.x = x 
	self.y = y 
	self.spriteRadius = r
	self.radius = 0 
	
	-- If there is no image, need to explicitly set the sprite's size
	self:setSize(r*2+8, r*2+8)
	
	-- circleImage = gfx.image.new(r*4, r*4) -- gfx.image.new(r * 2, r * 2)
	
	-- gfx.pushContext(circleImage)
	-- 	gfx.setColor(gfx.kColorWhite)
	-- 	gfx.fillCircleAtPoint(0, 0, self.radius)
	-- gfx.popContext()
	-- self:setImage(circleImage)
	
	-- self.scaleTimer = pd.timer.new(5000, 0, 1, pd.easingFunctions.outCubic)
	-- self.scaleTimer.timerEndedCallback = function(_sprite) _sprite:remove() explosionEnded() end
	-- self.scaleTimer.timerEndedArgs = {self}
	
	self:add()
end

function Explosion:update()
	-- print("Sprite radius:: " .. self.spriteRadius)
	-- print("Explosion is updating:: with scaleTimer value: " .. self.scaleTimer.value .. " and radius " .. self.radius)
	
	
	-- gfx.pushContext(circleImage)
	-- 	gfx.setColor(gfx.kColorWhite)
	-- 	-- Perhaps try: playdate.graphics.fillCircleInRect(x, y, width, height)
	-- 	gfx.fillCircleInRect(self.spriteRadius/2, self.spriteRadius/2, self.radius, self.radius)
	-- 	-- gfx.fillCircleAtPoint(self.radius, self.radius, self.radius)
	-- gfx.popContext()
	
	-- self.radius += 0.25
	
end

function Explosion:draw()
	
	local spriteWidth, spriteHeight = self:getSize()
	if not self.radius then
		self.radius = 0
		-- self:remove()
	elseif (self.radius >= self.spriteRadius) then
		self.radius = 0
		explosionEnded()
	else
		self.radius += 0.5
	end
	
	-- Drawing coordinates are relative to the sprite (e.g. (0, 0) is the top left of the sprite)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(spriteWidth / 2, spriteHeight / 2, self.radius)
		
end


-- This code snippet by davemakes on the Playdate Squade discord server:
-- https://discord.com/channels/675983554655551509/821661913393004565/1385544395650105497
-- 
-- local pd <const> = playdate
-- local gfx <const> = playdate.graphics
-- 
-- local maxRadius = 48
-- 
-- class('BlastSprite').extends(gfx.sprite)
-- 
-- function BlastSprite:init(x, y)
-- 	BlastSprite.super.init(self, x, y)
-- 	self:moveTo(x, y)
-- 
-- 	self.canvas = gfx.image.new(maxRadius * 2, maxRadius * 2)
-- 	self:setImage(self.canvas)
-- 	self:setImageDrawMode(gfx.kDrawModeXOR)
-- 
-- 	self.scaleTimer = pd.timer.new(1000, 0, 1, pd.easingFunctions.outCubic)
-- 	self.scaleTimer.timerEndedCallback = function(_sprite) _sprite:remove() end
-- 	self.scaleTimer.timerEndedArgs = {self}
-- end
-- 
-- function BlastSprite:update()
-- 	local _radius = maxRadius * self.scaleTimer.value
-- 	local _hitRadius = (maxRadius - 4) * self.scaleTimer.value
-- 	local _diameter = _hitRadius * 2
-- 
-- 	self:setCollideRect(maxRadius - _hitRadius, maxRadius - _hitRadius, _diameter, _diameter)
-- 
-- 	local _fallout = self:overlappingSprites()
-- 	for _, _hit in pairs(_fallout) do
-- 		if _hit:isa(BlastSprite) then
-- 			-- do nothing
-- 		else
-- 			_hit:remove()
-- 		end
-- 	end
-- 
-- 	gfx.pushContext(self.canvas)
-- 	gfx.setColor(gfx.kColorWhite)
-- 	gfx.fillCircleAtPoint(maxRadius, maxRadius, _radius)
-- 	gfx.popContext()
-- end