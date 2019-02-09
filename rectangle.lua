local class = require('30log')
local vector = require('vector')

local rectangle = class('rectangle', {
    position = vector(0,0),
    size = vector(10,10)
})

function rectangle:init(x,y,width,height)
    self.position = vector(x,y)
    self.size = vector(width,height)
end

function rectangle:draw()
    love.graphics.rectangle('fill',self.position.x,self.position.y,self.size.x,self.size.y)
end

return rectangle