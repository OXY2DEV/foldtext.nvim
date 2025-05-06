local examples = {};

---@type foldtext.section
examples.fold_hr = {
	kind = "section",
	output = function (_, window)
		local width = vim.api.nvim_win_get_width(window);
		local textoff = vim.fn.getwininfo(window)[1].textoff;

		width = width - textoff;

		local size = (vim.v.foldend - vim.v.foldstart) + 1;
		local len = vim.fn.strdisplaywidth(" " .. tostring(size) .. " lines ");

		return {
			{ string.rep("-", math.ceil((width - len) / 2)), "@comment" },
			{ " " },
			{ tostring(width), "@number" },
			{ " lines ", "@comment" },
			{ string.rep("-", math.floor((width - len) / 2)), "@comment" },
		};
	end
};

return examples;
