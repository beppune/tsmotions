local M = {}

-- Prints node. Only for debug purpose
local function debug_node(node)
	if node == nil then print("nіl node") return end

	local r, v = unpack(vim.api.nvim_win_get_cursor(0))
	local bufnr = vim.api.nvim_win_get_buf(0)
	local a, b, c, d = node:range()
	print( vim.treesitter.get_node_text(node, bufnr) .. ": sr:" .. a .. ", sc:" .. b .. ", er:" .. c .. ", ec:" .. d .. " cursor: " .. r .. ", " .. v )
end

local function get_tree()
	p = vim.treesitter.get_parser(0, nil, { error = false })
	if p ~= nil then
		return p:parse()[1]
	end
	return nil
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

-- Return an iterator based on an node list
local function type_name_iterator(nodes)
	local n = table.getn(nodes)
	local i = 0

	return function()
		i = i + 1
		if i <= n then
			return nodes[i]
		end
	end
end

-- Return a node iterator base on a ts query
local function ts_query_iterator(root, query)
	local query = vim.treesitter.query.parse(vim.bo.filetype, query)
	local captures = query:iter_captures(root, 0)

	return function()
		local _, node = captures()
		return node
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

	if r == sr and sc <= c and c < ec then return true end
	if r == er and sc <= c and c < ec then return true end
	if sr < r and r < er then return true end

	return false
	
end

-- Walks the tree from the root node and returns the two 'identifier' nodes
-- before and after the cursor position, or nil if there isn't any or none
local function walk(conf)

	conf = conf or {
		type = 'node_type',
		query = 'identifier'
	}

	local tree = get_tree()
	if tree == nil then return nil end

	local root = tree:root()

	local r, v = unpack(vim.api.nvim_win_get_cursor(0))

	local bufnr = vim.api.nvim_win_get_buf(0)

	local iterator = nil
	if conf.type == 'node_type' then
		local nodes = get_node_of_type(root, conf.query, nil)
		iterator = type_name_iterator(nodes)
	else
		iterator = ts_query_iterator(root, conf.query)
	end

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

local function place_at_node(node)
	if node ~= nil then
		local sr, sc = node:range()
		vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
	end
end

-- Module API
M.NextQuery = function(q)
	local args = {
		type = 'query',
		query = q
	}
	local _, after = unpack(walk(args))
	place_at_node(after)
end

M.PrevQuery = function(q)
	local args = {
		type = 'query',
		query = q
	}
	local before = unpack(walk(args))
	place_at_node(before)
end

M.NextTypeName = function(type_name)
	local args = {
		type = 'node_type',
		query = type_name,
	}
	local _, after = unpack( walk(args) )
	place_at_node(after)
end

M.PrevTypeName = function(type_name)
	local args = {
		type = 'node_type',
		query = type_name,
	}
	local before = unpack( walk(args) )
	place_at_node(before)
end

return M
