local class = require('30log')
local vector = require('vector')

local line = class('line', {
    position = vector(0,0),
    angle = vector(1,0)
})

function line:init(x,y,ax,ay)
    self.position = vector(x,y)

    if (ay ~= nil) then
        self.angle = vector(ax,ay)
    else
        self:set_angle(ax)
    end
end

function line:set_angle(degrees)
    local r = math.rad(degrees)
    self.angle = vector(math.cos(r), math.sin(r))
end

function line:get_angle()
    return math.deg(math.atan2(self.angle.y,self.angle.x))
end

function line:draw()
    local o = self.position
    local s = vector.scale(self.angle, 3000)
    local l = o - s
    local r = o + s
    love.graphics.line(l.x,l.y,r.x,r.y)
end

return line