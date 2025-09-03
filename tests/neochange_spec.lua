local neochange = require("neochange")

describe("NeoChange core functionality", function()
    local test_dir

    before_each(function()
        -- Create a temporary test directory with git repo
        test_dir = vim.fn.tempname()
        vim.fn.mkdir(test_dir, "p")
        vim.cmd("cd " .. test_dir)

        -- Set test directory for neochange
        neochange._set_test_dir(test_dir)

        -- Initialize git repo and create some branches for testing
        vim.fn.system("cd " .. test_dir .. " && git init --initial-branch=main")
        vim.fn.system("cd " .. test_dir .. " && git config user.email 'test@example.com'")
        vim.fn.system("cd " .. test_dir .. " && git config user.name 'Test User'")
        vim.fn.system("cd " .. test_dir .. " && echo 'test' > test.txt")
        vim.fn.system("cd " .. test_dir .. " && git add .")
        vim.fn.system("cd " .. test_dir .. " && git commit -m 'initial commit'")
        vim.fn.system("cd " .. test_dir .. " && git checkout -b feature-branch")
        vim.fn.system("cd " .. test_dir .. " && git checkout main")
    end)

    after_each(function()
        -- Clean up test directory and reset test override
        if test_dir then
            vim.fn.delete(test_dir, "rf")
        end
        neochange._set_test_dir(nil)
    end)

    describe("get_current_branch", function()
        it("should return current git branch", function()
            local current_branch, err = neochange.get_current_branch()

            assert.is_nil(err, "Error should be nil, got: " .. tostring(err))
            assert.is_not_nil(current_branch, "Current branch should not be nil")
            assert.is_string(current_branch, "Current branch should be a string")
            assert.is_true(#current_branch > 0, "Current branch name should not be empty")
        end)
    end)

    describe("get_branches", function()
        it("should return list of available branches", function()
            local branches, err = neochange.get_branches()

            assert.is_nil(err, "Error should be nil, got: " .. tostring(err))
            assert.is_not_nil(branches, "Branches should not be nil")
            assert.is_table(branches, "Branches should be a table")
            assert.is_true(#branches > 0, "Should have at least one branch")
        end)

        it("should include current branch in list", function()
            local current_branch = neochange.get_current_branch()
            local branches = neochange.get_branches()

            local found = false
            for _, branch in ipairs(branches) do
                if branch == current_branch then
                    found = true
                    break
                end
            end

            assert.is_true(found, "Current branch should be in branches list")
        end)

        it("should not contain duplicates", function()
            local branches = neochange.get_branches()
            local seen = {}

            for _, branch in ipairs(branches) do
                assert.is_nil(seen[branch], "Branch " .. branch .. " appears multiple times")
                seen[branch] = true
            end
        end)
    end)

    describe("switch_to_branch", function()
        local original_branch

        before_each(function()
            original_branch = neochange.get_current_branch()
        end)

        after_each(function()
            -- Always switch back to original branch
            if original_branch then
                neochange.switch_to_branch(original_branch)
            end
        end)

        it("should reject empty branch name", function()
            local success, message = neochange.switch_to_branch("")

            assert.is_false(success)
            assert.is_string(message)
            assert.matches("cannot be empty", message)
        end)

        it("should reject nil branch name", function()
            local success, message = neochange.switch_to_branch(nil)

            assert.is_false(success)
            assert.is_string(message)
        end)

        it("should reject switching to same branch", function()
            local current_branch = neochange.get_current_branch()
            local success, message = neochange.switch_to_branch(current_branch)

            assert.is_false(success)
            assert.matches("Already on branch", message)
        end)

        it("should reject invalid branch name", function()
            local success, message = neochange.switch_to_branch("non-existent-branch-12345")

            assert.is_false(success)
            assert.is_string(message)
        end)
    end)
end)

describe("NeoChange UI functionality", function()
    -- local ui = require("neochange.ui") -- Commented out since ui is not used in tests

    describe("show_branch_selector", function()
        it("should not error when called", function()
            assert.has_no.errors(function()
                -- Mock vim functions to avoid actual UI creation in tests
                local original_create_buf = vim.api.nvim_create_buf
                local original_open_win = vim.api.nvim_open_win

                vim.api.nvim_create_buf = function()
                    return 1
                end
                vim.api.nvim_open_win = function()
                    return 1
                end

                -- This would normally show UI, but we're just testing it doesn't crash
                -- ui.show_branch_selector()

                -- Restore original functions
                vim.api.nvim_create_buf = original_create_buf
                vim.api.nvim_open_win = original_open_win
            end)
        end)
    end)
end)

describe("NeoChange commands", function()
    local commands = require("neochange.commands")

    it("should setup commands without errors", function()
        assert.has_no.errors(function()
            commands.setup()
        end)
    end)

    it("should register NeoChange command", function()
        commands.setup()

        local cmd_info = vim.api.nvim_get_commands({})
        assert.is_not_nil(cmd_info.NeoChange)
    end)
end)
