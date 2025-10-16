local M = {}

local fmt = {
	user = function(user)
		return string.format("" .. " %-30s %-20s %s", user.FullName, user.User, user.Email)
	end,

	client = function(client)
		return string.format("" .. " %-30s 󰞍 %s", client.client, client.Stream or "No stream")
	end,

	change = function(change)
		local format = "#%d - %-35s"
		if change.status == "pending" then
			format = format .. "%3d  %3d 󰈔"
		end
		return string.format(
			format,
			change.change,
			string.gsub(change.Description or change.desc, "\r", ""),
			change.shelved and #change.shelved or 0,
			change.opened and #change.opened or 0
		)
	end,

	stream = function(stream)
		local icons = { development = "", mainline = "", task = "󱞁" }
		local indent = string.rep("\t", stream.depth or 0) or ""
		local format = "󰞍 %s " .. icons[stream.type] or "" .. "%-20s"
		return string.format(format, stream.stream, stream.parent)
	end,

	change_view = function(change)
		local lines = {}
		table.insert(lines, string.format("Change: %d (%s)", change.change, os.date("%Y-%m-%d %H:%M:%S", change.time)))
		table.insert(lines, "")
		table.insert(lines, string.format("Client: %s (%s)", change.client, change.user))
		table.insert(lines, "")
		table.insert(lines, "Description: ")
		table.insert(lines, "")
		for _, line in ipairs(vim.split(change.desc, "\n")) do
			table.insert(lines, "\t" .. line)
		end
		table.insert(lines, "")
		table.insert(lines, change.path)
		return lines
	end,
}

local itemizer = {
	users = function(users)
		return users
	end,
	clients = function(clients)
		table.sort(clients, function(left, right)
			return left.client < right.client
		end)
		return clients
	end,

	changes = function(changes, client)
		table.sort(changes, function(left, right)
			return tonumber(left.change) > tonumber(right.change)
		end)
		if client then
			table.insert(changes, 1, { change = "new", desc = "+ Create new changelist", client = client })
			local spec = P4.Clients(client)
			if spec then
				local desc =
					string.format("default changelist %3d 󰈔", spec.default and #P4.Clients(client).default or 0)
				table.insert(changes, 1, { change = "default", desc = desc, client = client })
			end
		end
		return changes
	end,

	streams = function(streams)
		local tree = {}
		local insert = function(tree, stream, depth)
			if not stream then
				return
			end
			table.insert(tree, { depth = depth, stream = stream.Stream, parent = stream.Parent, type = stream.Type })
			for _, child in ipairs(stream.children) do
				insert(tree, streams[child], depth + 1)
			end
		end
		for stream, spec in ipairs(streams) do
			if spec.Parent == "none" then
				insert(tree, spec, 0)
			end
		end
		return tree
	end,
}

local default_opts = {
	users = {
		prompt = "Select P4 User",
		format_item = fmt.user,
	},
	clients = {
		prompt = "Select P4 Client",
		format_item = fmt.client,
	},
	changes = {
		prompt = "Select P4 Changelist",
		format_item = fmt.change,
	},
	streams = {
		prompt = "Select P4 Stream",
		format_item = fmt.stream,
	},
}

M.notify = function(result)
	vim.schedule(function()
		if type(result) == "string" then
			vim.notify(result)
		else
			vim.notify(vim.inspect(result))
		end
	end)
end

M.confirm = function(msg)
	return vim.fn.confirm(msg or "Confirm?", "&Yes\n&No") == 1
end

M.select_user = function(users, opts, handler)
	opts = vim.tbl_extend("force", default_opts.users, opts or {})
	local choices = itemizer.users(users)
	vim.ui.select(choices, opts, handler)
end

M.select_client = function(clients, opts, handler)
	opts = vim.tbl_extend("force", default_opts.clients, opts or {})
	local choices = itemizer.clients(clients)
	vim.ui.select(choices, opts, handler)
end

M.select_change = function(changes, opts, handler, client)
	opts = vim.tbl_extend("force", default_opts.changes, opts or {})
	local choices = itemizer.changes(changes)
	vim.ui.select(choices, opts, handler)
end

M.select_stream = function(streams, opts, handler)
	opts = vim.tbl_extend("force", default_opts.streams, opts or {})
	local choices = itemizer.streams(streams)
	vim.ui.select(choices, opts, handler)
end

M.view_change = function(change)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, fmt.change_view(change))
	vim.api.nvim_set_current_buf(buf)
end

M.edit_change = function(change, handler)
	local buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(change.Description, "\r\n"))
	vim.api.nvim_buf_set_name(buf, change.Change)
	vim.api.nvim_set_current_buf(buf)

	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			change.desc = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			vim.api.nvim_buf_delete(buf, { force = true })
			handler(change)
		end,
	})
end

return M
