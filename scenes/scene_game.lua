
-- -----------------------------------------------------------------------------------

local brd = require( "game.board" )
local col = require( "data.colors" )
local composer = require( "composer" )
local dbg = require( "lib.debugging" )
local hlp = require( "lib.helper" )
local hi = require( "game.highscores" )
local menu = require( "scenes.menubar" )
local opt = require( "game.options" )
local over = require( "scenes.gameover" )
local sfx = require( "lib.sfx" )
local snd = require( "game.sounds" )
local widget = require( "widget" )
local words = require( "data.words" )

widget.setTheme( opt.widgetTheme )

-- -----------------------------------------------------------------------------------

local TAG = "scene_game.lua"

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- forward declarations 

local clockTime
local scoreGroup
local scoreHints
local scoreSkips
local scoreSolved 
local scoreWords
local scrollFoundWords
local textFoundWords

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Callback function called by board object ins response to a change in score.

local function updateScore()
    
    -- local phase = event.phase
	    
    scoreSolved.text = opt.score.numSquares
    scoreHints.text  = opt.gameOptions.hintCount - opt.score.numHints
    scoreSkips.text  = opt.gameOptions.skipCount - opt.score.numSkips
    
    -- re-populate the found words table to ensure most recent word is top of the list
    local w = ""
   	for i, v in ipairs( opt.score.wordsCurrent ) do
   		w = w .. v .. "\n"
   	end

   	textFoundWords.text = w
   	scrollFoundWords:scrollTo( "top", { time = 400 } )

   	hi.saveHighScores()
end

-- -----------------------------------------------------------------------------------
-- Callback function called by board object to update time text.

local function updateTime( event )

	local secs = event.secs
	 
    -- convert it to minutes and seconds
    local minutes = math.floor( secs / 60 )
    local seconds = secs % 60
	local timeDisplay = string.format( "%01d:%02d", minutes, seconds )
	     
    -- don't attempt to update if clockTime has not been created
    if( clockTime ) then 
    	clockTime.text = timeDisplay
    	if( secs == 10 ) then 
    		clockTime:setFillColor( 1, 0, 0 )
	   	end
    end
end

-- -----------------------------------------------------------------------------------
-- return the height/width of a single tile

local function getTileSize()

	local s = 0
	if( display.actualContentWidth < (display.actualContentHeight / 2) ) then 
		-- print(" opt 1")
		s = display.actualContentWidth / (opt.gameOptions.tileCount + 1)
	else
		-- print(" opt 1")
		s = display.actualContentHeight / (opt.gameOptions.tileCount + 8)
	end
	return s
end

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------
-- handle game over

function scene:gameOver( reason )

	local options = {
    	isModal = true,
    	effect = "fade",
    	time = 400,
    	params  = {
    				messageID = "gameover"
    			  }  
	}
 
	composer.showOverlay( "scenes.gameover", options )
	snd.playTimer( false )
	snd.playSound( snd.sounds.gameOver )
end

-- -----------------------------------------------------------------------------------
-- handle game over

function scene:showSquareSolvedMessage( msgID )

	local options = {
    	isModal = true,
    	effect = "fade",
    	time = 400,
    	params  = {
    				messageID = msgID
    			  }    	
	}
	composer.showOverlay( "scenes.gameover", options )
	snd.playTimer( false )	  		
end


-- -----------------------------------------------------------------------------------
-- Respond to a press of the hint button.

function scene:hint()
	
	board:hint()
	updateScore()
end

-- -----------------------------------------------------------------------------------
-- Next square following successful solve.

function scene:nextSquare()
	
	-- print( "*** scene_game:nextSquare()")
	board:nextSquare()
end

-- -----------------------------------------------------------------------------------
-- Respond to a press of the skip button.

function scene:squareSkipped()
	
	-- print( "*** scene_game:squareSkipped()")
	if( opt.score.numSkips >= opt.gameOptions.skipCount ) then 
		snd.playSound( snd.sounds.locked )
  		if( opt.gameOptions.haptic ) then
  			system.vibrate()
		end
	else
		board:pause()
 		opt.score.numSkips = opt.score.numSkips + 1
		board:solveSquare()
 		updateScore()
		scene:showSquareSolvedMessage( "skipped" )  -- scene:nextSquare() is called when this overlay is closed
	end
end

-- -----------------------------------------------------------------------------------
-- Respond to a successful square solution.

function scene:squareSolved()

 	board:pause()
 	opt.score.numSquares = opt.score.numSquares + 1
	updateScore()
	scene:showSquareSolvedMessage( "squaresolved" ) -- scene:nextSquare() is called when this overlay is closed
	snd.playSound( snd.sounds.solved )
end

-- -----------------------------------------------------------------------------------
-- Respond to a press of the skip button.

--[[
function scene:skip()
	
 	board:skip()

end
--]]

-- -----------------------------------------------------------------------------------
-- start a new game 

