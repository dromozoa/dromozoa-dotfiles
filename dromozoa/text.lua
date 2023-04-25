-- Copyright (C) 2018,2023 Tomoyuki Fujimori <moyu@dromozoa.com>
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

return {
  is_inseparable = require "dromozoa.text.is_inseparable";
  is_line_end_prohibited = require "dromozoa.text.is_line_end_prohibited";
  is_line_start_prohibited = require "dromozoa.text.is_line_start_prohibited";
  is_postfixed_abbreviation = require "dromozoa.text.is_postfixed_abbreviation";
  is_prefixed_abbreviation = require "dromozoa.text.is_prefixed_abbreviation";
}
