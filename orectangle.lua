local class = require('30log')
local vector = require('vector')

local orectangle = class('orectangle', {
    position = vector(0,0),
    size = vector(10,10),
    angle = 0
})

function orectangle:init(x,y,angle,width,height)
    self.position = vector(x,y)
    self.size = vector(width,height)
    self.angle = angle
end

function orectangle:draw()
    love.graphics.push()
    love.graphics.translate(self.position.x,self.position.y)
    love.graphics.rotate(math.rad(self.angle))
    love.graphics.rectangle('fill',-self.size.x/2,-self.size.y/2,self.size.x,self.size.y)
    love.graphics.pop()
end

return orectangle