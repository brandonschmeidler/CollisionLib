local vector = require('vector')
local shapes = require('shapes')

local collisions = {}

function collisions.overlapping(minA,maxA,minB,maxB)
    return minB <= maxA and minA <= maxB
end

function collisions.overlapping_ranges(a,b)
    return collisions.overlapping(a.x,a.y,b.x,b.y)
end

function collisions.equivalent_lines(a,b)
    if (not vector.is_parallel(a.angle,b.angle)) then return false end

    local d = a.position - b.position
    return vector.is_parallel(d,a.angle)
end

function collisions.on_one_side(axis,s)
    local d1 = s.position - axis.position
    local d2 = s:get_end() - axis.position
    local n = vector.rotate90(axis.angle)
    return vector.dot(n,d1) * vector.dot(n,d2) > 0
end

function collisions.project_segment(s,onto)
    local ontoUnit = vector.normalize(onto)
    local r = vector(0,0)
    r.x = vector.dot(ontoUnit, s.position)
    r.y = vector.dot(ontoUnit, s:get_end())
    return vector.sort(r)
end

function collisions.oriented_rectangle_edge(r,nr)
    local a = r.size / vector(2,2)
    local b = r.size / vector(2,2)

    nr = nr % 4
    if (nr == 0) then
        a.x = -a.x
    elseif (nr == 1) then
        b.y = -b.y
    elseif (nr == 2) then
        a.y = -a.y
        b = -b
    else
        a = -a
        b.x = -b.x
    end

    a = vector.rotate(a, r.angle)
    a = a + r.position
    b = vector.rotate(b, r.angle)
    b = b + r.position

    local edge = shapes.segment(0,0,0,0)
    edge.position = a
    edge:set_end(b.x,b.y)
    return edge
end

function collisions.separating_axis_for_oriented_rectangle(axis,r)
    local rEdge0 = collisions.oriented_rectangle_edge(r, 0)
    local rEdge2 = collisions.oriented_rectangle_edge(r, 2)
    local n = axis.position - axis:get_end()

    local axisRange = collisions.project_segment(axis, n)
    local r0Range = collisions.project_segment(rEdge0, n)
    local r2Range = collisions.project_segment(rEdge2, n)
    local rProjection = vector.hull(r0Range,r2Range)

    return not collisions.overlapping_ranges(axisRange, rProjection)
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

function collisions.collide_lines(a,b)
    if (vector.is_parallel(a.angle,b.angle)) then
        return collisions.equivalent_lines(a,b)
    else
        return true
    end
end

function collisions.collide_segments(a,b)
    local axisA = shapes.line(0,0,0)
    axisA.position = a.position
    axisA.angle = a:get_end() - a.position
    if (collisions.on_one_side(axisA,b)) then return false end

    local axisB = shapes.line(0,0,0)
    axisB.position = b.position
    axisB.angle = b:get_end() - b.position
    if (collisions.on_one_side(axisB,a)) then return false end

    if (vector.is_parallel(axisA.angle,axisB.angle)) then
        local rangeA = collisions.project_segment(a, axisA.angle)
        local rangeB = collisions.project_segment(b, axisA.angle)
        return collisions.overlapping_ranges(rangeA,rangeB)
    else
        return true
    end
end

function collisions.collide_orects(a,b)
    local edge = collisions.oriented_rectangle_edge(a, 0)
    if (collisions.separating_axis_for_oriented_rectangle(edge, b)) then return false end

    edge = collisions.oriented_rectangle_edge(a, 1)
    if (collisions.separating_axis_for_oriented_rectangle(edge, b)) then return false end

    edge = collisions.oriented_rectangle_edge(b, 0)
    if (collisions.separating_axis_for_oriented_rectangle(edge, a)) then return false end

    edge = collisions.oriented_rectangle_edge(b, 1)
    return not collisions.separating_axis_for_oriented_rectangle(edge, a)
end

function collisions.run_unit_rects()
    local a = shapes.rectangle(1,1,4,4)
    local b = shapes.rectangle(2,2,5,5)
    local c = shapes.rectangle(6,4,4,2)
    print('Rectangle-Rectangle')
    print(collisions.collide_rects(a,b) == true)
    print(collisions.collide_rects(b,c) == true)
    print(collisions.collide_rects(a,c) == false)
    print()
end

function collisions.run_unit_circles()
    local a = shapes.circle(4,4,2)
    local b = shapes.circle(7,4,2)
    local c = shapes.circle(10,4,2)
    print('Circle-Circle')
    print(collisions.collide_circles(a,b) == true)
    print(collisions.collide_circles(b,c) == true)
    print(collisions.collide_circles(a,c) == false)
    print()
end

function collisions.run_unit_lines()
    local a = vector(3,5)
    local b = vector(3,2)
    local c = vector(8,4)
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

function collisions.run_unit_segments()
    local a = vector(3,4)
    local b = vector(11,1)
    local c = vector(8,4)
    local d = vector(11,7)

    local s1 = shapes.segment(a.x,a.y,0,0)
    s1:set_end(b.x,b.y)
    local s2 = shapes.segment(c.x, c.y,0,0)
    s2:set_end(d.x,d.y)

    print('Segment-Segment')
    print(collisions.collide_segments(s1,s2) == false)
    print()
    
end

function collisions.run_unit_orects()
    local a = shapes.orectangle(3,5,2,6,15)
    local b = shapes.orectangle(10,5,4,4,-15)

    print('ORectangle-ORectangle')
    print(collisions.collide_orects(a,b) == false)
    print()
end

function collisions.run_unit()

    print('Collisions Unit Test')

    collisions.run_unit_rects()
    collisions.run_unit_circles()
    collisions.run_unit_lines()
    collisions.run_unit_segments()
    collisions.run_unit_orects()


end

return collisions