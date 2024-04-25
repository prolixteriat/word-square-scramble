
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------

local TAG = "gameover.lua"

-- ---------------------------------------------------------------------------------------

local filePath = "scenes/img/"

-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

function scene:showMessage( messageID )

	if( messageID == "gameover" ) then 
		gameOverImage.isVisible = true
	elseif( messageID == "squaresolved" ) then 
		squareSolvedImage.isVisible = true
	elseif( messageID == "skipped" ) then 
		squareSkippedImage.isVisible = true
	else
		dbg.errorMessage( TAG, "scene:showMessage", messageID )
	end
	return
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()

function scene:create( event )

	-- print( "*** gameover:create()" )
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	messageID = nil

	local w = display.actualContentWidth * 0.9
	local h = w * 348 / 470  -- ( h / w )
	gameOverImage   = display.newImageRect(sceneGroup, filePath .. "gameover.png", w, h)
	gameOverImage.x = display.contentCenterX
	gameOverImage.y = display.contentCenterY
	gameOverImage.isVisible = false

	local h = w * 333 / 658 -- ( h / w )
	squareSolvedImage   = display.newImageRect(sceneGroup, filePath .. "squaresolved.png", w, h)
	squareSolvedImage.x = display.contentCenterX
	squareSolvedImage.y = display.contentCenterY * 1.3
	squareSolvedImage.isVisible = false

	local h = w * 239 / 653 -- ( h / w )
	squareSkippedImage   = display.newImageRect(sceneGroup, filePath .. "skipped.png", w, h)
	squareSkippedImage.x = display.contentCenterX
	squareSkippedImage.y = display.contentCenterY * 1.3
	squareSkippedImage.isVisible = false

    -- respond to an image being pressed
    function gameOverImage:tap(event)
    	composer.hideOverlay( "fade", 400 )
    end
    gameOverImage:addEventListener( "tap", gameOverImage )
	squareSolvedImage:addEventListener( "tap", gameOverImage )
	squareSkippedImage:addEventListener( "tap", gameOverImage )
end

-- -----------------------------------------------------------------------------------
-- show()

function scene:show( event )

	-- print( "*** gameover:show()" )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		messageID = event.params.messageID
		assert( messageID == "gameover" or messageID == "squaresolved" or messageID == "skipped" )
		scene:showMessage( messageID )

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end

-- -----------------------------------------------------------------------------------
-- hide()

function scene:hide( event )

	-- print( "*** gameover:hide()" )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		gameOverImage.isVisible = false
		squareSolvedImage.isVisible = false
		squareSkippedImage.isVisible = false
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
        local scene = composer.getScene( "scenes.scene_game" )                        
        if( scene ) then 
        	if( messageID == "squaresolved") then 
        		scene:nextSquare()
        	elseif( messageID == "skipped" ) then 
        		scene:nextSquare()
        	elseif( messageID == "gameover" ) then 
        		composer.setVariable( "queryRestart", false )
        		scene:restartGame()
        	end
        end
	end
end

-- -----------------------------------------------------------------------------------
-- destroy()

function scene:destroy( event )

	-- print( "*** gameover:destroy()" )
	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	gameOverImage:removeEventListener( "tap" )
    -- squareSolvedImage:removeEventListener( "tap" )
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
