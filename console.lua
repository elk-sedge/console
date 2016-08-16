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
		["backspace"] = "backspace"
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

			console.performCommand(inputValue)

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

function getLines(text)

	-- adapted from http://lua-users.org/wiki/SplitJoin

	local lines = {} 

	local pattern = "(.-)\n"
	local lastEnd = 1
	local s, e, line = text:find(pattern, 1)

	while s do

		if (s ~= 1 or line ~= "") then

			table.insert(lines, line)

		end

		lastEnd = e + 1

		s, e, line = text:find(pattern, lastEnd)

	end

	if (lastEnd <= #text) then

		line = text:sub(lastEnd)
		table.insert(lines, line)

	end

	return lines

end

function console.addText(input)

	console.text.trueText = console.text.trueText .. input
	console.text.displayText = console.text.displayText .. input

	local lastLine = getLastLine(console.text.displayText)
	local lineWidth = console.graphics.font:getWidth(lastLine)

	if (lineWidth > console.dimensions.w) then

		local lastWord, s, e = getLastWord(console.text.displayText)

		if (lastWord == "§") then

			console.text.displayText = console.text.displayText .. "\n"

		else

			if (s > 1) then

				-- add last word to next line
				local textMinusLastWord = string.sub(console.text.displayText, 1, s - 1)
				console.text.displayText = textMinusLastWord .. "\n" .. lastWord

			else

				-- wrap word to next line
				local lastCharacter = string.sub(console.text.displayText, #console.text.displayText)
				local textMinusLastCharacter = string.sub(console.text.displayText, 1, #console.text.displayText - 1)
				console.text.displayText = textMinusLastCharacter .. "\n" .. lastCharacter

			end

		end

	end

end

function console.performCommand(command)

	if (command == "backspace") then

		console.text.trueText = console.text.trueText:sub(1, -2)
		console.text.displayText = console.text.displayText:sub(1, -2)

		-- if space becomes available on previous line for last word, move it
		local lineCount = getLineCount(console.text.displayText)
		local lastLine = getLastLine(console.text.displayText)
		local lineWidth = console.graphics.font:getWidth(lastLine)
		local prevLineSpace = getPrevLineSpace(console.text.displayText)

		if (lineCount > 1 and lineWidth < prevLineSpace) then

			-- remove last occurrence of \n in previous line
			-- console.text.displayText = string.gsub(console.text.displayText, "\n", "$", 1)

		end

	end

end

function getLastLine(text)

	local s, e = string.find(text, "[^\n]*$")
	local lastLine = string.sub(text, s, e)

	return lastLine, s, e

end

function getLastWord(text)

	local s, e, p = 0, 0, 0
	local lastWord = ""

	while (e < #text) do 

		s, e = string.find(text, "%S+$", p) -- ignore \n characters?

		if (s) then

			lastWord = string.sub(text, s, e)
			p = e + 1

		else

			lastWord = "§"
			s, e = #text, #text
			break

		end

	end

	return lastWord, s, e

end

function getPrevLineSpace(text)

	local prevLine = getPrevLine(text)
	local prevLineSpace = console.dimensions.w - console.graphics.font:getWidth(prevLine)

	return prevLineSpace

end

function getPrevLine(text)

	local lastLine, s, e = getLastLine(text)
	local prevLine = getLastLine(string.sub(text, 1, s - 2)) -- -2 removes line-break

	return prevLine, s, e

end

function getLineCount(text)

	local _, count = string.gsub(text, "\n", " ")

	return count + 1

end

return console