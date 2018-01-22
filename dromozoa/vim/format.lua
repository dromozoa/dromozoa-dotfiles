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

local dumper = require "dromozoa.commons.dumper"

local utf8 = require "dromozoa.utf8"
local east_asian_width = require "dromozoa.ucd.east_asian_width"
local is_white_space = require "dromozoa.ucd.is_white_space"
local jlreq = require "dromozoa.vim.jlreq"

local unpack = table.unpack or unpack

local function is_space(this)
  if type(this) == "number" then
    return is_white_space(this) and this ~= 0x3000
  else
    for i = 1, #this do
      if not is_space(this[i]) then
        return false
      end
    end
    return true
  end
end

local function is_line_start_prohibited(this)
  if type(this) == "number" then
    return jlreq.is_line_start_prohibited(this)
  else
    return is_line_start_prohibited(this[1])
  end
end

local function is_line_end_prohibited(this)
  if type(this) == "number" then
    return jlreq.is_line_end_prohibited(this)
  else
    return is_line_end_prohibited(this[#this])
  end
end

local function is_unbreakable(prev, this)
  if type(prev) == "table" then
    prev = prev[#prev]
  end
  if type(this) == "table" then
    this = this[1]
  end
  if jlreq.is_unbreakable(prev) and jlreq.is_unbreakable(this) then
    if prev == this then
      return this == 0x2014 or this == 0x2026 or this == 0x2025
    else
      return (prev == 0x3033 or prev == 0x3034) and this == 0x3035
    end
  else
    return false
  end
end

local east_asian_width_map = {
  ["N"]  = 1; -- neutral
  ["Na"] = 1; -- narrow
  ["H"]  = 1; -- halfwidth
  ["A"]  = 2; -- ambiguous
  ["W"]  = 2; -- wide
  ["F"]  = 2; -- fullwidth
}

local function get_width(this)
  if type(this) == "number" then
    return east_asian_width_map[east_asian_width(this)]
  else
    local width = 0
    for i = 1, #this do
      width = width + get_width(this[i])
    end
    return width
  end
end

local function encode_utf32(source)
  local result = { utf8.codepoint(source, 1, #source) }
  for i = #result, 1, -1 do
    if is_space(result[i]) then
      result[i] = nil
    else
      break
    end
  end
  return result
end

local function decode_utf32(source)
  return utf8.char(unpack(source))
end

local function parse(source)
  local head = {}
  local body = {}
  for j = 1, #source do
    local char = source[j]
    if #body == 0 then
      if is_space(char) then
        head[#head + 1] = char
      else
        if get_width(char) == 1 then
          body[1] = { char }
        else
          body[1] = char
        end
      end
    else
      if is_space(char) then
        body[#body + 1] = char
      else
        local prev = body[#body]
        if get_width(char) == 1 then
          if type(prev) == "table" then
            prev[#prev + 1] = char
          else
            body[#body + 1] = { char }
          end
        else
          if is_unbreakable(prev, char) then
            if type(prev) == "table" then
              prev[#prev + 1] = char
            else
              body[#body] = { prev, char }
            end
          else
            body[#body + 1] = char
          end
        end
      end
    end
  end
  return head, body
end

local function unparse(source)
  local result = {}
  for i = 1, #source do
    local this = source[i]
    if type(this) == "number" then
      result[#result + 1] = this
    else
      for j = 1, #this do
        result[#result + 1] = this[j]
      end
    end
  end
  return result
end

local function update_buffer(source, b, f, n)
  local m = #source
  if n < m then
    local x = f - 1
    for i = 1, n do
      b[x + i] = source[i]
    end
    local x = f - 2
    for i = n + 1, m do
      b:insert(source[i], x + i)
    end
  else
    local x = f - 1
    for i = 1, m do
      b[x + i] = source[i]
    end
    local x = f + m
    for i = m + 1, n do
      b[x] = nil
    end
  end
end

local function format_text(head, body, text_width)
  local max_width = text_width - get_width(head)

  local result = {}
  local width = 0
  for j = 1, #body do
    local this = body[j]
    if width == 0 then
      width = get_width(this)
      result[#result + 1] = { this }
    else
      width = width + get_width(this)
      if width > max_width and not is_space(this) and not is_line_start_prohibited(this) then
        local line1 = result[#result]
        local line2 = {}
        local line3 = {}

        width = 0
        for k = #line1, 1, -1 do
          local this = line1[k]
          if is_space(this) or is_line_end_prohibited(this) then
            line1[k] = nil
            width = width + get_width(this)
            line2[#line2 + 1] = this
          else
            break
          end
        end

        for k = #line2, 1, -1 do
          local this = line2[k]
          if #line3 > 0 or not is_space(this) then
            line3[#line3 + 1] = this
          end
        end

        width = width + get_width(this)
        line3[#line3 + 1] = this
        result[#result + 1] = line3
      else
        local line = result[#result]
        line[#line + 1] = this
      end
    end
  end

  return result
end

local function format_text_area(vim)
  local b = vim.buffer()
  local w = vim.window()
  local f = vim.eval "v:lnum"
  local n = vim.eval "v:count"
  local text_width = vim.eval "&textwidth"

  local paragraphs = {}
  for i = f, f + n - 1 do
    local line = encode_utf32(b[i])
    local head, body = parse(line)
    if #body == 0 then
      paragraphs[#paragraphs + 1] = { type = "separator" }
    else
      local paragraph = paragraphs[#paragraphs]
      if not paragraph or paragraph.type == "separator" then
        paragraphs[#paragraphs + 1] = { type = "paragraph", head = head, body = body }
      else
        local pbody = paragraph.body
        if type(pbody[#pbody]) == "table" and type(body[1]) == "table" then
          pbody[#pbody + 1] = 0x20
        end
        for j = 1, #body do
          pbody[#pbody + 1] = body[j]
        end
      end
    end
  end

  for i = 1, #paragraphs do
    local paragraph = paragraphs[i]
    if paragraph.type == "paragraph" then
      paragraph.lines = format_text(paragraph.head, paragraph.body, text_width)
    end
  end

  local result = {}
  for i = 1, #paragraphs do
    local paragraph = paragraphs[i]
    if paragraph.type == "separator" then
      result[#result + 1] = ""
    else
      local lines = paragraph.lines
      for j = 1, #lines do
        local head = unparse(paragraph.head)
        local body = unparse(lines[j])
        result[#result + 1] = decode_utf32(head) .. decode_utf32(body)
      end
    end
  end

  update_buffer(result, b, f, n)
  w.line = f + #result - 1
  w.col = 1

  return "0"
end

local function format_text_insert(vim, c)
  local b = vim.buffer()
  local w = vim.window()
  local f = vim.eval "v:lnum"
  local text_width = vim.eval "&textwidth"

  local out = assert(io.open("/tmp/test.log", "a"))
  out:write(([[
line = %d
col = %d
char = %s
lnum = %d
count = %d
]]):format(w.line, w.col, c, vim.eval "v:lnum", vim.eval "v:count"))
  out:close()

  c = utf8.codepoint(c)
  assert(not is_space(c))
  assert(vim.eval "v:count" == 1)

  local line = {}
  for _, char in utf8.codes(b[f]) do
    line[#line + 1] = char
  end
  line[#line + 1] = c

  local head = {}
  local body = {}
  for i = 1, #line do
    local char = line[i]
    if #body == 0 then
      if is_space(char) then
        head[#head + 1] = char
      else
        if get_width(char) == 1 then
          body[1] = { char }
        else
          body[1] = char
        end
      end
    else
      if is_space(char) then
        body[#body + 1] = char
      else
        if get_width(char) == 1 then
          local prev = body[#body]
          if type(prev) == "table" then
            prev[#prev + 1] = char
          else
            body[#body + 1] = { char }
          end
        else
          local prev = body[#body]
          if is_unbreakable(prev, char) then
            if type(prev) == "table" then
              prev[#prev + 1] = char
            else
              body[#body] = { prev, char }
            end
          else
            body[#body + 1] = char
          end
        end
      end
    end
  end

  print(dumper.encode(body))

  local max_width = text_width - get_width(head)
  print(max_width)
  local width = 0
  local lines = {}
  for i = 1, #body do
    local this = body[i]
    if width == 0 then
      width = get_width(this)
      lines[#lines + 1] = { this }
    else
      width = width + get_width(this)
      if width > max_width and not is_space(this) and not is_line_start_prohibited(this) then
        local line1 = lines[#lines]
        local line2 = {}

        width = 0
        for j = #line1, 1, -1 do
          local this = line1[j]
          if is_space(this) then
            line1[j] = nil
            -- [TODO] insert space and then remove space
          elseif is_line_end_prohibited(this) then
            line1[j] = nil
            width = width + get_width(this)
            table.insert(line2, 1, this)
          else
            break
          end
        end

        width = width + get_width(this)
        line2[#line2 + 1] = this
        lines[#lines + 1] = line2
      else
        local line = lines[#lines]
        line[#line + 1] = this
      end
    end
  end

  print(dumper.encode(lines))

  return "0"
end

return function (vim)
  local filetype = vim.eval "&filetype"
  if filetype == "text" then
    local c = vim.eval "v:char"
    if c == "" then
      return format_text_area(vim)
    else
      return format_text_insert(vim, c)
    end
  end
  return "1"
end
