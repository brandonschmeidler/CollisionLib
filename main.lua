local vector = require('vector')
local shapes = require('shapes')
local collisions = require('collisions')

function love.load()
    vector.run_unit()
    collisions.run_unit()

    r1 = shapes.orectangle(love.graphics.getWidth()/2,love.graphics.getHeight()/2,45,64,96)
    r2 = shapes.orectangle(0,0,0,32,32)
end

function love.update(dt)
    r2.position = vector(love.mouse.getPosition())
    r2.angle = r2.angle + 45 * dt
end

function love.draw()
    if (collisions.collide_orects(r1,r2)) then
        love.graphics.setColor(255,0,255,255)
    else
        love.graphics.setColor(255,255,255,255)
    end
    r1:draw()
    r2:draw()
end