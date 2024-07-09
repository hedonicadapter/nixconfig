local util = require("utils")
local get_hex = util.get_hex

local rep = string.rep

local palette = {
	normal = {
		black = "#292828",
		red = "#af5f5f",
		green = "#87875f",
		yellow = "#ffdf87",
		blue = "#569cd6",
		magenta = "#af8787",
		cyan = "#87afaf",
		white = "#FFEFC2",
		beige = "#dfaf87",
	},
}

local comments_fg = get_hex("Comment", "fg")
local errors_fg = get_hex("DiagnosticError", "fg")
local warnings_fg = get_hex("DiagnosticWarn", "fg")

local min_buffer_width = 30

local components = {
	separator = {
		text = " ",
		truncation = { priority = 1 },
	},

	lil_guy = {
		text = function(buffer)
			if not buffer.is_focused then
				return ""
			elseif buffer.diagnostics.errors ~= 0 then
				return "(٥¯ ¯) "
			elseif buffer.diagnostics.warnings ~= 0 then
				return "(˶˃⤙˂˶) "
			elseif buffer.is_modified then
				return "~(‾ࡇ‾)/ "
			else
				return "(~‾⌣‾)~ "
			end
		end,
		bg = "NONE",
		fg = function(buffer)
			if buffer.diagnostics.errors ~= 0 then
				return palette.normal.red
			elseif buffer.diagnostics.warnings ~= 0 then
				return palette.normal.yellow
			elseif buffer.is_modified then
				return palette.normal.green
			else
				return palette.normal.white
			end
		end,
		truncation = { priority = 1 },
	},

	devicon_or_pick_letter = {
		text = function(buffer)
			return buffer.devicon.icon
		end,
		fg = function(buffer)
			return (buffer.is_focused and buffer.devicon.color or comments_fg)
		end,
		style = function(_)
			return "italic,bold" or nil
		end,
		truncation = { priority = 1 },
	},

	index = {
		text = function(buffer)
			return buffer.index .. " "
		end,
		fg = function(buffer)
			return (buffer.diagnostics.errors ~= 0 and errors_fg)
				or (buffer.diagnostics.warnings ~= 0 and warnings_fg)
				or palette.normal.black
		end,
		truncation = { priority = 1 },
	},

	filename_root = {
		text = function(buffer)
			return vim.fn.fnamemodify(buffer.filename, ":r")
		end,
		fg = function(buffer)
			return (buffer.diagnostics.errors ~= 0 and errors_fg)
				or (buffer.diagnostics.warnings ~= 0 and warnings_fg)
				or nil
		end,
		style = function(buffer)
			return ((buffer.is_focused and buffer.diagnostics.errors ~= 0) and "bold,underline")
				or (buffer.is_focused and "bold")
				or (buffer.diagnostics.errors ~= 0 and "underline")
				or nil
		end,
		truncation = {
			priority = 3,
			direction = "middle",
		},
	},

	filename_extension = {
		text = function(buffer)
			local ext = vim.fn.fnamemodify(buffer.filename, ":e")
			return ext ~= "" and "." .. ext or ""
		end,
		fg = function(buffer)
			return (buffer.diagnostics.errors ~= 0 and errors_fg)
				or (buffer.diagnostics.warnings ~= 0 and warnings_fg)
				or palette.normal.black
		end,
		style = function(buffer)
			return ((buffer.is_focused and buffer.diagnostics.errors ~= 0) and "bold,underline")
				or (buffer.diagnostics.errors ~= 0 and "underline")
				or nil
		end,
		truncation = {
			priority = 2,
			direction = "left",
		},
	},

	diagnostics = {
		text = function(buffer)
			return (buffer.diagnostics.errors ~= 0 and "  " .. buffer.diagnostics.errors)
				or (buffer.diagnostics.warnings ~= 0 and "  " .. buffer.diagnostics.warnings)
				or ""
		end,
		hl = {
			fg = function(buffer)
				return (buffer.diagnostics.errors ~= 0 and errors_fg)
					or (buffer.diagnostics.warnings ~= 0 and warnings_fg)
					or nil
			end,
		},
		truncation = { priority = 1 },
	},

	close_or_unsaved = {
		text = function(buffer)
			return buffer.is_modified and " ●  " or ""
		end,
		fg = function(buffer)
			return buffer.is_modified and palette.normal.green or nil
		end,
		truncation = { priority = 1 },
	},
}

local get_remaining_space = function(buffer)
	local used_space = 0
	for _, component in pairs(components) do
		used_space = used_space
			+ vim.fn.strwidth(
				(type(component.text) == "string" and component.text)
					or (type(component.text) == "function" and component.text(buffer))
			)
	end
	return math.max(0, min_buffer_width - used_space)
end

local left_padding = {
	text = function(buffer)
		local remaining_space = get_remaining_space(buffer)
		return rep(" ", remaining_space / 2 + remaining_space % 2)
	end,
}

local right_padding = {
	text = function(buffer)
		local remaining_space = get_remaining_space(buffer)
		return rep(" ", remaining_space / 2)
	end,
}

require("cokeline").setup({
	show_if_buffers_are_at_least = 1,

	buffers = {
		-- filter_valid = function(buffer) return buffer.type ~= 'terminal' end,
		-- filter_visible = function(buffer) return buffer.type ~= 'terminal' end,
		focus_on_delete = "next",
		new_buffers_position = "next",
	},

	-- rendering = {
	-- 	max_buffer_width = 30,
	-- },

	default_hl = {
		fg = function(buffer)
			return buffer.is_focused and get_hex("Normal", "fg") or get_hex("Comment", "fg")
		end,

		bg = "NONE",
	},

	components = {
		components.separator,
		components.separator,
		components.index,
		components.lil_guy,
		components.devicon_or_pick_letter,
		components.filename_root,
		components.filename_extension,
		components.diagnostics,
		components.separator,
		components.close_or_unsaved,
	},
})
