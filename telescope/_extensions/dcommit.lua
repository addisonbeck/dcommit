local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local previewers = require "telescope.previewers"
local make_entry = require "telescope.make_entry"

-- our picker function: colors
local dcommit = function(opts)
  opts.entry_maker = vim.F.if_nil(opts.entry_maker, make_entry.gen_from_git_commits(opts))
  local git_command = vim.F.if_nil(opts.git_command, { "git", "log", "--pretty=oneline", "--abbrev-commit", "--", "." })

  pickers.new(opts, {
    prompt_title = "Git Commits",
    finder = finders.new_oneshot_job(git_command, opts),
      sorter = conf.file_sorter(opts),
      previewer = {
        previewers.git_commit_diff_to_parent.new(opts),
        previewers.git_commit_message.new(opts),
        previewers.git_commit_diff_to_head.new(opts),
        previewers.git_commit_diff_as_was.new(opts),
      },
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.cmd(string.format("term git sh %s", selection.value));
      end)
      return true
    end,
  }):find()
end

return require("telescope").register_extension({
  setup = function(ext_config, config)
    -- access extension config and user config
  end,
  exports = {
    dcommit = dcommit
  },
})

