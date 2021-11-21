-- SUIT, copyright (c) 2016 Matthias Richter
-- suit-compact by HTV04

--[[----------------------------------------------------------------------------
Copyright (c) 2016 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
------------------------------------------------------------------------------]]

-- Theme -----------------------------------------------------------------------

local theme = {}
theme.cornerRadius = 4

theme.color = {
	normal   = {bg = { 0.25, 0.25, 0.25}, fg = {0.73,0.73,0.73}},
	hovered  = {bg = { 0.19,0.6,0.73}, fg = {1,1,1}},
	active   = {bg = {1,0.6,  0}, fg = {1,1,1}}
}


-- HELPER
function theme.getColorForState(opt)
	local s = opt.state or "normal"
	return (opt.color and opt.color[opt.state]) or theme.color[s]
end

function theme.drawBox(x,y,w,h, colors, cornerRadius)
	colors = colors or theme.getColorForState(opt)
	cornerRadius = cornerRadius or theme.cornerRadius
	w = math.max(cornerRadius/2, w)
	if h < cornerRadius/2 then
		y,h = y - (cornerRadius - h), cornerRadius/2
	end

	love.graphics.setColor(colors.bg)
	love.graphics.rectangle('fill', x,y, w,h, cornerRadius)
end

function theme.getVerticalOffsetForAlign(valign, font, h)
	if valign == "top" then
		return 0
	elseif valign == "bottom" then
		return h - font:getHeight()
	end
	-- else: "middle"
	return (h - font:getHeight()) / 2
end

-- WIDGET VIEWS
function theme.Label(text, opt, x,y,w,h)
	y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)

	love.graphics.setColor((opt.color and opt.color.normal or {}).fg or theme.color.normal.fg)
	love.graphics.setFont(opt.font)
	love.graphics.printf(text, x+2, y, w-4, opt.align or "center")
end

function theme.Button(text, opt, x,y,w,h)
	local c = theme.getColorForState(opt)

	theme.drawBox(x,y,w,h, c, opt.cornerRadius)
	love.graphics.setColor(c.fg)
	love.graphics.setFont(opt.font)

	y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
	love.graphics.printf(text, x+2, y, w-4, opt.align or "center")
end

function theme.Checkbox(chk, opt, x,y,w,h)
	local c = theme.getColorForState(opt)
	local th = opt.font:getHeight()

	theme.drawBox(x+h/10,y+h/10,h*.8,h*.8, c, opt.cornerRadius)
	love.graphics.setColor(c.fg)
	if chk.checked then
		love.graphics.setLineStyle('smooth')
		love.graphics.setLineWidth(5)
		love.graphics.setLineJoin("bevel")
		love.graphics.line(x+h*.2,y+h*.55, x+h*.45,y+h*.75, x+h*.8,y+h*.2)
	end

	if chk.text then
		love.graphics.setFont(opt.font)
		y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
		love.graphics.printf(chk.text, x + h, y, w - h, opt.align or "left")
	end
end

function theme.Slider(fraction, opt, x,y,w,h)
	local xb, yb, wb, hb -- size of the progress bar
	local r =  math.min(w,h) / 2.1
	if opt.vertical then
		x, w = x + w*.25, w*.5
		xb, yb, wb, hb = x, y+h*(1-fraction), w, h*fraction
	else
		y, h = y + h*.25, h*.5
		xb, yb, wb, hb = x,y, w*fraction, h
	end

	local c = theme.getColorForState(opt)
	theme.drawBox(x,y,w,h, c, opt.cornerRadius)
	theme.drawBox(xb,yb,wb,hb, {bg=c.fg}, opt.cornerRadius)

	if opt.state ~= nil and opt.state ~= "normal" then
		love.graphics.setColor((opt.color and opt.color.active or {}).fg or theme.color.active.fg)
		if opt.vertical then
			love.graphics.circle('fill', x+wb/2, yb, r)
		else
			love.graphics.circle('fill', x+wb, yb+hb/2, r)
		end
	end
end

