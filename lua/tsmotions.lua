local M = {}

function get_tree()
	p = vim.treesitter.get_parser(0, nil, { error = false })
	if p ~= nil then
		return p:parse()[1]
	end
	return nil
end

local function get_node_of_type(node, type_name, list)
	list = list or {}

	if node:type() == type_name then
		table.insert(list, node)
	end

	for i = 0, node:child_count() -1 do
		child = node:child(i)
		get_node_of_type(child, type_name, list)
	end
	return list
end

local function is_after_cursor(node, r, c)
	local sr, sc, er, ec = node:range()
	return r < sr or (r == sr and c < sc)
end

local function walk()
	local tree = get_tree()
	if tree == nil then return nil end

	local root = tree:root()

	local r, v = unpack(vim.api.nvim_win_get_cursor(0))

	local bufnr = vim.api.nvim_win_get_buf(0)

	local nodes = get_node_of_type(root, 'identifier', nil)
	
	local before = nil
	local after = nil

	for _, node in ipairs(nodes) do
		local a, b, c, d = node:range()

		if is_after_cursor(node, r - 1, v) then
			print( vim.treesitter.get_node_text(node, bufnr) .. ": sr:" .. a .. ", sc:" .. b .. ", er:" .. c .. ", ec:" .. d .. " cursor: " .. r .. ", " .. v )
		end
	end

end

M.Next = function()
	walk()
end

return M
