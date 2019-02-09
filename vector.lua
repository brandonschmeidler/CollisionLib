local class = require('30log')
local common = require('common')

local vector = class('vector', {x=0,y=0})
function vector:init(x,y)
    self.x = x
    self.y = y
end

function vector.__add(a,b) return vector(a.x+b.x, a.y+b.y) end
function vector.__sub(a,b) return vector(a.x-b.x, a.y-b.y) end
function vector.__mul(a,b) return vector(a.x*b.x, a.y*b.y) end
function vector.__div(a,b) return vector(a.x/b.x, a.y/b.y) end
function vector.__eq(a,b) return common.equal_floats(a.x,b.x) and common.equal_floats(a.y,b.y) end
function vector.__unm(a) return vector(-a.x, -a.y) end
function vector.__tostring(a) return 'vector('.. tostring(a.x) .. ', ' .. tostring(a.y) .. ')' end


function vector.scale(a,scale)
    return a * vector(scale,scale)
end

function vector.length(a)
    return math.sqrt( a.x * a.x + a.y * a.y )
end

function vector.normalize(a)
    local len = vector.length(a)
    return a / vector(len,len)
end

function vector.rotate(a,degrees)
    local rad = math.rad(degrees)
    local sin = math.sin(rad)
    local cos = math.cos(rad)

    local r = vector(
        a.x * cos - a.y * sin, 
        a.x * sin + a.y * cos
    )
    if (common.equal_floats(r.x, 0.0)) then r.x = math.floor(r.x) end
    if (common.equal_floats(r.y, 0.0)) then r.y = math.floor(r.y) end
    
    return r
end

function vector.dot(a,b)
    return a.x * b.x + a.y * b.y
end

function vector.enclosed_angle(a,b)
    local ua = vector.normalize(a)
    local ub = vector.normalize(b)
    local dp = vector.dot(ua,ub)
    return math.deg(math.acos(dp))
end

function vector.project(a,b)
    local d = vector.dot(b,b)
    if (0 < d) then
        local dp = vector.dot(a,b)
        return vector.scale(b, dp/d)
    end
    return b
end

function vector.rotate90(a)
    return vector(-a.y,a.x)
end

function vector.is_parallel(a,b)
    local na = vector.rotate90(a)
    return common.equal_floats(0, vector.dot(na,b))
end

function vector.run_unit()
    local v1 = vector(20,100)
    local v2 = vector(2,10)

    local vadd = (v1 + v2) == vector(22,110)
    local vsub = (v1 - v2) == vector(18,90)
    local vmul = (v1 * v2) == vector(40,1000)
    local vdiv = (v1 / v2) == vector(10,10)
    local veq = v1 == vector(20,100)
    local vunm = -v1 == vector(-20,-100)
    local vscale = vector.scale(v2,2) == vector(4,20)
    local vlen = common.equal_floats(vector.length(vector(10,0)), 10)
    local vunit = common.equal_floats(vector.length(vector.normalize(v1)), 1)
    local vrot = vector.rotate(vector(10,0), 90) == vector(0,10)
    local vdot = common.equal_floats(vector.dot(vector(8,2),vector(-2,8)), 0)
    local vangle = common.equal_floats(vector.enclosed_angle(vector(8,2), vector(-2,8)), 90)
    local vrot90 = common.equal_floats(vector.enclosed_angle(v1, vector.rotate90(v1)), 90)

    print('Vector Unit Test')
    print('vadd:' .. tostring(vadd))
    print('vsub:' .. tostring(vsub))
    print('vmul:' .. tostring(vmul))
    print('vdiv:' .. tostring(vdiv))
    print('veq:' .. tostring(veq))
    print('vunm:' .. tostring(vunm))
    print('vscale:' .. tostring(vscale))
    print('vlen:' .. tostring(vlen))
    print('vunit:' .. tostring(vunit))
    print('vrot:' .. tostring(vrot))
    print('vdot:' .. tostring(vdot))
    print('vangle:' .. tostring(vangle))
    print('vrot90:' .. tostring(vrot90))
    print()
end

return vector