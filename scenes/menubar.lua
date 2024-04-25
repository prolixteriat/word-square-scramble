-- -----------------------------------------------------------------------------------
-- Menu bard functionality.
-- -----------------------------------------------------------------------------------

local composer = require( "composer" )
local dbg      = require( "lib.debugging" )
local hlp      = require( "lib.helper" )
local opt      = require( "game.options" )
local snd      = require( "game.sounds" )
local widget   = require( "widget" )

-- -----------------------------------------------------------------------------------

local M = {}

local TAG = "menubar.lua"

-- -----------------------------------------------------------------------------------

local filePath = "scenes/img/buttons/"

local hVal = 106
local wVal = 96
local yVal = display.screenOriginY + display.actualContentHeight - hVal
local xVal = 300

-- -----------------------------------------------------------------------------------
-- Local functions
-- -----------------------------------------------------------------------------------
-- Display button based upon input parameters.

local function createButton( group, x, file, scene )

    local button = widget.newButton( {
        defaultFile = filePath  .. file .. ".png",
        overFile    = filePath .. file .. "-over.png",
        width       = wVal, 
        height      = hVal,

        onRelease = function()
                        snd.playSound( snd.sounds.click )
                        hlp.gotoScene( scene )
                    end
        } )
    button.isRound = true
    button.x = x
    button.y = yVal
    group:insert( button )

    return button
end

-- -----------------------------------------------------------------------------------
-- Display debug button.

local function createDebugButton( group, x )

    local button = widget.newButton( {
        defaultFile = filePath  .. "overscan.png",
        overFile    = filePath .. "overscan-over.png",
        width       = wVal, 
        height      = hVal,

        onRelease = function()
                        snd.playSound( snd.sounds.click )
                        local scene = composer.getScene( "scenes.scene_game" )
                        if( scene == nil ) then 
                            hlp.gotoScene( "scenes.scene_game" )
                        end
                        scene.debug()
                    end
        } )
    button.isRound = true
    button.x = x
    button.y = yVal
    group:insert( button )

    return button
end

-- -----------------------------------------------------------------------------------
-- Display hint button.

local function createHintButton( group, x )

    local button = widget.newButton( {
        defaultFile = filePath  .. "bn_hint.png",
        overFile    = filePath .. "bn_hint-over.png",
        width       = wVal, 
        height      = hVal,

        onRelease = function()
                        snd.playSound( snd.sounds.click )
                        local scene = composer.getScene( "scenes.scene_game" )
                        if( scene == nil ) then 
                            hlp.gotoScene( "scenes.scene_game" )
                        end
                        scene:hint()
                    end
        } )
    button.isRound = true
    button.x = x
    button.y = yVal
    group:insert( button )

    return button
end

-- -----------------------------------------------------------------------------------
-- Display menu button.

local function createMenuButton( group, x )

    local button = createButton( group, x, "menu", "scenes.scene_menu" )
    return button
end

-- -----------------------------------------------------------------------------------
-- Display options button.

local function createOptionsButton( group, x )

    local button = createButton( group, x, "settings", "scenes.scene_options" )
    return button
end

-- -----------------------------------------------------------------------------------
-- Display restart button.

local function createRestartButton( group, x )

    -- local button = createButton( group, x, "restart", "scenes.scene_game" )

    local button = widget.newButton( {
        defaultFile = filePath  .. "restart.png",
        overFile    = filePath .. "restart-over.png",
        width       = wVal, 
        height      = hVal,        
        
        onRelease = function()
                        snd.playSound( snd.sounds.click )
                        -- check whether game already in progress
                        -- local scene = composer.getScene( "scenes.scene_game" )                        
                        -- if( scene ) then 
                        --     scene:restartGame()
                        -- end
                        -- print( "createRestartButton - Current scene: " .. composer.getSceneName( "current" ) )
                        opt.status = "restart"
                        hlp.gotoScene( "scenes.scene_game" )
                    end
        } )
    button.isRound = true
    button.x = x
    button.y = yVal
    group:insert( button )

    return button
    --]]
end

-- -----------------------------------------------------------------------------------
-- Display skip button.

local function createSkipButton( group, x )

    local button = widget.newButton( {
        defaultFile = filePath  .. "next.png",
        overFile    = filePath .. "next-over.png",
        width       = wVal, 
        height      = hVal,        
        
        onRelease = function()
                        snd.playSound( snd.sounds.click )
                        -- check whether game already in progress
                        local scene = composer.getScene( "scenes.scene_game" )                        
                        if( scene ) then 
                            scene:squareSkipped()
                        end
                        -- hlp.gotoScene( "scenes.scene_game" )
                    end
        } )
    button.isRound = true
    button.x = x
    button.y = yVal
    group:insert( button )

    return button
end

-- -----------------------------------------------------------------------------------
-- Published functions
-- -----------------------------------------------------------------------------------
-- Creates menu bar. Returns table containing buttons.

function M.createMenuBar( group )

	local buttons = {}

	buttons.menu    = createMenuButton( group, display.screenOriginX + wVal )
	buttons.options = createOptionsButton( group, display.screenOriginX + display.actualContentWidth - wVal)
    local gap = (buttons.options.x - buttons.menu.x) / 4
    buttons.restart = createRestartButton( group, buttons.menu.x + gap )
    buttons.skip    = createSkipButton( group, buttons.restart.x + gap )
    buttons.hint    = createHintButton( group, buttons.skip.x + gap )
    
	return buttons
end

-- -----------------------------------------------------------------------------------

return M

-- -----------------------------------------------------------------------------------
