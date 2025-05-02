---@type integer An autocmd group is used to group multiple event listeners together.
local augroup = vim.api.nvim_create_augroup("foldtext", {});

-- Update style for buffers whose option has changed.
vim.api.nvim_create_autocmd("OptionSet", {
	group = augroup,
	callback = function (event)
		---@type string[]
		local valid = { "filetype", "buftype", "foldmethod", "foldexpr" };

		if vim.list_contains(valid, event.match) then
			for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
				require("foldtext").attach(buffer);
			end
		end
	end
});

-- Update style for buffers that will be shown.
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = augroup,
	callback = function (event)
		require("foldtext").attach(event.buf);
	end
});

-- Clear the highlight group for fold text.
vim.api.nvim_create_autocmd({
	"VimEnter",
	"ColorScheme"
}, {
	group = augroup,
	callback = function ()
		vim.api.nvim_set_hl(0, "Folded", {
			link = "Normal"
		});
	end
});
