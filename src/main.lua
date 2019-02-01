-- math lib demos

-- demonstrations of each function in the mathlib extension library

-- Please be aware that the composer is broken for this file in daily builds 2014.2196 and above.

display.setStatusBar( display.HiddenStatusBar )

local composer = require( "composer" )
require("mathlib")

local main = { scenes={}, functions={} }

main.list = {
	{ label="math.lengthOf = function( ptA, ptB )", scene="lengthOf" },
	{ label="math.angleOf = function( centre, ptA, ptB )", scene="angleOf" },
	{ label="math.isPointInAngle = function( centre, first, second, point )", scene="isPointInAngle" },
	{ label="math.isPointConcave = function( a, pt, c )", scene="isPointConcave" },
	{ label="math.angleBetweenLines( lineA, lineB )", scene="angleBetweenLines" },
	{ label="math.getLineIntersection = function( lineA, lineB )", scene="getLineIntersection" },
	{ label="math.reflectPointAcrossLine = function( line, pt )", scene="reflectPointAcrossLine" },
	{ label="math.polygonArea = function( points )", scene="polygonArea" },
	{ label="math.isPolygonConcave = function( points )", scene="isPolygonConcave" },
	{ label="math.isPointInPolygon = function( points )", scene="isPointInPolygon" },
	{ label="math.getPolygonIntersection = function( subject, clip )", scene="getPolygonIntersection" },
	{ label="math.closestLineAndPoint = function( pt, points )", scene="closestLineAndPoint" },
	{ label="math.closestPolygonIntersection = function( a, b, polygon )", scene="closestPolygonIntersection" },
	{ label="math.bouncePointAgainstLine = function( line, pt )", scene="bouncePointAgainstLine" },
	{ label="math.bouncePointAgainstPolygon = function( points, pt )", scene="bouncePointAgainstPolygon" },
}

--[[ Back button ]]--
local back = display.newCircle( display.actualContentWidth-50, 50, 25 )
function back:touch(e)
	if (e.phase == "ended") then
		composer.gotoScene( "menu", { effect="fade", time=500 } )
	end
	return true
end
back:addEventListener( "touch", back )
back:addEventListener( "tap", function(e) return true end )
back.alpha = 0

--[[ Supporting functions ]]--
local function newDragSpot( parent, x, y, c, r, callback, label )
	local group = display.newGroup()
	parent:insert( group )
	group.x, group.y = x, y
	group.canDelete = false
	
	group.spot = display.newCircle( group, 0, 0, r or 30 )
	group.spot.fill = c or {1,0,0}
	
	if (label) then
		display.newText{ parent=group, text=label, fontSize=20, x=0, y=0 }
	end
	
	function group:touch(e)
		e.target.x, e.target.y = e.x, e.y
		if (callback) then callback( e.target ) end
		if (e.phase == "began") then
			display.getCurrentStage():setFocus( e.target )
			e.target.hasFocus = true
			return true
		elseif (e.target.hasFocus) then
			if (e.phase == "moved") then
			else
				e.target.hasFocus = false
				display.getCurrentStage():setFocus( nil )
			end
			return true
		end
		return false
	end
	group:addEventListener( "touch", group )
	
	function group:stopTouch()
		group:removeEventListener( "touch", group )
	end
	
	function group:tap(e)
		if (group.canDelete) then
			group:removeSelf()
			callback()
		end
		return true
	end
	group:addEventListener("tap",group)
	
	return group
end
main.functions.newDragSpot = newDragSpot

local function newLine( parent, ax, ay, bx, by, callback, labelA, labelB, radiusA, radiusB, colourA, colourB )
	local group = display.newGroup()
	parent:insert( group )
	
	local a, b = nil, nil
	
	local line = display.newLine( group, ax, ay, bx, by )
	line.strokeWidth = 4
	line.stroke = {0,0,1}
	
	function group:update( ax, ay, bx, by )
		line:removeSelf()
		line = display.newLine( group, ax, ay, bx, by )
		group:insert( 1, line )
		line.strokeWidth = 4
		line.stroke = {0,0,1}
		
		a.x, a.y = ax, ay
		b.x, b.y = bx, by
	end
	
	local function update( ax, ay, bx, by )
		group:update( ax, ay, bx, by )
		callback( group )
	end
	
	a = main.functions.newDragSpot( group, ax, ay, colourA or {1,0,0}, radiusA or 30, function(e) update( a.x, a.y, b.x, b.y ) end, labelA )
	b = main.functions.newDragSpot( group, bx, by, colourB or {1,0,0}, radiusB or 30, function(e) update( a.x, a.y, b.x, b.y ) end, labelB )
	
	group.a, group.b = a, b
	
	return group
