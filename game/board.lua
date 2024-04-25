
-- ---------------------------------------------------------------------------------------

local col  = require( "data.colors" )
local data = require( "data.words" )
local dbg  = require( "lib.debugging" )
local hi = require( "game.highscores" )
local hlp = require( "lib.helper" )
local opt  = require( "game.options" )
local puff = require( "lib.puff").newPuff
local snd  = require( "game.sounds" )

-- ---------------------------------------------------------------------------------------

local M = {}

local TAG = "board.lua"

-- ---------------------------------------------------------------------------------------
-- Local functions
-- ---------------------------------------------------------------------------------------
-- return true if provided co-ords are within an object's bounds

local function pointInBounds(x, y, object)
	local bounds = object.contentBounds
  	if not bounds then return false end
  	if x > bounds.xMin and x < bounds.xMax and y > bounds.yMin and y < bounds.yMax then
    	return true 
  	else 
    	return false
  	end
end

-- ----------------------------------------
-- update scores because a word has been found.

local function updateWordFound( word )

	table.insert( opt.score.wordsCurrent, 1, word )
	table.insert( opt.score.wordsAll, 1, word )
	snd.playSound( snd.sounds.wordFound )
end

-- ---------------------------------------------------------------------------------------

local abs = math.abs
local random = math.random

-- ---------------------------------------------------------------------------------------
-- Published functions
-- ---------------------------------------------------------------------------------------

