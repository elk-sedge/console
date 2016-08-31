local console = {}

console.dimensions = 
{
	w, h,
	fontSize
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
		["y"] = "y", ["z"] = "z", ["."] = ".", [","] = ",", ["space"] = " "
	},
	commands = 
	{
		["backspace"] = function() console.backspace() end
	}
}

console.text =
{
	trueText = "",
	displayText = ""
}

function console.init(w, h, fontSize, fontPath)

	console.dimensions.w = w
	console.dimensions.h = h
	console.dimensions.fontSize = fontSize

	console.graphics.canvas = love.graphics.newCanvas(w, h)
	console.graphics.font = love.graphics.newFont(fontPath, fontSize)

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

	end

end

function console.backspace()

	console.text.trueText = console.text.trueText:sub(1, -2)

	-- if last element is a newline/other non-character, remove two elements
	local lastCharacter = console.text.displayText:sub(#console.text.displayText, #console.text.displayText)

	if (not console.isCharacter(lastCharacter)) then

		console.text.displayText = console.text.displayText:sub(1, -3)

	else

		console.text.displayText = console.text.displayText:sub(1, -2)

	end

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

				end

			end

		end

	end

end

function console.isCharacter(element)

	for _, character in pairs(console.input.characters) do

		if (element == character) then

			return true

		end

	end

	return false

end

return console