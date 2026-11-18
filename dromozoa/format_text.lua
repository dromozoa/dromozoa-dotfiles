-- Copyright (C) 2026 Tomoyuki Fujimori <moyu@dromozoa.com>
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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-dotfiles. If not, see <https://www.gnu.org/licenses/>.

local dromozoa = {
  text = require "dromozoa.text",
  ucd = require "dromozoa.ucd",
  utf8 = require "dromozoa.utf8",
}

--------------------------------------------------------------------------------

local table_unpack = table.unpack or unpack

--------------------------------------------------------------------------------

local east_asian_widths = {
  N  = 1, -- neutral
  Na = 1, -- narrow
  H  = 1, -- halfwidth
  A  = 2, -- ambiguous
  W  = 2, -- wide
  F  = 2, -- fullwidth
}

--[[
https://www.unicode.org/reports/tr44/#General_Category_Values
| Abbr | Long            | Description                                       |
|------|-----------------|---------------------------------------------------|
| Mn   | Nonspacing_Mark | a nonspacing combining mark (zero advance width)  |
| Mc   | Spacing_Mark    | a spacing combining mark (positive advance width) |
| Me   | Enclosing_Mark  | an enclosing combining mark                       |
]]
---@param code integer
---@return boolean
local function is_combining_mark(code)
  return dromozoa.ucd.general_category(code):find "^M" ~= nil
end

---@param code integer
---@return boolean
local function is_space(code)
  -- 全角空白を除く空白類
  return dromozoa.ucd.is_white_space(code) and code ~= 0x3000
end

---@param a dromozoa.format_text.Char
---@param b dromozoa.format_text.Char
local function is_unbreakable(a, b)
  if dromozoa.text.is_prefixed_abbreviation(a:code()) and b:width() == 1 then
    -- 前置省略記号の後に半角文字
    return true
  elseif a:width() == 1 and dromozoa.text.is_postfixed_abbreviation(b:code()) then
    -- 半角文字の後に後置省略記号
    return true
  elseif dromozoa.text.is_inseparable(a:code()) and dromozoa.text.is_inseparable(b:code()) then
    -- 分離禁止文字
    if a:code() == b:code() then
      -- ダッシュ、三点リーダ、二点リーダ
      return a:code() == 0x2014 or a:code() == 0x2026 or a:code() == 0x2025
    else
      -- くの字点
      return (a:code() == 0x3033 or a:code() == 0x3034) and b:code() == 0x3035
    end
  else
    return false
  end
end

---@param source string
---@return integer
local function get_width(source)
  local width = 0
  for _, code in dromozoa.utf8.codes(source) do
    width = width + east_asian_widths[dromozoa.ucd.east_asian_width(code)]
  end
  return width
end

--------------------------------------------------------------------------------

---@class dromozoa.format_text.Char
---@field codes integer[]
local Char = {}
local Char_metatable = { __index = Char }

local function new_char(code)
  return setmetatable({
    codes = {},
  }, Char_metatable):append(code)
end

---@param code integer
---@return dromozoa.format_text.Char
function Char:append(code)
  table.insert(self.codes, code)
  return self
end

function Char:code()
  return self.codes[1]
end

---@return integer
function Char:width()
  return east_asian_widths[dromozoa.ucd.east_asian_width(self:code())]
end

---@return boolean
function Char:is_line_start_prohibited()
  return dromozoa.text.is_line_start_prohibited(self:code())
end

---@return boolean
function Char:is_line_end_prohibited()
  return dromozoa.text.is_line_end_prohibited(self:code())
end

---@return string
function Char:string()
  return dromozoa.utf8.char(table_unpack(self.codes))
end

--------------------------------------------------------------------------------

---@class dromozoa.format_text.Token
---@field chars dromozoa.format_text.Char[]
local Token = {}
local Token_metatable = { __index = Token }

---@param char dromozoa.format_text.Char
---@return dromozoa.format_text.Token
local function new_token(char)
  return setmetatable({
    chars = {},
  }, Token_metatable):append(char)
end

---@param char dromozoa.format_text.Char
---@return dromozoa.format_text.Token
function Token:append(char)
  table.insert(self.chars, char)
  return self
end

---@return dromozoa.format_text.Char
function Token:first_char()
  return self.chars[1]
end

