local P4 = {
	opts = {},

	default_opts = {
		debug = true,
		default_desc = "A CL has no name",
		windows = true,
		auto_open = true,
		auto_merge = true,
		path = "C:\\Program Files\\Perforce",
	},

	info = {},
	users = {},
	streams = {},
	clients = {},
	changes = {},

	user = "",
	client = "",
	change = 0,

	User = function(user)
		return P4.users[user or P4.user]
	end,

	Users = function()
		local users = {}
		for user, spec in pairs(P4.users) do
			table.insert(users, spec)
		end
		return users
	end,

	Stream = function(stream)
		return P4.streams[stream or P4.Client().Stream]
	end,

	Streams = function()
		local streams = {}
		for stream, spec in pairs(P4.streams) do
			table.insert(streams, spec)
		end
		return streams
	end,

	Client = function(client)
		return P4.clients[client or P4.client]
	end,

	Clients = function(user)
		user = user or P4.user
		local clients = {}
		for client, spec in pairs(P4.clients) do
			if user == nil or spec.Owner == user then
				table.insert(clients, spec)
			end
		end
		return clients
	end,

	Change = function(change)
		return P4.changes[change or P4.change]
	end,

	Changes = function(client)
		client = client or P4.client
		local changes = {}
		for change, spec in pairs(P4.changes) do
			if client == nil or spec.client == client then
				table.insert(changes, spec)
			end
		end
		return changes
	end,
}

local exec = require("p4_commands")
local ui = require("p4_ui")

P4.store = {
	Info = function(info)
		P4.info = info
		P4.user = info.user
	end,

	Users = function(users)
		for _, user in ipairs(users) do
			P4.users[user.User] = user
		end
	end,

	Streams = function(streams)
		for _, stream in ipairs(streams) do
			P4.streams[stream.Stream] = vim.tbl_extend("force", P4.streams[stream.Stream] or { children = {} }, stream)
			-- Makes building a stream graph easier
			if stream.Parent and stream.Parent ~= "none" then
				P4.streams[stream.Parent] = P4.streams[stream.Parent] or { children = {} }
				table.insert(P4.streams[stream.Parent].children, stream.Stream)
			end
		end
	end,

	Clients = function(clients)
		for _, client in ipairs(clients) do
			P4.clients[client.client] = client
		end
	end,

	Changes = function(changes)
		for _, change in ipairs(changes) do
			P4.changes[change.change] = change
		end
	end,

	Update = function()
		exec.info({}, P4.store.Info)
		exec.users({}, P4.store.Users)
		exec.streams({}, P4.store.Streams)
		exec.clients({ me = true }, P4.store.Clients)
		exec.changes({ me = true, status = "pending" }, P4.store.Changes)
	end,

	UpdateChange = function(change)
		exec.describe({ change = change }, function(change)
			P4.changes[change.change] = change
		end)
	end,
}

