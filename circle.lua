local class = require('30log')
local vector = require('vector')

local circle = class('circle', {
    position = vector(0,0),
    radius = 10
})

function circle:init(x,y,radius)
    self.position = vector(x,y)
    self.radius = radius
end

function circle:draw()
    love.graphics.circle('fill',self.position.x,self.position.y,self.radius)
end

return circle