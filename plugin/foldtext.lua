---@type integer An autocmd group is used to group multiple event listeners together.
local augroup = vim.api.nvim_create_augroup("foldtext", {});

-- Set defaults.
vim.o.foldtext = "v:lua.require('foldtext').foldtext()";
vim.opt.fillchars = {
	fold = " "
};

-- Update style for buffers whose option has changed.
vim.api.nvim_create_autocmd("OptionSet", {
	group = augroup,
	callback = function (event)
		---@type string[]
		local valid = { "filetype", "buftype", "foldmethod", "foldexpr" };

		if vim.list_contains(valid, event.match) then
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				require("foldtext").update_ID(win);
			end
		end
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
