local M = {}

M.Executing = 0

-- ... Change
-- ... Date
-- ... Client
-- ... User
-- ... Status
-- ... Description
--
-- ... Type
-- ... extraTag0
-- ... extraTagType0
-- ... IsPromoted
M.change = {
	args = { { stdin = "-i", stdout = "-o", original = "-O" }, { change = "%d" } },
	spec = function(args)
		local client = args.Client
		local change = args.Change or "new"
		local desc = args.Description
		local spec = {}
		table.insert(spec, "Client:\t" .. client)
		table.insert(spec, "Change:\t" .. change)
		if desc then
			table.insert(spec, "Description:")
			if type(desc) == "table" then
				for _, line in ipairs(desc or {}) do
					table.insert(spec, "\t" .. line)
				end
			else
				table.insert(spec, "\t" .. desc)
			end
		end
		return spec
	end,
}

-- ... change
-- ... time
-- ... user
-- ... client
-- ... status
-- ... changeType
-- ... shelved
-- ... IsPromoted
-- ... desc
M.changes = {
	args = {
		{
			status = "-s %s",
			client = "-c %s",
			max = "-m %d",
			reverse = "-r",
			time = "-t",
			user = "-u %s",
			me = "--me",
			long = "-l",
		},
		{ file = "%s", revision = "%s" },
	},
	default = { me = true, status = "pending" },
	list = true,
}

-- ... Client
-- ... Update
-- ... Access
-- ... Owner
-- ... Host
-- ... Description
--
-- ... Root
-- ... Options
-- ... SubmitOptions
-- ... LineEnd
-- ... Stream
-- ... View0
-- ... Type
-- ... Backup
M.client = {
	args = { { stdout = "-o", delete = "-d", stream = "-S %s" }, { client = "%s" } },
	default = { stdout = true },
	array = "views",
	canary = "Client",
}

-- ... client
-- ... Update
-- ... Access
-- ... Owner
-- ... Options
-- ... SubmitOptions
-- ... LineEnd
-- ... Root
-- ... Host
-- ... Stream
-- ... Type
-- ... Backup
-- ... Description
M.clients = {
	args = { me = "--me", stream = "-S %s", user = "-u %s" },
	default = { me = true },
	list = true,
}

M.copy = {
	args = {
		{ change = "-c %s", branch = "-b %s", preview = "-n", force = "-F", max = "-m %d" },
		{ from = "%s", to = "%s" },
	},
}

M.delete = {
	args = { change = "-c %s", keep = "-k", preview = "-n" },
}

-- ... name
-- ... time
-- ... type
-- ... map
-- ... desc
M.depots = {
	args = { type = "-t %s", all = "-a" },
	default = { all = true },
}

-- ... depotFile0
-- ... clientFile0
-- ... rev0
-- ... haveRev0
-- ... action0
-- ... change
-- ... type
-- ... user
-- ... client
M.describe = {
	args = { { short = "-s", added = "-a", shelved = "-S", original = "-O %s" }, { change = "%d" } },
	array = "files",
}

M.edit = {
	args = { { preview = "-n", change = "-c %s" }, { file = "%s" } },
}

M.filelog = {
	args = { { long = "-l", max = "-m", short = "-s", integrations = "-i", change = "-c" }, { file = "%s" } },
	default = { short = true },
}

M.files = {
	args = { { all = "-a", max = "-m %d", ignore_case = "-i" }, { change = '"@=%s"' }, { file = "%s" } },
}

M.grep = {
	args = { all = "-a" },
}

M.help = {
	args = { command = "%s" },
	default = { command = "help" },
}

-- ... userName
-- ... clientName
-- ... clientRoot
-- ... clientLock
-- ... clientStream
-- ... clientCwd
-- ... clientHost
-- ... clientCase
-- ... peerAddress
-- ... clientAddress
-- ... serverName
-- ... monitor
-- ... security
-- ... ldapAuth
-- ... serverAddress
-- ... serverRoot
-- ... serverDate
-- ... tzoffset
-- ... serverUptime
-- ... serverVersion
-- ... ServerID
-- ... serverServices
-- ... serverCluster
-- ... serverLicense
-- ... serverLicense-ip
-- ... caseHandling
-- ... allowStreamSpecInteg
-- ... allowPush
-- ... allowFetch
-- ... maxParallel
-- ... parentViewDefault
-- ... unloadSupport
-- ... extensionsSupport
-- ... memoryManager
-- ... transportInfo
M.info = {
	args = { short = "-s" },
	default = { short = true },
}

M.integrate = {
	args = {
		{
			stream = "-S %s",
			force = "-F",
			change = "-c %s",
			branch = "-b %s",
			reverse = "-r",
			preview = "-n",
			virtual = "-v",
			quiet = "-q",
		},
		{ from = "%s" },
		{ to = "%s" },
	},
}

M.interchanges = {
	args = {
		{
			stream = "-S %s",
			force = "-F",
			long = "-l",
			reverse = "-r",
			branch = "-b %s",
			preview = "-n",
			virtual = "-v",
			quiet = "-q",
		},
		{ from = "%s" },
		{ to = "%s" },
	},
}

M.move = {
	args = { { rename = "-r", change = "-c %s", preview = "-n" }, { from = "%s" }, { to = "%s" } },
}

