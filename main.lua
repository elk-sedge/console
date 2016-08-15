io.stdout:setvbuf("no")

-- require
local console = require("console")

-- var
local screenWidth, screenHeight = 800, 600
local font

-- main
function love.load()

	love.window.setMode(screenWidth, screenHeight)

	console.init(200, 100, 20, "Early GameBoy.ttf")

end

function love.draw()

	love.graphics.draw(console.getCanvas(), 0, 0)

end

function love.keypressed(key)

	console.doInput(key)

end