end
main.functions.newLine = newLine

local function newPolygon( parent, callback, allowAdd, isClosed )
	local group = display.newGroup()
	parent:insert( group )
	
	local background = display.newRect( group, display.actualContentWidth/2, display.actualContentHeight/2, display.actualContentWidth, display.actualContentHeight )
	background.fill = {0,0,0,0}
	background.isHitTestable = true
	
	local lines, spots = display.newGroup(), display.newGroup()
	group:insert( lines )
	group:insert( spots )
	group.lines, group.spots = lines, spots
	
	function group:update(target)
		while (lines.numChildren > 0) do
			lines[1]:removeSelf()
		end
		
		for i=2, spots.numChildren do
			local line = display.newLine( lines, spots[i-1].x, spots[i-1].y, spots[i].x, spots[i].y )
			line.strokeWidth = 4
			line.stroke = {0,0,1}
		end
		
		if ((isClosed == nil or isClosed == true) and spots.numChildren > 1) then
			local line = display.newLine( lines, spots[1].x, spots[1].y, spots[spots.numChildren].x, spots[spots.numChildren].y )
			line.strokeWidth = 4
			line.stroke = {0,0,1}
		end
		
		callback( group )
	end
	
	function group:tap(e)
		local spot = main.functions.newDragSpot( spots, e.x, e.y, {1,0,0}, 30, function(e) group:update(e) end )
		spot.canDelete = true
		group:update()
		return true
	end
	
	if (allowAdd == nil or allowAdd == true) then
		background:addEventListener("tap",group)
	else
		background.alpha = 0
	end
	
	return group
end
main.functions.newPolygon = newPolygon

--[[ Menu ]]--
local function menu()
	local scene = composer.newScene("menu")
	
	local function touch(e)
		if (e.phase == "ended") then
			composer.gotoScene( e.target.item.scene, { effect="fade", time=500 } )
		end
		return true
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen)
		for i=1, #main.list do
			local button = display.newText{ parent=sceneGroup, x=20, y=i*30, text=main.list[i].label, fontSize=20 }
			button.x = 20 + button.width/2
			button.item = main.list[i]
			button:addEventListener("touch",touch)
			print(button.text)
		end
	end
	
	function scene:show( event )
		local phase = event.phase

		if (phase == "will") then
			transition.to( back, { time=500, alpha=0 } )
		end
	end
	
	function scene:hide( event )
		local phase = event.phase

		if (phase == "will") then
			transition.to( back, { time=500, alpha=1 } )
		end
	end
	
	scene:addEventListener( "create", scene )
	scene:addEventListener( "show", scene )
	scene:addEventListener( "hide", scene )
	
	return scene
end
main.scenes.menu = menu
main.scenes.menu()

--[[ lengthOf ]]--
local function lengthOf()
	local scene = composer.newScene("lengthOf")
	
	local line = nil
	local label = nil
	
	local function update( target )
		print(target.a, target.b)
		local len = math.lengthOf( target )
		label.text = len
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.lengthOf( ptA, ptB )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		label = display.newText{ parent=sceneGroup, x=display.actualContentWidth/2, y=60, text="", fontSize=20 }
		
		line = main.functions.newLine( sceneGroup, 100, 100, 400, 100, update )
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.lengthOf = lengthOf
main.scenes.lengthOf()

--[[ angleOf( centre, ptA, ptB ) ]]--
local function angleOf()
	local scene = composer.newScene("angleOf")
	
	local lineA, lineB = nil, nil
	local labelA, labelB, labelC = nil, nil, nil
	
	local function update( target )
		lineA:update( lineB.a.x, lineB.a.y, lineA.b.x, lineA.b.y )
		lineB:update( lineB.a.x, lineB.a.y, lineB.b.x, lineB.b.y )
		
		local a = math.angleOf( lineA.a )
		local b = math.angleOf( lineA.a, lineA.b )
		local c = math.angleOf( lineA.a, lineA.b, lineB.b )
		
		labelA.text = "Angle at A from (0,0): "..a
		labelB.text = "Angle of B from A: "..b
		labelC.text = "Angle between B and C at A: "..c
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.angleOf( centre, ptA, ptB )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		labelA = display.newText{ parent=sceneGroup, x=display.actualContentWidth/2, y=60, text="", fontSize=20 }
		labelB = display.newText{ parent=sceneGroup, x=display.actualContentWidth/2, y=90, text="", fontSize=20 }
		labelC = display.newText{ parent=sceneGroup, x=display.actualContentWidth/2, y=120, text="", fontSize=20 }
		
		lineA = main.functions.newLine( sceneGroup, 100, 150, 400, 100, update, "A", "B" )
		lineB = main.functions.newLine( sceneGroup, 100, 150, 400, 200, update, "A", "C" )
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.angleOf = angleOf
main.scenes.angleOf()

