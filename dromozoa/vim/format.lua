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

local text = require "dromozoa.text"
local ucd = require "dromozoa.ucd"
local utf8 = require "dromozoa.utf8"

local unpack = table.unpack or unpack

--[[
https://www.unicode.org/reports/tr44/#General_Category_Values
| Abbr | Long            | Description                                       |
|------|-----------------|---------------------------------------------------|
| Mn   | Nonspacing_Mark | a nonspacing combining mark (zero advance width)  |
| Mc   | Spacing_Mark    | a spacing combining mark (positive advance width) |
| Me   | Enclosing_Mark  | an enclosing combining mark                       |
]]
local function is_combining_mark(code)
  return ucd.general_category(code):find "^M"
end

local function get_head_code(this)
  while type(this) == "table" do
    this = this[1]
  end
  return this
end

local function get_tail_code(this)
  while type(this) == "table" do
    if this.class == "char" then
      this = this[1]
    else
      this = this[#this]
    end
  end
  return this
end

local function is_space(this)
  if type(this) == "number" then
    return ucd.is_white_space(this) and this ~= 0x3000
  else
    if this.class == "char" then
      return is_space(this[1])
    else
      for i = 1, #this do
        if not is_space(this[i]) then
          return false
        end
      end
      return true
    end
  end
end

local function is_line_start_prohibited(this)
  return text.is_line_start_prohibited(get_head_code(this))
end

local function is_line_end_prohibited(this)
  return text.is_line_end_prohibited(get_tail_code(this))
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
    return east_asian_width_map[ucd.east_asian_width(this)]
  else
    if this.class == "char" then
      return get_width(this[1])
    else
      local width = 0
      for i = 1, #this do
        width = width + get_width(this[i])
      end
      return width
    end
  end
end

local function is_unbreakable(that, this)
  that = get_tail_code(that)
  this = get_head_code(this)
  if text.is_prefixed_abbreviation(that) and get_width(this) == 1 then
    return true
  elseif get_width(that) == 1 and text.is_postfixed_abbreviation(this) then
    return true
  elseif text.is_inseparable(that) and text.is_inseparable(this) then
    if that == this then
      return this == 0x2014 or this == 0x2026 or this == 0x2025
    else
      return (that == 0x3033 or that == 0x3034) and this == 0x3035
    end
  else
    return false
  end
end

local function is_word(this)
  return type(this) == "table" and this.class == "word"
end

local function parse(source)
  local head = {}
  local body = {}

  for i = 1, #source do
    local this = source[i]
    if #body == 0 then
      if is_space(this) then
        head[#head + 1] = this
      else
        if get_width(this) == 1 then
          body[1] = {
            class = "word";
            this;
          }
        else
          body[1] = this
        end
      end
    else
      if is_space(this) then
        body[#body + 1] = this
      else
        local that = body[#body]
        if is_unbreakable(that, this) then
          if is_word(that) then
            that[#that + 1] = this
          else
            body[#body] = {
              class = "word";
              that;
              this;
            }
          end
        elseif get_width(this) == 1 then
          if is_word(that) then
            that[#that + 1] = this
          else
            body[#body + 1] = {
              class = "word";
              this;
            }
          end
        else
          body[#body + 1] = this
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
    if is_word(this) then
      for j = 1, #this do
        result[#result + 1] = this[j]
      end
    else
      result[#result + 1] = this
    end
  end
  return result
end

local function format(head, body, text_width)
  local max_width = text_width - get_width(head)
  local result = {}
  local width = 0
  for i = 1, #body do
    local this = body[i]
    if width == 0 then
      width = get_width(this)
      result[#result + 1] = { this }
    else
      width = width + get_width(this)
      if width <= max_width or is_space(this) or is_line_start_prohibited(this) then
        local line = result[#result]
        line[#line + 1] = this
      else
        local line1 = result[#result]
        local items = {}

        for j = #line1, 1, -1 do
          local this = line1[j]
          if is_space(this) or is_line_end_prohibited(this) then
            line1[j] = nil
            items[#items + 1] = this
          else
            break
          end
        end

        width = 0
        local line2 = {}
        for j = #items, 1, -1 do
          local this = items[j]
          if #line2 > 0 or not is_space(this) then
            width = width + get_width(this)
            line2[#line2 + 1] = this
          end
        end

        width = width + get_width(this)
        line2[#line2 + 1] = this
        result[#result + 1] = line2
      end
    end
  end
  return result
end

local function update_buffer(source, buffer, f, n)
  local m = #source
  if n < m then
    local x = f - 1
    for i = 1, n do
      buffer[x + i] = source[i]
    end
    local x = f - 2
    for i = n + 1, m do
      buffer:insert(source[i], x + i)
    end
  else
    local x = f - 1
    for i = 1, m do
      buffer[x + i] = source[i]
    end
    local x = f + m
    for i = m + 1, n do
      buffer[x] = nil
    end
  end
  return f + m - 1
end

local function format_text(vim)
  local buffer = vim.buffer()
  local window = vim.window()
  local f = vim.eval "v:lnum"
  local n = vim.eval "v:count"
  local inserted = vim.eval "v:char"
  local text_width = vim.eval "&textwidth"
  local col = window.col

  local paragraphs = {}
  local m = f + n - 1
  for i = f, m do
    local s = buffer[i]
    local line = {}

    local inserted_col
    local inserted_char
    if i == m and inserted ~= "" then
      inserted_col = window.col
      inserted_char = {
        class = "char";
        inserted = true;
        utf8.codepoint(inserted);
      }
    end

    for j, code in utf8.codes(s) do
      if j == inserted_col then
        line[#line + 1] = inserted_char
        inserted_char = nil
      end
      if is_combining_mark(code) then
        local that = line[#line]
        if type(that) == "number" then
          line[#line] = {
            class = "char";
            that;
            code;
          }
        else
          that[#that + 1] = code
        end
      else
        line[#line + 1] = code
      end
    end

    if inserted_char then
      line[#line + 1] = inserted_char
    end

    for j = #line, 1, -1 do
      if is_space(line[j]) then
        line[j] = nil
      else
        break
      end
    end

    local head, body = parse(line)
    if #body == 0 then
      paragraphs[#paragraphs + 1] = { class = "separator" }
    else
      local paragraph = paragraphs[#paragraphs]
      if not paragraph or paragraph.class == "separator" then
        paragraphs[#paragraphs + 1] = {
          class = "paragraph";
          head = head;
          body = body;
        }
      else
        local that_body = paragraph.body
        local that = that_body[#that_body]
        local this = body[1]
        if is_word(that) and get_width(get_tail_code(that)) == 1 and is_word(this) and get_width(get_head_code(this)) == 1 then
          that_body[#that_body + 1] = 0x20
        end
        for j = 1, #body do
          that_body[#that_body + 1] = body[j]
        end
      end
    end
  end

  for i = 1, #paragraphs do
    local paragraph = paragraphs[i]
    if paragraph.class == "paragraph" then
      local lines = format(paragraph.head, paragraph.body, text_width)
      for j = 1, #lines do
        lines[j] = unparse(lines[j])
      end
      paragraph.lines = lines
    end
  end

  local result_col = 1
  local result_lines = {}
  for i = 1, #paragraphs do
    local paragraph = paragraphs[i]
    if paragraph.class == "separator" then
      result_lines[#result_lines + 1] = ""
    else
      local head = utf8.char(unpack(paragraph.head))
      local lines = paragraph.lines
      for j = 1, #lines do
        local line = lines[j]
        local result_line = head
        for k = 1, #line do
          local char = line[k]
          if type(char) == "table" then
            if char.inserted then
              result_col = #result_line + 1
            else
              result_line = result_line .. utf8.char(unpack(char))
            end
          else
            result_line = result_line .. utf8.char(char)
          end
        end
        result_lines[#result_lines + 1] = result_line
      end
    end
  end

  window.line = update_buffer(result_lines, buffer, f, n)
  window.col = result_col

  return "0"
end

return function (vim)
  local filetype = vim.eval "&filetype"
  if filetype == "text" then
    return format_text(vim)
  end
  return "1"
end