function theme.Input(input, opt, x,y,w,h)
	local utf8 = require 'utf8'
	theme.drawBox(x,y,w,h, (opt.color and opt.color.normal) or theme.color.normal, opt.cornerRadius)
	x = x + 3
	w = w - 6

	local th = opt.font:getHeight()

	-- set scissors
	local sx, sy, sw, sh = love.graphics.getScissor()
	love.graphics.setScissor(x-1,y,w+2,h)
	x = x - input.text_draw_offset

	-- text
	love.graphics.setColor((opt.color and opt.color.normal and opt.color.normal.fg) or theme.color.normal.fg)
	love.graphics.setFont(opt.font)
	love.graphics.print(input.text, x, y+(h-th)/2)

	-- candidate text
	local tw = opt.font:getWidth(input.text)
	local ctw = opt.font:getWidth(input.candidate_text.text)
	love.graphics.setColor((opt.color and opt.color.normal and opt.color.normal.fg) or theme.color.normal.fg)
	love.graphics.print(input.candidate_text.text, x + tw, y+(h-th)/2)

	-- candidate text rectangle box
	love.graphics.rectangle("line", x + tw, y+(h-th)/2, ctw, th)

	-- cursor
	if opt.hasKeyboardFocus and (love.timer.getTime() % 1) > .5 then
		local ct = input.candidate_text;
		local ss = ct.text:sub(1, utf8.offset(ct.text, ct.start))
		local ws = opt.font:getWidth(ss)
		if ct.start == 0 then ws = 0 end

		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle('rough')
		love.graphics.line(x + opt.cursor_pos + ws, y + (h-th)/2,
		                   x + opt.cursor_pos + ws, y + (h+th)/2)
	end

	-- reset scissor
	love.graphics.setScissor(sx,sy,sw,sh)
end

-- Widgets ---------------------------------------------------------------------

local widgets = {}