function scene:restartGame()

	-- start a new game
	local function restart()
		composer.setVariable( "queryRestart", true )
		opt.initScores()
		opt.status = "play"
		if( clockTime ) then 
			clockTime.text = ""
			clockTime:setFillColor( 1 )
		end
		board:restart( opt.gameOptions.tileCount, getTileSize() )
	end

	-- handler that gets notified when the alert closes
	local function onComplete( event )
	    if ( event.action == "clicked" ) then
	        local i = event.index
	        if ( i == 2 ) then
	        	-- yes pressed - start a new game
	        	restart()
	        elseif ( i == 1 ) then
	        	-- no pressed - continue current game
	            board:continueGame()
	        end
	    end
	end
	
	-- check whether instruction comes from a current game - if so, ask for confirmation
	local queryRestart = composer.getVariable( "queryRestart" )
	if( queryRestart ) then 
		native.showAlert( "New Game", "Do you want to abandon the current game?", { "No", "Yes" }, onComplete )
	else
		restart()
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
	local tileSize = getTileSize()
	composer.setVariable( "queryRestart", true )

	-- scores
	scoreGroup = display.newGroup()
	sceneGroup:insert( scoreGroup )
	local fontSize = 50
	local border = 30
	local textX = display.screenOriginX + border 
	
	local oy = display.screenOriginY + (opt.gameOptions.tileCount + 1.5) * tileSize
	local textColor = col.colIvory
    
	local textY = oy + fontSize * 4 
	
	local textSolved  = display.newText( scoreGroup, "Solved: ", textX, textY, opt.defaultFont, fontSize )
	textSolved.anchorX, textSolved.anchorY = 0, 0
	scoreSolved = display.newText( scoreGroup, "0", textSolved.x + textSolved.width + 10, textY, opt.defaultFont, fontSize )
    scoreSolved.anchorX, scoreSolved.anchorY = 0, 0
    scoreSolved:setFillColor( unpack(textColor) )	

	textY = textY + fontSize * 1.5
    local textSkips  = display.newText( scoreGroup, "Skips:", textX, textY, opt.defaultFont, fontSize )
	textSkips.anchorX, textSkips.anchorY = 0, 0
	scoreSkips = display.newText( scoreGroup, "0", scoreSolved.x, textY, opt.defaultFont, fontSize )
    scoreSkips.anchorX, scoreSkips.anchorY = 0, 0
    scoreSkips:setFillColor( unpack(textColor) )	

    textY = textY + fontSize * 1.5
    local textHints  = display.newText( scoreGroup, "Hints:", textX, textY, opt.defaultFont, fontSize )
	textHints.anchorX, textHints.anchorY = 0, 0
	scoreHints = display.newText( scoreGroup, "0", scoreSolved.x, textY, opt.defaultFont, fontSize )
	scoreHints.anchorX, scoreHints.anchorY = 0, 0
	scoreHints:setFillColor( unpack(textColor) )	

    -- found words
    scrollFoundWords = widget.newScrollView {
	        left = display.contentCenterX + 100,
	        top = scoreSolved.y,
	        width = display.actualContentWidth / 3,
	        height = menubar.menu.y - menubar.menu.height - scoreSolved.y,
        	hideBackground = false,
        	backgroundColor = col.colGroup,
        	horizontalScrollDisabled = true,
        	verticalScrollDisabled = false,
    }
    textFoundWords = display.newText( "", 0, 0, scrollFoundWords.width, scrollFoundWords.height * 4, opt.defaultFont, 40 )
    textFoundWords.anchorX, textFoundWords.anchorY = 0, 0
    textFoundWords:setFillColor( unpack(col.colIvory) )
    scrollFoundWords:insert( textFoundWords )
    sceneGroup:insert( scrollFoundWords )

	-- timer
	local f = 72
	local x = textSolved.x
	local y = menubar.menu.y - menubar.menu.height - f
	-- reposition timer if overlap with scores
	if( y <= (scoreHints.y + scoreHints.height) ) then 
		x = scoreHints.x + 100
	end
	clockTime = display.newText( {text="", x=x, y=y, font=opt.defaultFont, fontSize=f, align="left"} )
	clockTime.anchorX, clockTime.anchorY = 0, 0
	clockTime:setFillColor( 1 )
	sceneGroup:insert( clockTime )	

	board = brd.new( self, updateScore, updateTime, 
					  { rows = opt.gameOptions.tileCount, cols = opt.gameOptions.tileCount, width = tileSize, height = tileSize } )
	sceneGroup:insert( board )

	-- debug
   	function scoreSolved:tap(event)
    	textDebug.isVisible = not textDebug.isVisible
    	snd.playSound( snd.sounds.click )
    end
    function scoreSkips:tap(event)
    	board:solveSquare()
    end
    if( dbg.debug ) then 
		textY = textY + fontSize * 1.5
	    textDebug  = display.newText( scoreGroup, "", textX, textY, opt.defaultFont, 30 )
		textDebug.anchorX, textDebug.anchorY = 0, 0
		textDebug:setFillColor( unpack(col.colYellow) )	
    	textDebug.isVisible = false
    	scoreSolved:addEventListener( "tap", scoreSolved )	
    	scoreSkips:addEventListener( "tap", scoreSkips )	
	end

end

-- -----------------------------------------------------------------------------------
-- show()

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

		updateScore()
		menubar.hint.isVisible = true
		menubar.skip.isVisible = true
		
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		-- print("*** scene_game:show - did")
		-- print("scene_game:show - [board.status: " .. board:getStatus() .. "] - [opt.status: " .. opt.status .. " ]")
		if( board:getStatus() == "init" ) then 
			board:play()
		elseif( board:getStatus() == "ended" or opt.status == "restart" ) then 
			scene:restartGame()
		elseif( opt.status == "skip" ) then 
			board:skip()
		else
			board:play()
		end	
    	if( dbg.debug ) then 
			scene:debug()
		end
	end
end

-- -----------------------------------------------------------------------------------
-- hide()

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		-- print("*** scene_game:hide - will")
		if( board:getStatus() ~= "ended" ) then 
			board:pause()
		end
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		
		-- dbgButton:removeEventListener( "tap" )
	end
end

-- -----------------------------------------------------------------------------------
-- destroy()

function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end

-- -----------------------------------------------------------------------------------
-- Test functions
-- -----------------------------------------------------------------------------------

function scene:debug()
	
	if( dbg.debug and board ) then 
	local w = ""
	   	for i, v in pairs( board:getCurrentSquare() ) do
	   		w = w .. v .. ", "
	   	end
		textDebug.text = w
   	end
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
