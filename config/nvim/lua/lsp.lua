local nvim_lsp = require("lspconfig")

-- python
nvim_lsp.pyright.setup{}

-- bash
nvim_lsp.bashls.setup{}

-- clangd
nvim_lsp.clangd.setup{}

-- dart
nvim_lsp.dartls.setup{
    cmd = { "dart", "/opt/flutter/bin/cache/dart-sdk/bin/snapshots/analysis_server.dart.snapshot", "--lsp" }
}

-- deno
nvim_lsp.denols.setup{}

-- dockerfile
nvim_lsp.dockerls.setup{}

-- go
nvim_lsp.gopls.setup{}

-- julia
nvim_lsp.julials.setup{
    on_new_config = function(new_config,new_root_dir)
    server_path = "/home/yog/.julia/packages/LanguageServer/jiDTR/src"
    cmd = {
        "julia",
        "--project="..server_path,
        "--startup-file=no",
        "--history-file=no",
        "-e", [[
            using Pkg;
            Pkg.instantiate()
            using LanguageServer; using SymbolServer;
            depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
            project_path = dirname(something(Base.current_project(pwd()), Base.load_path_expand(LOAD_PATH[2])))
            # Make sure that we only load packages from this environment specifically.
            @info "Running language server" env=Base.load_path()[1] pwd() project_path depot_path
            server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path);
            server.runlinter = true;
            run(server);
        ]]
    };
    new_config.cmd = cmd
    end
}

-- rust
nvim_lsp.rust_analyzer.setup{}

-- lua
nvim_lsp.sumneko_lua.setup{
    cmd = { "/usr/bin/lua-language-server", "-E", "/usr/share/lua-language-server/main.lua" };
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                path = vim.split(package.path, ";"),
            },
            diagnostics = { globals = {"vim"} },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
        }
    }
}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<cr>", opts)
    buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<cr>", opts)
    -- buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<cr>", opts)
    buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
    buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
    -- buf_set_keymap("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>", opts)
    -- buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>", opts)
    -- buf_set_keymap("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>", opts)
    -- buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
    buf_set_keymap("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
    buf_set_keymap("n", "<leader>r", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
    buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
    buf_set_keymap("n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", opts)
    -- buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>", opts)
    -- buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<cr>", opts)
    buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<cr>", opts)

    -- lspsaga better for these
    buf_set_keymap("n", "gh", [[<cmd>lua require"lspsaga.provider".lsp_finder()<cr>]], opts)
    buf_set_keymap("n", "<leader>ca", [[<cmd>lua require"lspsaga.codeaction".code_action()<cr>]], opts)
    buf_set_keymap("v", "<leader>ca", [[:<C-U>lua require"lspsaga.codeaction".range_code_action()<cr>]], opts)
    buf_set_keymap("n", "K", [[<cmd>lua require"lspsaga.hover".render_hover_doc()<cr>]], opts)
    buf_set_keymap("n", "[d", [[<cmd>lua require"lspsaga.diagnostic".lsp_jump_diagnostic_prev()<cr>]], opts)
    buf_set_keymap("n", "]d", [[<cmd>lua require"lspsaga.diagnostic".lsp_jump_diagnostic_next()<cr>]], opts)
    buf_set_keymap("n", "<C-f>", [[<cmd>lua require("lspsaga.action").smart_scroll_with_saga(1)<cr>]], opts)
    buf_set_keymap("n", "<C-b>", [[<cmd>lua require("lspsaga.action").smart_scroll_with_saga(-1)<cr>]], opts)
end

-- Use a loop to conveniently call "setup" on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "pyright", "bashls", "clangd", "dartls", "denols", "dockerls",
                  "gopls", "julials", "rust_analyzer", "sumneko_lua" }
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150,
        }
    }
end

-- using lspsaga since it looks better
require"lspsaga".init_lsp_saga()

-- show function signature when cursor idle in insert mode
vim.cmd [[autocmd CursorHoldI * silent! lua require("lspsaga.signaturehelp").signature_help()]]
