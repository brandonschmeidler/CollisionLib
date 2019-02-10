local vector = require('vector')
local shapes = require('shapes')
local common = require('common')

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

function collisions.clamp_on_rectangle(p,r)
    local clamp = vector(0,0)
    clamp.x = common.clamp(p.x, r.position.x, r.position.x + r.size.x)
    clamp.y = common.clamp(p.y, r.position.y, r.position.y + r.size.y)
    return clamp
end

function collisions.rectangle_corner(r,nr)
    local corner = vector(r.position.x,r.position.y)
    nr = nr % 4
    if (nr == 0) then
        corner.x = corner.x + r.size.x
    elseif (nr == 1) then
        corner = corner + r.size
    elseif (nr == 2) then
        corner.y = corner.y + r.size.y
    end
    return corner
end

function collisions.separating_axis_for_rectangle(axis,r)
    local n = axis.position - axis:get_end()
    local rEdgeA = shapes.segment(0,0,0,0)
    rEdgeA.position = collisions.rectangle_corner(r,0)

    local corner = collisions.rectangle_corner(r,1)
    rEdgeA:set_end(corner.x,corner.y)

    local rEdgeB = shapes.segment(0,0,0,0)
    rEdgeB.position = collisions.rectangle_corner(r,2)

    corner = collisions.rectangle_corner(r,3)
    rEdgeB:set_end(corner.x,corner.y)

    local rEdgeARange = collisions.project_segment(rEdgeA, n)
    local rEdgeBRange = collisions.project_segment(rEdgeB, n)
    local rProjection = vector.hull(rEdgeARange, rEdgeBRange)

    local axisRange = collisions.project_segment(axis,n)

    return not collisions.overlapping_ranges(axisRange,rProjection)
end

function collisions.oriented_rectangle_corner(r,nr)
    local c = vector.scale(r.size, 0.5)
    nr = nr % 4
    if (nr == 0) then
        c.x = -c.x
    elseif (nr == 1) then
        -- do nothing
    elseif (nr == 2) then
        c.y = -c.y
    else
        c = -c
    end

    c = vector.rotate(c, r.angle)
    return c + r.position
end

function collisions.enlarge_rectangle_point(r,p)
    local enlarged = shapes.rectangle(0,0,0,0)
    enlarged.position.x = math.min(r.position.x,p.x)
    enlarged.position.y = math.min(r.position.y,p.y)
    enlarged.size.x = math.max(r.position.x + r.size.x, p.x)
    enlarged.size.y = math.max(r.position.y + r.size.y, p.y)
    enlarged.size = enlarged.size - enlarged.position
    return enlarged
end

function collisions.oriented_rectangle_rectangle_hull(r)
    local h = shapes.rectangle(r.position.x,r.position.y, 0,0)
    for nr=0,3 do
        local corner = collisions.oriented_rectangle_corner(r,nr)
        h = collisions.enlarge_rectangle_point(h, corner)
    end
    return h
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

function collisions.collide_point_in_circle(x,y,c)
    local dist = c.position - vector(x,y)
    return vector.length(dist) <= c.radius
end

function collisions.collide_point_in_rect(x,y,r)
    local left = r.position.x
    local right = r.position.x + r.size.x
    local top = r.position.y
    local bottom = r.position.y + r.size.y

    return left <= x and top <= y and x <= right and y <= bottom
end

function collisions.collide_circle_line(c,l)
    local lc = c.position - l.position
    local p = vector.project(lc, l.angle)
    local nearest = l.position + p
    return collisions.collide_point_in_circle(nearest.x,nearest.y,c)
end

function collisions.collide_circle_segment(c,s)
    if (collisions.collide_point_in_circle(s.position.x,s.position.y,c)) then return true end
    local endpoint = s:get_end()
    if (collisions.collide_point_in_circle(endpoint.x,endpoint.y,c)) then return true end

    local d = endpoint - s.position
    local lc = c.position - s.position
    local p = vector.project(lc,d)
    local nearest = s.position + p

    return collisions.collide_point_in_circle(nearest.x,nearest.y,c) and vector.length(p) <= vector.length(d) and 0 <= vector.dot(p,d)
end

function collisions.collide_circle_rect(c,r)
    local clamped = collisions.clamp_on_rectangle(c.position,r)
    return collisions.collide_point_in_circle(clamped.x,clamped.y,c)
end

function collisions.collide_circle_orect(c,r)
    local lr = shapes.rectangle(0,0,0,0)
    lr.size = r.size

    local lc = shapes.circle(0,0,c.radius)
    local dist = c.position - r.position
    dist = vector.rotate(dist, -r.angle)
    lc.position = dist + vector.scale(r.size, 0.5)

    return collisions.collide_circle_rect(lc,lr)
end

