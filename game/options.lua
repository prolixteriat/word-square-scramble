
-- ---------------------------------------------------------------------------------------

local dbg = require ("lib.debugging")
local hlp = require( "lib.helper" )

-- ---------------------------------------------------------------------------------------

local M = {}

local TAG = "options.lua"

-- ---------------------------------------------------------------------------------------

M.defaultFont     = "fonts/Dosis-Bold.ttf"
M.defaultFontSize = 50
M.widgetTheme     = "widget_theme_android_holo_light"
-- M.restart         = false  -- set to true when a game restart is required rather than continuation
M.status = "play" -- ("restart"; "skip")

-- -----------------------------------------------------------------------------------

local defaultLocation = system.DocumentsDirectory
local optionsFileName = "options_001.json"

-- ---------------------------------------------------------------------------------------
-- Local functions
-- ---------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------
-- Published functions
-- ---------------------------------------------------------------------------------------
-- Initialise score.

function M.initScores()

	M.score = M.createScores()
end

-- ---------------------------------------------------------------------------------------
-- Initialise score.

function M.createScores()

    local score = {}

    score.numSquares   = 0    -- no. of completed squares
    score.numHints     = 0    -- no. of hints used
    score.numSkips     = 0    -- no. of skips used
    score.wordsCurrent = {}   -- list of words found in current square
    score.wordsAll     = {}   -- list of words found in current game

    return score
end

-- ---------------------------------------------------------------------------------------
-- returns index of word for the current square if already found, else nil

function M.isWordFound( word )

    -- print( "isWordFound: " .. word )
    -- dbg.printTable( M.score.wordsCurrent ) 
    local i = table.indexOf( M.score.wordsCurrent, word )
    -- print ( "   i: " .. (i or "not found") )
    return i
end

-- ---------------------------------------------------------------------------------------
-- return number of words currently found in current word square

function M.getNumberWordsFound()

    return table.getn( M.score.wordsCurrent )
end

-- ---------------------------------------------------------------------------------------
-- Load the game options. 

function M.loadGameOptions()

    M.gameOptions = hlp.loadTable( optionsFileName )
    if( M.gameOptions == nil ) then
        -- file load has failed - initialise to default values
        dbg.errorMessage( TAG, "loadGameOptions", "Failed to load options file")
        M.gameOptions = {}
        M.gameOptions.capitals   = true     -- use capitals for tiles
        -- M.gameOptions.colorCount = 2        -- number of tile colours per board
        M.gameOptions.showFound  = true     -- show any words found in current square
        M.gameOptions.haptic     = true     -- vibrate on attempt to move locked tile
        -- M.gameOptions.minLen     = 4        -- minimum length for word match (0 = tileCount) 
        -- M.gameOptions.moveLimit  = 0        -- maximum no. moves per tile (0 = unlimited)
        M.gameOptions.hintCount  = 4        -- no. of available hints per game
        M.gameOptions.playSounds = true     -- play sound effects
        M.gameOptions.skipCount  = 4        -- no. of available square skips per game
        M.gameOptions.tileCount  = 4        -- number of tiles in each row and column
        M.gameOptions.timeLimit  = 0        -- no. of mins for time-limited game (0 = unlimited)
    end
end



-- -----------------------------------------------------------------------------------
-- Save the game options.

function M.saveGameOptions()

    hlp.saveTable( M.gameOptions, optionsFileName )
end

-- -----------------------------------------------------------------------------------
-- Test functions
-- -----------------------------------------------------------------------------------
-- output current game options to console

function M.testOutputGameOptions()

    if( dbg.runTests ) then 
        dbg.statusMessage( TAG, "testOutputGameOptions", "Current game options:")
        dbg.printTable( M. gameOptions )
    end
end

-- ---------------------------------------------------------------------------------------

return M

-- ---------------------------------------------------------------------------------------
