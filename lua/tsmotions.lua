local M = {}

function get_tree()
	p = vim.treesitter.get_parser(0, nil, { error = false })
	if p ~= nil then
		return p:parse()[1]
	end
	return nil
end

local queries = {
	identifier = '(identifier) @id'
}

local function walk(before)
	local tree = get_tree()
	if tree == nil then return nil end
	
	local q = vim.treesitter.query.parse(vim.o.filetype, queries['identifier'])
	if q == nil then return nil end

	
	local root = tree:root()

	local r, c = unpack(vim.api.nvim_win_get_cursor(0))
	local from = -1
	local to = r
	print(after)
	
	if before ~= nil and before then
		from = r
		to, _, _ = root:end_()
	end

	local bufnr = vim.api.nvim_win_get_buf(0)

	for id, node, meta in q:iter_captures(tree:root(), bufnr, r) do
		vim.print( vim.treesitter.get_node_text(node, bufnr) .. " " .. node:range())
	end

end

M.Print = function()
	walk()
end

return M
