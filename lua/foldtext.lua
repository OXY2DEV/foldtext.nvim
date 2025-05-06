local foldtext = {};
local components = require("foldtext.components")

---@type string The value of 'foldtext'.
foldtext.FDT = "v:lua.require('foldtext').foldtext(%d)";

---@type foldtext.config
foldtext.config = {
	ignore_buftypes = { "nofile" },

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

--- Detaches from the window.
---@param window integer
foldtext.detach = function (window)
	---|fS

	---@type string Foldtext format.
	local foldtext_pattern = string.gsub(foldtext.FDT, "%%d", "%d+");

	if string.match(vim.wo[window].foldtext, foldtext_pattern) then
		vim.wo[window].foldtext = "";
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

foldtext.update_ID = function (window)
	---|fS

	local buffer = vim.api.nvim_win_get_buf(window);
	local ft, bt = vim.bo[buffer].ft, vim.bo[buffer].bt;

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
			local ran_cond, cond = pcall(_config.condition, window);

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

---@param window integer
foldtext.attach = function (window)
	---|fS

	if not window or not vim.api.nvim_win_is_valid(window) then
		-- Do not attach to non-existing windows.
		return;
	end

	---@type integer
	local buffer = vim.api.nvim_win_get_buf(window);
	---@type string Foldtext format.
	local foldtext_pattern = string.gsub(foldtext.FDT, "%%d", "%d+");

	if string.match(vim.wo[window].foldtext or "", foldtext_pattern) then
		local buf, win = string.match(vim.wo[window].foldtext, "%((%d+),(%d+)%)");

		if buf == buffer and win == window then
			-- Already attached only update ID.
			foldtext.update_ID(window);
			return;
		end
	end

	foldtext.set_opt(window);
	vim.wo[window].foldtext = string.format(foldtext.FDT, window);

	foldtext.update_ID(window);

	---|fE
end

---@param window integer
foldtext.foldtext = function (window)
	---|fS

	local buffer = vim.api.nvim_win_get_buf(window);

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

	---|fE
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
