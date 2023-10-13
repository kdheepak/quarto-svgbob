local pandoc = require("pandoc")
local mmdc = os.getenv("MMDC") or pandoc.system.get_working_directory() .. "/node_modules/.bin/mmdc"
local filetype = "svg"

local renderer = {
	render_dot = function(text, attrs)
		if attrs[1] then
			attrs = attrs[1][2]
		end
		local params = { "-Tsvg" }
		for w in attrs:gmatch("%S+") do
			table.insert(params, w)
		end
		local cmd = { "dot", params, text }
		local data = pandoc.pipe(cmd[1], cmd[2], cmd[3])
		return data
	end,
	render_svgbob = function(text)
		-- io.stderr:write("svgbob found: " .. text .. "\n")
		local params = {}
		local cmd = { "svgbob_cli", params, text }
		local data = pandoc.pipe(cmd[1], cmd[2], cmd[3])
		return data
	end,
}
local get_render_lang = function(inputstr)
	local sep = "_"
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t[#t]
end

function Render(elem)
	for format, render_cmd in pairs(renderer) do
		if elem.classes[1] == format or elem.classes[1] == get_render_lang(format) then
			local data = render_cmd(elem.text, elem.attributes or {})
			return data
		end
	end
	return nil
end

function RenderCodeBlock(elem)
	local data = Render(elem)
	if data ~= nil then
		return pandoc.Para({ pandoc.RawInline("html", data) })
	else
		return nil
	end
end

function RenderCode(elem)
	elem.text = elem.text:gsub("\\n.", "\n")
	local data = Render(elem)
	if data ~= nil then
		return pandoc.RawInline("html", data)
	else
		return nil
	end
end

return { { CodeBlock = RenderCodeBlock, Code = RenderCode } }
