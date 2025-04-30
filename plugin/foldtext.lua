local augroup = vim.api.nvim_create_augroup("foldtext", {});

vim.api.nvim_create_autocmd("BufNew", {
	group = augroup,
	callback = function (event)
		require("foldtext").attach(event.buf);
	end
});

-- Create autocmd
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	callback = function (event)
		require("foldtext").attach(event.buf);
	end
})

vim.api.nvim_create_autocmd({
	"VimEnter",
	"ColorScheme"
}, {
	callback = function ()
		vim.api.nvim_set_hl(0, "Folded", {
			link = "Normal"
		});
	end
});
