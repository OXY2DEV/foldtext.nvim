--- Parts for the fold text.
local parts = {};

---@param val any
---@param ... any
---@return table
local function eval (val, ...)
	---|fS "doc: Evaluates given value"

	local primary_eval = {};

	if type(val) == "table" then
		primary_eval = vim.deepcopy(val);
	elseif type(val) == "function" then
		local can_eval, new_val = pcall(val, ...);

		if can_eval and type(new_val) == "table" then
			primary_eval = new_val;
		else
			return { kind = "" };
		end
	else
		return { kind = "" };
	end

	for k, v in pairs(primary_eval) do
		if k ~= "condition" and type(v) == "function" then
			local can_eval, new_val = pcall(v, ...);

			if can_eval and new_val ~= nil then
				primary_eval[k] = new_val;
			else
				primary_eval[k] = nil;
			end
		end
	end

	return primary_eval;

	---|fE
end

--- Shows tree-sitter highlighted text as foldtext.
---@param buffer integer
---@param _ integer
---@param config foldtext.bufline
---@return foldtext.fragment[]
parts.bufline = function (buffer, _, config)
	---|fS "doc: Tree-sitter highlighted text"

	local start, stop = vim.fn.getbufline(buffer, vim.v.foldstart)[1], vim.fn.getbufline(buffer, vim.v.foldend)[1];
	local fragments = {};
	local virtcol = -1;

	local d = 0;

	-- BUG, We can't properly scroll over tabs.
	-- Solution: Disable scrolling for now.
	--
	-- vim.api.nvim_win_call(window, function ()
	-- 	local view = vim.fn.winsaveview();
	-- 	virtcol = view.leftcol or 0;
	-- end);
	--
	-- virtcol = virtcol - 1;

	for p, part in ipairs(vim.fn.split(start, "\\zs")) do
		---|fS "func: Start line of fold."

		local hl_captures = vim.treesitter.get_captures_at_pos(buffer, vim.v.foldstart - 1, p - 1);

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

	if type(config.delimiter) ~= "string" then
		return fragments;
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

		local hl_captures = vim.treesitter.get_captures_at_pos(buffer, vim.v.foldend - 1, p - 1);

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

--- Conventional commit style messages.
---@param buffer integer
---@param _ integer
---@param config foldtext.description
---@return foldtext.fragment[]
parts.description = function (buffer, _, config)
	---|fS "doc: Conventional commits style messages"

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
		vim.fn.getbufline(buffer, vim.v.foldstart)
	);
	local message = string.match(line, config.pattern or "[\"'](.+)[\"']");

	if not message then
		return {};
	elseif string.match(message, "^(.-)%((.+)%)[:,]%s*(.+)$") then
		local kind, scope, desc = string.match(message, "^(.-)%((.+)%)[:,]%s*(.+)$");
		local style = kind_style(kind);

		return {
			{ style.icon or "", style.icon_hl or style.hl },
			{ string.format(style.scope_format or "%s", scope), style.scope_hl or style.hl },
			{ style.separator or ", ", style.separator_hl or style.hl },
			{ desc, style.hl },
		};
	elseif string.match(message, "^(.-)[:,]%s*(.+)$") then
		local kind, desc = string.match(message, "^(.-)[:,]%s*(.+)$");
		local style = kind_style(kind);

		return {
			{ style.icon or "", style.icon_hl or style.hl },
			{ desc, style.hl },
		};
	else
		return {};
	end

	---|fE
end

---@param buffer integer
---@param config foldtext.section
---@return foldtext.fragment[]
parts.section = function (buffer, window, config)
	---|fS

	if vim.islist(config.output --[[ @as foldtext.fragment[] ]]) then
		return config.output --[[ @as foldtext.fragment[] ]];
	elseif type(config.output) == "function" then
		local can_call, result = pcall(config.output --[[ @as foldtext_dynamic_fragments ]], buffer, window);
		return can_call and result or {};
	end

	return {};

	---|fE
end

---@param config foldtext.fold_size
---@return table
parts.fold_size = function (_, _, config)
	---|fS "doc: Fold size"

	---@type integer
	local size = (vim.v.foldend - vim.v.foldstart) + 1;

	return {
		{ config.padding_left or "", config.padding_left_hl or config.hl },
		{ config.icon or "", config.icon_hl or config.hl },
		{ tostring(size), config.hl },
		{ config.padding_right or "", config.padding_right_hl or config.hl },
	};

	---|fE
end

--- Indentation.
---@param buffer number
---@param config foldtext.indent
---@return foldtext.fragment[]
parts.indent = function (buffer, _, config)
	---|fS "doc: Indentation"

	local line = table.concat(
		vim.fn.getbufline(buffer, vim.v.foldstart)
	);

	return {
		{ line:match("^(%s*)"), config.hl }
	};

	---|fE
end

---@param items foldtext_part[]
---@param buffer integer
---@param window integer
---@return foldtext.fragment[]
parts.handle = function (items, buffer, window)
	---|fS

	if vim.islist(items) == false then
		return {};
	end

	local output = {};

	for _, item in ipairs(items) do
		local _item = eval(item, buffer, window, output);
		local can_call, result;

		if _item.condition then
			local ran_condition, case = pcall(_item.condition, buffer, window, output);

			if ran_condition and case == false then
				goto continue;
			end
		end

		can_call, result = pcall(parts[_item.kind or ""], buffer, window, item, output);

		if can_call and result then
			output = vim.list_extend(output, result);
		end

		::continue::
	end

	return output;

	---|fE
end

return parts;
