
-- ---------------------------------------------------------------------------------------

local dbg = require( "lib.debugging" )
local hlp = require( "lib.helper" )
local opt = require( "game.options" )
local sql = require( "sqlite3" )

-- ---------------------------------------------------------------------------------------

local M = {}

local TAG = "words.lua"

-- ---------------------------------------------------------------------------------------

M.usedSquares = {} -- queue to track which word squares have been used recently

-- ---------------------------------------------------------------------------------------

M.minWordLen          =  4  -- minimum word length
M.maxWordLen          =  7  -- maximum word length
M.minTileCount        =  4  -- minimum tile count
M.maxTileCount        =  M.maxWordLen  -- maximum tile count

local defaultLocation = system.ResourceDirectory
local maxLetters      = 26  -- number of characters in alphabet

local vowels = {}
vowels[1], vowels[2], vowels[3], vowels[4], vowels[5] = "a", "e", "i", "o", "u"

-- ---------------------------------------------------------------------------------------
-- Scores:
-- initialise individual letter score table
local let = {}
let.a, let.e, let.i, let.o, let.u, let.l, let.n, let.s, let.t, let.r = 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
let.d, let.g = 2, 2
let.b, let.c, let.m, let.p = 3, 3, 3, 3
let.f, let.h, let.v, let.w, let.y = 4, 4, 4, 4, 4
let.k = 5
let.j, let.x = 8, 8
let.q, let.z = 10, 10

-- initialise word length scores
local len = {}
len[3], len[4], len[5], len[6], len[7], len[8] = 6, 10, 15, 21, 28, 36

-- initialise colour scores
local col = {}
col[1], col[2], col[3], col[4], col[5], col[6], col[7], col[8] = 34, 21, 13, 8, 5, 3, 2, 1

-- ---------------------------------------------------------------------------------------
-- Local functions
-- ---------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------
-- Published functions
-- ---------------------------------------------------------------------------------------
-- Return true if the supplied word exists

function M.doesWordExist( word )

	-- dbg.statusMessage( TAG, "doesWordExist", word )
	local found = false
	local id = string.len( word )
	word = string.lower( word )
	-- check that word meets length requirements
	if( (id >= M.minWordLen) and 
		(id <= M.maxWordLen) and 
		((opt.gameOptions.minLen == 0) or (id >= opt.gameOptions.minLen))  ) then
		if( M.words[id].list[word] ) then 
			found = true 
		end
	end
	return found
end

-- ---------------------------------------------------------------------------------------
-- Return a weighted random letter

function M.getRandomLetter( wordLen )

    local n = wordLen or opt.gameOptions.tileCount
    local letter = nil    -- return value

    local rndNum = math.random( 1, M.words[n].freq[maxLetters][1] )
    local i = 0
    repeat
    	i = i + 1
    until( (i > maxLetters) or (rndNum <= M.words[n].freq[i][1]) )

    if( i <= maxLetters ) then
    	letter = M.words[n].freq[i][2]
    	if( opt.gameOptions.capitals ) then 
    		letter = string.upper( letter )
    	end
    else
    	dbg.errorMessage( TAG, "getRandomLetter", rndNum )
    end
    return letter
end

-- ---------------------------------------------------------------------------------------
-- Return a random vowel

function M.getRandomVowel()

	local i = math.random(1, 5)
	local v = vowels[i]
    if( opt.gameOptions.capitals ) then 
    	v = string.upper( v )
    end
    return v
end

-- ---------------------------------------------------------------------------------------
--[[
create a queue containing all row indices in random order
when a new hint is requested, pop index from queue
test whether word represented by index has been found, if so pop another index
continue until unfound word is selected

--]]

local hintQueue = {}

function M.initHints()

	hlp.queueInit( hintQueue )
	for i=1, opt.gameOptions.tileCount do 
		hlp.queueAdd( hintQueue, i )
	end
	hlp.queueShuffle( hintQueue )
	-- print( "*** words.initHints()" )
	-- dbg.printTable( hintQueue )
end

-- ---------------------------------------------------------------------------------------
-- return a word from a given square which has not already been found, else nil

function M.getHintWord( square )

	local word = nil
	repeat
		assert( hlp.queueCount( hintQueue ) > 0 )
		local i = hlp.queueRemove( hintQueue )
		word = square[tostring(i)]
	until( not opt.isWordFound( word ) )

	return word
end

