
-- ---------------------------------------------------------------------------------------

local data = require( "data.words" )
local dbg = require ("lib.debugging")
local hlp = require( "lib.helper" )
local opt = require( "game.options" )
local snd = require( "game.sounds" )

-- ---------------------------------------------------------------------------------------

local M = {}

local TAG = "highscores.lua"

-- ---------------------------------------------------------------------------------------

local defaultLocation  = system.DocumentsDirectory
local highScoreFileName = "highscores_001.json"

-- ---------------------------------------------------------------------------------------
-- Local functions
-- ---------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------
-- Published functions
-- ---------------------------------------------------------------------------------------
-- Load the saved high scores. 
-- Note: both of the following need to have been called first:
--   opt.initScores() opt.loadGameOptions()

function M.loadHighScores()

    -- print( "*** highscores.loadHighScores()")
    -- M.highScore = hlp.loadTable( highScoreFileName )
    M.highScore = {}
    local hs = hlp.loadTable( highScoreFileName )
    -- M.highScore = nil
    M.isHighScore = false  -- true if high score already achieved for game
    -- if( M.highScore == nil ) then
    if( hs == nil ) then
        -- file load has failed - initialise to default values
        dbg.errorMessage( TAG, "loadHighScores", "Failed to load high scores file")
        M.highScore = {}
        for i=data.minWordLen, data.maxWordLen do
            M.highScore[i] = {}
            M.highScore[i].numSquares = 0
            M.highScore[i].numHints   = 0
            M.highScore[i].numSkips   = 0
            M.highScore[i].timeLimit  = 0 
        end
        M.highScore.gameCount = 0
        M.highScore.feedback  = 0    
    else
        -- convert string-indexed array to number-indexed array
        for i=data.minWordLen, data.maxWordLen do
            M.highScore[i] = hlp.shallowCopyTable( hs[tostring(i)] )
        end
        M.highScore.gameCount = hs.gameCount
        M.highScore.feedback  = hs.feedback  
        hs = nil  
    end

    -- dbg.printTable( M.highScore )
end

-- -----------------------------------------------------------------------------------
-- Update and save the high score, if required. Return true if new high score.
function M.saveHighScores()

    local newHighScore = false
    
    -- check whether new high score
    -- print("*** highscores.saveHighScores()")

    -- local i = tostring(opt.gameOptions.tileCount)
    hlp.saveTable( M.highScore, highScoreFileName ) 
    local i = opt.gameOptions.tileCount
    if( opt.score.numSquares > M.highScore[i].numSquares ) then 
        -- dbg.statusMessage(TAG, "saveHighScores", Saving high scores")
        newHighScore = true
        -- only play high score sound once
        if( (M.highScore.gameCount > 1) and (not M.isHighScore) ) then 
            snd.playSound( snd.sounds.highScore )
            M.isHighScore = true 
        end
        M.highScore[i].numSquares = opt.score.numSquares
        M.highScore[i].numHints   = opt.score.numHints
        M.highScore[i].numSkips   = opt.score.numSkips
        M.highScore[i].timeLimit  = opt.gameOptions.timeLimit
        hlp.saveTable( M.highScore, highScoreFileName )
        -- debug
        -- dbg.printTable( M.highScore )
        -- .printTable( opt.score )
        -- local json = require( "json" )
        -- print( json.encode( M.highScore ) )
    end
    
    return newHighScore
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