P4.cmd = {
	Refresh = function()
		P4.store.Update()
	end,

	SetClient = function(client)
		P4.client = client
		local spec = P4.Clients(client)
		if spec and P4.opts.auto_cwd then
			vim.fn.chdir(spec.Root)
			vim.notify(spec.Root .. " is now CWD")
		end
		vim.cmd("redrawstatus")
	end,

	PickClient = function(prompt, handler)
		ui.select_client(P4.Clients(), { prompt = prompt or "Select P4 Client" }, handler or function(client)
			P4.cmd.SetClient(client.client)
		end)
	end,

	SetChange = function(change)
		P4.change = change
		if P4.opts.auto_open then
			P4.cmd.OpenFiles(change)
		end
		vim.cmd("redrawstatus")
	end,

	PickChange = function(prompt, handler)
		ui.select_change(P4.Changes(), { prompt = prompt or "Select P4 Client" }, handler or function(change)
			P4.cmd.SetChange(change.change)
		end)
	end,

	NewChange = function(client, desc)
		client = client or P4.client
		desc = desc or vim.fn.input("Description:\n", P4.opts.default_desc)
		local args = { raw = true, stdin = exec.change.spec({ Client = client, Description = desc, Change = "new" }) }
		exec.change(args, function(result)
			ui.notify(result)
			P4.cmd.Refresh()
		end)
	end,

	Shelve = function(change)
		exec.shelve({ change = change or P4.change, raw = true }, function(result)
			ui.notify(result)
			P4.cmd.Refresh()
		end)
	end,

	Unshelve = function(from, to)
		exec.unshelve({ shelf = from or P4.change, change = to or P4.change, raw = true }, function(result)
			ui.notify(result)
			P4.cmd.Refresh()
		end)
	end,

	Revert = function(change)
		exec.revert({ change = change or P4.change, raw = true }, function(result)
			ui.notify(result)
			P4.cmd.Refresh()
		end)
	end,

	DeleteShelf = function(change)
		exec.shelve({ change = change or P4.Change().change, delete = true, raw = true }, function(result)
			ui.notify(result)
			P4.cmd.Refresh()
		end)
	end,

	OpenFiles = function(change)
		exec.opened({ change = change or P4.change or "default" }, function(files)
			vim.schedule(function()
				local count = 0
				for _, file in ipairs(files) do
					local client = P4.Client(file.client)
					if client and client.Stream then
						local stream = client.Stream:gsub("(%W)", "%%%1")
						local filename = string.gsub(file.depotFile, stream, client.Root)
						local buf = vim.fn.bufadd(filename)
						vim.fn.bufload(buf)
						vim.bo[buf].buflisted = true
						count = count + 1
					end
				end
				vim.notify(count .. " files opened")
			end)
		end)
	end,

	EditFile = function(file, change)
		change = change or P4.change or "default"
		file = file or vim.fn.expand("%:p")
		exec.edit({ change = change, file = file, raw = true }, function(result)
			ui.notify(result)
			P4.cmd.Refresh()
		end)
	end,

	AddFile = function(file, change)
		change = change or P4.change or "default"
		file = file or vim.fn.expand("%:p")
		exec.add({ change = change, file = file, raw = true }, function(result)
			ui.notify(result)
			P4.cmd.Refresh()
		end)
	end,

	Sync = function(client)
		exec.sync({ client = client or P4.client, raw = true }, function(result)
			ui.notify(result)
			P4.cmd.Refresh()
		end)
	end,

	ViewChange = function(change)
		exec.change({ stdout = true, change = change, raw = true }, function(change)
			vim.schedule(function()
				ui.view_change_spec(change)
			end)
		end)
	end,

	ViewChanges = function(user)
		exec.changes({ user = user or P4.user, status = "submitted", reverse = true, long = true }, function(result)
			ui.select_change(result, { prompt = "Select change to view" }, function(change)
				if change then
					P4.cmd.ViewChange(change.change)
				end
			end)
		end)
	end,

	ViewUsers = function()
		ui.select_user(P4.Users(), nil, function(user)
			if user then
				P4.cmd.ViewChanges({ user = user.User })
			end
		end)
	end,

	Timelapse = function(file)
		file = file or vim.fn.expand("%:p")
		for _, client in pairs(P4.clients) do
			if client.Stream and file:match(client.Root) then
				local filename = file:gsub(client.Root, client.Stream)
				vim.system({ P4.opts.path .. "\\p4vc.bat", "timelapse", filename })
				vim.notify("Opening " .. filename .. " in TLV...")
				return
			end
		end
		vim.notify("Could not find depot path for " .. file, vim.log.levels.WARN)
	end,
}

P4.setup = function(opts)
	P4.opts = vim.tbl_extend("force", P4.default_opts, opts or {})
	P4.cmd.Refresh()

	vim.api.nvim_create_autocmd("BufWritePre", {
		desc = "Opens a file for edit on save",
		group = vim.api.nvim_create_augroup("P4Save", { clear = true }),
		callback = function(args)
			if vim.bo[args.buf].buftype == "" then
				local filename = vim.api.nvim_buf_get_name(args.buf)
				local readonly = vim.fn.filewritable(filename) == 0
				if readonly then
					P4.cmd.Edit(filename)
				end
			end
		end,
	})

	-- TODO: register vim commands
	return P4
end

P4.Status = function()
	local client = P4.Client() or {}
	local change = P4.Change() or {}
	return client.client, client.Stream, change.change, change.desc
end

return P4
