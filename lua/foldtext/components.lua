--- Components for the fold text.
local components = {};

components.description = function (buffer, _, config)
	local kind_styles = vim.tbl_deep_extend("force", {
		default = {
			icon = "A ",
			icon_hl = "Special"
		},

		fix = {},
		feat = {},

		docs = {},
		style = {},

		perf = {},
		test = {},
		build = {},
		chore = {},

		msg = {}
	}, config.kinds or {});

	local function kind_style (kind)
		return vim.tbl_extend("force", kind_styles.default, kind_styles[kind] or {});
	end

	local line = table.concat(
		vim.fn.getbufline(buffer, vim.v.foldstart)
	);
	local message = string.match(line, config.pattern or "[\"'](.+)[\"']");

	if not message then
		return {};
	elseif string.match(message, "^(.-)%((.+)%):%s*(.+)$") then
		local kind, scope, desc = string.match(message, "^(.-)%((.+)%):%s*(.+)$");
		local style = kind_style(kind);

		return {
			{ style.icon or "", style.icon_hl },
			{ string.format(style.scope_format or "%s", scope), style.scope_hl },
			{ style.separator or ", ", style.separator_hl },
			{ desc, style.hl },
		};
	elseif string.match(message, "^(.-):%s*(.+)$") then
		local kind, desc = string.match(message, "^(.-):%s*(.+)$");
		local style = kind_style(kind);

		return {
			{ style.icon or "", style.icon_hl },
			{ desc, style.hl },
		};
	else
		return {};
	end
end

--- Fold size.
---@param buffer integer
---@param config table
---@return table
components.section = function (buffer, _, config)
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
components.fold_size = function (_, _, config)
	local size = (vim.v.foldend - vim.v.foldstart) + 1;

	return {
		{ string.format(config.format or "%d", size), config.hl }
	}
end

--- Indentation.
---@param buffer number
---@param config table
---@return table
components.indent = function (buffer, _, config)
	local line = table.concat(
		vim.fn.getbufline(buffer, vim.v.foldstart)
	);

	return {
		{ line:match("^(%s*)"), config.hl }
	};
end

components.handle = function (buffer, window, items)
	if vim.islist(items) == false then
		return {};
	end

	local output = {};

	for _, item in ipairs(items) do
		local can_call, result = pcall(components[item.kind or item.type or ""], buffer, window, item);

		if can_call and result then
			output = vim.list_extend(output, result);
		end
	end

	return output;
end

return components;
