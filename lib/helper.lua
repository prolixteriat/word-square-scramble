-- -----------------------------------------------------------------------------------

local composer = require( "composer" )
local dbg = require ("lib.debugging")
local json = require( "json" )

-- -----------------------------------------------------------------------------------

local M = {}

local TAG = "helper.lua"

-- -----------------------------------------------------------------------------------

local defaultLocation = system.DocumentsDirectory
local filePath = "lib/img/"

-- -----------------------------------------------------------------------------------
-- Local functions
-- -----------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------
-- Published functions
-- -----------------------------------------------------------------------------------

function M.gotoScene( menu )
    
    composer.gotoScene( menu, { time=800, effect="crossFade" } )
end

-- -----------------------------------------------------------------------------------
-- return the key for a given value in a supplied has table, else return nil

function M.getKeyFromValue( t, val )

    local key = nil
    -- dbg.printTable( t )
    -- print( "Val: " .. val )
    for k, v in pairs( t ) do
        -- print( "k: " .. k .. " - v: " .. v )
        if( v == val ) then 
            key = k 
            break
        end
    end
    return key
end

-- -----------------------------------------------------------------------------------

function M.loadTable( filename, location )
 
    local loc = location
    if not location then
        loc = defaultLocation
    end
 
    local path = system.pathForFile( filename, loc )
    local file, errorString = io.open( path, "r" )
 
    if not file then
        dbg.errorMessage( TAG, "loadTable", errorString )
        return nil
    else
        local contents = file:read( "*a" )
        local t, pos, msg = json.decode( contents )
        io.close( file )
        if( not t ) then 
            dbg.errorMessage( TAG, "M.loadTable", "File " ..  filename .. " failed at ".. tostring(pos) .. ": " .. tostring(msg) )
        end
        return t
    end
end

-- -----------------------------------------------------------------------------------
-- Save table to file. Return true if successful.

function M.saveTable( t, filename, location )
 
    local loc = location
    if not location then
        loc = defaultLocation
    end
 
    local path = system.pathForFile( filename, loc )
    local file, errorString = io.open( path, "w" )
 
    if not file then
        dbg.errorMessage( TAG, "saveTable", errorString )
        return false
    else
        file:write( json.encode( t ) )
        io.close( file )
        return true
    end
end

-- -----------------------------------------------------------------------------------

function M.shuffleTable( t )

    if ( type(t) ~= "table" ) then
        dbg.errorMessage( TAG, "shuffleTable", type(t) )
        return false
    end
 
    local j
 
    for i = #t, 2, -1 do
        j = math.random( i )
        t[i], t[j] = t[j], t[i]
    end
    return t
end

-- -----------------------------------------------------------------------------------
-- http://lua-users.org/wiki/CopyTable

function M.shallowCopyTable( orig )

    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- -----------------------------------------------------------------------------------
-- Queue class
-- -----------------------------------------------------------------------------------
-- https://www.tutorialspoint.com/how-to-implement-a-queue-in-lua-programming
-- https://www.lua.org/pil/11.4.html

-- -----------------------------------------------------------------------------------
-- Call initialisation function.  

function M.queueInit( q, lim )

    q.first = 1
    q.last  = 0
    q.limit = lim or -1 -- maximum size of queue (-1 indicates unlimited size)
    q.data  = {}
end

-- -----------------------------------------------------------------------------------
-- add a new value to the queue, accounting for any maximum queue size limit

function M.queueAdd( q, val )
   
    q.last = q.last + 1
    q.data[q.last] = val
    if( (q.limit > -1) and ((q.last - q.first) >= q.limit) ) then 
        M.queueRemove( q )
    end
end

-- -----------------------------------------------------------------------------------
-- return true if the queue contains a specific value 

function M.queueContains( q, val )

    found = false
    if( q.first <= q.last ) then
        for i = q.first, q.last do
            if( q.data[i] == val ) then 
                found = true 
                break
            end
        end
    end
    return found
end

-- -----------------------------------------------------------------------------------
-- return the number of members in the queue

function M.queueCount( q )

    return q.last - q.first + 1
end

-- -----------------------------------------------------------------------------------
-- remove all members from the queue

function M.queueFlush( q ) 

    repeat
        local rval = M.queueRemove( q )
    until( rval == nil )
end

-- -----------------------------------------------------------------------------------
-- pop a member from the queue

function M.queueRemove( q )
    
    local rval = nil
    if( q.first > q.last ) then
        dbg.errorMessage( TAG, "queueRemove", "empty queue")
    else
        rval = q.data[q.first]
        q.data[q.first] = nil
        q.first = q.first + 1
    end
    return rval
end

-- -----------------------------------------------------------------------------------
-- randomly shuffle the queue members

function M.queueShuffle( q )

    M.shuffleTable( q.data )
end


-- -----------------------------------------------------------------------------------

function M.queueDump( q ) 

    print ("first: " .. q.first )
    print ("last:  " .. q.last )
    for i = q.first, q.last  do
        print( i .. " - " .. q.data[i] )
    end
end

-- -----------------------------------------------------------------------------------

return M

-- -----------------------------------------------------------------------------------