---@return dromozoa.format_text.Char
function Token:last_char()
  return self.chars[#self.chars]
end

---@return integer
function Token:width()
  local width = 0
  for _, char in ipairs(self.chars) do
    width = width + char:width()
  end
  return width
end

---@return boolean
function Token:is_space()
  for _, char in ipairs(self.chars) do
    if not is_space(char:code()) then
      return false
    end
  end
  assert(#self.chars == 1)
  return true
end

---@return string
function Token:string()
  local buffer = {}
  for _, char in ipairs(self.chars) do
    table.insert(buffer, char:string())
  end
  return table.concat(buffer)
end

--------------------------------------------------------------------------------

---@class dromozoa.format_text.Text
---@field tokens dromozoa.format_text.Token[]
local Text = {}
local Text_metatable = { __index = Text }

---@return dromozoa.format_text.Text
local function new_text()
  return setmetatable({
    tokens = {},
  }, Text_metatable)
end

---@param token dromozoa.format_text.Token
---@return dromozoa.format_text.Text
function Text:append(token)
  table.insert(self.tokens, token)
  return self
end

--------------------------------------------------------------------------------

---@alias dromozoa.format_text.Paragraph.Kind
---| "empty"
---| "unordered"
---| "ordered"
---| "paragraph"
---| "prefixed"

---@class dromozoa.format_text.Paragraph
---@field kind dromozoa.format_text.Paragraph.Kind
---@field prefix1 string
---@field prefix2 string
---@field texts dromozoa.format_text.Text[]
local Paragraph = {}
local Paragraph_metatable = { __index = Paragraph }

---@param kind dromozoa.format_text.Paragraph.Kind
---@param prefix1 string
---@param text string
---@return dromozoa.format_text.Paragraph
local function new_paragraph(kind, prefix1, text)
  local prefix2 = prefix1
  if kind == "unordered" or kind == "ordered" then
    local _, j = assert(text:find "^%S+ ")
    prefix2 = prefix2 .. string.rep(" ", j)
  end
  return setmetatable({
    kind = kind,
    prefix1 = prefix1,
    prefix2 = prefix2,
    texts = {},
  }, Paragraph_metatable):append(text)
end

---@param body string
---@return dromozoa.format_text.Paragraph
function Paragraph:append(body)
  ---@type dromozoa.format_text.Text
  local text = new_text()

  ---@type dromozoa.format_text.Char[]
  local chars = {}
  ---@type dromozoa.format_text.Char?
  local char

  for _, code in dromozoa.utf8.codes(body) do
    if char and is_combining_mark(code) then
      char:append(code)
    else
      char = new_char(code)
      table.insert(chars, char)
    end
  end

  ---@type dromozoa.format_text.Token?
  local token
  for _, char in ipairs(chars) do
    if is_space(char:code()) then
      text:append(new_token(char))
      token = nil
    elseif token and (is_unbreakable(token:last_char(), char) or (not token:is_space() and token:last_char():width() == 1 and char:width() == 1)) then
      token:append(char)
    else
      token = new_token(char)
      text:append(token)
    end
  end

  table.insert(self.texts, text)
  return self
end

---@param ... dromozoa.format_text.Paragraph.Kind
---@return boolean
function Paragraph:check(...)
  for _, kind in ipairs { ... } do
    if self.kind == kind then
      return true
    end
  end
  return false
end

---@param line_number integer
---@return string
function Paragraph:prefix(line_number)
  if line_number == 1 then
    return self.prefix1
  else
    return self.prefix2
  end
end

---@param text_width integer
---@return string
function Paragraph:format(text_width)
  if self:check "empty" then
    return "\n"
  end

  ---@type dromozoa.format_text.Token[]
  local tokens = {}
  for i, text in ipairs(self.texts) do
    for j, token in ipairs(text.tokens) do
      -- 半角文字に挟まれた改行を空白に置き換える
      if i > 1 and j == 1 and tokens[#tokens]:last_char():width() == 1 and token:first_char():width() == 1 then
        table.insert(tokens, new_token(new_char(0x20)))
      end
      table.insert(tokens, token)
    end
  end

  local line_number = 0
  local token_start = 1

  ---@type string[]
  local buffer = {}

  while token_start <= #tokens do
    line_number = line_number + 1
    local max_width = text_width - get_width(self:prefix(line_number))
    local width = 0

    local token_index
    for i = token_start, #tokens do
      local token = tokens[i]
      width = width + token:width()
      if i == token_start or width <= max_width or token:is_space() or token:first_char():is_line_start_prohibited() then
        token_index = i
      else
        break
      end
    end

    local token_end = token_start
    for i = token_index, token_start + 1, -1 do
      local token = tokens[i]
      if not token:is_space() and not token:last_char():is_line_end_prohibited() then
        token_end = i
        break
      end
    end

    table.insert(buffer, self:prefix(line_number))
    for i = token_start, token_end do
      table.insert(buffer, tokens[i]:string())
    end
    table.insert(buffer, "\n")

    token_start = #tokens + 1
    for i = token_end + 1, #tokens do
      local token = tokens[i]
      if not token:is_space() then
        token_start = i
        break
      end
    end
  end

  return table.concat(buffer)
end

--------------------------------------------------------------------------------

---@param lines string[]
---@return dromozoa.format_text.Paragraph[]
local function parse(lines)
  ---@type dromozoa.format_text.Paragraph[]
  local paragraphs = {}
  for _, line in ipairs(lines) do
    local prefix, text = line:gsub("%s+$", ""):match "^(%s*)(.*)"
    ---@type dromozoa.format_text.Paragraph.Kind
    local kind = "paragraph"
    if text == "" then
      kind = "empty"
    elseif text:find "^%- " then
      kind = "unordered"
    elseif text:find "^%d+%. " then
      kind = "ordered"
    elseif text:find "^[>#] " or text:find "^// " or text:find "^%-%- " then
      local p, t = text:match "^(%S+ )(.*)"
      prefix = prefix .. p
      text = t
      kind = "prefixed"
    end

    if kind == "empty" or kind == "unordered" or kind == "ordered" then
      table.insert(paragraphs, new_paragraph(kind, prefix, text))
    elseif kind == "paragraph" then
      local paragraph = paragraphs[#paragraphs]
      if paragraph and (paragraph:check "paragraph" and paragraph:prefix(1) == prefix or paragraph:check("unordered", "ordered")) then
        paragraph:append(text)
      else
        table.insert(paragraphs, new_paragraph(kind, prefix, text))
      end
    else
      local paragraph = paragraphs[#paragraphs]
      if paragraph and paragraph:check "prefixed" and paragraph:prefix(1) == prefix then
        paragraph:append(text)
      else
        table.insert(paragraphs, new_paragraph(kind, prefix, text))
      end
    end
  end
  return paragraphs
end

---@param lines string[]
---@param text_width integer
---@return string
local function format_text(lines, text_width)
  local paragraphs = parse(lines)

  ---@type string[]
  local buffer = {}
  for _, paragraph in ipairs(paragraphs) do
    table.insert(buffer, paragraph:format(text_width))
  end
  return table.concat(buffer)
end

return format_text