--[[ isPointInAngle( centre, first, second, point ) ]]--
local function isPointInAngle()
	local scene = composer.newScene("isPointInAngle")
	
	local lineA, lineB = nil, nil
	local point = nil
	local label = nil
	
	local function update( target )
		lineA:update( lineB.a.x, lineB.a.y, lineA.b.x, lineA.b.y )
		lineB:update( lineB.a.x, lineB.a.y, lineB.b.x, lineB.b.y )
		
		if (math.isPointInAngle( lineA.a, lineA.b, lineB.b, point )) then
			label.text = "Point is in Angle"
			label.fill = {0,1,0}
			label.x = display.contentCenterX
		else
			label.text = "Point is NOT in Angle"
			label.fill = {1,0,0}
			label.x = display.contentCenterX
		end
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.isPointInAngle( centre, first, second, point )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		label = display.newText{ parent=sceneGroup, x=display.actualContentWidth/2, y=60, text="", fontSize=20 }
		
		lineA = main.functions.newLine( sceneGroup, 100, 150, 400, 100, update, "A", "B" )
		lineB = main.functions.newLine( sceneGroup, 100, 150, 400, 200, update, "A", "C" )
		
		point = main.functions.newDragSpot( sceneGroup, 250, 100, {0,1,0}, 30, update, "" )
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.isPointInAngle = isPointInAngle
main.scenes.isPointInAngle()

--[[ isPointConcave( centre, first, second, point ) ]]--
local function isPointConcave()
	local scene = composer.newScene("isPointConcave")
	
	local lineA, lineB = nil, nil
	local label = nil
	
	local function update( target )
		lineA:update( lineB.a.x, lineB.a.y, lineA.b.x, lineA.b.y )
		lineB:update( lineB.a.x, lineB.a.y, lineB.b.x, lineB.b.y )
		
		if (math.isPointConcave( lineA.b, lineA.a, lineB.b )) then
			label.text = "Point B is Concave"
			label.fill = {0,1,0}
			label.x = display.contentCenterX
		else
			label.text = "Point B is NOT Concave"
			label.fill = {1,0,0}
			label.x = display.contentCenterX
		end
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.isPointConcave( a, pt, c )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		label = display.newText{ parent=sceneGroup, x=display.actualContentWidth/2, y=60, text="", fontSize=20 }
		
		lineA = main.functions.newLine( sceneGroup, 100, 150, 400, 100, update, "Pt", "A" )
		lineB = main.functions.newLine( sceneGroup, 100, 150, 400, 200, update, "Pt", "C" )
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.isPointConcave = isPointConcave
main.scenes.isPointConcave()

--[[ angleBetweenLines ]]--
local function angleBetweenLines()
	local scene = composer.newScene("angleBetweenLines")
	
	local lineA, lineB = nil, nil
	local label = nil
	
	local function update( target )
		local angle = math.angleBetweenLines( lineA, lineB )
		label.text = angle
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.angleBetweenLines( lineA, lineB )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		label = display.newText{ parent=sceneGroup, x=display.actualContentWidth/2, y=60, text="", fontSize=20 }
		
		lineA = main.functions.newLine( sceneGroup, 100, 100, 400, 100, update )
		lineB = main.functions.newLine( sceneGroup, 100, 200, 400, 200, update )
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.angleBetweenLines = angleBetweenLines
main.scenes.angleBetweenLines()

