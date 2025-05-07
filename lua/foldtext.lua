local foldtext = {};

---@type string The value of 'foldtext'.
foldtext.FDT = "v:lua.require('foldtext').foldtext()";
foldtext.format = "v:lua%.require%('foldtext'%)%.foldtext%(%)";

---@type foldtext.config
foldtext.config = {
	ignore_filetypes = {},
	ignore_buftypes = {},

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

		ts_expr = {
			---|fS "config: Tree-sitter fold configuration"

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

			---|fE
		}
	}
};

--- Detaches from the window.
---@param window integer
foldtext.detach = function (window)
	---|fS

	if string.match(vim.wo[window].foldtext, foldtext.format) then
		vim.wo[window].foldtext = "";
	end

	---|fE
end

foldtext.update_ID = function (window)
	---|fS

	if not string.match(vim.wo[window].foldtext or "", foldtext.format) then
		return;
	end

	local buffer = vim.api.nvim_win_get_buf(window);
	local ft, bt = vim.bo[buffer].ft, vim.bo[buffer].bt;

	if vim.list_contains(foldtext.config.ignore_buftypes or {}, bt) then
		foldtext.detach(window);
		return;
	elseif vim.list_contains(foldtext.config.ignore_filetypes or {}, ft) then
		foldtext.detach(window);
		return;
	elseif foldtext.config.condition then
		local ran_cond, cond = pcall(foldtext.config.condition, buffer, window);

		if ran_cond and not cond then
			foldtext.detach(window);
			return;
		end
	end

	local fd_ID = "default";
	local keys = vim.tbl_keys(foldtext.config.styles or {});

	local function is_valid (key)
		local _config = (foldtext.config.styles or {})[key];

		if not _config then
			return false;
		elseif vim.list_contains(_config.filetypes or {}, ft) then
			return true;
		elseif vim.list_contains(_config.buftypes or {}, bt) then
			return true;
		elseif _config.condition then
			local ran_cond, cond = pcall(_config.condition, buffer, window);

			if ran_cond and cond then
				return true;
			end
		end

		return false;
	end

	for _, key in ipairs(keys) do
		if key ~= "default" and is_valid(key) then
			fd_ID = key;
			break;
		end
	end

	vim.w[window].__fdID = fd_ID;

	---|fE
end

foldtext.foldtext = function ()
	---|fS

	local window = vim.api.nvim_get_current_win();

	local parts = require("foldtext.parts")
	local buffer = vim.api.nvim_win_get_buf(window);

	if not vim.w[window].__fdID then
		foldtext.update_ID(window);
	end

	local ID = vim.w[window].__fdID or "default";
	local config = foldtext.config.styles[ID];

	---@type table[]
	local foldtext_parts = ID == "default" and config or (config.parts or {});

	if vim.islist(foldtext_parts) then
		local can_handle, output = pcall(parts.handle, foldtext_parts, buffer, window);
		return can_handle and output or {};
	elseif type(foldtext_parts) == "function" then
		local can_eval, eval = pcall(foldtext_parts, buffer, window);

		if can_eval and vim.islist(eval) then
			local can_handle, output = pcall(parts.handle, foldtext_parts, buffer, window);
			return can_handle and output or {};
		end
	end

	return {};

	---|fE
end

--- Setup function
---@param user_config? foldtext.config
foldtext.setup = function (user_config)
	---|fS

	if type(user_config) == "table" then
		local checked = require("foldtext.compat").check(user_config);

		foldtext.config = vim.tbl_deep_extend(
			"force",
			foldtext.config,
			checked or {}
		);
	end

	---|fE
end

return foldtext;
