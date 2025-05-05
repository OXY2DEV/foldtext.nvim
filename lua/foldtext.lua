local foldtext = {};
local components = require("foldtext.components")

---@type string The value of 'foldtext'.
foldtext.FDT = "v:lua.require('foldtext').foldtext(%d,%d)";

---@type foldtext.config
foldtext.config = {
	styles = {
		default = {
			---|fS "config: Default configuration"
			{ kind = "indent", },
			{ kind = "description" },
			{
				kind = "fold_size",
				condition = function (_, _, parts)
					return #parts > 1;
				end,

				padding_left = " ",
				icon = "󰘖 ",

				hl = "@conditional"
			},
			{
				kind = "fold_size",
				condition = function (_, _, parts)
					return #parts == 1;
				end,

				icon = "󰘖 ",
				padding_right = " lines folded!",

				padding_right_hl = "@comment",
				icon_hl = "@conditional",
				hl = "@number",
			}
			---|fE
		},

		fallback = {
			condition = function (_, window)
				return vim.wo[window].foldmethod == "expr" and vim.wo[window].foldexpr == "v:lua.vim.treesitter.foldexpr()";
			end,

			parts = {
				{
					kind = "bufline",

					delimiter = " ... ",
					hl = "@comment"
				}
			},
		}
	}
};

--- Detaches from the windows containing
--- `buffer`
---@param buffer integer
foldtext.detach = function (buffer)
	---|fS

	---@type string Pattern for our foldtext.
	local pattern = string.format(foldtext.FDT, "%d+");

	for _, win in ipairs(vim.fn.win_findbuf(buffer)) do
		---@type string The window's foldtext.
		local _foldtext = vim.wo[win].foldtext;

		if string.match(_foldtext, pattern) then
			vim.wo[win].fillchars = ""
			vim.wo[win].foldtext = "";
		end
	end

	---|fE
end

--- Sets the necessary options for the foldtext.
---@param win integer
foldtext.set_opt = function (win)
	---|fS

	local fillchars = vim.wo[win].fillchars;

	if not fillchars or fillchars == "" then
		vim.wo[win].fillchars = "fold: ";
	elseif string.match(fillchars, "fold:") then
		vim.wo[win].fillchars = string.gsub(fillchars, "fold:[^,]+", "fold: ");
	else
		vim.wo[win].fillchars = fillchars .. ",fold: ";
	end

	---|fE
end

---@param buffer integer
foldtext.attach = function (buffer)
	---|fS

	if not buffer or not vim.api.nvim_buf_is_valid(buffer) then
		return;
	end

	local bt, ft = vim.bo[buffer].bt, vim.bo[buffer].ft;

	if vim.list_contains(foldtext.config.ignore_buftypes or {}, bt) or vim.list_contains(foldtext.config.ignore_filetypes or {}, ft) then
		-- Ignore these buffers.
		foldtext.detach(buffer);
		return;
	end

	---@param style table
	---@return boolean
	local function is_valid_style (style, window)
		---|fS

		if style.supported_ft and vim.list_contains(style.supported_ft, ft) == false then
			return false;
		elseif style.supported_bt and vim.list_contains(style.supported_bt, bt) == false then
			return false;
		elseif not style.condition then
			return true;
		end

		local can_run, valid = pcall(style.condition, buffer, window);

		if can_run == false or valid == false then
			return false;
		else
			return true;
		end

		---|fE
	end

	---@type string[]
	local keys = vim.tbl_keys(foldtext.config.styles or {});
	table.sort(keys);

	for _, win in ipairs(vim.fn.win_findbuf(buffer)) do
		local fdID = "default";

		for _, k in ipairs(keys) do
			local style = foldtext.config.styles[k];

			if k == "default" then
				goto continue;
			elseif foldtext.config.condition then
				local ran_cond, cond = pcall(foldtext.config.condition, buffer, win);

				if ran_cond and not cond then
					goto continue;
				end
			end

			if is_valid_style(style, win) then
				fdID = k;
				break;
			end

			::continue::
		end

		vim.w[win].__fdID = fdID;

		foldtext.set_opt(win);
		vim.wo[win].foldtext = string.format(foldtext.FDT, buffer, win);

		return;
	end

	---|fE
end

---@param buffer integer
---@param window integer
foldtext.foldtext = function (buffer, window)
	local ID = vim.w[window].__fdID or "default";
	local config = foldtext.config.styles[ID];

	---@type table[]
	local parts = ID == "default" and config or (config.parts or {});

	if vim.islist(parts) then
		return components.handle(parts, buffer, window);
	elseif type(parts) == "function" then
		local can_eval, eval = pcall(parts, buffer, window);

		if can_eval and vim.islist(eval) then
			return components.handle(eval, buffer, window);
		end
	end

	return {};
end

--- Setup function
---@param user_config? foldtext.config
foldtext.setup = function (user_config)
	---|fS

	if type(user_config) == "table" then
		foldtext.configuration = vim.tbl_deep_extend("force", foldtext.configuration, user_config);
	end

	---|fE
end

return foldtext;
