fig = 1

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
		if not ProgramExists("svgbob_cli") then	-- svgbob_cli and svgbob allowed
			cmd[1] = "svgbob"
		end
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

function ProgramExists(program)
    if os.platform == "Windows" then
    	local data = os.execute("where " .. program)
		if string.match(data, "Could not find") ~= nil then
			return false
		else
			return true
		end
    else
    	local data = os.execute("which " .. program .. " > /dev/null 2>&1")
		if data == nil then
			return false
		else
			return true
		end
    end
end

function InsertSvgLatex(svg_data)
	if not os.exists("assets/") then
		os.mkdir("assets/")
	end
	local file_name = "assets/fig_" .. tostring(fig)
	local file = io.open(file_name .. ".svg",'w')
	file:write(svg_data)
	file:close()
	pandoc.pipe("inkscape", { "--export-type=png", "--export-dpi=300", file_name  .. ".svg" }, "")
	fig = fig + 1
	return pandoc.Para({pandoc.Image({}, file_name  .. ".png")})
end

function RenderCodeBlock(elem)
	local data = Render(elem)
	if data ~= nil then
		if FORMAT:match 'latex' or 'beamer' then
			return InsertSvgLatex(data)
		else
			return pandoc.Para({ pandoc.RawInline("html", data) })
		end
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

-- Function taken from: github.com/mokeyish/obsidian-enhancing-export/lua/polyfill.lua
-- https://github.com/mokeyish/obsidian-enhancing-export/blob/16cdb17ef673e822e03e6d270aa33b28079774cc/lua/polyfill.lua#L53
os.mkdir = function(dir)
	if os.exists(dir) then
	  return
	end
	if os.platform == "Windows" then
	  dir = os.text.toencoding(dir)
	  os.execute('mkdir "' .. dir .. '"')
	else
	  os.execute('mkdir -p "' .. dir .. '"')
	end
  end

-- Function taken from: github.com/mokeyish/obsidian-enhancing-export/lua/polyfill.lua
-- https://github.com/mokeyish/obsidian-enhancing-export/blob/16cdb17ef673e822e03e6d270aa33b28079774cc/lua/polyfill.lua

os.exists = function(path)
	if os.platform == "Windows" then
		path = string.gsub(path, "/", "\\")
		path = os.text.toencoding(path)
		local _, _, code = os.execute('if exist "' .. path .. '" (exit 0) else (exit 1)')
		return code == 0
	else
		local _, _, code = os.execute('test -e "' .. path .. '"')
		return code == 0
	end
end

return { { CodeBlock = RenderCodeBlock, Code = RenderCode } }
