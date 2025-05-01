--- Components for the fold text.
local components = {};

components.bufline = function (buffer, window, config, foldstart, foldend)
	---|fS

	local start, stop = vim.fn.getbufline(buffer, foldstart or vim.v.foldstart)[1], vim.fn.getbufline(buffer, foldend or vim.v.foldend)[1];
	local fragments = {};
	local virtcol = 0;

	local d = 0;

	vim.api.nvim_win_call(window, function ()
		local view = vim.fn.winsaveview();
		virtcol = view.leftcol or 0;
	end);

	virtcol = virtcol - 1;

	for p, part in ipairs(vim.fn.split(start, "\\zs")) do
		---|fS "func: Start line of fold."

		local hl_captures = vim.treesitter.get_captures_at_pos(buffer, (foldstart or vim.v.foldstart) - 1, p - 1);

		if d <= virtcol then
			goto continue;
		end

		if #hl_captures > 0 then
			local last = hl_captures[#hl_captures];

			table.insert(fragments, {
				part,
				"@" .. last.capture .. "." .. last.lang
			});
		else
			table.insert(fragments, { part });
		end

		::continue::
		d = d + vim.fn.strdisplaywidth(part);

		---|fE
	end

	local whitespace = vim.fn.strchars(string.match(stop, "^%s*"));

	if config.delimiter then
		local delimiter = config.delimiter;

		for _, part in ipairs(vim.fn.split(delimiter, "\\zs")) do
			if d <= virtcol then
				goto continue;
			end

			table.insert(fragments, { part, config.hl });

			::continue::
			d = d + vim.fn.strdisplaywidth(part);
		end
	end

	for p, part in ipairs(vim.fn.split(stop, "\\zs")) do
		---|fS "func: End line of fold."

		local hl_captures = vim.treesitter.get_captures_at_pos(buffer, (foldend or vim.v.foldend) - 1, p - 1);

		if p <= whitespace or d <= virtcol then
			goto continue;
		end

		if #hl_captures > 0 then
			local last = hl_captures[#hl_captures];

			table.insert(fragments, {
				part,
				"@" .. last.capture .. "." .. last.lang
			});
		else
			table.insert(fragments, { part });
		end

		::continue::
		d = d + vim.fn.strdisplaywidth(part);

		---|fE
	end

	return fragments;

	---|fE
end

components.description = function (buffer, _, config, foldstart, foldend)
	---|fS

	local kind_styles = vim.tbl_deep_extend("force", {
		---|fS "style: Styles for different messages"

		default = {
			icon = " ",
			icon_hl = "@constant",

			hl = "@comment"
		},

		fix = {
			icon = "󰁨 ",
			icon_hl = "DiagnosticHint",
		},
		feat = {
			icon = "󱉂 ",
			icon_hl = "DiagnosticOk",
		},

		doc = {
			icon = "󰗚 ",
			icon_hl = "@comment",
		},
		style = {
			icon = " ",
			icon_hl = "@conditional",
		},

		perf = {
			icon = "󰓅 ",
			icon_hl = "DiagnosticError",
		},

		---|fE
	}, config.kinds or {});

	local function kind_style (kind)
		return vim.tbl_extend("force", kind_styles.default, kind_styles[kind] or {});
	end

	local line = table.concat(
		vim.fn.getbufline(buffer, foldstart or vim.v.foldstart)
	);
	local message = string.match(line, config.pattern or "[\"'](.+)[\"']");

	if not message then
		return {};
	elseif string.match(message, "^(.-)%((.+)%)[:,]%s*(.+)$") then
		local kind, scope, desc = string.match(message, "^(.-)%((.+)%)[:,]%s*(.+)$");
		local style = kind_style(kind);

		return {
			{ style.icon or "", style.icon_hl },
			{ string.format(style.scope_format or "%s", scope), style.scope_hl },
			{ style.separator or ", ", style.separator_hl },
			{ desc, style.hl },
		};
	elseif string.match(message, "^(.-)[:,]%s*(.+)$") then
		local kind, desc = string.match(message, "^(.-)[:,]%s*(.+)$");
		local style = kind_style(kind);

		return {
			{ style.icon or "", style.icon_hl },
			{ desc, style.hl },
		};
	else
		return {};
	end

	---|fE
end

--- Fold size.
---@param buffer integer
---@param config table
---@return table
components.section = function (buffer, _, config, foldstart, foldend)
	if vim.islist(config.output) then
		return config.output;
	elseif type(config.output) == "function" then
		local can_call, result = pcall(config.output, buffer);
		return can_call and result or {};
	end

	return {};
end

--- Fold size.
---@param config table
---@return table
components.fold_size = function (_, _, config, foldstart, foldend)
	local size = ((foldend or vim.v.foldend) - (foldstart or vim.v.foldstart)) + 1;

	return {
		{ config.padding_left or "", config.icon_hl or config.hl },
		{ config.icon or "", config.icon_hl or config.hl },
		{ tostring(size), config.hl },
		{ config.padding_right or "", config.icon_hl or config.hl },
	}
end

--- Indentation.
---@param buffer number
---@param config table
---@return table
components.indent = function (buffer, window, config, foldstart, foldend)
	local line = table.concat(
		vim.fn.getbufline(buffer, foldstart or vim.v.foldstart)
	);

	return {
		{ line:match("^(%s*)"), config.hl }
	};
end

components.handle = function (items, ...)
	if vim.islist(items) == false then
		return {};
	end

	local output = {};

	for _, item in ipairs(items) do
		---@class Args
		---
		---@field [1] integer
		---@field [2] integer
		---@field [3] table
		---@field [4] integer?
		---@field [5] integer?
		local args = { ... };
		table.insert(args, 3, item);

		local can_call, result = pcall(components[item.kind or item.type or ""], unpack(args));

		if can_call and result then
			output = vim.list_extend(output, result);
		end
	end

	return output;
end

return components;
