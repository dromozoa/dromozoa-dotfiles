// Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
//
// This file is part of dromozoa-dotfiles.
//
// dromozoa-dotfiles is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// dromozoa-dotfiles is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with dromozoa-dotfiles. If not, see <https://www.gnu.org/licenses/>.

// https://www.w3.org/TR/jlreq/
// https://www.w3.org/TR/jlreq/ja/

(function (root) {
  const copy = root.copy;
  const document = root.document;
  const parseInt = root.parseInt;

  const tables = document.querySelectorAll("table.charclass");

  const dataset = [];
  for (let i = 0; i < tables.length; ++i) {
    const table = tables[i];
    const trs = table.querySelectorAll("tbody > tr");
    const h3 = table.parentNode.querySelector("h3");
    const id = h3.getAttribute("id");
    const name = h3.querySelector(".heading > .index").textContent;

    const data = [];
    for (let j = 0; j < trs.length; ++j) {
      const tr = trs[j];
      const code = tr.querySelector("td:nth-child(2)").textContent;
      const name = tr.querySelector("td:nth-child(3)").textContent;
      const remark = tr.querySelector("td:nth-child(4)").textContent;
      data.push({ code: code, name: name, remark: remark })
    }
    dataset.push({ id: id, name: name, data: data })
  }

  if (copy) {
    copy(dataset);
  }
  return dataset;
}(this));