function collisions.collide_rect_line(r,l)
    local n = vector.rotate90(l.angle)
    local c1 = r.position
    local c2 = c1 + r.size
    local c3 = vector(c2.x,c1.y)
    local c4 = vector(c1.x,c2.y)

    c1 = c1 - l.position
    c2 = c2 - l.position
    c3 = c3 - l.position
    c4 = c4 - l.position

    local dp1 = vector.dot(n,c1)
    local dp2 = vector.dot(n,c2)
    local dp3 = vector.dot(n,c3)
    local dp4 = vector.dot(n,c4)

    return (dp1 * dp2 <= 0) or (dp2 * dp3 <= 0) or (dp3 * dp4 <= 0)
end

function collisions.collide_rect_segment(r,s)
    local sLine = shapes.line(s.position.x,s.position.y,0)
    sLine.angle = s:get_end() - s.position
    if (not collisions.collide_rect_line(r,sLine)) then return false end

    local rRange = vector(r.position.x,r.position.x+r.size.x)
    local sRange = vector(s.position.x,s:get_end().x)
    sRange = vector.sort(sRange)

    if (not collisions.overlapping_ranges(rRange,sRange)) then return false end

    rRange = vector(r.position.y,r.position.y+r.size.y)
    sRange = vector(s.position.y,s:get_end().y)
    sRange = vector.sort(sRange)
    return collisions.overlapping_ranges(rRange,sRange)
end

function collisions.collide_rect_orect(r,oR)
    local orHull = collisions.oriented_rectangle_rectangle_hull(oR)
    if (not collisions.collide_rects(orHull,r)) then return false end

    local edge = collisions.oriented_rectangle_edge(oR,0)
    if (collisions.separating_axis_for_rectangle(edge,r)) then return false end

    edge = collisions.oriented_rectangle_edge(oR,1)
    return not collisions.separating_axis_for_rectangle(edge,r)
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

function collisions.run_unit_point_in_circle()
    local c = shapes.circle(6,4,3)
    local p1 = vector(8,3)
    local p2 = vector(11,7)

    print('Point-Circle')
    print(collisions.collide_point_in_circle(p1.x,p1.y,c) == true)
    print(collisions.collide_point_in_circle(p2.x,p2.y,c) == false)
    print()
end

function collisions.run_unit_point_in_rect()
    local r = shapes.rectangle(3,2,6,4)
    local p1 = vector(4,5)
    local p2 = vector(11,4)

    print('Point-Rect')
    print(collisions.collide_point_in_rect(p1.x,p1.y,r) == true)
    print(collisions.collide_point_in_rect(p2.x,p2.y,r) == false)
    print()
end

function collisions.run_unit_circle_line()
    local c = shapes.circle(6,3,2)
    local l = shapes.line(4,7,0)
    l.angle = vector(5,-1)

    print('Circle-Line')
    print(collisions.collide_circle_line(c,l) == false)
    print()

end

function collisions.run_unit_circle_segment()
    local c = shapes.circle(4,4,3)
    local s = shapes.segment(8,6,0,0)
    s:set_end(13,6)

    print('Circle-Segment')
    print(collisions.collide_circle_segment(c,s) == false)
    print()
end

function collisions.run_unit_circle_rect()
    local r = shapes.rectangle(3,2,6,4)
    local c1 = shapes.circle(5,4,1)
    local c2 = shapes.circle(7,8,1)

    print('Circle-Rect')
    print(collisions.collide_circle_rect(c1,r) == true)
    print(collisions.collide_circle_rect(c2,r) == false)
    print()
end

function collisions.run_unit_circle_orect()
    local r = shapes.orectangle(5,4,30,6,4)
    local c = shapes.circle(5,7,2)

    print('Circle-ORectangle')
    print(collisions.collide_circle_orect(c,r) == true)
    print()
end

function collisions.run_unit_rect_line()
    local l = shapes.line(6,8,0)
    l.angle = vector(2,-3)
    local r = shapes.rectangle(3,2,6,4)

    print('Rectangle-Line')
    print(collisions.collide_rect_line(r,l) == true)
    print()
end

function collisions.run_unit_rect_segment()
    local r = shapes.rectangle(3,2,6,4)
    local s = shapes.segment(6,8,0,0)
    s:set_end(10,2)

    print('Rectangle-Segment')
    print(collisions.collide_rect_segment(r,s) == true)
    print()
end

function collisions.run_unit_rect_orect()
    local r = shapes.rectangle(1,5,3,3)
    local oR = shapes.orectangle(10,4,25,8,4)

    print('Rectangle-ORectangle')
    print(collisions.collide_rect_orect(r,oR) == false)
    print()
end

function collisions.run_unit()

    print('Collisions Unit Test')

    collisions.run_unit_rects()
    collisions.run_unit_circles()
    collisions.run_unit_lines()
    collisions.run_unit_segments()
    collisions.run_unit_orects()
    collisions.run_unit_point_in_circle()
    collisions.run_unit_point_in_rect()
    collisions.run_unit_circle_line()
    collisions.run_unit_circle_segment()
    collisions.run_unit_circle_rect()
    collisions.run_unit_circle_orect()
    collisions.run_unit_rect_line()
    collisions.run_unit_rect_segment()
    collisions.run_unit_rect_orect()


end

return collisions