--[[ math.getLineIntersection = function( a, b, c, d ) ]]--
local function getLineIntersection()
	local scene = composer.newScene("getLineIntersection")
	
	local polygon = nil
	local lineA = nil
	local dots = nil
	
	local function update( target )
		local intersected = 0
		
		for i=1, polygon.spots.numChildren-1 do
			local lineB = { a=polygon.spots[i], b=polygon.spots[i+1] }
			
			local dointersect, x, y = math.getLineIntersection( lineA, lineB )
			
			if (dointersect) then
				intersected = intersected + 1
				
				if (dots[intersected] == nil) then
					display.newCircle( dots, 0, 0, 5 )
				end
				
				local dot = dots[intersected]
				dot.alpha = 1
				dot.x, dot.y = x, y
			end
		end
		
		for i=intersected+1, dots.numChildren do
			dots[i].alpha = 0
		end
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.getLineIntersection( lineA, lineB )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		lineA = main.functions.newLine( sceneGroup, 100, 100, 400, 100, update )
		
		polygon = main.functions.newPolygon( sceneGroup, update, nil, false )
		
		dots = display.newGroup()
		sceneGroup:insert( dots )
		
		polygon:tap( {x=100, y=200} )
		polygon:tap( {x=400, y=200} )
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.getLineIntersection = getLineIntersection
main.scenes.getLineIntersection()

--[[ math.reflectPointAcrossLine = function( line, pt ) ]]--
local function reflectPointAcrossLine()
	local scene = composer.newScene("reflectPointAcrossLine")
	
	local line = nil
	local ptA, ptB = nil, nil
	
	local function update( target )
		if (target == ptB) then
			local pt = math.reflectPointAcrossLine( line, ptB )
			ptA.x, ptA.y = pt.x, pt.y
		else
			local pt = math.reflectPointAcrossLine( line, ptA )
			ptB.x, ptB.y = pt.x, pt.y
		end
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.reflectPointAcrossLine( line, pt )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		line = main.functions.newLine( sceneGroup, 100, 200, 400, 200, update )
		
		ptA = main.functions.newDragSpot( sceneGroup, 250, 100, {0,1,0}, 30, update, "" )
		ptB = main.functions.newDragSpot( sceneGroup, 250, 300, {0,0,1}, 30, update, "" )
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.reflectPointAcrossLine = reflectPointAcrossLine
main.scenes.reflectPointAcrossLine()

--[[ polygonArea( points ) ]]--
local function polygonArea()
	local scene = composer.newScene("polygonArea")
	
	local polygon = nil
	local label = nil
	
	local function update( target )
		local a = math.polygonArea( polygon.spots )
		label.text = a
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.polygonArea( points )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		polygon = main.functions.newPolygon( sceneGroup, update )
		
		label = display.newText{ parent=sceneGroup, x=display.actualContentWidth/2, y=60, text="", fontSize=20 }
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.polygonArea = polygonArea
main.scenes.polygonArea()

--[[ isPolygonConcave( points ) ]]--
local function isPolygonConcave()
	local scene = composer.newScene("isPolygonConcave")
	
	local polygon = nil
	local label = nil
	
	local function update( target )
		local a = math.isPolygonConcave( polygon.spots )
		
		if (a) then
			label.text = "Concave"
		else
			label.text = "Convex"
		end
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.isPolygonConcave( points )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		polygon = main.functions.newPolygon( sceneGroup, update )
		
		label = display.newText{ parent=sceneGroup, x=display.actualContentWidth/2, y=60, text="", fontSize=20 }
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.isPolygonConcave = isPolygonConcave
main.scenes.isPolygonConcave()

--[[ isPointInPolygon( points ) ]]--
local function isPointInPolygon()
	local scene = composer.newScene("isPointInPolygon")
	
	local polygon = nil
	local label = nil
	local point = nil
	
	local function update()
		local a = math.isPointInPolygon( polygon.spots, point )
		
		if (a) then
			label.text = "Inside"
		else
			label.text = "Outside"
		end
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.isPointInPolygon( points )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		polygon = main.functions.newPolygon( sceneGroup, update )
		
		point = main.functions.newDragSpot( sceneGroup, display.actualContentWidth/2, display.actualContentHeight/2, {0,1,0}, 30, update )
		
		label = display.newText{ parent=sceneGroup, x=display.actualContentWidth/2, y=60, text="", fontSize=20 }
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.isPointInPolygon = isPointInPolygon
main.scenes.isPointInPolygon()

