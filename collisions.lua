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


end

return collisions