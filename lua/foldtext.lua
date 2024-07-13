local foldtext = {};

local isTuple = function (tbl)
	for _, v in ipairs(tbl) do
		if type(v) == "table" then
			return true;
		end
	end

	return false;
end

foldtext.configuraton = {
	__remap = {
		scss = "css"
	},

	default = {
		{
			type = "text",
			text = "──"
		},
		{
			type = "data",
			value = function (data)
				if data.text:match("icon:%s*(.-);") then
					return { " " .. data.text:match("icon:%s*(.-);") .. " " }
				end
			end
		},
		{
			type = "text",
			text = "──"
		},
		{
			type = "data",
			value = function (data)
				if data.text:match("title:%s*(.-);") then
					return { " " .. data.text:match("title:%s*(.-);") .. " " }
				end
			end
		},
		{
			type = "data",
			value = function (data)
				local width = vim.api.nvim_win_get_width(data.window) - vim.fn.getwininfo(data.window)[1].textoff;

				if data.text:match("line_num:%s*(.-);") ~= "false" then
					local num_part = " " .. (data.end_line - data.start_line) .. " lines ";

					return { string.rep("─",  width - (data.foldTextLen + vim.fn.strchars(num_part) + 2)) }
				end

				return { string.rep("─", width - data.foldTextLen - 2) }
			end
		},
		{
			type = "data",
			value = function (data)
				if data.text:match("line_num:%s*(.-);") ~= "false" then
					local num_part = " " .. tostring(data.end_line - data.start_line) .. " lines ";

					return { num_part }
				end
			end
		},
		{
			type = "text",
			text = "──"
		},
	},

	markdown = {
		{
			type = "text",
			text = " "
		},
		{
			type = "data",
			value = function (data)
				if data.text:match("summary:%s*(.-);") then
					return { data.text:match("summary:%s*(.-);") }
				end
			end
		},
	},

	lua = {
		default = {
			{
				type = "data",
				condition = function ()
					if vim.o.foldmethod == "indent" then
						return true;
					end

					return false;
				end,

				value = function (data)
					local spaces = data.text:match("^%s*") or "";

					return { string.rep(" ", vim.fn.strdisplaywidth(spaces)) }
				end
			},
			{
				type = "text",
				condition = function ()
					if vim.o.foldmethod == "indent" then
						return true;
					end

					return false;
				end,

				text = "...",
				hl = "TabLineSel"
			},
			{
				type = "data",
				condition = function ()
					if vim.o.foldmethod == "indent" then
						return true;
					end

					return false;
				end,

				value = function (data)
					local num = tostring(data.end_line - data.start_line + 1);

					return {
						{ " -- ", "Comment" },
						{ num, "Title" },
						{ " Lines folded!", "Comment" }
					}
				end
			},


			{
				type = "text",
				condition = function ()
					if vim.o.foldmethod == "marker" then
						return true;
					end

					return false;
				end,

				text = "──"
			},
			{
				type = "data",
				condition = function ()
					if vim.o.foldmethod == "marker" then
						return true;
					end

					return false;
				end,

				value = function (data)
					local def_icons = {
						["function"] = "󰡱 ",
						["variable"] = " ",
						["class"] = " ",
						["operators"] = "󰃬 ",
						["color"] = " ",
						["config"] = " ",
						["doc"] = "󰏪 ",
						["dependencies"] = " ",
						["sub"] = " ",
						["look"] = "󰨵 ",

						default = " "
					};
					local def_hls = {
						["function"] = "@function",
						["variable"] = "Special",
						["class"] = "@constructor",
						["operators"] = "@operator",
						["color"] = "@attribute",
						["config"] = "@parameter",
						["doc"] = "@keyword",
						["dependencies"] = "@function.builtin",
						["sub"] = "@keyword.export",
						["look"] = "@function.macro",

						default = "DevIconLua"
					};

					local title;
					local icon, hl;

					if not data.text:match("type:%s*(.-);") then
						icon = def_icons.default;
						hl = def_hls.default
					elseif data.text:match("type:%s*(.-);") == "custom" then
						icon = data.text:match("icon:%s*(.-);") or def_icons.default;
						hl = data.text:match("hl:%s*(.-);") or def_hls.default;
					else
						icon = def_icons[data.text:match("type:%s*(.-);")];
						hl = def_hls[data.text:match("type:%s*(.-);")];
					end

					title = data.text:match("title:%s*(.-);")

					return {
						" " .. icon .. (title or "") .. " ",
						hl
					}
				end
			},
			{
				type = "data",
				condition = function ()
					if vim.o.foldmethod == "marker" then
						return true;
					end

					return false;
				end,

				value = function (data)
					local width = vim.api.nvim_win_get_width(data.window) - vim.fn.getwininfo(data.window)[1].textoff;
					local num_part = " " .. (data.end_line - data.start_line + 1) .. " lines ";

					return {
						string.rep("─", width - (data.foldTextLen + vim.fn.strchars(num_part) + 2))
					}
				end
			},
			{
				type = "data",
				condition = function ()
					if vim.o.foldmethod == "marker" then
						return true;
					end

					return false;
				end,

				value = function (data)
					local num_part = " " .. (data.end_line - data.start_line + 1) .. " lines ";

					return {
						num_part,
						"tabline_tab_inactive_alt"
					}
				end
			},
			{
				type = "text",
				condition = function ()
					if vim.o.foldmethod == "marker" then
						return true;
					end

					return false;
				end,

				text = "──"
			}
		},

		code = {
			{
				type = "data",
				value = function (data)
					local spaces = data.text:match("^%s*") or "";

					return { string.rep(" ", vim.fn.strdisplaywidth(spaces)) }
				end
			},
			{
				type = "text",

				text = "...",
				hl = "TabLineSel"
			},
			{
				type = "data",

				value = function (data)
					local num = tostring(data.end_line - data.start_line + 1);

					return {
						{ " -- ", "Comment" },
						{ num, "Title" },
						{ " Lines folded!", "Comment" }
					}
				end
			},
		},

		plugin = {
			{
				type = "data",
				value = function (data)
					local badges = {};
					local _defs = {
						color = "  ",
						lsp = "  ",
						cmp = "  ",
						git = "  ",
						looks = "  ",
						browser = "  ",
						ts = "󰆋  "
					};
					local _hls = {
						color = "@exception",
						lsp = "@constant",
						cmp = "@variable",
						git = "@constructor",
						looks = "@diff.plus",
						browser = "@define",
						ts = "@character"
					};

					if not data.text:match("|(.-)|") then
						return badges;
					end

					for match in data.text:gmatch("|(.-)|") do
						if _defs[match] then
							table.insert(badges, {
								_defs[match] or "",
								_hls[match]
							})
						end
					end

					return badges;
				end
			},
			{
				type = "data",
				value = function (data)
					local name = data.text:match("name:%s*(.-);");

					return {
						name or "",
						"Special"
					}
				end
			},
			{
				type = "text",
				text = "  ",
			},
		}
	},

	html = {
		default = {
			{
				type = "data",
				value = function (data)
					local spaces = data.text:match("^%s*") or "";

					return { string.rep(" ", vim.fn.strdisplaywidth(spaces)) }
				end
			},
			{
				type = "text",

				text = "</...>",
				hl = "TabLineSel"
			},
			{
				type = "data",

				value = function (data)
					local num = tostring(data.end_line - data.start_line + 1);

					return {
						{ " <!-- ", "Comment" },
						{ num, "Title" },
						{ " Lines folded!", "Comment" },
						{ " -->", "Comment" }
					}
				end
			},
		}
	},
	css = {
		default = {
			{
				type = "data",
				value = function (data)
					local spaces = data.text:match("^%s*") or "";

					return { string.rep(" ", vim.fn.strdisplaywidth(spaces)) }
				end
			},
			{
				type = "text",

				text = "...",
				hl = "TabLineSel"
			},
			{
				type = "data",

				value = function (data)
					local num = tostring(data.end_line - data.start_line + 1);

					return {
						{ " // ", "Comment" },
						{ num, "Title" },
						{ " Lines folded!", "Comment" }
					}
				end
			},
		}
	},
};

