--[[
aeslua: Lua AES implementation
Copyright (c) 2006,2007 Matthias Hilbig

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser Public License as published by the
Free Software Foundation; either version 2.1 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser Public License for more details.

A copy of the terms and conditions of the license can be found in
License.txt or online at

	http://www.gnu.org/copyleft/lesser.html

To obtain a copy, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

Author
-------
Matthias Hilbig
http://homepages.upb.de/hilbig/aeslua/
hilbig@upb.de
]]

local public = {};

aeslua.buffer = public;

function public.new ()
  return {};
end

function public.addString (stack, s)
  table.insert(stack, s)
  for i = #stack - 1, 1, -1 do
    if #stack[i] > #stack[i+1] then 
        break;
    end
    stack[i] = stack[i] .. table.remove(stack);
  end
end

function public.toString (stack)
  for i = #stack - 1, 1, -1 do
    stack[i] = stack[i] .. table.remove(stack);
  end
  return stack[1];
end

--return public;