local foldtext = require("foldtext");

-- Setup default options
vim.o.fillchars = "fold: "
vim.o.foldtext = "v:lua.require('foldtext').text()";

-- Create autocmd
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	callback = function (event)
		local buffer = event.buf;

		if foldtext.configuration.bt_ignore and vim.list_contains(foldtext.configuration.bt_ignore, vim.bo[buffer].buftype) then
			vim.wo[window].foldtext = "";
			return;
		end

		if foldtext.configuration.ft_ignore and vim.list_contains(foldtext.configuration.ft_ignore, vim.bo[buffer].filetype) then
			vim.wo[window].foldtext = "";
			return;
		end

		local windows = foldtext.get_attached_wins(buffer);

		for _, window in ipairs(windows) do
			vim.wo[window].foldtext = "v:lua.require('foldtext').text(" .. window .. "," .. buffer .. ")";
		end
	end
})