foldtext.ns_id = vim.api.nvim_create_namespace("Foldtext");

foldtext.list_buf_wins = function (buffer)
	local wins = vim.api.nvim_list_wins();
	local filtered = {};

	for _, window in ipairs(wins) do
		if vim.api.nvim_win_get_buf(window) == buffer then
			table.insert(filtered, window);
		end
	end

	return filtered;
end

foldtext.get_len = function (text)
	local _l = 0;

	for _, part in ipairs(text) do
		_l = _l + vim.fn.strchars(part[1]);
	end

	return _l;
end

foldtext.text = function (window, buffer)
	local ft = vim.bo[buffer].filetype;

	if type(foldtext.configuraton.__remap) == "table" then
		ft = foldtext.configuraton.__remap[ft] or ft;
	end

	local foldStart = vim.v.foldstart;
	local foldEnd = vim.v.foldend;
	local foldStartLine = table.concat(vim.fn.getbufline(vim.api.nvim_get_current_buf(), foldStart));

	local conf = {};

	if foldtext.configuraton[ft] then
		if not vim.islist(foldtext.configuraton[ft]) then
			conf = foldtext.configuraton[ft][foldStartLine:match("##(.-)##") or "default"] --[[@as table]];
		else
			conf = foldtext.configuraton[ft];
		end
	elseif foldtext.configuraton.default then
		if not vim.islist(foldtext.configuraton.default) then
			conf = foldtext.configuraton.default[foldStartLine:match("##(.-)##") or "default"];
		else
			conf = foldtext.configuraton.default;
		end
	else
		return {}
	end

	local _o = {};

	for _, part in ipairs(conf or {}) do
		if part.condition and part.condition() == false then
			goto conditionNotMet;
		end

		if part.type == "text" then
			table.insert(_o, { part.text, part.hl });
		elseif part.type == "info" then
			local match = foldStartLine:match(part.pattern);

			if match then
				table.insert(_o, { match or "", part.hl });
			end
		elseif part.type == "data" then
			local input = { window = window, buffer = buffer, text = foldStartLine, start_line = foldStart, end_line = foldEnd, foldTextLen = foldtext.get_len(_o) };

			if type(part.value) == "function" and pcall(part.value --[[@as function]], input) then
				local out = part.value(input);

				if out and isTuple(out) then
					_o = vim.list_extend(_o, out);
				elseif type(out) == "table" and not vim.tbl_isempty(out) then
					table.insert(_o, out);
				end
			end

		end

		::conditionNotMet::
	end

	return _o;
end

foldtext.setup = function (config_table)
	vim.o.fillchars = "fold: "
	vim.o.foldtext = "v:lua.require('foldtext').text()";

	foldtext.configuraton = vim.tbl_extend("force", foldtext.configuraton, config_table or {});

	vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
		callback = function (event)
			local windows = foldtext.list_buf_wins(event.buf);

			for _, window in ipairs(windows) do
				vim.wo[window].foldtext = "v:lua.require('foldtext').text(" .. window .. "," .. event.buf .. ")";
			end
		end
	})
end

return foldtext;
