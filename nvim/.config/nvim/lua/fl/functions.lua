local M = {}

M.restart_all_lsp_servers = function()
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client then
      local client_name = client.name
      client.stop()
      vim.defer_fn(function()
        require('lspconfig')[client_name].autostart()
      end, 500)
    end
  end
end

M.generate_compile_commands = function()
  local Job = require'plenary.job'
  local notify = require'notify'
  local filename = vim.fn.expand('%:p')
  Job:new({
    command = 'commands_for_file.py',
    args = { filename },
    cwd = '~/fbsource',
    on_start = function()
      notify("Generating compile commands for " .. filename, "info", {
        timeout = 1000
      })
    end,
    on_exit = function(j, return_val)
      if return_val == 0 then
        require'notify'("Compile commands done. Restarting language server...", "info", {
          timeout = 1000
        })
        M.restart_all_lsp_servers()
      else
       notify("Compile commands error. \n" .. table.concat(j:stderr_result(), "\n"), "error")
      end
    end,
    enable_recording = true,
  }):start()
end

return M
