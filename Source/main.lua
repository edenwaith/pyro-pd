local gfx = playdate.graphics

-- The Playdate dev docs recommend this to seed the random number generator
-- https://sdk.play.date/2.3.1/Inside%20Playdate.html#f-getSecondsSinceEpoch
-- When I leave the scene and come back, the roll seems to be the same value
-- This can create an exploit where the user comes in, wins, leaves, then comes
-- back to win again.  Is this randomization enough?
math.randomseed(playdate.getSecondsSinceEpoch())

gfx.setColor(gfx.kColorBlack)

function playdate.update()
    gfx.fillRect(0, 0, 400, 240)
    playdate.drawFPS(0,0)
end
