local vector = require('vector')
local shapes = require('shapes')
local collisions = require('collisions')

function love.load()
    vector.run_unit()
    collisions.run_unit()

    r = shapes.rectangle(0,0,32,32)
    oR = shapes.orectangle(love.graphics.getWidth()/2,love.graphics.getHeight()/2, 0, 128,256)
end

function love.update(dt)
    oR.angle = oR.angle + 45 * dt
    r.position = vector(love.mouse.getPosition())
end

function love.draw()
    if (collisions.collide_rect_orect(r,oR)) then
        love.graphics.setColor(255,0,255,255)
    else
        love.graphics.setColor(255,255,255,255)
    end
    r:draw()
    oR:draw()
end