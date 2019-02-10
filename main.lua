local vector = require('vector')
local shapes = require('shapes')
local collisions = require('collisions')

function love.load()
    vector.run_unit()
    collisions.run_unit()

    s = shapes.segment(love.graphics.getWidth()/2,love.graphics.getHeight()/2,0,love.graphics.getWidth()/2)
    r = shapes.orectangle(love.graphics.getWidth()*0.25,love.graphics.getHeight()/2,0,45,80)
end

function love.update(dt)
    local mpos = vector(love.mouse.getPosition())
    s:set_end(mpos.x,mpos.y)
    r.angle = r.angle + 45 * dt
end

function love.draw()
    
    if (collisions.collide_segment_orect(s,r)) then
        love.graphics.setColor(255,0,255,255)
    else
        love.graphics.setColor(255,255,255,255)
    end
    s:draw()
    r:draw()
end