-- ---------------------------------------------------------------------------------------
-- Return a randomly selected word square

function M.getWordSquare( len )

	local l = len or opt.gameOptions.tileCount
	local n = table.getn( M.words[l] )
	local r                -- random index
	-- check that square has not been recently used
	repeat
		r = math.random( 1, n )
	until( not hlp.queueContains( M.usedSquares, r ) )
	-- print( "[l: " .. l .. "] - [n: " .. n .. "] - [r: " .. r .. "]" )
	-- store the square's index to prevent re-use
	hlp.queueAdd( M.usedSquares, r ) 
	local square = M.words[l][r]
	-- dbg.printTable( square )
	return square
end

-- ---------------------------------------------------------------------------------------
-- Returns a word square as a randomly shuffled list of letters

function M.getWordSquareList ( square )

	local l  = opt.gameOptions.tileCount
	local ws = square or M.getWordSquare( l )
	
	local sl = {}  -- shuffled list of letters
	for r = 1, l do 
		local word = ws[tostring(r)]
		-- print ( "r: " .. r .. " - " .. word )
		for c = 1, l do
			local letter = string.sub( word, c, c )
			if( opt.gameOptions.capitals ) then 
    			letter = string.upper( letter )
    		end
			-- print ( "   c: " .. c .. " - " .. letter )
			table.insert( sl, letter)
		end
	end
	hlp.shuffleTable( sl )
	-- dbg.printTable( sl )
	
	return sl
end

-- ---------------------------------------------------------------------------------------
-- Returns the string index of a word within a square, else nil

function M.wordSquareHasWord( square, word )

	-- dbg.printTable( square )
	local w = string.lower( word )
	for k, v in pairs( square ) do 
		-- print("wordSquareHasWord: [key: " .. k .. "] - [value: " .. v .. "] - [word: " .. w .. "]")
		if( v == w ) then 
			return k
		end
	end

	return nil 
end

-- ---------------------------------------------------------------------------------------
-- Calculate and return the score for a given word

function M.getWordScore( word )

	local score = 0 -- return value

	word = string.lower( word )
	-- letter score
	for c in word:gmatch(".") do
		score = score + let[c]
	end
	-- length score
	local l = string.len( word )
	score = score + len[l]
	-- bonus for maximum length
	if( l == opt.gameOptions.tileCount ) then 
		score = score + math.floor(len[l] / 2)
	end
	-- colour score
	if( opt.gameOptions.colorCount > 1 ) then 
		local n = opt.gameOptions.tileCount - opt.gameOptions.colorCount
		score = score + col[n]
	end
	
	return score
end

-- ---------------------------------------------------------------------------------------
-- Initialise letter-related data structures

function M.init()

	M.words = {}

	for i=M.minWordLen, M.maxWordLen do
		M.words[i] = {}
		-- M.words[i].list = {}
		-- M.words[i].freq = {}
		-- for j = 1, maxLetters do
		-- 	M.words[i].freq[j] = {}
		-- end
	end	
end

-- ---------------------------------------------------------------------------------------
-- Read JSON files previously created by saveWordFile function. Return true if successful.
-- Note that ResourceDirectory is the same folder as main.lua

function M.loadWordFiles( location )

    local loc = location
    if not loc then
        loc = defaultLocation
    end
    local success = true
	M.init()
	
	-- dbg.timerStart()
	for i=M.minWordLen, M.maxWordLen do
		local fn = "squares_" .. string.format("%02d", i) .. ".json"
		M.words[i] = hlp.loadTable( fn, loc )
		if( M.words[i] == nil ) then 
			dbg.errorMessage( TAG, "loadWordFiles", fn )
			success = false
		end
	end
	-- dbg.timerStop()

	return success
end

-- ---------------------------------------------------------------------------------------
-- Test functions
-- ---------------------------------------------------------------------------------------
-- Test that JSON files have been successfully read. Returns true if successful.

function M.testSuccessfulLoad()

	if( not dbg.runTests ) then return true end

	local result = true
	local function testSquare( l )
		print( "\nSquare size: " .. l )
		print( "  no. squares: " .. table.getn( M.words[l] ))
		dbg.printTable( M.words[l][1] )
	end

	for i=M.minWordLen, M.maxWordLen do
		testSquare( i )
	end
	return result
end

-- ---------------------------------------------------------------------------------------

return M

-- ---------------------------------------------------------------------------------------
