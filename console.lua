local console = {}

console.dimensions = 
{
	w, h,
	fontSize, fontHeight
}

console.graphics = 
{
	canvas,
	font
}

console.input = 
{	
	characters =
	{
		["a"] = "a", ["b"] = "b", ["c"] = "c", ["d"] = "d", ["e"] = "e", ["f"] = "f", ["g"] = "g", ["h"] = "h",
		["i"] = "i", ["j"] = "j", ["k"] = "k", ["l"] = "l", ["m"] = "m", ["n"] = "n", ["o"] = "o", ["p"] = "p",
		["q"] = "q", ["r"] = "r", ["s"] = "s", ["t"] = "t", ["u"] = "u", ["v"] = "v", ["w"] = "w", ["x"] = "x",
		["y"] = "y", ["z"] = "z", ["."] = ".", [","] = ",", ["-"] = "-", ["space"] = " "
	},
	commands = 
	{
		["backspace"] = function() console.backspace() end, 
		["up"] = function() console.moveCursor("up") end, 
		["down"] = function() console.moveCursor("down") end, 
		["left"] = function() console.moveCursor("left") end, 
		["right"] = function() console.moveCursor("right") end
	}
}

console.text =
{
	trueText = "",
	displayText = ""
}

console.cursor = 
{
	col = 1, row = 1,
	x = 0, y = 0
}

function console.init(w, h, fontSize, fontPath)

	console.graphics.canvas = love.graphics.newCanvas(w, h)
	console.graphics.font = love.graphics.newFont(fontPath, fontSize)

	console.dimensions.w = w
	console.dimensions.h = h
	console.dimensions.fontSize = fontSize
	console.dimensions.fontHeight = console.graphics.font:getHeight("a")

	console.draw()

end

function console.draw()

	love.graphics.setCanvas(console.graphics.canvas)
	love.graphics.clear()

	-- draw border
	love.graphics.rectangle("line", 0, 0, console.dimensions.w, console.dimensions.h)

	-- draw text
	love.graphics.setFont(console.graphics.font)
	love.graphics.print(console.text.displayText, 0, 0)

	-- draw cursor
	love.graphics.line(console.cursor.x, console.cursor.y, console.cursor.x, console.cursor.y + console.dimensions.fontHeight)

	love.graphics.setCanvas()

end

function console.getCanvas()

	return console.graphics.canvas

end

function console.doInput(input)

	local isInput, inputTypeKey, inputKey, inputValue = console.getInputValue(input)

	if (isInput) then

		if (inputTypeKey == "characters") then

			console.addText(inputValue)

		elseif (inputTypeKey == "commands") then

			inputValue()

		end

	end

	console.draw()

end

function console.getInputValue(input)

	for inputTypeKey, inputType in pairs(console.input) do

		for inputKey, inputValue in pairs(inputType) do

			if (inputKey == input) then

				return true, inputTypeKey, inputKey, inputValue

			end

		end

	end

	return false, nil, nil, nil

end

function splitString(text, pattern)

	-- adapted from http://lua-users.org/wiki/SplitJoin

	local lines = {} 

	local pat = "(.-)" .. pattern
	local lastEnd = 1
	local s, e, line = text:find(pat, 1)

	while s do

		if (s ~= 1 or line ~= "") then

			table.insert(lines, line)

		end

		lastEnd = e + 1

		s, e, line = text:find(pat, lastEnd)

	end

	if (lastEnd <= #text) then

		line = text:sub(lastEnd)
		table.insert(lines, line)

	end

	return lines

end

function getLines(text)

	return splitString(text, "\n")

end

function getWords(text)

	return splitString(text, "%s")

end

function console.addText(input)

	console.text.trueText = console.text.trueText .. input
	console.text.displayText = console.text.displayText .. input

	console.moveCursor("right")

	local lines = getLines(console.text.displayText)

	local lastLine = lines[#lines]
	local lineWidth = console.graphics.font:getWidth(lastLine)

	if (lineWidth > console.dimensions.w) then

		local lastLineWords = getWords(lines[#lines])
		local lastWord = lastLineWords[#lastLineWords]

		if (#lastLineWords > 1) then 

			-- move last word to next line
			table.remove(lastLineWords, #lastLineWords)
			table.remove(lines, #lines)

			table.insert(lines, table.concat(lastLineWords, " "))
			table.insert(lines, lastWord)

			console.text.displayText = table.concat(lines, "\n")

		else

			-- wrap last word to next line
			local lastWordMinusLastChar = lastWord:sub(1, -2)
			local lastWordLastChar = string.sub(lastWord, #lastWord)

			table.remove(lastLineWords, #lastLineWords)
			table.remove(lines, #lines)

			table.insert(lastLineWords, lastWordMinusLastChar)			
			table.insert(lines, table.concat(lastLineWords, " "))
			table.insert(lines, lastWordLastChar)

			console.text.displayText = table.concat(lines, "\n")

		end

		console.moveCursor("down")

	end

end

function console.backspace()

	console.text.trueText = console.text.trueText:sub(1, -2)
	console.text.displayText = console.text.displayText:sub(1, -2)

	console.moveCursor("left")

	-- if space becomes available on previous line for last word, move it
	local lines = getLines(console.text.displayText)

	if (#lines > 0) then

		local lastLineWords = getWords(lines[#lines])

		if (#lastLineWords == 1) then
			
			local previousLine = lines[#lines - 1]

			if (previousLine) then

				local currentWord = lastLineWords[#lastLineWords]

				local wordWidth = console.graphics.font:getWidth(currentWord)
				local previousLineSpace = console.dimensions.w - console.graphics.font:getWidth(previousLine)

				if (wordWidth < previousLineSpace) then

					local previousLineWords = getWords(lines[#lines - 1])

					table.remove(lines, #lines)
					table.remove(lines, #lines)

					table.insert(previousLineWords, currentWord)
					table.insert(lines, table.concat(previousLineWords, " "))

					console.text.displayText = table.concat(lines, "\n")

					console.moveCursorToEndOfPreviousLine()

				end

			end

		end

	end

end

function console.moveCursor(direction)

	local cursor = console.cursor
	local lines = getLines(console.text.displayText)

	local moved = false

	if (direction == "up") then

		if (cursor.row > 1) then

			cursor.row = cursor.row - 1
			moved = true

		end

	elseif (direction == "down") then

		if (cursor.row < #lines) then

			cursor.row = cursor.row + 1

			local cursorLine = lines[cursor.row]

			if (cursor.col > #cursorLine) then

				cursor.col = #cursorLine

			end

			moved = true

		end

	elseif (direction == "left") then

		if (cursor.col > 1) then

			cursor.col = cursor.col - 1
			moved = true

		end

	elseif (direction == "right") then

		local cursorLine = lines[cursor.row]

		if (cursorLine) then

			if (cursor.col < #cursorLine) then

				cursor.col = cursor.col + 1
				moved = true

			end

		end

	end

	local cursorRow = lines[cursor.row]

	if (cursorRow) then

		cursor.x = console.graphics.font:getWidth(cursorRow:sub(1, cursor.col))

	else

		cursor.x = 0

	end

	cursor.y = console.dimensions.fontHeight * (cursor.row - 1)

	return moved

end

function console.moveCursorToEndOfPreviousLine()

	console.moveCursor("up")

	local moveRightPossible = console.moveCursor("right")

	repeat

		moveRightPossible = console.moveCursor("right")

	until not moveRightPossible

end

return console