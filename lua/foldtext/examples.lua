---@type table<string, foldtext.custom_style>
local examples = {};

--- A horizontal rule with the fold size.
examples.fold_hr = {
	condition = function ()
		return true;
	end,
	parts = {
		{
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
					{ tostring(size), "@number" },
					{ " lines ", "@comment" },
					{ string.rep("-", math.floor((width - len) / 2)), "@comment" },
				};
			end
		}
	}
};

--- Markdown detail tags.
examples.detail = {
	condition = function (buffer, window)
		return vim.bo[buffer].ft == "markdown" and vim.wo[window].foldmethod == "expr" and vim.wo[window].foldexpr == "v:lua.vim.treesitter.foldexpr()";
	end,

	parts = {
		{
			condition = function (buffer)
				local next_line = table.concat(
					vim.fn.getbufline(buffer, vim.v.lnum + 1)
				);

				return string.match(next_line, "%s*<summary>(.-)</summary>") ~= nil;
			end,

			kind = "section",
			output = function (buffer)
				local next_line = table.concat(
					vim.fn.getbufline(buffer, vim.v.lnum + 1),
					""
				);
				local summary = string.match(next_line, "%s*<summary>(.-)</summary>");

				return {
					{ summary or "hi", "@comment" }
				};
			end
		}
	}
};

return examples;