function widgets.Button(core, text, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.id = opt.id or text
	opt.font = opt.font or love.graphics.getFont()

	w = w or opt.font:getWidth(text) + 4
	h = h or opt.font:getHeight() + 4

	opt.state = core:registerHitbox(opt.id, x,y,w,h)
	core:registerDraw(opt.draw or core.theme.Button, text, opt, x,y,w,h)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end

do
	local function isType(val, typ)
		return type(val) == "userdata" and val.typeOf and val:typeOf(typ)
	end

	function widgets.ImageButton(core, normal, ...)
		local opt, x,y = core.getOptionsAndSize(...)
		opt.normal = normal or opt.normal or opt[1]
		opt.hovered = opt.hovered or opt[2] or opt.normal
		opt.active = opt.active or opt[3] or opt.hovered
		opt.id = opt.id or opt.normal

		local image = assert(opt.normal, "No image for state `normal'")

		core:registerMouseHit(opt.id, x, y, function(u,v)
			-- mouse in image?
			u, v = math.floor(u+.5), math.floor(v+.5)
			if u < 0 or u >= image:getWidth() or v < 0 or v >= image:getHeight() then
				return false
			end

			if opt.mask then
				-- alpha test
				assert(isType(opt.mask, "ImageData"), "Option `mask` is not a love.image.ImageData")
				assert(u < mask:getWidth() and v < mask:getHeight(), "Mask may not be smaller than image.")
				local _,_,_,a = mask:getPixel(u,v)
				return a > 0
			end

			return true
		end)

		if core:isActive(opt.id) then
			image = opt.active
		elseif core:isHovered(opt.id) then
			image = opt.hovered
		end

		assert(isType(image, "Image"), "state image is not a love.graphics.image")

		core:registerDraw(opt.draw or function(image,x,y, r,g,b,a)
			love.graphics.setColor(r,g,b,a)
			love.graphics.draw(image,x,y)
		end, image, x,y, love.graphics.getColor())

		return {
			id = opt.id,
			hit = core:mouseReleasedOn(opt.id),
			hovered = core:isHovered(opt.id),
			entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
			left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
		}
	end
end

function widgets.Label(core, text, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.id = opt.id or text
	opt.font = opt.font or love.graphics.getFont()

	w = w or opt.font:getWidth(text) + 4
	h = h or opt.font:getHeight() + 4

	opt.state = core:registerHitbox(opt.id, x,y,w,h)
	core:registerDraw(opt.draw or core.theme.Label, text, opt, x,y,w,h)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end

function widgets.Checkbox(core, checkbox, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.id = opt.id or checkbox
	opt.font = opt.font or love.graphics.getFont()

	w = w or (opt.font:getWidth(checkbox.text) + opt.font:getHeight() + 4)
	h = h or opt.font:getHeight() + 4

	opt.state = core:registerHitbox(opt.id, x,y,w,h)
	local hit = core:mouseReleasedOn(opt.id)
	if hit then
		checkbox.checked = not checkbox.checked
	end
	core:registerDraw(opt.draw or core.theme.Checkbox, checkbox, opt, x,y,w,h)

	return {
		id = opt.id,
		hit = hit,
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end

do
	local utf8 = require 'utf8'

	local function split(str, pos)
		local offset = utf8.offset(str, pos) or 0
		return str:sub(1, offset-1), str:sub(offset)
	end

	function widgets.Input(core, input, ...)
		local opt, x,y,w,h = core.getOptionsAndSize(...)
		opt.id = opt.id or input
		opt.font = opt.font or love.graphics.getFont()

		local text_width = opt.font:getWidth(input.text)
		w = w or text_width + 6
		h = h or opt.font:getHeight() + 4

		input.text = input.text or ""
		input.cursor = math.max(1, math.min(utf8.len(input.text)+1, input.cursor or utf8.len(input.text)+1))
		-- cursor is position *before* the character (including EOS) i.e. in "hello":
		--   position 1: |hello
		--   position 2: h|ello
		--   ...
		--   position 6: hello|

		-- get size of text and cursor position
		opt.cursor_pos = 0
		if input.cursor > 1 then
			local s = input.text:sub(1, utf8.offset(input.text, input.cursor)-1)
			opt.cursor_pos = opt.font:getWidth(s)
		end

		-- compute drawing offset
		local wm = w - 6 -- consider margin
		input.text_draw_offset = input.text_draw_offset or 0
		if opt.cursor_pos - input.text_draw_offset < 0 then
			-- cursor left of input box
			input.text_draw_offset = opt.cursor_pos
		end
		if opt.cursor_pos - input.text_draw_offset > wm then
			-- cursor right of input box
			input.text_draw_offset = opt.cursor_pos - wm
		end
		if text_width - input.text_draw_offset < wm and text_width > wm then
			-- text bigger than input box, but does not fill it
			input.text_draw_offset = text_width - wm
		end

		-- user interaction
		if input.forcefocus ~= nil and input.forcefocus then
			core.active = opt.id
			input.forcefocus = false
		end

		opt.state = core:registerHitbox(opt.id, x,y,w,h)
		opt.hasKeyboardFocus = core:grabKeyboardFocus(opt.id)

		if (core.candidate_text.text == "") and opt.hasKeyboardFocus then
			local keycode,char = core:getPressedKey()
			-- text input
			if char and char ~= "" then
				local a,b = split(input.text, input.cursor)
				input.text = table.concat{a, char, b}
				input.cursor = input.cursor + utf8.len(char)
			end

			-- text editing
			if keycode == 'backspace' then
				local a,b = split(input.text, input.cursor)
				input.text = table.concat{split(a,utf8.len(a)), b}
				input.cursor = math.max(1, input.cursor-1)
			elseif keycode == 'delete' then
				local a,b = split(input.text, input.cursor)
				local _,b = split(b, 2)
				input.text = table.concat{a, b}
			end

			-- cursor movement
			if keycode =='left' then
				input.cursor = math.max(0, input.cursor-1)
			elseif keycode =='right' then -- cursor movement
				input.cursor = math.min(utf8.len(input.text)+1, input.cursor+1)
			elseif keycode =='home' then -- cursor movement
				input.cursor = 1
			elseif keycode =='end' then -- cursor movement
				input.cursor = utf8.len(input.text)+1
			end

			-- move cursor position with mouse when clicked on
			if core:mouseReleasedOn(opt.id) then
				local mx = core:getMousePosition() - x + input.text_draw_offset
				input.cursor = utf8.len(input.text) + 1
				for c = 1,input.cursor do
					local s = input.text:sub(0, utf8.offset(input.text, c)-1)
					if opt.font:getWidth(s) >= mx then
						input.cursor = c-1
						break
					end
				end
			end
		end

		input.candidate_text = {text=core.candidate_text.text, start=core.candidate_text.start, length=core.candidate_text.length}
		core:registerDraw(opt.draw or core.theme.Input, input, opt, x,y,w,h)

		return {
			id = opt.id,
			hit = core:mouseReleasedOn(opt.id),
			submitted = core:keyPressedOn(opt.id, "return"),
			hovered = core:isHovered(opt.id),
			entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
			left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
		}
	end
end

function widgets.Slider(core, info, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)

	opt.id = opt.id or info

	info.min = info.min or math.min(info.value, 0)
	info.max = info.max or math.max(info.value, 1)
	info.step = info.step or (info.max - info.min) / 10
	local fraction = (info.value - info.min) / (info.max - info.min)
	local value_changed = false

	opt.state = core:registerHitbox(opt.id, x,y,w,h)

	if core:isActive(opt.id) then
		-- mouse update
		local mx,my = core:getMousePosition()
		if opt.vertical then
			fraction = math.min(1, math.max(0, (y+h - my) / h))
		else
			fraction = math.min(1, math.max(0, (mx - x) / w))
		end
		local v = fraction * (info.max - info.min) + info.min
		if v ~= info.value then
			info.value = v
			value_changed = true
		end

		-- keyboard update
		local key_up = opt.vertical and 'up' or 'right'
		local key_down = opt.vertical and 'down' or 'left'
		if core:getPressedKey() == key_up then
			info.value = math.min(info.max, info.value + info.step)
			value_changed = true
		elseif core:getPressedKey() == key_down then
			info.value = math.max(info.min, info.value - info.step)
			value_changed = true
		end
	end

	core:registerDraw(opt.draw or core.theme.Slider, fraction, opt, x,y,w,h)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
		changed = value_changed,
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end

do
	local Layout = {}
	function Layout.new(x,y,padx,pady)
		return setmetatable({_stack = {}}, {__index = Layout}):reset(x,y,padx,pady)
	end

	function Layout:reset(x,y, padx,pady)
		self._x = x or 0
		self._y = y or 0
		self._padx = padx or 0
		self._pady = pady or self._padx
		self._w = nil
		self._h = nil
		self._widths = {}
		self._heights = {}
		self._isFirstCell = true

		return self
	end

	function Layout:padding(padx,pady)
		if padx then
			self._padx = padx
			self._pady = pady or padx
		end
		return self._padx, self._pady
	end

	function Layout:size()
		return self._w, self._h
	end

	function Layout:nextRow()
		return self._x, self._y + self._h + self._pady
	end

	Layout.nextDown = Layout.nextRow

	function Layout:nextCol()
		return self._x + self._w + self._padx, self._y
	end

	Layout.nextRight = Layout.nextCol

	function Layout:push(x,y)
		self._stack[#self._stack+1] = {
			self._x, self._y,
			self._padx, self._pady,
			self._w, self._h,
			self._widths,
			self._heights,
		}

		return self:reset(x,y, padx or self._padx, pady or self._pady)
	end

	function Layout:pop()
		assert(#self._stack > 0, "Nothing to pop")
		local w,h = self._w, self._h
		self._x, self._y,
		self._padx,self._pady,
		self._w, self._h,
		self._widths, self._heights = unpack(self._stack[#self._stack])
		self._isFirstCell = false
		self._stack[#self._stack] = nil

		self._w, self._h = math.max(w, self._w or 0), math.max(h, self._h or 0)

		return w, h
	end

	--- recursive binary search for position of v
	local function insert_sorted_helper(t, i0, i1, v)
		if i1 <= i0 then
			table.insert(t, i0, v)
			return
		end

		local i = i0 + math.floor((i1-i0)/2)
		if t[i] < v then
			return insert_sorted_helper(t, i+1, i1, v)
		elseif t[i] > v then
			return insert_sorted_helper(t, i0, i-1, v)
		else
			table.insert(t, i, v)
		end
	end

	local function insert_sorted(t, v)
		if v <= 0 then return end
		insert_sorted_helper(t, 1, #t, v)
	end

	local function calc_width_height(self, w, h)
		if w == "" or w == nil then
			w = self._w
		elseif w == "max" then
			w = self._widths[#self._widths]
		elseif w == "min" then
			w = self._widths[1]
		elseif w == "median" then
			w = self._widths[math.ceil(#self._widths/2)] or 0
		elseif type(w) ~= "number" then
			error("width: invalid value (" .. tostring(w) .. ")", 3)
		end

		if h == "" or h == nil then
			h = self._h
		elseif h == "max" then
			h = self._heights[#self._heights]
		elseif h == "min" then
			h = self._heights[1]
		elseif h == "median" then
			h = self._heights[math.ceil(#self._heights/2)] or 0
		elseif type(h) ~= "number" then
			error("width: invalid value (" .. tostring(w) .. ")", 3)
		end

		if not w or not h then
			error("Invalid cell size", 3)
		end

		insert_sorted(self._widths, w)
		insert_sorted(self._heights, h)
		return w,h
	end

	function Layout:row(w, h)
		w,h = calc_width_height(self, w, h)
		local x,y = self._x, self._y + (self._h or 0)

		if not self._isFirstCell then
			y = y + self._pady
		end
		self._isFirstCell = false

		self._y, self._w, self._h = y, w, h

		return x,y,w,h
	end

	Layout.down = Layout.row

	function Layout:up(w, h)
		w,h = calc_width_height(self, w, h)
		local x,y = self._x, self._y - (self._h and h or 0)

		if not self._isFirstCell then
			y = y - self._pady
		end
		self._isFirstCell = false

		self._y, self._w, self._h = y, w, h

		return x,y,w,h
	end

	function Layout:col(w, h)
		w,h = calc_width_height(self, w, h)

		local x,y = self._x + (self._w or 0), self._y

		if not self._isFirstCell then
			x = x + self._padx
		end
		self._isFirstCell = false

		self._x, self._w, self._h = x, w, h

		return x,y,w,h
	end

	Layout.right = Layout.col

	function Layout:left(w, h)
		w,h = calc_width_height(self, w, h)

		local x,y = self._x - (self._w and w or 0), self._y

		if not self._isFirstCell then
			x = x - self._padx
		end
		self._isFirstCell = false

		self._x, self._w, self._h = x, w, h

		return x,y,w,h
	end

	local function layout_iterator(t, idx)
		idx = (idx or 1) + 1
		if t[idx] == nil then return nil end
		return idx, unpack(t[idx])
	end

	local function layout_retained_mode(self, t, constructor, string_argument_to_table, fill_width, fill_height)
		-- sanity check
		local p = t.pos or {0,0}
		if type(p) ~= "table" then
			error("Invalid argument `pos' (table expected, got "..type(p)..")", 2)
		end
		local pad = t.padding or {}
		if type(p) ~= "table" then
			error("Invalid argument `padding' (table expected, got "..type(p)..")", 2)
		end

		self:push(p[1] or 0, p[2] or 0)
		self:padding(pad[1] or self._padx, pad[2] or self._pady)

		-- first pass: get dimensions, add layout info
		local layout = {n_fill_w = 0, n_fill_h = 0}
		for i,v in ipairs(t) do
			if type(v) == "string" then
				v = string_argument_to_table(v)
			end
			local x,y,w,h = 0,0, v[1], v[2]
			if v[1] == "fill" then w = 0 end
			if v[2] == "fill" then h = 0 end

			x,y, w,h = constructor(self, w,h)

			if v[1] == "fill" then
				w = "fill"
				layout.n_fill_w = layout.n_fill_w + 1
			end
			if v[2] == "fill" then
				h = "fill"
				layout.n_fill_h = layout.n_fill_h + 1
			end
			layout[i] = {x,y,w,h, unpack(v,3)}
		end

		-- second pass: extend "fill" cells and shift others accordingly
		local fill_w = fill_width(layout, t.min_width or 0, self._x + self._w - p[1])
		local fill_h = fill_height(layout, t.min_height or 0, self._y + self._h - p[2])
		local dx,dy = 0,0
		for _,v in ipairs(layout) do
			v[1], v[2] = v[1] + dx, v[2] + dy
			if v[3] == "fill" then
				v[3] = fill_w
				dx = dx + v[3]
			end
			if v[4] == "fill" then
				v[4] = fill_h
				dy = dy + v[4]
			end
		end

		-- finally: return layout with iterator
		local w, h = self:pop()
		layout.cell = function(self, i)
			if self ~= layout then -- allow either colon or dot syntax
				i = self
			end
			return unpack(layout[i])
		end
		layout.size = function()
			return w, h
		end
		return setmetatable(layout, {__call = function()
			return layout_iterator, layout, 0
		end})
	end

	function Layout:rows(t)
		return layout_retained_mode(self, t, self.row,
				function(v) return {nil, v} end,
				function() return self._widths[#self._widths] end, -- fill width
				function(l,mh,h) return (mh - h) / l.n_fill_h end) -- fill height
	end

	function Layout:cols(t)
		return layout_retained_mode(self, t, self.col,
				function(v) return {v} end,
				function(l,mw,w) return (mw - w) / l.n_fill_w end, -- fill width
				function() return self._heights[#self._heights] end) -- fill height
	end

	--[[ "Tests"
	do

	L = Layout.new()

	print("immediate mode")
	print("--------------")
	x,y,w,h = L:row(100,20) -- x,y,w,h = 0,0, 100,20
	print(1,x,y,w,h)
	x,y,w,h = L:row()       -- x,y,w,h = 0, 20, 100,20 (default: reuse last dimensions)
	print(2,x,y,w,h)
	x,y,w,h = L:col(20)     -- x,y,w,h = 100, 20, 20, 20
	print(3,x,y,w,h)
	x,y,w,h = L:row(nil,30) -- x,y,w,h = 100, 20, 20, 30
	print(4,x,y,w,h)
	print('','','', L:size()) -- w,h = 20, 30
	print()

	L:reset()

	local layout = L:rows{
		pos = {10,10},   -- optional, default {0,0}

		{100, 10},
		{nil, 10},       -- {100, 10}
		{100, 20},       -- {100, 20}
		{},              -- {100, 20} -- default = last value
		{nil, "median"}, -- {100, 20}
		"median",        -- {100, 20}
		"max",           -- {100, 20}
		"min",           -- {100, 10}
		""               -- {100, 10} -- default = last value
	}

	print("rows")
	print("----")
	for i,x,y,w,h in layout() do
		print(i,x,y,w,h)
	end
	print()

	--  +-------+-------+----------------+-------+
	--  |       |       |                |       |
	-- 70 {100, | "max" |     "fill"     | "min" |
	--  |   70} |       |                |       |
	--  +--100--+--100--+------220-------+--100--+
	--
	--  `-------------------,--------------------'
	--                     520
	local layout = L:cols{
		pos = {10,10},
		min_width = 520,

		{100, 70},
		"max",    -- {100, 70}
		"fill",   -- {min_width - width_of_items, 70} = {220, 70}
		"min",    -- {100,70}
	}

	print("cols")
	print("----")
	for i,x,y,w,h in layout() do
		print(i,x,y,w,h)
	end
	print()

	L:push()
	L:row()

	end
	--]]

	-- TODO: nesting a la rows{..., cols{...} } ?

	local instance = Layout.new()

	widgets.Layout = setmetatable({
		new     = Layout.new,
		reset   = function(...) return instance:reset(...) end,
		padding = function(...) return instance:padding(...) end,
		push    = function(...) return instance:push(...) end,
		pop     = function(...) return instance:pop(...) end,
		row     = function(...) return instance:row(...) end,
		col     = function(...) return instance:col(...) end,
		down    = function(...) return instance:down(...) end,
		up      = function(...) return instance:up(...) end,
		left    = function(...) return instance:left(...) end,
		right   = function(...) return instance:right(...) end,
		rows    = function(...) return instance:rows(...) end,
		cols    = function(...) return instance:cols(...) end,
	}, {__call = function(_,...) return Layout.new(...) end})
end

-- SUIT ------------------------------------------------------------------------

local suit = {}
do
	local NONE = {}

	suit.__index = suit

	function suit.new(theme)
		return setmetatable({
			-- TODO: deep copy/copy on write? better to let user handle => documentation?
			theme = theme,
			mouse_x = 0, mouse_y = 0,
			mouse_button_down = false,
			candidate_text = {text="", start=0, length=0},

			draw_queue = {n = 0},

			Button = widgets.Button,
			ImageButton = widgets.ImageButton,
			Label = widgets.Label,
			Checkbox = widgets.Checkbox,
			Input = widgets.Input,
			Slider = widgets.Slider,

			layout = widgets.Layout.new(),
		}, suit)
	end

	-- helper
	function suit.getOptionsAndSize(opt, ...)
		if type(opt) == "table" then
			return opt, ...
		end
		return {}, opt, ...
	end

	-- gui state
	function suit:setHovered(id)
		return self.hovered ~= id
	end

	function suit:anyHovered()
		return self.hovered ~= nil
	end

	function suit:isHovered(id)
		return id == self.hovered
	end

	function suit:wasHovered(id)
		return id == self.hovered_last
	end

	function suit:setActive(id)
		return self.active ~= nil
	end

	function suit:anyActive()
		return self.active ~= nil
	end

	function suit:isActive(id)
		return id == self.active
	end


	function suit:setHit(id)
		self.hit = id
		-- simulate mouse release on button -- see suit:mouseReleasedOn()
		self.mouse_button_down = false
		self.active = id
		self.hovered = id
	end

	function suit:anyHit()
		return self.hit ~= nil
	end

	function suit:isHit(id)
		return id == self.hit
	end

	function suit:getStateName(id)
		if self:isActive(id) then
			return "active"
		elseif self:isHovered(id) then
			return "hovered"
		elseif self:isHit(id) then
			return "hit"
		end
		return "normal"
	end

	-- mouse handling
	function suit:mouseInRect(x,y,w,h)
		return self.mouse_x >= x and self.mouse_y >= y and
		       self.mouse_x <= x+w and self.mouse_y <= y+h
	end

	function suit:registerMouseHit(id, ul_x, ul_y, hit)
		if not self.hovered and hit(self.mouse_x - ul_x, self.mouse_y - ul_y) then
			self.hovered = id
			if self.active == nil and self.mouse_button_down then
				self.active = id
			end
		end
		return self:getStateName(id)
	end

	function suit:registerHitbox(id, x,y,w,h)
		return self:registerMouseHit(id, x,y, function(x,y)
			return x >= 0 and x <= w and y >= 0 and y <= h
		end)
	end

	function suit:mouseReleasedOn(id)
		if not self.mouse_button_down and self:isActive(id) and self:isHovered(id) then
			self.hit = id
			return true
		end
		return false
	end

	function suit:updateMouse(x, y, button_down)
		self.mouse_x, self.mouse_y = x,y
		if button_down ~= nil then
			self.mouse_button_down = button_down
		end
	end

	function suit:getMousePosition()
		return self.mouse_x, self.mouse_y
	end

	-- keyboard handling
	function suit:getPressedKey()
		return self.key_down, self.textchar
	end

	function suit:keypressed(key)
		self.key_down = key
	end

	function suit:textinput(char)
		self.textchar = char
	end

	function suit:textedited(text, start, length)
		self.candidate_text.text = text
		self.candidate_text.start = start
		self.candidate_text.length = length
	end

	function suit:grabKeyboardFocus(id)
		if self:isActive(id) then
			if love.system.getOS() == "Android" or love.system.getOS() == "iOS" then
				if id == NONE then
					love.keyboard.setTextInput( false )
				else
					love.keyboard.setTextInput( true )
				end
			end
			self.keyboardFocus = id
		end
		return self:hasKeyboardFocus(id)
	end

	function suit:hasKeyboardFocus(id)
		return self.keyboardFocus == id
	end

	function suit:keyPressedOn(id, key)
		return self:hasKeyboardFocus(id) and self.key_down == key
	end

	-- state update
	function suit:enterFrame()
		if not self.mouse_button_down then
			self.active = nil
		elseif self.active == nil then
			self.active = NONE
		end

		self.hovered_last, self.hovered = self.hovered, nil
		self:updateMouse(love.mouse.getX(), love.mouse.getY(), love.mouse.isDown(1))
		self.key_down, self.textchar = nil, ""
		self:grabKeyboardFocus(NONE)
		self.hit = nil
	end

	function suit:exitFrame()
	end

	-- draw
	function suit:registerDraw(f, ...)
		local args = {...}
		local nargs = select('#', ...)
		self.draw_queue.n = self.draw_queue.n + 1
		self.draw_queue[self.draw_queue.n] = function()
			f(unpack(args, 1, nargs))
		end
	end

	function suit:draw()
		self:exitFrame()
		love.graphics.push('all')
		for i = self.draw_queue.n,1,-1 do
			self.draw_queue[i]()
		end
		love.graphics.pop()
		self.draw_queue.n = 0
		self:enterFrame()
	end
end

local instance = suit.new(theme)
return setmetatable({
	_instance = instance,

	new = suit.new,
	getOptionsAndSize = suit.getOptionsAndSize,

	-- core functions
	setHovered = function(...) return instance:setHovered(...) end,
	anyHovered = function(...) return instance:anyHovered(...) end,
	isHovered = function(...) return instance:isHovered(...) end,
	wasHovered = function(...) return instance:wasHovered(...) end,
	anyActive = function(...) return instance:anyActive(...) end,
	setActive = function(...) return instance:setActive(...) end,
	isActive = function(...) return instance:isActive(...) end,
	setHit = function(...) return instance:setHit(...) end,
	anyHit = function(...) return instance:anyHit(...) end,
	isHit = function(...) return instance:isHit(...) end,

	mouseInRect = function(...) return instance:mouseInRect(...) end,
	registerHitbox = function(...) return instance:registerHitbox(...) end,
	registerMouseHit = function(...) return instance:registerMouseHit(...) end,
	mouseReleasedOn = function(...) return instance:mouseReleasedOn(...) end,
	updateMouse = function(...) return instance:updateMouse(...) end,
	getMousePosition = function(...) return instance:getMousePosition(...) end,

	getPressedKey = function(...) return instance:getPressedKey(...) end,
	keypressed = function(...) return instance:keypressed(...) end,
	textinput = function(...) return instance:textinput(...) end,
	textedited = function(...) return instance:textedited(...) end,
	grabKeyboardFocus = function(...) return instance:grabKeyboardFocus(...) end,
	hasKeyboardFocus = function(...) return instance:hasKeyboardFocus(...) end,
	keyPressedOn = function(...) return instance:keyPressedOn(...) end,

	enterFrame = function(...) return instance:enterFrame(...) end,
	exitFrame = function(...) return instance:exitFrame(...) end,
	registerDraw = function(...) return instance:registerDraw(...) end,
	draw = function(...) return instance:draw(...) end,

	-- widgets
	Button = function(...) return instance:Button(...) end,
	ImageButton = function(...) return instance:ImageButton(...) end,
	Label = function(...) return instance:Label(...) end,
	Checkbox = function(...) return instance:Checkbox(...) end,
	Input = function(...) return instance:Input(...) end,
	Slider = function(...) return instance:Slider(...) end,

	-- layout
	layout = instance.layout
}, {
	-- theme
	__newindex = function(t, k, v)
		if k == "theme" then
			instance.theme = v
		else
			rawset(instance, k, v)
		end
	end,
	__index = function(t, k)
		return k == "theme" and instance.theme or rawget(t, k)
	end,
})
