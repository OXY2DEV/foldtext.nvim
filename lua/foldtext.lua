local foldtext = {};
local components = require("foldtext.components")

foldtext.ns = vim.api.nvim_create_namespace("foldtext");

---@type string The value of 'foldtext'.
foldtext.FDT = "v:lua.require('foldtext').foldtext(%d,%d)";

foldtext.config = {
	external_styles = { "fallback" },

	styles = {
		default = {
			---|fS "config: Default configuration"
			{
				kind = "indent",
			},
			{
				kind = "description",

				output = {
					{ "hi", "Special" }
				}
			},
			{
				kind = "fold_size",

				padding_left = " ",
				icon = "󰘖 ",

				hl = "@conditional"
			}
			---|fE
		},

		fallback = {
			condition = function (_, window)
				return vim.wo[window].foldmethod == "expr" and vim.wo[window].foldexpr == "vim.treesitter.foldexpr()";
			end,

			parts = {
				{
					kind = "section",

					delimiter = " ... ",
					hl = "@comment"
				}
			},
		}
	}
};

foldtext.detach = function (buffer)
	---|fS

	local pattern = string.format(foldtext.FDT, "%d+");

	for _, win in ipairs(vim.fn.win_findbuf(buffer)) do
		local _foldtext = vim.wo[win].foldtext;

		if string.match(_foldtext, pattern) then
			vim.wo[win].fillchars = ""
			vim.wo[win].foldtext = "";
		end
	end

	---|fE
end

foldtext.set_opt = function (win)
	local fillchars = vim.wo[win].fillchars;

	if not fillchars or fillchars == "" then
		vim.wo[win].fillchars = "fold: ";
	elseif string.match(fillchars, "fold:") then
		vim.wo[win].fillchars = string.gsub(fillchars, "fold:[^,]+", "fold: ");
	else
		vim.wo[win].fillchars = fillchars .. ",fold: ";
	end
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
			if k == "default" then
				goto continue;
			end

			local style = foldtext.config.styles[k];

			if is_valid_style(style, win) then
				fdID = k;
				break;
			end

			::continue::
		end

		if vim.list_contains(foldtext.config.external_styles or {}, fdID) == false then
			vim.w[win].__fdID = fdID;

			foldtext.set_opt(win);
			vim.wo[win].foldtext = string.format(foldtext.FDT, buffer, win);

			return;
		end
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
---@param user_config foldtext.cofig?
foldtext.setup = function (user_config)
	---|fS

	if type(user_config) == "table" then
		foldtext.configuration = vim.tbl_deep_extend("force", foldtext.configuration, user_config);
	end

	---|fE
end

return foldtext;
