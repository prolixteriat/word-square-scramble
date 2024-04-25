
local composer = require( "composer" )
local hlp = require( "lib.helper" )

-- -----------------------------------------------------------------------------------

local TAG = "scene_instructions.lua"

local scene = composer.newScene()

local col = require( "data.colors" )
local dbg = require( "lib.debugging" )
local hlp = require( "lib.helper" )
local menu = require( "scenes.menubar" )
local opt = require( "game.options" )
local widget = require( "widget" )

-- -----------------------------------------------------------------------------------

local filePath = "scenes/img/"


-- -----------------------------------------------------------------------------------
-- Scene functions
-- -----------------------------------------------------------------------------------

function scene:showInstructions( group )

		local s = [[
The aim of the game is to solve word squares by sliding tiles within the game board.

A word square consists of a group of words set out in a square grid such that the same words can be read both horizontally and vertically.

You will be presented with a randomly generated game board. Each board is capable of arrangement into a word square.

Once any correct word has been identified in a row (not a column), its tiles will change colour to indicate that it is a correct word - but not necessarily in the correct row. The square is solved when all words have been identified and moved to the correct rows.

Pressing the skip button will show you the solution to the current square before advancing to the next square.

Pressing the hint button will identify the letters belonging to one word within the current word square. Note that you will still need to arrange identified letters into the correct order in a row. Once arranged into the correct order, the tiles will be shaded in a solid colour and the word will be listed in the found words panel.

You can use the options button to select various game settings, including the number of skips and hints available within each game.

	]]

	local border = 20
	local mbHeight = 106   -- menubar height
	
	local scrollView = widget.newScrollView 
    	{
	        width = display.actualContentWidth,
	        height = (display.actualContentHeight  * 0.8) - mbHeight,
        	hideBackground = false,
        	backgroundColor = col.colGroup,
        	horizontalScrollDisabled = true,
        	verticalScrollDisabled = false
    }
	scrollView.x = display.contentCenterX
	scrollView.y = display.contentCenterY - mbHeight   
    
    local w = display.actualContentWidth * 0.3
	local h = w * 447 / 446  -- (h / w)
	local boardImage1 = display.newImageRect(filePath .. "game_01.png", w, h)
	boardImage1.x = border
	boardImage1.y = border
	boardImage1.anchorX, boardImage1.anchorY = 0, 0
    
    h = w * 443 / 443   -- (h / w)
    local boardImage2 = display.newImageRect(filePath .. "game_02.png", w, h)
	boardImage2.x = (display.actualContentWidth / 2) - (w / 2)
	boardImage2.y = border
	boardImage2.anchorX, boardImage2.anchorY = 0, 0

    h = w * 441 / 442   -- (h / w)
    local boardImage3 = display.newImageRect(filePath .. "game_04.png", w, h)
	boardImage3.x = display.actualContentWidth - w - border
	boardImage3.y = border
	boardImage3.anchorX, boardImage3.anchorY = 0, 0

    -- textHelp = display.newText( s, border, boardImage1.y+boardImage1.height + border, scrollView.width - 2 * border, scrollView.height * 2, opt.defaultFont, 35 )
    textHelp = display.newText( s, 
    	border, 
    	boardImage1.y+boardImage1.height + border, 
    	scrollView.width - 2 * border, 
    	scrollView.height, 
    	opt.defaultFont, 35 )
    textHelp.anchorX, textHelp.anchorY = 0, 0
    textHelp:setFillColor( unpack(col.colIvory) )


	w = display.actualContentWidth * 1.0
	h = w * 86 / 258  -- (h / w)
    local menubarImage = display.newImageRect(filePath .. "menubar.png", w, h)
	menubarImage.x = display.contentCenterX
	menubarImage.y = display.screenOriginY + display.actualContentHeight - mbHeight

    -- respond to the overlay being pressed
    function menubarImage:tap( event )
    	hlp.gotoScene( "scenes.scene_menu" )
    end
    menubarImage:addEventListener( "tap", menubarImage )

    scrollView:insert( boardImage1 )
    scrollView:insert( boardImage2 )
    scrollView:insert( boardImage3 )
    scrollView:insert( textHelp )
    group:insert( menubarImage )
    group:insert( scrollView )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	-- menubar = menu.createMenuBar( sceneGroup )
	scene:showInstructions( sceneGroup )
end

-- -----------------------------------------------------------------------------------
-- show()

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		-- menubar.hint.isVisible = false
		-- menubar.skip.isVisible = false				
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
	-- menubar = nil
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

