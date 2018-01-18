-- Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-dotfiles.
--
-- dromozoa-dotfiles is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-dotfiles is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-dotfiles.  If not, see <http://www.gnu.org/licenses/>.

local utf8 = require "dromozoa.utf8"
local east_asian_width = require "dromozoa.ucd.east_asian_width"

local unpack = table.unpack or unpack

local widths = {
  ["N"]  = 1; -- neutral
  ["Na"] = 1; -- narrow
  ["H"]  = 1; -- halfwidth
  ["A"]  = 2; -- ambiguous
  ["W"]  = 2; -- wide
  ["F"]  = 2; -- fullwidth
}

local function char_width(char)
  return widths[east_asian_width(char)]
end

local function format(buffer, first, last, max_width)
  if not buffer then
    buffer = vim.buffer()
  end
  if not first then
    first = vim.eval "v:lnum"
  end
  if not last then
    last = first + vim.eval "v:count" - 1
  end
  if not max_width then
    max_width = vim.eval "&textwidth"
  end

  local paragraphs = { { text = {} } }
  for i = first, last do
    local line = buffer[i]
    local head, body, tail = line:match "^(%s*)(.-)(%s*)$"

    local paragraph = paragraphs[#paragraphs]
    local text = paragraph.text

    if body == "" then
      if #text > 0 then
        paragraphs[#paragraphs + 1] = { text = {} }
      end
    else
      if #text == 0 then
        paragraph.indent = #head
        paragraph.margin = #head
      else
        local prev_char = text[#text]
        local prev_width = char_width(prev_char)
        local width = char_width(utf8.codepoint(body))
        if prev_width == 1 or width == 1 then
          text[#text + 1] = 0x20
        end
      end
      for _, char in utf8.codes(body) do
        text[#text + 1] = char
      end
    end
  end

  for i = 1, #paragraphs do
    local paragraph = paragraphs[i]
    local text = paragraph.text

    local lines = {}
    local line_number = 1
    local width = 0

    for j = 1, #text do
      local line = lines[line_number]
      if not line then
        line = {}
        lines[line_number] = line

        if line_number == 1 then
          width = paragraph.indent
        else
          width = paragraph.margin
        end
        for _ = 1, width do
          line[#line + 1] = 0x20
        end
      end

      local char = text[j]
      width = width + char_width(char)
      line[#line + 1] = char

      if width >= max_width then
        line_number = line_number + 1
      end
    end

    paragraph.lines = lines
  end

  local result = {}
  for i = 1, #paragraphs do
    local paragraph = paragraphs[i]
    local lines = paragraph.lines

    if i > 1 then
      result[#result + 1] = ""
    end
    for j = 1, #lines do
      result[#result + 1] = utf8.char(unpack(lines[j]))
    end
  end

  local buffer_count = last - first + 1
  local result_count = #result
  if buffer_count < result_count then
    for i = 1, buffer_count do
      buffer[first + i - 1] = result[i]
    end
    for i = buffer_count + 1, result_count do
      buffer:insert(first + i - 1, result[i])
    end
  else
    for i = 1, result_count do
      buffer[first + i - 1] = result[i]
    end
    for i = result_count + 1, buffer_count do
      buffer[first + result_count + 1] = nil
    end
  end

  return "0"
end

local function format()
  return "1"
end

return format
