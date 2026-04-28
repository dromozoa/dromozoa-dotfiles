local function lsp_buf_map(bufnr, lhs, rhs, desc, mode)
  vim.keymap.set(mode or "n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
end

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = {
    spacing = 2,
    source = "if_many",
  },
  signs = true,
  float = {
    border = "rounded",
    source = "if_many",
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my-lsp-attach", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    lsp_buf_map(bufnr, "gd", vim.lsp.buf.definition, "LSP: goto definition")
    lsp_buf_map(bufnr, "gD", vim.lsp.buf.declaration, "LSP: goto declaration")
    lsp_buf_map(bufnr, "gr", vim.lsp.buf.references, "LSP: references")
    lsp_buf_map(bufnr, "gi", vim.lsp.buf.implementation, "LSP: implementation")
    lsp_buf_map(bufnr, "K", vim.lsp.buf.hover, "LSP: hover")
    lsp_buf_map(bufnr, "<C-k>", vim.lsp.buf.signature_help, "LSP: signature help")
    lsp_buf_map(bufnr, "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
    lsp_buf_map(bufnr, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action", { "n", "x" })
    lsp_buf_map(bufnr, "<leader>f", function()
      vim.lsp.buf.format({ async = false })
    end, "LSP: format")

    lsp_buf_map(bufnr, "[d", vim.diagnostic.goto_prev, "Diagnostic: prev")
    lsp_buf_map(bufnr, "]d", vim.diagnostic.goto_next, "Diagnostic: next")
    lsp_buf_map(bufnr, "<leader>e", vim.diagnostic.open_float, "Diagnostic: line")
    lsp_buf_map(bufnr, "<leader>q", vim.diagnostic.setloclist, "Diagnostic: loclist")

    if client:supports_method("textDocument/documentHighlight") then
      local group = vim.api.nvim_create_augroup("my-lsp-highlight-" .. bufnr, { clear = true })

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "LspDetach" }, {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
      })
    end

    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
})

vim.lsp.config("lua_ls", {
  cmd = { "/opt/lua-language-server/bin/lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".git",
  },
  settings = {
    Lua = {
      runtime = {
        version = "Lua 5.4",
        pathStrict = true,
      },
      completion = {
        callSnippet = "Replace",
      },
      hint = {
        enable = true,
      },
      diagnostics = {
        disable = {
          "lowercase-global",
          "redefined-local",
        },
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      format = {
        defaultConfig = {
          -- align_continuous_assign_statement = "false",
        },
      },
    },
  },
})

vim.lsp.enable("lua_ls")
