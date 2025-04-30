local renderer = {};

--- Clamps values within a list
---@param tbl any[]
---@param index number
---@param tbl_repeat boolean
---@return any
renderer.clamp = function (tbl, index, tbl_repeat)
	if type(tbl) ~= "table" then
		return tbl;
	end

	if index <= #tbl then
		return tbl[index];
	elseif tbl_repeat == true then
		return tbl[index % #tbl];
	else
		return tbl[#tbl];
	end
end

--- Creates a gradient from a text and a list of hl
---@param config { text: string, hl: string[], gradient_repeat: boolean? }
---@return table
renderer.gradient = function (config)
	local _o = {};

	for c = 0, vim.fn.strchars(config.text) - 1 do
		table.insert(_o, {
			vim.fn.strcharpart(config.text, c, 1),
			renderer.clamp(config.hl, c + 1, config.gradient_repeat)
		});
	end

	return _o;
end

--- Raw text renderer
---@param config foldtext.config.raw
---@return table?
renderer.raw = function (config)
	if not config or not config.text then
		return;
	end

	if vim.islist(config.hl) then
		return renderer.gradient(config);
	else
		return { config.text or "", config.hl };
	end
end;

return renderer;
