local neochange = require("neochange")

local M = {}

local function create_floating_window(content, title, config)
    config = config or {}
    local ui_config = config.ui or {}

    local width = math.floor(vim.o.columns * (ui_config.width_ratio or 0.6))
    local height = math.min(#content + 4, math.floor(vim.o.lines * (ui_config.height_ratio or 0.4)))

    local row = math.ceil((vim.o.lines - height) / 2 - 1)
    local col = math.ceil((vim.o.columns - width) / 2)

    local border_opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = ui_config.border or "rounded",
    }

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, border_opts)

    if title then
        vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal,FloatBorder:FloatBorder")
        vim.api.nvim_buf_set_option(buf, "modifiable", true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
            " " .. title,
            string.rep("─", width - 2),
            "",
        })

        local title_start_line = 3
        for i, line in ipairs(content) do
            vim.api.nvim_buf_set_lines(
                buf,
                title_start_line + i - 1,
                title_start_line + i - 1,
                false,
                { line }
            )
        end
    else
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    end

    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "readonly", true)

    return buf, win
end

local function highlight_current_branch(buf, current_branch, branches, title_offset)
    vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)

    for i, branch in ipairs(branches) do
        local line_num = i + title_offset - 1
        if branch == current_branch then
            vim.api.nvim_buf_add_highlight(buf, -1, "CursorLine", line_num, 0, -1)
            vim.api.nvim_buf_add_highlight(buf, -1, "String", line_num, 2, 4)
        end
    end
end

function M.show_branch_selector(config)
    config = config or {}
    local ui_config = config.ui or {}

    local branches, err = neochange.get_branches()
    if err then
        vim.notify("Failed to get branches: " .. err, vim.log.levels.ERROR)
        return
    end

    local current_branch, branch_err = neochange.get_current_branch()
    if branch_err then
        vim.notify("Failed to get current branch: " .. branch_err, vim.log.levels.ERROR)
        return
    end

    if #branches == 0 then
        vim.notify("No branches found", vim.log.levels.WARN)
        return
    end

    local display_lines = {}
    local current_line = 1

    for i, branch in ipairs(branches) do
        local prefix = "  "
        if branch == current_branch then
            prefix = "● "
            current_line = i
        end
        table.insert(display_lines, prefix .. branch)
    end

    local title = ui_config.title or "NeoChange - Branch Selector"
    local buf, win = create_floating_window(display_lines, title, config)

    local title_offset = 4
    highlight_current_branch(buf, current_branch, branches, title_offset)

    vim.api.nvim_win_set_cursor(win, { current_line + title_offset - 1, 0 })

    local function close_window()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    local function select_branch()
        local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
        local branch_index = cursor_line - title_offset + 1

        if branch_index >= 1 and branch_index <= #branches then
            local selected_branch = branches[branch_index]
            close_window()

            if selected_branch ~= current_branch then
                neochange.switch_to_branch(selected_branch)
            else
                vim.notify("Already on branch '" .. selected_branch .. "'", vim.log.levels.INFO)
            end
        end
    end

    local function update_cursor_highlight()
        local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
        local branch_index = cursor_line - title_offset + 1

        vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)

        for i, branch in ipairs(branches) do
            local line_num = i + title_offset - 1
            if branch == current_branch then
                vim.api.nvim_buf_add_highlight(buf, -1, "String", line_num, 2, 4)
            end
            if i == branch_index then
                vim.api.nvim_buf_add_highlight(buf, -1, "CursorLine", line_num, 0, -1)
            end
        end
    end

    local keymaps = {
        ["<CR>"] = select_branch,
        ["<Space>"] = select_branch,
        ["q"] = close_window,
        ["<Esc>"] = close_window,
        ["j"] = function()
            local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
            local max_line = #branches + title_offset - 1
            if cursor_line < max_line then
                vim.api.nvim_win_set_cursor(win, { cursor_line + 1, 0 })
                update_cursor_highlight()
            end
        end,
        ["k"] = function()
            local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
            local min_line = title_offset
            if cursor_line > min_line then
                vim.api.nvim_win_set_cursor(win, { cursor_line - 1, 0 })
                update_cursor_highlight()
            end
        end,
        ["<Down>"] = function()
            local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
            local max_line = #branches + title_offset - 1
            if cursor_line < max_line then
                vim.api.nvim_win_set_cursor(win, { cursor_line + 1, 0 })
                update_cursor_highlight()
            end
        end,
        ["<Up>"] = function()
            local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
            local min_line = title_offset
            if cursor_line > min_line then
                vim.api.nvim_win_set_cursor(win, { cursor_line - 1, 0 })
                update_cursor_highlight()
            end
        end,
    }

    for key, func in pairs(keymaps) do
        vim.keymap.set("n", key, func, { buffer = buf, silent = true, nowait = true })
    end

    vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = buf,
        callback = update_cursor_highlight,
    })

    vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
        buffer = buf,
        once = true,
        callback = close_window,
    })

    vim.cmd("setlocal cursorline")
end

return M
