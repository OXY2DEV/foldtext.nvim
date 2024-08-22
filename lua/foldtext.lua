local foldtext = {};
local renderer = require("foldtext.renderer")

--- Gets attached windows of a buffer
---@param buffer number
---@return number[]
foldtext.get_attached_wins = function (buffer)
	local windows = vim.api.nvim_list_wins();
	local _f = {};

	for _, win in ipairs(windows) do
		if vim.api.nvim_win_get_buf(win) == buffer then
			table.insert(_f, win);
		end
	end

	return _f;
end

--- Checks if an input is a list or not
---@param input any
---@return boolean
foldtext.isList = function (input)
	if type(input) ~= "table" then
		return false;
	end

	for _, item in ipairs(input) do
		if type(item) ~= "table" then
			return false;
		end
	end

	return true;
end

--- Returns table containing values from a table containing
--- functions(doesn't mutate original table)
---@param tbl table
---@param ... any
---@return table
foldtext.value = function (tbl, ...)
	local _t = {};

	for k, v in pairs(tbl) do
		if vim.list_contains({ "handler" }, k) or vim.islist(tbl.__skip) and vim.list_contains(tbl.__skip, k) then
			_t[k] = v;
		elseif pcall(v, ...) then
			_t[k] = v(...);
		else
			_t[k] = v;
		end
	end

	return _t;
end

--- Missing math.clamp() function
---@param value number
---@param min number
---@param max number
---@return number
foldtext.clamp = function (value, min, max)
	return math.max(math.min(value, max), min);
end


--- Default configuration table
---@type foldtext.cofig
foldtext.configuration = {
	bt_ignore = {},
	ft_ignore = {},

	default = {
		---+ ${conf,Default foldtext}
		{
			type = "raw",
			text = function (win)
				local w = vim.api.nvim_win_get_width(win);
				local off = vim.fn.getwininfo(win)[1].textoff;
				local diff = vim.fn.strchars(" " .. tostring(vim.v.foldend - vim.v.foldstart) .. " lines ");

				return string.rep("─", math.floor((w - off - diff) / 2));
			end,
			hl = "Comment",

			gradient_repeat = true
		},
		{
			type = "fold_size",
			prefix = " ",
			postfix = " lines "
		},
		{
			type = "raw",
			text = function (win)
				local w = vim.api.nvim_win_get_width(win);
				local off = vim.fn.getwininfo(win)[1].textoff;
				local diff = vim.v.foldend - vim.v.foldstart;

				return string.rep("─", math.ceil((w - off - 2 - vim.fn.strchars(diff)) / 2));
			end,
			hl = "Comment",

			gradient_repeat = true
		},
		---_
	},

	custom = {
		{
			---+ ${conf, Markdown detail tag foldtext}
			ft = { "markdown" },
			condition = function (_, buf)
				local ln = table.concat(vim.fn.getbufline(buf, vim.v.foldstart))

				if ln:match("^%s*<summary>(.-)</summary>") then
					return true;
				else
					return false;
				end
			end,
			config = {
				{
					type = "indent",
					hl = "Normal"
				},
				{
					type = "raw",
					text = " ",
					hl = "Title"
				},
				{
					type = "custom",
					handler = function (_, buf)
						local ln = table.concat(vim.fn.getbufline(buf, vim.v.foldstart))

						return { ln:match("^%s*<summary>(.-)</summary>"), "Title" };
					end
				}
			}
			---_
		},
		{
			---+ ${conf, Identifier folds}
			ft = { "lua" },
			condition = function (_, buf)
				local ln = table.concat(vim.fn.getbufline(buf, vim.v.foldstart))

				if ln:match("%${(.+),?.*}") then
					return true;
				else
					return false;
				end
			end,
			config = {
				{
					type = "indent"
				},
				{
					type = "custom",
					handler = function (_, buf)
						local ln = table.concat(vim.fn.getbufline(buf, vim.v.foldstart))
						local tag = ln:match("%${(%a+).*}");

						local tags = {
							default = { "  " },
							conf = { "  ", "Title" },
							ui = { " 󰨵 ", nil },
							func = { " 󰡱 ", nil },
							hl = { "  ", nil },
							calc = { " 󰃬 ", nil },
							dep = { "  ", nil }
						};

						return not tags[tag] and tags.default or tags[tag];
					end
				},
				{
					type = "custom",
					handler = function (_, buf)
						local ln = table.concat(vim.fn.getbufline(buf, vim.v.foldstart))
						local txt = ln:match("%${.+,(.*)}") or " Fold";

						return { txt:gsub("^%s*", "") .. ", ", "Comment" };
					end
				},
				{
					type = "fold_size",
					hl = "Title"
				},
				{
					type = "raw",
					text = " lines",
					hl = "Comment"
				}
			}
			---_
		},
		{
			---+ ${conf, Conf-doc link folds}
			ft = { "lua" },
			condition = function (_, buf)
				local ln = table.concat(vim.fn.getbufline(buf, vim.v.foldstart))

				if ln:match("%${(link)=.-}") then
					return true;
				else
					return false;
				end
			end,
			config = {
				{
					type = "raw",
					text = "  ",
					hl = "Comment"
				},
				{
					type = "custom",
					handler = function (_, buf)
						local ln = table.concat(vim.fn.getbufline(buf, vim.v.foldstart))
						local from = ln:match("from: (.-);") or "";
						local r_1, r_2 = ln:match("range: (%d+),%d+;"), ln:match("range: %d+,(%d+);");

						return {
							{ from, "Comment" },
							{ r_1 and "[" .. r_1 or "", "Comment" },
							{ r_2 and "," .. r_2 .. "]" or "", "Comment" },
						};
					end
				},
				{
					type = "custom",
					handler = function (_, buf)
						local ln = table.concat(vim.fn.getbufline(buf, vim.v.foldstart))
						local tag = ln:match("%${link=(.-)}") or "default";

						local tags = {
							default = { "  " },
							conf = { "  ", "Title" },
							ui = { " 󰨵", nil },
							func = { " 󰡱 ", nil },
							hl = { "  ", nil },
							calc = { " 󰃬 ", nil },
							dep = { "  ", nil }
						};

						return not tags[tag] and tags.default or tags[tag];
					end
				}
			}
			---_
		},
		{
			---+ ${conf= Default fold text for lua}
			ft = { "lua" },
			config = {
				{
					type = "indent",
				},
				{
					type = "raw",
					text = "...",
					hl = "TabLineSel"
				},
				{
					type = "raw",
					text = " -- ",
					hl = "Comment"
				},
				{
					type = "fold_size",
				},
				{
					type = "raw",
					text = " lines folded!",
					hl = "Comment"
				},
				{
					type = "custom",
					handler = function (_, buf)
						local ln = table.concat(vim.fn.getbufline(buf, vim.v.foldstart))
						local tag = ln:match("%${([^=}]+).-}$") or "default";
						local text = ln:match("%${.-=(.+)}$") or "";

						local tags = {
							ns = { "" },
							default = { "  " },
							conf = { "  ", "Title" },
							ui = { " 󰨵", nil },
							func = { " 󰡱 ", nil },
							hl = { "  ", nil },
							calc = { " 󰃬 ", nil },
							dep = { "  ", nil }
						};

						return {
							not tags[tag] and tags.default or tags[tag],
							text and { text, tags[tag][2] } or nil
						};
					end
				}
			}
			---_
		},


		{
			---+ ${conf, Foldtext for indent based folds}
			condition = function (win, _)
				if vim.wo[win].foldmethod == "indent" then
					return true;
				else
					return false;
				end
			end,
			config = {
				{
					type = "indent",
				},
				{
					type = "raw",
					text = "...",
					hl = "TabLineSel"
				},
				{
					type = "custom",
					handler = function (_, buf)
						local comment = vim.bo[buf].commentstring;
						local before = comment:match("(.-)%%s")

						return { " " .. before .. (before:match("(%s)$") and "" or " "), "Comment" };
					end
				},
				{
					type = "fold_size",
				},
				{
					type = "raw",
					text = " lines folded!",
					hl = "Comment"
				},
				{
					type = "custom",
					handler = function (_, buf)
						local comment = vim.bo[buf].commentstring;
						local after = comment:match("%%s(.*)")

						return { (after:match("(^%s)") and "" or " ") .. after, "Comment" };
					end
				},
			}
			---_
		},
	}
};

--- Renderer for the foldtext
---@param window number?
---@param buffer number?
---@return [ string, string ][]
foldtext.text = function (window, buffer)
	local _t = {};
	local conf = foldtext.configuration.default or {};

	if not window then
		window = vim.api.nvim_get_current_win();
	end

	if not buffer then
		buffer = vim.api.nvim_get_current_buf();
	end

	for _, custom in ipairs(foldtext.configuration.custom or {}) do
		if custom.ft and not vim.list_contains(custom.ft, vim.bo[buffer].filetype) then
			goto ignore;
		end

		if custom.bt and vim.list_contains(custom.bt, vim.bo[buffer].buftype) then
			goto ignore;
		end

		if custom.condition and pcall(custom.condition, window, buffer) then
			if custom.condition(window, buffer) == false then
				goto ignore;
			else
				conf = custom.config;
				break;
			end
		end

		::ignore::
	end

	for _, part in ipairs(conf) do
		if part.condition then
			if part.condition == false then
				goto ignorePart;
			elseif pcall(part.condition, window, buffer) and part.condition(window, buffer) == false then
				goto ignorePart;
			end
		end

		part = foldtext.value(part, window, buffer)
		local segmant;

		if part.type == "raw" and pcall(renderer.raw, part) then
			segmant = renderer.raw(part);
		elseif part.type == "fold_size" and pcall(renderer.fold_size, part) then
			segmant = renderer.fold_size(part);
		elseif part.type == "indent" and pcall(renderer.indent, part, buffer) then
			segmant = renderer.indent(part, buffer);
		elseif part.type == "custom" and pcall(part.handler, window, buffer) then
			segmant = part.handler(window, buffer);
		end

		if foldtext.isList(segmant) then
			_t = vim.list_extend(_t, segmant);
		elseif type(segmant) == "table" then
			table.insert(_t, segmant);
		end
		::ignorePart::
	end

	return _t;
end

--- Setup function
---@param user_config foldtext.cofig?
foldtext.setup = function (user_config)
	if type(user_config) == "table" then
		foldtext.configuration = vim.tbl_deep_extend("force", foldtext.configuration, user_config);
	end
end

return foldtext;
