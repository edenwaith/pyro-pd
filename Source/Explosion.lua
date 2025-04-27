local pd <const> = playdate
local gfx <const> = pd.graphics

class('Explosion').extends(gfx.sprite)

function Explosion:init(x, y, r)
	Explosion.super.init(self)
	self:moveTo(x, y)
	
	local circleImage = gfx.image.new(r * 2, r * 2)
	gfx.pushContext(circleImage)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillCircleAtPoint(r, r, r)
	gfx.popContext()
	self:setImage(circleImage)
	self:add()
end
