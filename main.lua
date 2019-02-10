local vector = require('vector')
local shapes = require('shapes')
local collisions = require('collisions')

function love.load()
    vector.run_unit()
    collisions.run_unit()

    c = shapes.circle(0,0,32)
    r = shapes.orectangle(love.graphics.getWidth()/2,love.graphics.getHeight()/2,45,128,200)
end

function love.update(dt)
    c.position = vector(love.mouse.getPosition())

    r.angle = r.angle + 45 * dt
end

function love.draw()
    if (collisions.collide_circle_orect(c,r)) then
        love.graphics.setColor(255,0,255,255)
    else
        love.graphics.setColor(255,255,255,255)
    end
    c:draw()
    r:draw()
end