-- ... depotFile
-- ... clientFile
-- ... movedFile*
-- ... rev
-- ... haveRev
-- ... action
-- ... change
-- ... type
-- ... user
-- ... client
M.opened = {
	args = {
		{
			short = "-s",
			change = "-c %s",
			default = "-c default",
			server = "-a",
			client = "-C %s",
			max = "-m %d",
			user = "-u %s",
		},
		{ file = "%s" },
	},
	default = { short = true },
	list = true,
}

M.reconcile = {
	args = {
		clean = "-w",
		preview = "-n",
		modtime = "-m",
		change = "-c %s",
		added = "-a",
		deleted = "-d",
		edited = "-e",
	},
	default = { clean = true },
}

M.reopen = {
	args = { change = "-c %s" },
	default = { change = "default" },
}

M.reshelve = {
	args = { { source = "-s %s", change = "-c %s", force = "-f" }, { file = "%s" } },
}
-- ... clientFile
-- ... fromFile
-- ... startFromRev
-- ... endFromRev
-- ... shelvedChange
-- ... resolveType
-- ... resolveFlag
-- ... contentResolveType
M.resolve = {
	args = { op = "-a%s" },
	ops = { safe = "s", merge = "m", force = "f", theirs = "t", yours = "y", mergetool = "?" },
}

M.revert = {
	args = {
		{ unchanged = "-a", change = "-c %s", keep = "-k", preview = "-n", wipe = "-w" },
		{ all = "//...", files = "%s" },
	},
	default = { all = true },
}

-- ... Stream
-- ... Update
-- ... Access
-- ... Owner
-- ... Name
-- ... Parent
-- ... Type
-- ... desc
--
-- ... Options
-- ... firmerThanParent
-- ... changeFlowsToParent
-- ... changeFlowsFromParent
-- ... baseParent
-- ... ParentView
M.streams = {
	args = { path = "%s" },
	canary = "Stream",
	list = true,
}

M.shelve = {
	args = { change = "-c %s", delete = "-d", force = "-f", replace = "-r" },
}

-- ... depotFile
-- ... clientFile
-- ... rev
-- ... action
-- ... fileSize
M.sync = {
	args = {
		{ force = "-f", preview = "-n", preview_network = "-N", reopen = "-r", safe = "-s", max = "-m %d" },
		{ file = "%s" },
	},
	canary = "action",
}

M.unshelve = {
	args = {
		shelf = "-s %s",
		change = "-c %s",
		force = "-f",
		branch = "-b %s",
		preview = "-n",
		parent = "-P %s",
		stream = "-S %s",
	},
}

-- ... User
-- ... Update
-- ... Access
-- ... FullName
-- ... Email
-- ... Type
M.users = { args = {} }

local function MakeCommand(name, spec, args)
	args = args or spec.default
	local cmd = { "p4" }

	if not args.raw then
		table.insert(cmd, "-Mj")
		table.insert(cmd, "-ztag")
	end
	if args.client then
		table.insert(cmd, "-c")
		table.insert(cmd, args.client)
	end
	table.insert(cmd, name)

	local function appendArgs(arglist)
		for name, fmt in pairs(arglist) do
			if args[name] then
				for _, value in ipairs(vim.split(string.format(fmt, args[name]), " ")) do
					table.insert(cmd, value)
				end
			end
		end
	end
	if type(spec.args[1]) == "table" then
		for _, list in ipairs(spec.args) do
			appendArgs(list)
		end
	else
		appendArgs(spec.args)
	end
	return cmd
end

local cleanArray = function(result, arrayName)
	if not arrayName then
		return result
	end

	local array = {}
	for key, value in pairs(result) do
		local name, index = key:match("(%a+)(%d+)")
		if index then
			local i = tonumber(index) + 1
			local val = {}
			val[name] = value
			array[i] = vim.tbl_extend("force", array[i] or {}, val)
			result[key] = nil
		end
	end
	if #array == 0 then
		return
	end
	local arr = {}
	arr[arrayName] = array
	return vim.tbl_extend("force", result, arr)
end

local parse = function(result, args, cmd)
	args = args or {}
	if args.raw then
		if type(result) == "string" then
			return vim.split(result, "\n")
		else
			local msg = result.code == 0 and result.stdout or result.stderr
			return msg
		end
	end
	local parsed = {}
	local stdout = vim.fn.split(result.stdout, "\n")
	if #stdout == 1 and not cmd.list then
		local value = cleanArray(vim.fn.json_decode(stdout), cmd.array)
		if cmd.canary == nil or value[cmd.canary] then
			return value
		end
	else
		local parsed = {}
		for _, line in ipairs(stdout) do
			local value = cleanArray(vim.fn.json_decode(line), cmd.array)
			if cmd.canary == nil or value[cmd.canary] then
				table.insert(parsed, value)
			end
		end
		return parsed
	end
end

for cmd, t in pairs(M) do
	if type(t) == "table" then
		setmetatable(t, {
			__call = function(t, args, handler)
				if vim.fn.executable("p4") == 0 then
					vim.notify("No Perforce installation found")
					return
				end
				args = args or {}
				local command = MakeCommand(cmd, t, args)
				local opts = { stdin = args.stdin }
				-- P(command, "test")
				M.Executing = M.Executing + 1
				if handler then
					return vim.system(command, opts, function(result)
						vim.schedule(function()
							M.Executing = M.Executing - 1
							handler(parse(result, args, t))
						end)
					end)
				else
					M.Executing = M.Executing - 1
					return parse(vim.system(command, opts):wait(), result, args, t)
				end
			end,
		})
	end
end

return M