function M.new( parent, scoreCallback, timeCallback, options )
  
  	options = options or {}

  	local rows = options.rows or 5
  	local cols = options.cols or 5
  	local width = options.width or (display.actualContentWidth / cols) - 6
  	local height = options.height or width
  	local paused = options.paused or false
  	local parentScene = parent
  	local updateScore = scoreCallback
  	local updateTime = timeCallback
  	local secondsLeft = opt.gameOptions.timeLimit * 60 -- duration of game (secs)
  	hi.highScore.gameCount = hi.highScore.gameCount + 1

	hlp.queueInit( data.usedSquares, 20 )
	local currentSquare = nil   -- array of strings forming current square

  	local board = display.newGroup()   
  	board.status = "init"
  	board.timer = {}

  	-- handle countdown timer
  	local function timeClick( event )
  		secondsLeft = secondsLeft - 1
  		updateTime( { secs = secondsLeft } )
  		if( secondsLeft == 0 ) then 
  			board:gameOver( "Out of time" )
  		elseif( secondsLeft <= 10 ) then
  			snd.playTimer( true )
  		end

  	end
  
  	if( secondsLeft > 0 ) then 
  		board.countDownTimer = timer.performWithDelay( 1000, timeClick, secondsLeft )
  	end

  	if paused then board.status = "paused" end

	-- ----------------------------------------
	--  
  	function board:play()
    	
    	-- print( "*** board:play()" )
		paused = false
    	board.status = "idle"    
    	board:initSquare()
    	board:replenish()    
    	board:recycle()
    	if( secondsLeft > 0 ) then 
    		timer.resume( board.countDownTimer )
    	end
  	end 

	-- ----------------------------------------

  	function board:pause()
		-- print( "*** board:pause()" )
    	paused = true
    	board.status = "paused"  
  		if( secondsLeft > 0 ) then 
    		timer.pause( board.countDownTimer )
    		snd.playTimer( false )
    	end
  	end  

	-- ----------------------------------------
	--  
  	function board:continueGame()
    	
    	-- print( "*** board:continueGame()" )
		paused = false
    	board.status = "idle"    
    	if( secondsLeft > 0 ) then 
    		timer.resume( board.countDownTimer )
    	end
  	end 

	-- ----------------------------------------
	--  
  	function board:nextSquare()
    	
    	-- print( "*** board:nextSquare()" )
		paused = false
    	board.status = "idle"    
    	-- cancel previous square
		local pieces = board.piece
    	for i = #pieces,1,-1 do
       		display.remove(pieces[i])
       		table.remove(pieces,i)  
    	end
    	board:initSquare()
    	board:replenish()    
    	board:recycle()
    	if( secondsLeft > 0 ) then 
    		timer.resume( board.countDownTimer )
    	end
  	end 

	-- ----------------------------------------
	--  
  	function board:newGame()
    	
    	-- print( "*** board:newGame()" )
		paused = false
    	board.status = "idle"    
    	-- cancel previous square
		local pieces = board.piece
    	for i = #pieces,1,-1 do
       		display.remove(pieces[i])
       		table.remove(pieces,i)  
    	end
    	if( secondsLeft > 0 ) then 
  			timer.cancel( board.countDownTimer )
  			snd.playTimer( false )	
  		end

		board:play()
  	
		secondsLeft = opt.gameOptions.timeLimit * 60
    	if( secondsLeft > 0 ) then 
  			-- updateTime()
  			board.countDownTimer = timer.performWithDelay( 1000, timeClick, secondsLeft )
    	end

  	end 

  	-- ----------------------------------------
  	-- 

  	function board:restart( tileCount, tileSize )
  	
  		-- print( "*** board:restart()" )
  		local tc = tileCount or rows 
  		local ts = tileSize  or width
		-- cancel previous game
		local pieces = board.piece
    	for i = #pieces,1,-1 do
       		display.remove(pieces[i])
       		table.remove(pieces,i)  
    	end
    	if( secondsLeft > 0 ) then 
  			timer.cancel( board.countDownTimer )
  			snd.playTimer( false )	
  		end
    	-- new game
        updateScore() 
		cols, rows    = tc, tc
		height, width = ts, ts
		hi.highScore.gameCount = hi.highScore.gameCount + 1
		board:play()
        -- board:testInjectSquare()
  	
		secondsLeft = opt.gameOptions.timeLimit * 60
    	if( secondsLeft > 0 ) then 
  			-- updateTime()
  			board.countDownTimer = timer.performWithDelay( 1000, timeClick, secondsLeft )
    	end
        
  	end

  	-- ----------------------------------------
  	--  start a new word square

  	function board:initSquare()

  		-- print("*** board:initSquare()")
  		col.initWordSquareColor()
  		data.initHints()
		opt.score.wordsCurrent = nil 
		opt.score.wordsCurrent = {}
		updateScore()

  	end

  	-- ----------------------------------------
  	
  	function board:getCurrentSquare()

  		return currentSquare
  	end

  	-- ----------------------------------------
  
  	-- display screen info for debugging purposes...
  	-- print( "screenOriginX:      " .. display.screenOriginX )
  	-- print( "contentCenterX:     " .. display.contentCenterX )
  	-- print( "actualContentWidth: " .. display.actualContentWidth )
  	-- print( "contentWidth:       " .. display.contentWidth )
  	-- print( "cols:               " .. cols )
  	-- print( "width:              " .. width )
	-- local tmp = display.newRect( 0, 0, 50, 50 )
	-- tmp.x = display.contentCenterX, tmp.y = display.contentCenterY 
  	
  	function board:newPiece(r,c, letter)

    	-- print( "*** board:newPiece()" )

    	if not board.removeSelf then return false end
    	if board.piece == nil then
      		board.piece = {}
    	end
    	local pieces = board.piece
    	-- function that builds a new game piece    
    	local nextPiece = #pieces+1

    	-- each tile consists of a group, a background rectangle plus a text character:
      	--   make group
      	-- calculate offsets to centre board horizontally
	  	local ox = (display.screenOriginX + (display.actualContentWidth - (cols * width)) / 2) - (width / 2)
  		local oy = display.screenOriginY + height / 2
      	local squareGroup = display.newGroup()
      	squareGroup.x = ox + c*width
      	squareGroup.y = oy + r*height 
      	
      	squareGroup.width  = width - 2
      	squareGroup.height = height - 2
      	--   make background rectangle
      	local space = display.newRoundedRect(self, 0, 0, width-2, height-2, width * 0.10)
      	space.color = col.colIvory
      	space:setFillColor( unpack(space.color) ) 
	  	space.moves = 0
	  	--   make text character
      	local rndLetter = letter 
      	piece = display.newText(self, rndLetter, 0, 0, opt.defaultFont, 70)
      	piece.letter = string.lower( rndLetter  )
      	piece:setFillColor( unpack(col.colTileText) ) 
      	squareGroup:insert( space )
      	squareGroup:insert( piece )
      	pieces[nextPiece] = squareGroup
      	board:insert( squareGroup ) 

    	-- make a local copy
    	local currentPiece = pieces[nextPiece]    
    	currentPiece.id = nextPiece
    	currentPiece.r,currentPiece.c = r,c
    	transition.from( currentPiece, { time = 1000, xScale = 0.01, yScale = 0.01, transition=easing.outBounce } )
    
		-- ----------------------------------------
    	-- touch listener function
    	function currentPiece:touch( event )

    		-- print( "currentPiece:touch: [moving: " .. (self.moving and "true" or "false") .. "] - [status: " .. board.status .. "] - [phase: " .. event.phase .. "]" )
      		if not self.moving and board.status == "idle" and event.phase == "began" then
	        	-- first we set the focus on the object
	        	display.getCurrentStage():setFocus( self, event.id )
		        self:toFront()
		        self.isFocus = true
		        self.isMoving = true

		        -- then we store the original x and y position
		        self.markX = self.x
		        self.markY = self.y

		        board.status = "swapping"      
		        transition.to (self, { tag="board", time=100, xScale = 1.2, yScale = 1.2, transition=easing.outQuad } )

      		elseif self.isFocus then

	        	if event.phase == "moved" then

	          		local dx, dy = abs(event.x - event.xStart), abs(event.y - event.yStart)
	          		local lr, ud = false, false

			        if dx > 16 or dy > 16 then 
			        	if dx > dy then lr = true end 
			        	if dy > dx then ud = true end 
			    	end

		          	-- then drag our object
		          	self.x = event.x - event.xStart + self.markX
		          	self.y = event.y - event.yStart + self.markY

		          	-- keep it lr/ud
		          	if ud then self.x = self.markX end
		          	if lr then self.y = self.markY end

		          	-- only allow moving a single space
		          	if self.x < self.markX - width then self.x = self.markX - width end
		          	if self.x > self.markX + width then self.x = self.markX + width end
		          	if self.y < self.markY - height then self.y = self.markY - height end
		          	if self.y > self.markY + height then self.y = self.markY + height end

	        	elseif event.phase == "ended" or event.phase == "cancelled" then

	          		-- is there a new piece under where we let go?
			        local lx = (self.contentBounds.xMin + self.contentBounds.xMax) * 0.5
			        local ly = (self.contentBounds.yMin + self.contentBounds.yMax) * 0.5          
			        local pieceToSwap = board:findPiece(lx,ly,self.id)

		          	-- keep from double touches
		          	local function checkMatches()
		            	if pieceToSwap then pieceToSwap.moving = false end
		            	self.moving = false 
		            	board:cull()              
		          	end

	          		local function noMove()
	            		self.moving = false
	            		board.status = "idle"
	          		end

	          		if ( pieceToSwap ) then
	            		-- keep from double touches
	            		pieceToSwap.moving = true

			            -- swap row and column
			            pieceToSwap.r, self.r = self.r, pieceToSwap.r
			            pieceToSwap.c, self.c = self.c, pieceToSwap.c

			            transition.to(self, { tag="board", time = 250, xScale = 1, yScale = 1, x = pieceToSwap.x, y = pieceToSwap.y, transition = easing.outBounce, onComplete = checkMatches } )
			            transition.to(pieceToSwap, { tag="board", time = 250, x = self.markX, y = self.markY, transition = easing.outBounce } )              
	          		else           
	            		transition.to(self, { tag="board", time = 333, xScale = 1, yScale = 1, x = self.markX, y = self.markY, transition = easing.outBounce, onComplete = noMove }  )     
	          		end
	          		-- we end the movement by removing the focus from the object
	          		display.getCurrentStage():setFocus( self, nil )
	          		self.isFocus = false      
	        	end
      		end
      		-- return true so Solar2D knows that the touch event was handled properly
      		return true
    	end

    	-- finally, add an event listener to the tile to allow it to be dragged
    	currentPiece:addEventListener( "touch" )
  	end

	-- ----------------------------------------

	function board:findPiece(x,y,id)
    	if not board.removeSelf then return false end    
    	-- find a piece at a screen x,y
    	local pieces = board.piece
	    id = id or -1
	    if pieces == nil then return false end
	    for i = #pieces, 1, -1 do
	    	if pointInBounds(x,y,pieces[i]) and i ~= id then
	        	return pieces[i]
	    	end
	    end
	    return false
  	end

  	-- ----------------------------------------

	function board:getPiece(r,c)
		if not board.removeSelf then return false end    
	    -- get a piece at a board r,c
	    local pieces = board.piece
	    if pieces == nil then return false end
	    for i = #pieces,1,-1 do
	    	if pieces[i] and pieces[i].r == r and pieces[i].c == c then
	        	return pieces[i]
	    	end
	    end
	    return false    
	  end

  	-- ----------------------------------------
  	-- provide hint. returns true if successful 
 
  	function board:hint() 

  		-- check that hints are available
  		-- need another condition to check that not all words have been found ###
  		if( (opt.score.numHints >= opt.gameOptions.hintCount) or 
  		 	(opt.score.numHints >= opt.gameOptions.tileCount) or 
  		 	(table.getn( opt.score.wordsCurrent ) >= opt.gameOptions.tileCount) ) then 
	  		snd.playSound( snd.sounds.locked )
	  		if( opt.gameOptions.haptic ) then
	  			system.vibrate()
  			end
  		else
  			opt.score.numHints = opt.score.numHints + 1
  			local word = data.getHintWord( currentSquare )
			local color = col.getWordSquareColor()      -- get a new colour for the hint letters
			local colorGrad = col.getGradient( color )  -- gradient is used until letters are correctly formed into word
      		local count = 0  -- number of letters matched
      		for l in word:gmatch(".") do
				local found = false   -- flags whether current letter has been found
				for r = 1, rows do
					for c = 1, cols do
						local piece = board:getPiece(r, c)
						-- does the piece match the letter and the piece hasn't been matched already?
						if( (piece[2].letter == l) and (piece[1].color == col.colIvory) ) then 
	      					piece[1].color = color
							-- use gradient colour until letters are arranged into correct order in a single row
	      					piece[1]:setFillColor( colorGrad )
							count = count + 1
							if( count >= opt.gameOptions.tileCount ) then 
								return true
							end
							found = true
							break  -- for c
						end
					end
					if( found ) then 
						break  -- for r
					end
				end
			end
  		end
  		return false
  	end

  	-- ----------------------------------------
  	-- return true if all rows are matched (but not necessarily in correct order)

  	function board:checkMatchAllRows() 

  		solved = true
  		for r = 1, rows do 
  			if( not board:checkMatchRow( r ) ) then 
  				solved = false
  				-- do not break as we want all rows to be processed
  			end
  		end
  		return solved
  	end

  	-- ----------------------------------------
  	-- return true if match in row r
  
  	function board:checkMatchRow( r ) 

      	local match = false
      	local word  = board:getWordRow( r )
      	local rm = data.wordSquareHasWord( currentSquare, word ) -- index of matching row in word square
      	if( rm ) then
      		-- check whether letters may have been associated with another word via use of a hint
      		local color = board:getColorRow( r ) 
      		-- print( "Row: " .. r )
      		-- dbg.printTable( color )
      		if( color and (not opt.isWordFound( word )) ) then 
    			-- new found word
      			-- print( "board:checkMatchRow - New word: " .. word )
      			match = true
      			updateWordFound( word, true )
	      		updateScore() 
	      		-- do letters form part of a hint word?
	      		if( color == col.colIvory ) then 
	      			color = col.getWordSquareColor()
	      		end
	      		for c = 1, cols do
	      			local piece = board:getPiece(r, c)
      				piece[1].color = color
      				piece[1].fill = color
	      		end
	      		-- board:flashRow( r )
      		else
      			-- print( "board:checkMatchRow - Existing word: " .. word )
      			
      		end
      	end

      	return match
  	end

	-- ----------------------------------------
	-- return the uniform colour in row r - else nil if not uniform (bi = begin index; ei = end index)
  
	function board:getColorRow( r, bi, ei )

		local b = bi or 1
		local e = ei or cols
		local color = nil
		local p1 = board:getPiece(r,b)
		if( p1 ) then 
			color = p1[1].color  -- colour in first square in sequence
		    for c = b+1, e do
		    	local p2 = board:getPiece(r,c)
		    	if( (not p2) or (p2[1].color ~= color) ) then 
		    		color = nil
		    		break
		    	end
		    end
		end
	    return color
	end

  	-- ----------------------------------------
  	-- return the word in row r - (bi = begin index; ei = end index)

  	function board:getWordRow( r, bi, ei )

      	local b = bi or 1
		local e = ei or cols
		local word = ""
      	for c = b, e do
         	local p = board:getPiece(r,c)
         	if( p ) then 
         		word = word .. p[2].letter
         	end
      	end
      	return word
  	end

	-- ----------------------------------------
 	
	function board:getStatus()

		return board.status 
	end

	-- ----------------------------------------
	-- handle game over

	function board:gameOver( reason )
		board:pause()
		board.status = "ended"
		parentScene:gameOver( reason )
	end

 	-- ----------------------------------------
 	-- check whether square has been solved

 	function board:isSquareSolved() 

 		local solved = true
 		for r = 1, rows do 
 			local word = board:getWordRow( r )
 			-- print( "board:isSquareSolved: [r: " .. r .. "] - [word: " .. word .. "] - [square: " .. currentSquare[tostring(r)] .. "]" )
 			local clr = board:getColorRow( r )   -- prevent the same letter from another word from being matched
 			if( (word ~= currentSquare[tostring(r)]) or (not clr) ) then 
 				solved = false
 				break
 			end
 		end
 		-- local solved = ( table.getn( opt.score.wordsCurrent ) == opt.gameOptions.tileCount )
 		-- print( "board:isSquareSolved: [solved: " .. (solved and "true" or "false") .. "] - [wordsCurrent: " .. table.getn( opt.score.wordsCurrent ) .. "] - [tileCount: " .. opt.gameOptions.tileCount .. "]")
 		if( solved ) then 	
	  		parentScene:squareSolved()
 		end
 		return solved
 	end

 	-- ----------------------------------------
  	-- 

  	function board:cull()
    	-- print( "*** board:cull()" )

    	if not board.removeSelf then return false end 
	    if paused then return false end        
	    local pieces = board.piece
	    if pieces == nil then return false end
	    local cull = false
	    board.status = "matching"

	    -- horizontal
	    for r = 1, rows do
	    	local match = board:checkMatchRow( r ) 
	        if( match ) then 
	        	board.status = "matched"
				cull = true
   	      		-- board.status = "culling"
   	      		updateScore()  
	      	end	      
	    end
  
    	board:isSquareSolved()
		board.status = "idle"

  	end

  	-- ----------------------------------------

  	function board:replenish()
    	-- print( "*** board:replenish()" )
    	if not board.removeSelf then return false end    
    	board:recycle()
    	currentSquare = data.getWordSquare() 
    	local sl = data.getWordSquareList( currentSquare ) 
    	local count = 0
    	for i = 1, rows do
      		for j = 1, cols do
        		count = count + 1
        		letter = sl[count]
        		-- print( "[count: " .. count .. "] - [letter: " .. letter .. "]" ) -- debug
       			board:newPiece(i,j, letter) 
      		end
    	end
    	if( dbg.debug ) then 
			parentScene:debug()
		end

  		if( board:checkMatchAllRows() ) then 
  			board:isSquareSolved()
  		end

  	end
  	  
    -- ----------------------------------------

  	function board:recycle()
    	-- print( "*** board:recycle()" )

    	if not board.removeSelf then return false end    
    	-- object cleanup
    	local pieces = board.piece
    	if pieces == nil then return false end

    	-- compact table
    	for i = #pieces,1,-1 do
      		if pieces[i].cull then  
        		display.remove(pieces[i])
        		table.remove(pieces,i)  
      		end  
    	end  

    	-- re-id
    	for i = 1, #pieces,1 do
      		pieces[i].id = i
    	end    
  	end

