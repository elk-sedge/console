io.stdout:setvbuf("no")

-- require
local console = require("console")

-- var
local screenWidth, screenHeight = 800, 600
local consoleWidth, consoleHeight = 400, 200

-- main
function love.load()

	love.window.setMode(screenWidth, screenHeight)
	console.init(consoleWidth, consoleHeight, 20, "Early GameBoy.ttf")

end

function love.draw()

	love.graphics.draw(console.getCanvas(), (screenWidth / 2) - (consoleWidth / 2), (screenHeight / 2) - (consoleHeight / 2))

end

function love.keypressed(key)

	console.doInput(key)

end