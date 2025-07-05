import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "CoreLibs/animator"
import "Explosion"

local gfx <const> = playdate.graphics
local snd <const> = playdate.sound
local geo <const> = playdate.geometry
-- local Animator = playdate.graphics.animator -- TODO: Check if this value is needed

-- Firework variables
local fireworkSprite = nil
local fireworkImage = gfx.image.new("images/defaultFirework")
local fireworkImageTable = gfx.imagetable.new("images/firework") 
local fireworkPoint = geo.point.new(math.random(55, 345), math.random(55, 185))
local fireworkAnimationLoop
local frameTime = 200 
local numFireworks = math.random(1, 6)

-- Explosion variables
local explosionSprite = nil 
local explosionPoint = geo.point.new(0, 240)

-- Arc variables
-- This arc animator code comes from the animator.lua code
-- local arc = geo.arc.new(120, 40, 30, -95, 100)
local arc = geo.arc.new(120, 235, 60, 90, 25)
local arcAnimator = gfx.animator.new(2000, arc, playdate.easingFunctions.outQuart) -- outQuart and outCubic look good
arcAnimator.repeatCount = 2
arcAnimator.reverses = true

local lineSegment = geo.lineSegment.new(170, 10, 300, 50)
local lsAnim = gfx.animator.new(10000, lineSegment, playdate.easingFunctions.linear, 2000)


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
    
    -- Lower the volume, the default level distorts the audio even at a low setting
    synthPlayer:setVolume(0.5)
    
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
    -- local explosionX = math.random(60, 340)
    explosionPoint.x = math.random(60, 340) 
    explosionPoint.y = 240
    explosionSprite = Explosion(explosionPoint.x, explosionPoint.y, 10)
end

function explosionEnded()

    explosionSprite:remove()
    
    showArc()

    -- startFireworks()
end

function showArc()
    print("showArc")
    randomizeSpriteLocation()
    
-- TODO: Need to calculate how to draw the arc dependent upon the start and end points
    
    local startAngle = 270
    local distanceBetweenPoints = explosionPoint:distanceToPoint(fireworkPoint)
    local xDelta = math.abs(explosionPoint.x - fireworkPoint.x) -- verify this is always correct
    local yDelta = explosionPoint.y - fireworkPoint.y
    local arcX = explosionPoint.x
    
    -- TODO: When determining how long the animation should last, calculate it dependent on the distance
    lineSegment = geo.lineSegment.new(explosionPoint.x, explosionPoint.y, fireworkPoint.x, fireworkPoint.y)
    lsAnim = gfx.animator.new(2000, lineSegment, playdate.easingFunctions.outSine) 
    -- Easing Functions: https://sdk.play.date/2.7.5/Inside%20Playdate.html#M-easingFunctions
    -- playdate.easingFunctions.linear) 
-- playdate.easingFunctions.outQuart : too much of a delay at the end before the animation ends
    -- playdate.easingFunctions.outCubic
    -- outSine : this looks decent and doesn't have the delay at the end
    
    print("distanceBetweenPoints (" .. explosionPoint.x .. ", "  .. explosionPoint.y .. ") and (" .. fireworkPoint.x .. ", " .. fireworkPoint.y .. ") :: " .. distanceBetweenPoints)
    

    
    -- 1. Solve for angle A
    local alpha = math.asin(yDelta/distanceBetweenPoints)
    
    -- 2. Solve for radius r
    local radius = (distanceBetweenPoints/2)/math.cos(alpha)
    
    -- 3. Solve for angle C (endAngle)
    local endAngle = math.asin(yDelta/radius)
    endAngle = math.deg(endAngle) -- convert from radius to degrees
    
    -- These angles may not be correct, I'll need to experiment if the angles, especially if the
    -- radius is off screen, so the start angle might be something other than 90 or 270.
    if (explosionPoint.x < fireworkPoint.x) then 
        startAngle = 270
        arcX = arcX + radius
    else 
        -- What if the firework is exactly over the explosion point? Will this work?
        startAngle = 90
        arcX = arcX - radius
    end
    
    print("Arc startAngle is " .. startAngle)
    
    -- Do I need to convert the endAngle to degrees first?
    print("radius is:: " .. radius .. " and endAngle is:: " .. endAngle)
    
    -- Get the location of the explosion and where the firework will land
    -- arc = geo.arc.new(120, 235, 60, 90, 25)
    -- arc(x, y, radius, startAngle, endAngle, [direction])
    -- Direction is 'true' for clockwise, 'false' for counterclockwise
    arc = geo.arc.new(arcX, explosionPoint.y, radius, startAngle, endAngle)
    
    -- This should only be shown after the arcAnimator has completed
    -- startFireworks()
end

function startFireworks()
    fireworkSprite = gfx.sprite.new(fireworkImageTable[1])
    fireworkSprite.update = nil
    
    local fireworksCount = math.random(0, 5)
    -- randomizeSpriteLocation()
    showFirework(fireworkPoint.x, fireworkPoint.y, fireworksCount)
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
            end 
        end
    end
    
    fireworkSprite:moveTo(x, y)
    fireworkSprite:add()
end

function randomizeSpriteLocation()
    fireworkPoint.x = math.random(55, 345)
    fireworkPoint.y = math.random(55, 175)
end

gameSetup()

function playdate.update()
    
    playdate.drawFPS(0,0)
    
    gfx.sprite.update() -- update all sprites
    playdate.timer.updateTimers()
    
    if explosionSprite ~= nil then
        explosionSprite:markDirty()
    end
    
    
    if lsAnim then
        -- gfx.drawLine(lineSegment)
        local p = lsAnim:currentValue()
        gfx.fillCircleAtPoint(p, 2)
        
        if lsAnim:ended() then
            lsAnim = nil
            startFireworks()
        end
    end
    
    
    
    if arcAnimator then
    -- FIXME: Temporarily commented out until the arc is calculated properly
        -- gfx.drawArc(arc)
        -- local p = arcAnimator:currentValue()
        -- gfx.fillCircleAtPoint(p, 3)
        
        -- gfx.drawTextAligned(math.floor(100*arcAnim:progress()).."%", 121, 30, kTextAlignment.center)
    end
    
    
    if playdate.buttonJustPressed( playdate.kButtonA ) then
        randomizeSpriteLocation()
        showFirework(fireworkPoint.x, fireworkPoint.y, math.random(0, 5))
    end
end