
local composer = require( "composer" )
local col = require( "data.colors" )
local data = require( "data.words" )
local dbg = require( "lib.debugging" )
local hi = require( "game.highscores" )
local hlp = require( "lib.helper" )
local menu = require( "scenes.menubar" )
local opt = require( "game.options" )

-- -----------------------------------------------------------------------------------

local TAG = "scene_highscores.lua"

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------

local border    = 25
local fontSize  = 35
local ox, oy    = display.screenOriginX, display.screenOriginY
local textColor = col.colIvory

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------
-- create the visual option controls and add to group

function scene:createControls( group )

	scoreDisplay = {}
	local textY = oy + 100
	local highScoresHeader = display.newText( group, "High Scores", display.contentCenterX, textY, opt.defaultFont, fontSize * 2 )
	
	display.setDefault( "anchorX", 0 )
	display.setDefault( "anchorY", 0 )

	local gapY = 80
	local textX = ox + 20
	textY = textY + gapY + 50
	local txtBS = display.newText( group, "Board size:", textX, textY, opt.defaultFont, fontSize, "left" )
	local txtSS = display.newText( group, "Squares solved:", textX, txtBS.y + fontSize + gapY, opt.defaultFont, fontSize, "left" )
	local txtSU = display.newText( group, "Skips used:", textX, txtSS.y + fontSize + gapY, opt.defaultFont, fontSize, "left" )
	local txtHU = display.newText( group, "Hints used:", textX, txtSU.y + fontSize + gapY, opt.defaultFont, fontSize, "left" )
	local txtTL = display.newText( group, "Time limit:\n(mins)", textX, txtHU.y + fontSize + gapY, opt.defaultFont, fontSize, "left" )

	local gapX = (display.actualContentWidth - (txtSS.x + txtSS.width)) / 4
	for i = data.minWordLen, data.maxWordLen do 
		textX = txtSS.x + txtSS.width + 50 + gapX * (i - 4)
		scoreDisplay[i] = {}
		local txt = display.newText( group, tostring(i), textX, txtBS.y, opt.defaultFont, fontSize, "left" )
		scoreDisplay[i].boardSize = txt
		txt  = display.newText( group, "-", textX, txtSS.y, opt.defaultFont, fontSize, "left" )
		scoreDisplay[i].solvedSquares = txt
		txt  = display.newText( group, "-", textX, txtSU.y, opt.defaultFont, fontSize, "left" )
		scoreDisplay[i].usedSkips = txt
		txt  = display.newText( group, "-", textX, txtHU.y, opt.defaultFont, fontSize, "left" )
		scoreDisplay[i].usedHints = txt
		txt  = display.newText( group, "-", textX, txtTL.y, opt.defaultFont, fontSize, "left" )
		scoreDisplay[i].timeLimit = txt
	end

	-- local l = display.newline( group, txtBS.x, txtBS.y, scoreDisplay[data.maxWordLen].timeLimit.x, scoreDisplay[data.maxWordLen].timeLimit.y )
	-- local l = display.newline( group, txtBS.x, txtBS.y, txtTL.x, txtTL.y )
	-- local l = display.newLine( group, 200, 90, 227, 165 )
	textY = txtBS.y + txtBS.height + gapY / 2
	local l = display.newLine( group, txtBS.x, 
			textY, 
			scoreDisplay[data.maxWordLen].boardSize.x + scoreDisplay[data.maxWordLen].boardSize.width, 
			textY )
	-- l:append( 305,165, 243,216, 265,290, 200,245, 135,290, 157,215, 95,165, 173,165, 200,90 )
	l:setStrokeColor( unpack( col.colRed) )
	l.strokeWidth = 4
	display.setDefault( "anchorX", 0.5 )
	display.setDefault( "anchorY", 0.5 )
	-- dbg.printTable( scoreDisplay )
end

-- -----------------------------------------------------------------------------------
-- create the visual option controls and add to group

function scene:showScores( group )

	-- print("*** scene_highscores:showScores()")
	-- dbg.printTable( hi.highScore )
	for i = data.minWordLen, data.maxWordLen do 
		-- local s = hi.highScore[tostring(i)]  -- score
		local s = hi.highScore[i]  -- score
		local d = scoreDisplay[i]  -- display
		-- dbg.printTable( s )
		d.solvedSquares.text = tostring(s.numSquares)
		d.usedSkips.text = tostring(s.numSkips)
		d.usedHints.text = tostring(s.numHints)
		if( s.timeLimit == 0 ) then 
			d.timeLimit.text = "-"
		else
			d.timeLimit.text = tostring(s.timeLimit)
		end
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	menubar = menu.createMenuBar( sceneGroup, TAG )
	scene:createControls( sceneGroup )
end

-- -----------------------------------------------------------------------------------
-- show()

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		menubar.hint.isVisible    = false
		menubar.skip.isVisible    = false		
		composer.setVariable( "queryRestart", false )
		scene:showScores()		
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		-- back:addEventListener( "tap" )
	end
end

-- -----------------------------------------------------------------------------------
-- hide()

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
	
	end
end

-- -----------------------------------------------------------------------------------
-- destroy()

function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	menubar = nil
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene

-- -----------------------------------------------------------------------------------