-- ----------------------------------------

  	function board:finalize()
    	-- print( "*** board:finalize()" )

    	if not board.removeSelf then return false end    
    	transition.cancel("board")
    	board.status = "finalizing"
    	snd.playTimer( false )
    	-- clean up timers
    	for i = #board.timer, 1, -1 do
      		timer.cancel(board.timer[i])
      		board.timer[i]=nil 
    	end
    	hlp.queueFlush( data.usedSquares )
	
  	end

	-- ---------------------------------------------------------------------------------------
	-- solve the square - used with skips
	
	function board:solveSquare()

		-- inject a given character at a specific location
		local function doInject( r, c, char )
			local square = board:getPiece( r, c )
      		square[2].text   = char
      		square[2].letter = char
      		if( opt.gameOptions.capitals ) then 
	      		square[2].text = string.upper( char )
      		end
      		square[1].color = col.colIvory
		end

		col.initWordSquareColor()
		for k, v in pairs( currentSquare ) do 
			local r = tonumber( k )
			local c = 0
     		for l in v:gmatch(".") do
     			c = c + 1
     			doInject( r, c, l )
     		end
     		board:checkMatchRow( r )
		end	
	end
	
  	-- ---------------------------------------------------------------------------------------
	-- Test functions
	-- ---------------------------------------------------------------------------------------
	-- inject partially formed words which require only one char to be moved in order to match

  	function board:testInjectWord()

		if( not dbg.runTests ) then return end

		-- inject a given character at a specific location
		local function doInject( r, c, char )
			local square = board:getPiece( r, c )
      		square[2].text = char
      		square[2].letter = char
      		square[1]:setFillColor( unpack(col.colIvory) )
		end

		-- add the same letter at two locations
		local function injectLetter( r, c, char )
			doInject( r, c, char )
			doInject( c, r, char )
		end

		-- add horizontal and vertical test words for tile counts of 4, 5 and 6
		injectLetter( 2, 1, "t" )
		injectLetter( 2, 2, "e" )
		injectLetter( 2, 3, "s" )
		injectLetter( 3, 4, "t" )
		if( opt.gameOptions.tileCount == 5 ) then 
			injectLetter( 2, 5, "s" )
		elseif( opt.gameOptions.tileCount == 6) then 
			injectLetter( 2, 5, "e" )
			injectLetter( 2, 6, "r" )
		end
	end

	-- ----------------------------------------

  	-- end of 'new' function
	board:addEventListener('finalize')

  	return board
end

-- ---------------------------------------------------------------------------------------

return M

-- ---------------------------------------------------------------------------------------

