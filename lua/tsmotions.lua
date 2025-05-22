local M = {}

-- Prints node. Only for debug purpose
local function debug_node(node)
	if node == nil then print("nіl node") return end

	local r, v = unpack(vim.api.nvim_win_get_cursor(0))
	local bufnr = vim.api.nvim_win_get_buf(0)
	local a, b, c, d = node:range()
	print( vim.treesitter.get_node_text(node, bufnr) .. ": sr:" .. a .. ", sc:" .. b .. ", er:" .. c .. ", ec:" .. d .. " cursor: " .. r .. ", " .. v )
end

function get_tree()
	p = vim.treesitter.get_parser(0, nil, { error = false })
	if p ~= nil then
		return p:parse()[1]
	end
	return nil
end

function M.query()
	local query = vim.treesitter.query.parse(vim.bo.filetype, [[
		([
			(function_declaration (block) @function.block)
			(function_definition (block) @function.block)
		])	
	]])
	local tree = vim.treesitter.get_parser():parse()[1]
	for id, node, metadata in query:iter_captures(tree:root(), 0) do
		debug_node(node)
	end
end

-- Recursively fills a list of nodes of a given type
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

local function type_name_iterator(nodes)
	if nodes == nil then return nil end

	local n = table.getn(nodes)
	local i = 0

	return function()
		i = i + 1
		if i <= n then
			return nodes[i]
		end
	end
end

-- True if given node is after the cursor position
local function is_after_cursor(node, r, c)
	local sr, sc, er, ec = node:range()
	return r < sr or (r == sr and c < sc)
end

-- True if given node is around cursor position
local function is_around_cursor(node, r, c)
	local sr, sc, er, ec = node:range()
	return r == sr and sc <= c and c < ec
end

-- Walks the tree from the root node and returns the two 'identifier' nodes
-- before and after the cursor position, or nil if there isn't any or none
local function walk()
	local tree = get_tree()
	if tree == nil then return nil end

	local root = tree:root()

	local r, v = unpack(vim.api.nvim_win_get_cursor(0))

	local bufnr = vim.api.nvim_win_get_buf(0)

	local nodes = get_node_of_type(root, 'identifier', nil)

	local iterator = type_name_iterator(nodes)

	local before = nil
	local after = nil

	for node in iterator do
		-- skip if node is around cursor, otherwise 
		-- it will count as previous node
		if not is_around_cursor(node, r - 1, v) then

			before = after
			after = node

			-- this test is useless for the last element of the list
			-- since it breaks from the for loop anyways (see below).
			if is_after_cursor(node, r - 1, v) then
				break
			end
		end
	end

	-- After the for loop іs not clear if the last node of the list
	-- passed the inner if test so here 'after' is properly assigned nil
	-- if effectivley there is no node ot type 'identifier' after the cursor
	if not is_after_cursor(after, r - 1, v) then
		after = nil
	end

	return { before, after }

end

-- Module API
M.NextId = function()
	local _, after = unpack(walk())
	if after ~= nil then
		local sr, sc = after:range()
		vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
	end
end

M.PrevId = function()
	local before = unpack(walk())
	if before ~= nil then
		local sr, sc = before:range()
		vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
	end
end

return M
