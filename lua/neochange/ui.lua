local neochange = require("neochange")

local M = {}

function M.show_branch_selector()
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

    vim.ui.select(branches, {
        prompt = "Select branch:",
        format_item = function(branch)
            if branch == current_branch then
                return "● " .. branch .. " (current)"
            else
                return "  " .. branch
            end
        end,
    }, function(selected_branch)
        if selected_branch then
            if selected_branch ~= current_branch then
                neochange.switch_to_branch(selected_branch)
            else
                vim.notify("Already on branch '" .. selected_branch .. "'", vim.log.levels.INFO)
            end
        end
    end)
end

return M
