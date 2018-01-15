#! /usr/bin/env lua

local colors = {
  { "a", "black" };
  { "b", "red" };
  { "c", "green" };
  { "d", "brown" };
  { "e", "blue" };
  { "f", "magenta" };
  { "g", "cyan" };
  { "h", "light grey" };
  { "A", "bold black, usually shows up as dark grey" };
  { "B", "bold red" };
  { "C", "bold green" };
  { "D", "bold brown, usually shows up as yellow" };
  { "E", "bold blue" };
  { "F", "bold magenta" };
  { "G", "bold cyan" };
  { "H", "bold light grey; looks like bright white" };
  { "x", "default foreground or background" };
}

local color_map = {}
for i = 1, #colors do
  local item = colors[i]
  color_map[item[1]] = item[2]
end

local attributes = {
  "directory";
  "symbolic link";
  "socket";
  "pipe";
  "executable";
  "block special";
  "character special";
  "executable with setuid bit set";
  "executable with setgid bit set";
  "directory writable to others, with sticky bit";
  "directory writable to others, without sticky bit";
}

local attributes = {
  "ディレクトリ";
  "シンボリックリンク";
  "UNIXソケット";
  "パイプ";
  "実行可能ファイル";
  "ブロックスペシャル";
  "キャラクタスペシャル";
  "setuidビット付き実行可能ファイル";
  "setgidビット付き実行可能ファイル";
  "stickyビット付きothers書き込み可能ディレクトリ";
  "stickyビット無しothers書き込み可能ディレクトリ";
}

local function decode(source)
  local result = {}
  local i = 0
  for fg, bg in source:gmatch("(.)(.)") do
    i = i + 1
    result[i] = { fg, bg }
  end
  return result
end

local default = decode "exfxcxdxbxegedabagacad"
local setting = decode "gxcxheheDxagadabagacad"

local function write_color_html(out, colors)
  out:write([[
<table>
  <tr>
    <th>コード</th>
    <th>説明</th>
  </tr>
]])
  for i = 1, #colors do
    local c = colors[i]
    out:write(([[
  <tr>
    <td>%s</td>
    <td>%s</td>
  </tr>
]]):format(c[1], c[2]))
  end
  out:write([[
</table>
]])
end

local function write_setting_html(out, default, setting)
  out:write([[
<table>
]])
  for i = 1, #default do
    local d = default[i]
    local s = setting[i]
    out:write(([[
<tr>
  <td>%s</td>
  <td>%s</td>
  <td>%s</td>
  <td>%s</td>
  <td>%s</td>
</tr>
]]):format(attributes[i], d[1], d[2], s[1], s[2]))
  end
  out:write([[
</table>
]])
end

-- write_color_html(io.stdout, colors)
write_setting_html(io.stdout, default, setting)
