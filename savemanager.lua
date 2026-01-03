--[[
   Save Table to File
   Load Table from File
   v 1.0
   
   Lua 5.2 compatible
   
   Only Saves Tables, Numbers and Strings
   Insides Table References are saved
   Does not save Userdata, Metatables, Functions and indices of these
   ----------------------------------------------------
   table.save( table , filename )
   
   on failure: returns an error msg
   
   ----------------------------------------------------
   table.load( filename or stringtable )
   
   Loads a table that has been saved via the table.save function
   
   on success: returns a previously saved table
   on failure: returns as second argument an error msg
   ----------------------------------------------------
   
   Licensed under the same terms as Lua itself.
]]--

-- declare local variables
--// exportstring( string )
--// returns a "Lua" portable version of the string
local function exportstring( s )
    return string.format("%q", s)
end

--// The Save Function
function table.save(  tbl,filename )
    local charS,charE = "   ","\n"
    local file,err = io.open( filename, "wb" )
    if err or file==nil then 
        return err 
    else
        -- initiate variables for save procedure
        local tables,lookup = { tbl },{ [tbl] = 1 }
        file:write( "return {"..charE )

        -- eatch table
        for idx,t in ipairs( tables ) do
            file:write( "-- Table: {"..idx.."}"..charE )
            file:write( "{"..charE )
            local thandled = {}

            for i,v in ipairs( t ) do
                thandled[i] = true
                local stype = type( v )
                -- only handle value
                if stype == "table" then
                    if not lookup[v] then
                        table.insert( tables, v )
                        lookup[v] = #tables
                    end
                    file:write( charS.."{"..lookup[v].."},"..charE )
                elseif stype == "string" then
                    file:write(  charS..exportstring( v )..","..charE )
                elseif stype == "number" then
                    file:write(  charS..tostring( v )..","..charE )
                end
            end
      
            for i,v in pairs( t ) do
                -- escape handled values
                if (not thandled[i]) then              
                    local str = ""
                    local stype = type( i )
                    -- handle index
                    if stype == "table" then
                        if not lookup[i] then
                            table.insert( tables,i )
                            lookup[i] = #tables
                        end
                        str = charS.."[{"..lookup[i].."}]="
                    elseif stype == "string" then
                        str = charS.."["..exportstring( i ).."]="
                    elseif stype == "number" then
                        str = charS.."["..tostring( i ).."]="
                    end
                
                    if str ~= "" then
                        stype = type( v )
                        -- handle value
                        if stype == "table" then
                            if not lookup[v] then
                            table.insert( tables,v )
                            lookup[v] = #tables
                            end
                            file:write( str.."{"..lookup[v].."},"..charE )
                        elseif stype == "string" then
                            file:write( str..exportstring( v )..","..charE )
                        elseif stype == "number" then
                            file:write( str..tostring( v )..","..charE )
                        end
                    end
                end
            end
            file:write( "},"..charE )
        end
        file:write( "}" )
        file:close()
    end
end

--// The Load Function
function table.load( sfile )
    local ftables,err = loadfile( sfile )
    if err then return _,err end
    local tables = ftables()
    for idx = 1,#tables do
        local tolinki = {}
        for i,v in pairs( tables[idx] ) do
        if type( v ) == "table" then
            tables[idx][i] = tables[v[1]]
        end
        if type( i ) == "table" and tables[i[1]] then
            table.insert( tolinki,{ i,tables[i[1]] } )
        end
        end
        -- link indices
        for _,v in ipairs( tolinki ) do
        tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
        end
    end
    return tables[1]
end
--[[
    MIT License Savemanager.lua

    Copyright (c) 2026 Magnus Oblerion

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]--
local savemanager = {
    savedir = love.filesystem.getSaveDirectory(),
    ffileExist = function(self,pfile)
        if not love.filesystem.getInfo(self.savedir.."/"..pfile) == nil then 
            return true
        end
        return false
    end,
    fload = function(self,pfile)
        if love.filesystem.getInfo(self.savedir) == nil then 
           love.filesystem.createDirectory("")
        end
        return table.load(self.savedir.."/"..pfile..".lua")
    end,
    fwrite = function (self,ptable,pfile)
        local tinput = ptable or {}
        if love.filesystem.getInfo(self.savedir) == nil then 
            love.filesystem.createDirectory("")
        end
        table.save(tinput,self.savedir.."/"..pfile..".lua")
    end
}
return savemanager
