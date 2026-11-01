-- for ansible lsp
vim.filetype.add({
    pattern = {
        [".*/roles/.*/tasks/.*%.ya?ml"]    = "yaml.ansible",
        [".*/roles/.*/handlers/.*%.ya?ml"] = "yaml.ansible",
        [".*/playbooks/.*%.ya?ml"]         = "yaml.ansible",
    },
})

-- for javascript/typescript
local ts = { cmd = { "typescript-language-server", "--stdio" }, roots = { "package.json", ".git" } }

local servers = {
    go         = { cmd = { "gopls" },                                roots = { "go.mod", "go.work" } },
    python     = { cmd = { "pyright-langserver", "--stdio" },        roots = { "pyproject.toml", "setup.py", ".git" } },
    terraform  = { cmd = { "terraform-ls", "serve" },               roots = { ".terraform" } },
    javascript = ts,
    typescript = ts,
    ["yaml.ansible"] = { cmd = { "ansible-language-server", "--stdio" }, roots = { "ansible.cfg", ".git" } },
    yaml = {
        cmd      = { "yaml-language-server", "--stdio" },
        roots    = { ".git" },
        settings = { yaml = { schemas = {
            kubernetes = { "*.k8s.yaml", "k8s/**/*.yaml", "kubernetes/**/*.yaml", "manifests/**/*.yaml" },
        } } },
    },
}

vim.api.nvim_create_autocmd("FileType", {
    group    = vim.api.nvim_create_augroup("lsp", { clear = true }),
    pattern  = vim.tbl_keys(servers),
    callback = function(args)
        local s    = servers[args.match]
        local file = vim.api.nvim_buf_get_name(args.buf)
        local root = vim.fs.find(s.roots, { upward = true, path = vim.fs.dirname(file) })[1]
        vim.lsp.start({
            name     = s.cmd[1],
            cmd      = s.cmd,
            root_dir = root and vim.fs.dirname(root) or vim.fs.dirname(file),
            settings = s.settings,
        })
        vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    end,
})
