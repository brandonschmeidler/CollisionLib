local class = require('30log')
local vector = require('vector')

local segment = class('segment', {
    position = vector(0,0),
    angle = 0,
    length = 100
})

function segment:init(x,y,angle,length)
    self.position = vector(x,y)
    self.angle = angle
    self.length = length
end

function segment:get_end()
    local ra = math.rad(self.angle)
    local uo = vector(math.cos(ra), math.sin(ra))
    local off = vector.scale(uo,self.length)
    return self.position + off
end

function segment:set_end(x,y)
    local off = vector(x,y) - self.position
    local ra = math.atan2(off.y,off.x)
    self.angle = math.deg(ra)
    self.length = vector.length(off)
end

function segment:draw()
    local a = self.position
    local b = self:get_end()
    love.graphics.line(a.x,a.y,b.x,b.y)
end

return segment