--[[ getPolygonIntersection( ... ) ]]--
local function getPolygonIntersection()
	local scene = composer.newScene("getPolygonIntersection")
	
	local polygonA, polygonB = nil, nil
	local overlay = nil
	local intersect = nil
	local dot = nil
	
	local function update()
		local intersect = math.getPolygonIntersection( polygonA.spots, polygonB.spots )
		
		while (overlay.numChildren > 0) do
			overlay[1]:removeSelf()
		end
		
		if (#intersect > 3) then
			-- get dimensions of polygon's bounding box
			local centroid = math.getBoundingCentroid( intersect )
			
			-- adjust vertices of polygon to be centred around the centre of the polygon's bounding box
			local polygon, bounds = math.centrePolygon( intersect )
			
			-- render polygon fill
			display.newPolygon( overlay, bounds.x, bounds.y, math.pointsToTable( intersect ) ).fill = {0,1,0,.5}
			
			-- render centroid point
			display.newCircle( overlay, centroid.centroid.x, centroid.centroid.y, 5 )
			
			-- render white outline, line for line
			for i=1, #polygon-1 do
				local line = display.newLine( overlay, polygon[i].x+centroid.centroid.x, polygon[i].y+centroid.centroid.y, polygon[i+1].x+centroid.centroid.x, polygon[i+1].y+centroid.centroid.y )
				line.stroke = {1,1,1}
				line.strokeWidth = 3
			end
			local line = display.newLine( overlay, polygon[1].x+centroid.centroid.x, polygon[1].y+centroid.centroid.y, polygon[#polygon].x+centroid.centroid.x, polygon[#polygon].y+centroid.centroid.y )
			line.stroke = {1,1,1}
			line.strokeWidth = 3
		end
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.getPolygonIntersection( subject, clip )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		polygonA = main.functions.newPolygon( sceneGroup, update, false )
		polygonB = main.functions.newPolygon( sceneGroup, update, false )
		
		overlay = display.newGroup()
		sceneGroup:insert( overlay )
		
		polygonA:tap( {x=display.actualContentWidth*.3, y=display.actualContentHeight*.3} )
		polygonA:tap( {x=display.actualContentWidth*.4, y=display.actualContentHeight*.3} )
		polygonA:tap( {x=display.actualContentWidth*.45, y=display.actualContentHeight*.4} )
		polygonA:tap( {x=display.actualContentWidth*.45, y=display.actualContentHeight*.5} )
		polygonA:tap( {x=display.actualContentWidth*.4, y=display.actualContentHeight*.6} )
		polygonA:tap( {x=display.actualContentWidth*.3, y=display.actualContentHeight*.6} )
		polygonA:tap( {x=display.actualContentWidth*.25, y=display.actualContentHeight*.5} )
		polygonA:tap( {x=display.actualContentWidth*.25, y=display.actualContentHeight*.4} )
		
		polygonB:tap( {x=display.actualContentWidth*.6, y=display.actualContentHeight*.3} )
		polygonB:tap( {x=display.actualContentWidth*.7, y=display.actualContentHeight*.3} )
		polygonB:tap( {x=display.actualContentWidth*.75, y=display.actualContentHeight*.4} )
		polygonB:tap( {x=display.actualContentWidth*.75, y=display.actualContentHeight*.5} )
		polygonB:tap( {x=display.actualContentWidth*.7, y=display.actualContentHeight*.6} )
		polygonB:tap( {x=display.actualContentWidth*.6, y=display.actualContentHeight*.6} )
		polygonB:tap( {x=display.actualContentWidth*.55, y=display.actualContentHeight*.5} )
		polygonB:tap( {x=display.actualContentWidth*.55, y=display.actualContentHeight*.4} )
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.getPolygonIntersection = getPolygonIntersection
main.scenes.getPolygonIntersection()

--[[ closestLineAndPoint( points, pt ) ]]--
local function closestLineAndPoint()
	local scene = composer.newScene("closestLineAndPoint")
	
	local polygon = nil
	local line = nil
	
	local function update()
		if (line and polygon) then
			local found = math.closestLineAndPoint( line.b, polygon.spots )
			
			for i=1, polygon.lines.numChildren or #polygon.lines do
				local pt = found[1]
				if (i == pt.index) then
					polygon.lines[i].fill = {0,1,0}
				else
					polygon.lines[i].fill = {0,0,1}
				end
				line:update( pt.pt.x, pt.pt.y, line.b.x, line.b.y )
			end
		end
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.closestLineAndPoint( pt, points )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		polygon = main.functions.newPolygon( sceneGroup, update )
		polygon:tap( {x=display.actualContentWidth*.35, y=display.actualContentHeight*.35} )
		polygon:tap( {x=display.actualContentWidth*.45, y=display.actualContentHeight*.15} )
		polygon:tap( {x=display.actualContentWidth*.55, y=display.actualContentHeight*.35} )
		polygon:tap( {x=display.actualContentWidth*.75, y=display.actualContentHeight*.45} )
		polygon:tap( {x=display.actualContentWidth*.55, y=display.actualContentHeight*.55} )
		polygon:tap( {x=display.actualContentWidth*.45, y=display.actualContentHeight*.75} )
		polygon:tap( {x=display.actualContentWidth*.35, y=display.actualContentHeight*.55} )
		polygon:tap( {x=display.actualContentWidth*.15, y=display.actualContentHeight*.45} )
		
		line = main.functions.newLine( sceneGroup, 100, 100, 400, 100, update, nil, nil, 15, 30, {1,1,1}, {0,1,0} )
		line.a:stopTouch()
		
		update()
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.closestLineAndPoint = closestLineAndPoint
main.scenes.closestLineAndPoint()

--[[ closestPolygonIntersection( a, b, polygon ) ]]--
local function closestPolygonIntersection()
	local scene = composer.newScene("closestPolygonIntersection")
	
	local polygon = nil
	local line = nil
	local points = {}
	
	local function update()
		if (polygon and line) then
			local found = math.polygonLineIntersection( polygon.spots, line.a, line.b, true )
			
			for i=1, #points do
				local point = points[i]
				point.isVisible = (i <= #found)
				if (point.isVisible) then
					point.x, point.y = found[i].x, found[i].y
				end
			end
		end
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.closestPolygonIntersection( a, b, polygon )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		polygon = main.functions.newPolygon( sceneGroup, update )
		polygon:tap( {x=display.actualContentWidth*.35, y=display.actualContentHeight*.35} )
		polygon:tap( {x=display.actualContentWidth*.45, y=display.actualContentHeight*.15} )
		polygon:tap( {x=display.actualContentWidth*.55, y=display.actualContentHeight*.35} )
		polygon:tap( {x=display.actualContentWidth*.75, y=display.actualContentHeight*.45} )
		polygon:tap( {x=display.actualContentWidth*.55, y=display.actualContentHeight*.55} )
		polygon:tap( {x=display.actualContentWidth*.45, y=display.actualContentHeight*.75} )
		polygon:tap( {x=display.actualContentWidth*.35, y=display.actualContentHeight*.55} )
		polygon:tap( {x=display.actualContentWidth*.15, y=display.actualContentHeight*.45} )
		
		line = main.functions.newLine( sceneGroup, 100, 100, 400, 100, update, nil, nil, 30, 30, {0,1,0}, {0,0,1} )
		
		for i=1, 10 do
			local point = main.functions.newDragSpot( sceneGroup, 250, 200, {1,1,1}, 25-(2*i), nil, "" )
			point.alpha = 1-(i/10)
			points[ #points+1 ] = point
		end
		
		update()
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.closestPolygonIntersection = closestPolygonIntersection
main.scenes.closestPolygonIntersection()

--[[ math.bouncePointAgainstLine = function( line, pt ) ]]--
local function bouncePointAgainstLine()
	local scene = composer.newScene("bouncePointAgainstLine")
	
	local lineA, lineB = nil, nil
	local reflect, bounce, inter, velocity = nil, nil, nil, nil
	
	local function update( target )
		local point = { x=lineB.b.x, y=lineB.b.y, velocity={ x=lineB.a.x-lineB.b.x, y=lineB.a.y-lineB.b.y } }
		local success, a, b, c = math.bouncePointAgainstLine( lineA, point ) -- bounced point, reflected point, intersection
		
		reflect.isVisible = not (c == nil)
		bounce.isVisible = not (c == nil)
		inter.isVisible = not (c == nil)
		velocity.isVisible = not (c == nil)
		
		if (c ~= nil) then
			bounce.x, bounce.y = a.x, a.y
			reflect.x, reflect.y = b.x, b.y
			inter.x, inter.y = c.x, c.y
			velocity.x, velocity.y = a.x+a.velocity.x, a.y+a.velocity.y
		end
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.bouncePointAgainstLine( line, pt )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		lineA = main.functions.newLine( sceneGroup, 100, 100, 400, 100, update )
		lineB = main.functions.newLine( sceneGroup, 350, 200, 450, 300, update )
		
		lineB.a.spot.fill = {0,1,0}
		lineB.b.spot.fill = {0,0,1}
		
		reflect = main.functions.newDragSpot( sceneGroup, 250, 100, {0,0,1}, 20, update, "a" )
		bounce = main.functions.newDragSpot( sceneGroup, 200, 100, {0,1,0}, 20, update, "b" )
		inter = main.functions.newDragSpot( sceneGroup, 200, 100, {1,0,0}, 20, update, "c" )
		velocity = main.functions.newDragSpot( sceneGroup, 200, 100, {1,1,1}, 10, update, "d" )
		
		update()
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.bouncePointAgainstLine = bouncePointAgainstLine
main.scenes.bouncePointAgainstLine()

--[[ bouncePointAgainstPolygon( points, pt ) ]]--
local function bouncePointAgainstPolygon()
	local scene = composer.newScene("bouncePointAgainstPolygon")
	
	local polygon = nil
	local line = nil
	local bounce = nil
	local point = nil
	
	local function update()
		if (line and bounce and polygon) then
			local velocity = { x=line.b.x-line.a.x, y=line.b.y-line.a.y }
			local pt = { x=line.a.x, y=line.a.y, velocity=velocity }
			
			local reflect, found = math.bouncePointAgainstPolygon( polygon.spots, pt )
			
			point.isVisible = (#found > 0)
			
			if (#found > 0) then
				while (bounce.numChildren > 0) do
					bounce[1]:removeSelf()
				end
				
				for i=1, #found do
					display.newCircle( bounce, found[1].x, found[1].y, 5 )
				end
				
				local l = nil
				if (#found == 1) then
					l = display.newLine( bounce, found[1].x, found[1].y, reflect.x+reflect.velocity.x, reflect.y+reflect.velocity.y )
				elseif (#found > 1) then
					l = display.newLine( bounce, found[1].x, found[1].y, found[2].x, found[2].y )
					
					for i=3, #found do
						l:append( found[i].x, found[i].y )
					end
				
					l:append( reflect.x+reflect.velocity.x, reflect.y+reflect.velocity.y )
				end
				
				l.strokeWidth = 3
				
				point.x, point.y = reflect.x+reflect.velocity.x, reflect.y+reflect.velocity.y
				
--				bounce:update( found[1].x, found[1].y, reflect.x, reflect.y )
			end
		end
	end
	
	function scene:create( event )
		local sceneGroup = self.view
		
		-- Called when the scene is still off screen (but is about to come on screen).
		local button = display.newText{ parent=sceneGroup, x=20, y=20, text="math.bouncePointAgainstPolygon( pt, points )", fontSize=20 }
		button.x = 20 + button.width/2
		button.fill = {.5,.75,1}
		
		polygon = main.functions.newPolygon( sceneGroup, update )
		polygon:tap( {x=display.actualContentWidth*.30, y=display.actualContentHeight*.35} )
		polygon:tap( {x=display.actualContentWidth*.70, y=display.actualContentHeight*.35} )
		polygon:tap( {x=display.actualContentWidth*.70, y=display.actualContentHeight*.70} )
		polygon:tap( {x=display.actualContentWidth*.30, y=display.actualContentHeight*.70} )
		polygon:tap( {x=display.actualContentWidth*.05, y=display.actualContentHeight*.4} )
		polygon:tap( {x=display.actualContentWidth*.27, y=display.actualContentHeight*.6} )
		
		line = main.functions.newLine( sceneGroup, 100, 100, 400, 400, update, nil, nil, 30, 30, {0,1,0}, {0,0,1} )
		
		bounce = display.newGroup()
		sceneGroup:insert( bounce )
		
--		bounce = main.functions.newLine( sceneGroup, 100, 150, 400, 150, nil, nil, nil, 15, 15, {1,1,1}, {0,1,0} )
--		bounce.a:stopTouch()
--		bounce.b:stopTouch()
		
		point = main.functions.newDragSpot( sceneGroup, 250, 200, {0,1,1}, 15, nil, "B" )
		
		update()
	end
	
	scene:addEventListener( "create", scene )
	
	return scene
end
main.scenes.bouncePointAgainstPolygon = bouncePointAgainstPolygon
main.scenes.bouncePointAgainstPolygon()

--[[ Go to main menu ]]--
back:touch{ phase="ended" }
