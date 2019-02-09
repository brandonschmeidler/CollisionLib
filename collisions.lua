local vector = require('vector')
local shapes = require('shapes')

local collisions = {}

function collisions.overlapping(minA,maxA,minB,maxB)
    return minB <= maxA and minA <= maxB
end

function collisions.collide_rects(a,b)
    local al = a.position.x
    local ar = a.position.x + a.size.x
    local at = a.position.y
    local ab = a.position.y + a.size.y

    local bl = b.position.x
    local br = b.position.x + b.size.x
    local bt = b.position.y
    local bb = b.position.y + b.size.y
    return collisions.overlapping(al,ar,bl,br) and collisions.overlapping(at,ab,bt,bb)
end

function collisions.collide_circles(a,b)
    local radSum = a.radius + b.radius
    local dist = a.position - b.position
    return vector.length(dist) <= radSum
end

function collisions.equivalent_lines(a,b)
    if (not vector.is_parallel(a.angle,b.angle)) then return false end

    local d = a.position - b.position
    return vector.is_parallel(d,a.angle)
end

function collisions.collide_lines(a,b)
    if (vector.is_parallel(a.angle,b.angle)) then
        return collisions.equivalent_lines(a,b)
    else
        return true
    end
end

function collisions.run_unit()

    print('Collisions Unit Test')

    local a = shapes.rectangle(1,1,4,4)
    local b = shapes.rectangle(2,2,5,5)
    local c = shapes.rectangle(6,4,4,2)
    print('Rectangle-Rectangle')
    print(collisions.collide_rects(a,b) == true)
    print(collisions.collide_rects(b,c) == true)
    print(collisions.collide_rects(a,c) == false)
    print()


    a = shapes.circle(4,4,2)
    b = shapes.circle(7,4,2)
    c = shapes.circle(10,4,2)
    print('Circle-Circle')
    print(collisions.collide_circles(a,b) == true)
    print(collisions.collide_circles(b,c) == true)
    print(collisions.collide_circles(a,c) == false)
    print()

    a = vector(3,5)
    b = vector(3,2)
    c = vector(8,4)
    local up = vector(5,-1)
    local down = vector(5,2)
    local l1 = shapes.line(a.x,a.y,math.deg(math.atan2(up.y,up.x)))
    local l2 = shapes.line(a.x,a.y,math.deg(math.atan2(down.x,down.y)))
    local l3 = shapes.line(b.x,b.y,math.deg(math.atan2(down.x,down.y)))
    local l4 = shapes.line(c.x,c.y,math.deg(math.atan2(up.y,up.x)))
    print('Line-Line')
    print(collisions.collide_lines(l1,l2) == true)
    print(collisions.collide_lines(l1,l3) == true)
    print(collisions.collide_lines(l2,l3) == false)
    print(collisions.collide_lines(l1,l4) == true)
    print()


end

return collisions