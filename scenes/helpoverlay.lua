
local composer = require( "composer" )
local col = require( "data.colors" )
local dbg = require( "lib.debugging" )
local opt = require( "game.options" )
local widget = require( "widget" )

-- -----------------------------------------------------------------------------------

local scene = composer.newScene()

local TAG = "helpoverlay.lua"

-- -----------------------------------------------------------------------------------

local helpText = {}
helpText.size = [[
Board Size:

Choose the number of tiles in each row and column of the board.

The greater the number of tiles, the more difficult it is to solve each word square.
]]
helpText.time = [[
Time (mins):

Choose the duration of each game in minutes.

Note that choosing the '-' option means that each game has an unlimited duration.
]]
helpText.hints = [[
Hints Available:

Choose the maximum number of word hints available to be used.

Using a word hint will identify the letters belonging to one word within the word square.

Note that you will still need to arrange identified letters into the correct order in a row. Once arranged into the correct order, the tiles will be shaded in a solid colour and the word will be listed in the found words panel.
]]
helpText.skips = [[
Skips Available:

Choose the maximum number of word square skips available to be used.

Using a word square skip will abandon the current square and move to the next square.
]]

helpText.firstRun = [[
Welcome to Word Square Scramble!

A word square consists of a group of words set out in a square grid, such that the same words can be read both horizontally and vertically.

The aim of the game is to solve randomly generated word squares by sliding letter tiles within the game board. Each board is capable of arrangement into a word square.

Once a correct word has been identified in a row (not a column), its tiles will change colour to indicate that it is a correct word - but not necessarily in the correct row.

Use the Instructions menu option for further information.


Tap to continue.
]]


-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

function scene:showHelp( option )

	textHelp.text = helpText[option]
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local border = 20
	scrollView = widget.newScrollView 
    	{
	        width = display.actualContentWidth * 0.85,
	        height = display.actualContentHeight * 0.7,
        	hideBackground = false,
        	backgroundColor = col.colOverlay,
        	horizontalScrollDisabled = true,
        	verticalScrollDisabled = false
    }
	scrollView.x = display.contentCenterX
	scrollView.y = display.contentCenterY    
    textHelp = display.newText( "", border, border, scrollView.width - 2 * border, scrollView.height * 2, opt.defaultFont, 35 )
    textHelp.anchorX, textHelp.anchorY = 0, 0
    textHelp:setFillColor( unpack(col.colIvory) )
    scrollView:insert( textHelp )
    sceneGroup:insert( scrollView )

    -- respond to the overlay being pressed
    function scrollView:tap( event )
    	composer.hideOverlay( "fade", 400 )
    end
    scrollView:addEventListener( "tap", scrollView )

end

-- -----------------------------------------------------------------------------------
-- show()

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		local helpID = event.params.helpID
		assert( helpID == "size" or helpID == "time" or helpID == "skips" or helpID == "hints" or helpID == "firstRun" )
		scene:showHelp( helpID )
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

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
	scrollView:removeEventListener( "tap" )
        
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
