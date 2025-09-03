local M = {}

local config_path = vim.fn.stdpath("config")

local function execute_git_command(cmd)
    local handle = io.popen("cd " .. config_path .. " && " .. cmd .. " 2>&1")
    if not handle then
        return nil, "Failed to execute command"
    end

    local result = handle:read("*a")
    local success = handle:close()

    if not success then
        return nil, result
    end

    return result, nil
end

local function get_current_branch()
    local result, err = execute_git_command("git branch --show-current")
    if err then
        return nil, err
    end
    return result:gsub("%s+", ""), nil
end

local function get_all_branches()
    local result, err = execute_git_command("git branch -a")
    if err then
        return nil, err
    end

    local branches = {}
    for line in result:gmatch("[^\r\n]+") do
        local branch = line:gsub("^%s*%*?%s*", ""):gsub("^remotes/origin/", "")
        if branch ~= "HEAD" and not branch:match("->") and branch ~= "" then
            branches[#branches + 1] = branch
        end
    end

    local unique_branches = {}
    local seen = {}
    for _, branch in ipairs(branches) do
        if not seen[branch] then
            unique_branches[#unique_branches + 1] = branch
            seen[branch] = true
        end
    end

    return unique_branches, nil
end

local function switch_branch(branch_name)
    if not branch_name or branch_name == "" then
        return false, "Branch name cannot be empty"
    end

    local current_branch, err = get_current_branch()
    if err then
        return false, "Failed to get current branch: " .. err
    end

    if current_branch == branch_name then
        return false, "Already on branch '" .. branch_name .. "'"
    end

    local result, switch_err = execute_git_command("git checkout " .. branch_name)
    if switch_err then
        return false, "Failed to switch branch: " .. switch_err
    end

    if result:match("error:") or result:match("fatal:") then
        return false, "Git error: " .. result
    end

    return true, "Successfully switched to branch '" .. branch_name .. "'"
end

local function reload_config()
    vim.cmd("source $MYVIMRC")

    for name, _ in pairs(package.loaded) do
        if name:match("^user%.") or name:match("^config%.") then
            package.loaded[name] = nil
        end
    end

    return true
end

function M.switch_to_branch(branch_name)
    local success, message = switch_branch(branch_name)

    if success then
        vim.notify(message, vim.log.levels.INFO)

        vim.defer_fn(function()
            reload_config()
            vim.notify("Configuration reloaded", vim.log.levels.INFO)
        end, 100)
    else
        vim.notify(message, vim.log.levels.ERROR)
    end

    return success, message
end

function M.get_branches()
    return get_all_branches()
end

function M.get_current_branch()
    return get_current_branch()
end

return M
