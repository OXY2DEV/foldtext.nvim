local compat = {};

---@type any[]
compat.alerted = {};

---@param from string
---@param to string
compat.name_change = function (from, to)
	---|fS

	if vim.list_contains(compat.alerted, from .. " > " .. to) then
		return;
	end

	local message = {
		{ "  foldtext.nvim ", "DiagnosticVirtualTextWarn" },
		{ ": ", "@comment" },
		{ string.format(" %s ", from), "DiagnosticVirtualTextHint" },
		{ " option has been renamed to ", "@comment" },
		{ string.format(" %s ", to), "DiagnosticVirtualTextOk" },
		{ ".", "@comment" }
	};

	table.insert(compat.alerted, from .. " > " .. to);
	vim.api.nvim_echo(message, true, {});

	---|fE
end

---@param from string[]
---@param to string[]
compat.moved_to = function (from, to)
	---|fS

	local msg = table.concat(from, " > ") .. " to " .. table.concat(to, " > ");

	if vim.list_contains(compat.alerted, msg) then
		return;
	end

	local message = {
		{ "  foldtext.nvim ", "DiagnosticVirtualTextWarn" },
		{ ": ", "@comment" },
	};

	for f, item in ipairs(from) do
		table.insert(message, {
			string.format(" %s ", item),
			f == #from and "DiagnosticVirtualTextWarn" or "DiagnosticVirtualTextHint"
		});

		if f ~= #from then
			table.insert(message, {
				" → ",
				"@comment"
			});
		end
	end

	table.insert(message, {
		" has been moved to ",
		"@comment"
	});

	for f, item in ipairs(to) do
		table.insert(message, {
			string.format(" %s ", item),
			f == #to and "DiagnosticVirtualTextOk" or "DiagnosticVirtualTextHint"
		});

		if f ~= #to then
			table.insert(message, {
				" → ",
				"@comment"
			});
		end
	end

	table.insert(compat.alerted, msg);
	vim.api.nvim_echo(message, true, {});

	---|fE
end

---@param id any
---@param msg [ string, string? ][]
compat.alert = function (id, msg)
	---|fS

	if vim.list_contains(compat.alerted, id) then
		return;
	end

	local header = {
		{ "  foldtext.nvim ", "DiagnosticVirtualTextWarn" },
		{ ": ", "@comment" },
	};

	table.insert(compat.alerted, id);
	vim.api.nvim_echo(vim.list_extend(header, msg), true, {});

	---|fE
end

local function eval (v, ...)
	if type(v) ~= "function" then
		return v;
	end

	local can_call, new_val = pcall(v, ...);
	return can_call and new_val or nil;
end

local function check_func (v)
	if type(v) ~= "function" then
		return v;
	end

	return function (a, b, c)
		return eval(v, b, a, c);
	end
end

---@param parts table[]
---@return foldtext_part[]
compat.handle_parts = function (parts)
	---|fS

	local new_parts = {};

	for _, part in ipairs(parts) do
		if part.type == "raw" then
			compat.alert("raw", {
				{ " raw ", "DiagnosticVirtualTextError" },
				{ " parts have been replaced with ", "@comment" },
				{ " section ", "DiagnosticVirtualTextHint" },
				{ ".", "@comment" }
			});

			table.insert(new_parts, {
				kind = "section",
				condition = check_func(part.condition),

				output = function (buf, win, ...)
					local text, hl = eval(part.text, win, buf, ...), eval(part.hl, win, buf, ...);

					return {
						{ text or "", hl }
					};
				end
			});
		elseif part.type == "fold_size" or part.type == "indent" then
			compat.alert("raw", {
				{ " " .. part.type .. " ", "DiagnosticVirtualTextError" },
				{ " has option name changes!", "@comment" },
			});

			table.insert(new_parts, {
				kind = part.type,
				condition = check_func(part.condition),

				padding_left = part.prefix,
				padding_right = part.postfix,

				hl = part.hl
			});
		elseif part.type == "custom" then
			compat.alert("raw", {
				{ " custom ", "DiagnosticVirtualTextError" },
				{ " parts have been replaced with ", "@comment" },
				{ " section ", "DiagnosticVirtualTextHint" },
				{ ".", "@comment" }
			});

			table.insert(new_parts, {
				kind = "section",
				condition = check_func(part.condition),

				output = function (buf, win, ...)
					local output = eval(part.handler, buf, win, ...) or {};

					if vim.islist(output) and #output <= 2 and type(output[1]) == "string" then
						return {
							output
						};
					else
						return output;
					end
				end
			});
		else
			-- table.insert(new_parts, part);
		end
	end

	return new_parts;

	---|fE
end

---@param config any
---@return foldtext.config
compat.check = function (config)
	---|fS

	if type(config) ~= "table" then
		return {};
	end

	local fixed = {
		styles = {},
	};

	for k, v in pairs(config) do
		if k == "ft_ignore" then
			compat.name_change("ft_ignore", "ignore_filetypes");
			fixed.ignore_filetypes = v;
		elseif k == "bt_ignore" then
			compat.name_change("bt_ignore", "ignore_buftypes");
			fixed.ignore_buftypes = v;
		elseif k == "default" then
			compat.moved_to({ "default" }, { "styles", "default" });
			fixed.styles.default = compat.handle_parts(v or {});
		elseif k == "custom" then
			compat.moved_to({ "custom" }, { "styles", "[string]" });
			compat.alert("breaking", {
				{ "Custom styles have breaking changes!", "DiagnosticError" }
			});

			for i, item in ipairs(v) do
				fixed.styles["style_" .. i] = {
					filetypes = item.ft,
					buftypes = item.bt,
					condition = item.condition,

					parts = compat.handle_parts(item.config or {})
				};
			end
		else
			fixed[k] = v;
		end
	end

	return fixed;

	---|fE
end

return compat;
