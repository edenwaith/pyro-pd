import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "Explosion"

local gfx <const> = playdate.graphics
local snd <const> = playdate.sound

local fireworkSprite = nil
local fireworkImage = gfx.image.new("images/defaultFirework")
local fireworkImageTable = gfx.imagetable.new("images/firework") 


local fireworkX = math.random(55, 345)
local fireworkY = math.random(55, 185)

local fireworkAnimationLoop
local frameTime = 200 
local numFireworks = math.random(1, 6)

local explosionSprite = nil 


-- Play the background music MIDI 
function playSouthernCross()
    
    local synthPlayer = snd.synth.new(snd.kWaveTriangle) -- kWaveSquare
    local southernCross = snd.sequence.new('sounds/southern-cross.mid')
    assert(southernCross)
    
    local track1 = southernCross:getTrackAtIndex(1)
    local track2 = southernCross:getTrackAtIndex(2)
    local track3 = southernCross:getTrackAtIndex(3)
    local track4 = southernCross:getTrackAtIndex(4)
    local track5 = southernCross:getTrackAtIndex(5)
    local track6 = southernCross:getTrackAtIndex(6)
    local track7 = southernCross:getTrackAtIndex(7)
    local track8 = southernCross:getTrackAtIndex(8)
    local track9 = southernCross:getTrackAtIndex(9)
    
    track1:setInstrument(synthPlayer:copy())
    track2:setInstrument(synthPlayer:copy())
    track3:setInstrument(synthPlayer:copy())
    track4:setInstrument(synthPlayer:copy())
    track5:setInstrument(synthPlayer:copy())
    track6:setInstrument(synthPlayer:copy())
    track7:setInstrument(synthPlayer:copy())
    track8:setInstrument(synthPlayer:copy())
    track9:setInstrument(synthPlayer:copy())
    
    southernCross:setTrackAtIndex(1, track1)
    southernCross:setTrackAtIndex(2, track2)
    southernCross:setTrackAtIndex(3, track3)
    southernCross:setTrackAtIndex(4, track4)
    southernCross:setTrackAtIndex(5, track5)
    southernCross:setTrackAtIndex(6, track6)
    southernCross:setTrackAtIndex(7, track7)
    southernCross:setTrackAtIndex(8, track8)
    southernCross:setTrackAtIndex(9, track9)
    
    southernCross:play()
end

function gameSetup()
    
    -- The Playdate dev docs recommend this to seed the random number generator
    -- https://sdk.play.date/2.3.1/Inside%20Playdate.html#f-getSecondsSinceEpoch
    -- When I leave the scene and come back, the roll seems to be the same value
    -- This can create an exploit where the user comes in, wins, leaves, then comes
    -- back to win again.  Is this randomization enough?
    math.randomseed(playdate.getSecondsSinceEpoch())
    
    -- Remember to add gfx.sprite.update(), otherwise this won't appear 
    -- Set up a background image
    local backgroundImage = gfx.image.new( "images/starry-night-background" )
    assert( backgroundImage )
    
    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            -- x,y,width,height is the updated area in sprite-local coordinates
            -- The clip rect is already set to this area, so we don't need to set it ourselves
            backgroundImage:draw( 0, 0 )
        end
    )
    
    playSouthernCross()
    
    -- Verify that the images and table exist
    assert(fireworkImage)
    assert(fireworkImageTable)
    
    showExplosion()
    
    -- TODO: Check if Animator can be useful for changing the explosion's size
    -- Also check once the animation is completed, then remove the sprite
end

function showExplosion()
    local explosionX = math.random(60, 340)
    explosionSprite = Explosion(explosionX, 240, 10)
end

function explosionEnded()
    print("Boom boom")
    explosionSprite:remove()
    -- showExplosion()
    startFireworks()
end

function startFireworks()
    fireworkSprite = gfx.sprite.new(fireworkImageTable[1])
    fireworkSprite.update = nil
    
    local fireworksCount = math.random(0, 5)
    randomizeSpriteLocation()
    showFirework(fireworkX, fireworkY, fireworksCount)
end 

function showFirework(x, y, fireworksCount)
    print("Welcome to showFirework at location::: (" .. x .. ", " .. y .. ")")
    fireworkSprite.update = nil
    
    -- Crash: attempt to index a nil value (field 'animation')
    -- Solution: Add the "CoreLibs/animation" library!
    -- Source: https://devforum.play.date/t/animation-loop-throwing-an-error/6385
    fireworkAnimationLoop  = gfx.animation.loop.new(frameTime, fireworkImageTable, false)
    assert(fireworkAnimationLoop)
    
    fireworkSprite.update = function()
        fireworkSprite:setImage(fireworkAnimationLoop:image())
        
        if not fireworkAnimationLoop:isValid() then
            
            fireworkSprite:remove()
            
            if (fireworksCount > 0) then
                -- Create some deltas for x and y
                local deltaX = math.random(-20, 20)
                local deltaY = math.random(-20, 20)

                showFirework(x+deltaX, y+deltaY, fireworksCount-1)
            else
                showExplosion()
                -- randomizeSpriteLocation()
                -- local fireworksCount = math.random(0, 5)
                -- showFirework(fireworkX, fireworkY, fireworksCount)
            end 
        end
    end
    
    fireworkSprite:moveTo(x, y)
    fireworkSprite:add()
end

function randomizeSpriteLocation()
    fireworkX = math.random(55, 345)
    fireworkY = math.random(55, 185)
end

gameSetup()

function playdate.update()
    
    playdate.drawFPS(0,0)
    
    gfx.sprite.update() -- update all sprites
    playdate.timer.updateTimers()
    
    if explosionSprite ~= nil then
        explosionSprite:markDirty()
    end
    
    if playdate.buttonJustPressed( playdate.kButtonA ) then
        randomizeSpriteLocation()
        showFirework(fireworkX, fireworkY, math.random(0, 5))
    end
end