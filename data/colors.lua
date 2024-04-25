
-- ---------------------------------------------------------------------------------------

local dbg = require ( "lib.debugging" )
local opt = require( "game.options" )

-- ---------------------------------------------------------------------------------------

local M = {}

local TAG = "colors.lua"

-- ---------------------------------------------------------------------------------------

-- https://encycolorpedia.com/named
M.colAzure    = {   0 / 255,  56 / 255, 168 / 255 }
M.colBlue     = {  29 / 255, 172 / 255, 214 / 255 }
M.colBlueLt   = { 178 / 255, 255 / 255, 255 / 255 }
M.colBone     = { 227 / 255, 218 / 255, 201 / 255 }
M.colBrown    = { 150 / 255,  90 / 255,  62 / 255 }
M.colBrownLt  = { 193 / 255, 154 / 255, 107 / 255 }
M.colCharcoal = {  54 / 255,  69 / 255,  79 / 255 }
M.colGreen    = {  33 / 255, 192 / 255,  60 / 255 }
M.colGreenDk  = {  30 / 255,  77 / 255,  43 / 255 }
M.colGrey     = { 169 / 255, 169 / 255, 169 / 255 }
M.colIvory    = { 255 / 255, 255 / 255, 240 / 255 }
M.colNavy     = {   2 / 255,   7 / 255,  93 / 255 }
M.colOrange   = { 255 / 255, 166 / 255,   0 / 255 }
M.colPurple   = { 106 / 255,  13 / 255, 173 / 255 }
M.colRed      = { 236 / 255,  59 / 255, 131 / 255 }
M.colYellow   = { 191 / 255, 255 / 255,   0 / 255 }
M.colViolet   = {  85 / 255,  27 / 255, 140 / 255 }
M.colVioletDk = {  68 / 255,  22 / 255, 112 / 255 }
M.colVioletLt = { 106 / 255,  34 / 255, 175 / 255 }

M.colBackground = M.colVioletDk
M.colGroup      = M.colViolet
M.colOverlay    = M.colVioletLt
M.colTileText   = M.colCharcoal

M.colors = {M.colRed, M.colGreen, M.colBlue, M.colYellow, M.colOrange, M.colBrownLt, M.colBlueLt, M.colBone}

-- ---------------------------------------------------------------------------------------
-- Local functions
-- ---------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------
-- Published functions
-- ---------------------------------------------------------------------------------------
-- return a gradient table based upon an input colour table

function M.getGradient( color )

	local gradient = {
        type="gradient",
        color1=M.colIvory, color2=color, direction="down"
    }
    
    -- ivory is handled differently in order to provide visual distinction
    if( color == M.colIvory ) then 
        gradient.color1 = M.colGrey
        gradient.color2 = M.colIvory
        gradient.direction = "up"
    end
    return gradient
end

-- ---------------------------------------------------------------------------------------
-- return a random colour based upon board size

function M.getRandomColor( boardSize )

	local color = nil  -- return value
	
	if( opt.gameOptions.colorCount == 1 ) then 
		color = M.colIvory
	else
		-- select random colour  
		local i = math.random( 1, opt.gameOptions.colorCount )  
	    if( (i >= 1) and (i <= table.getn(M.colors))) then
	    	color = M.colors[i]
	    else
	    	dbg.errorMessage( TAG, "getRandomColor", boardSize )
	    end
    end

	return color
end

-- ---------------------------------------------------------------------------------------

local colCounter

function M.initWordSquareColor()

	colCounter = 0
end

-- ---------------------------------------------------------------------------------------
-- return a colour based upon the number of words already found

function M.getWordSquareColor()

	colCounter = colCounter + 1
	assert( (colCounter > 0) and (colCounter <= table.getn(M.colors)) )
	return M.colors[colCounter]
end

-- ---------------------------------------------------------------------------------------

return M

-- ---------------------------------------------------------------------------------------
