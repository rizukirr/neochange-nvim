local neochange = require("neochange")
local ui = require("neochange.ui")

local M = {}

local function complete_branches(arg_lead)
    local branches, err = neochange.get_branches()
    if err then
        vim.notify("Failed to get branches: " .. err, vim.log.levels.ERROR)
        return {}
    end

    local matches = {}
    for _, branch in ipairs(branches) do
        if branch:lower():find(arg_lead:lower(), 1, true) then
            table.insert(matches, branch)
        end
    end

    return matches
end

function M.setup(config)
    config = config or {}

    vim.api.nvim_create_user_command("NeoChange", function(opts)
        local branch_name = opts.args

        if branch_name == "" then
            ui.show_branch_selector(config)
            return
        end

        neochange.switch_to_branch(branch_name)
    end, {
        nargs = "?",
        complete = function(arg_lead, cmd_line, cursor_pos)
            return complete_branches(arg_lead)
        end,
        desc = "Switch Neovim configuration branch",
    })
end

return M
