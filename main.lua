local uisys=require("dengui")
local canvas

function love.load()
    local screenX,screenY=love.graphics.getWidth( ),love.graphics.getHeight( )
    uisys.init(screenX,screenY)
    canvas=love.graphics.newCanvas(screenX,screenY)
end
local i=0
function love.draw(dt)
    i=i+1
    uisys.update()
    love.graphics.setCanvas(canvas)
    love.graphics.clear( )
    love.graphics.print(tostring(i))
    love.graphics.setCanvas()
    love.graphics.draw(canvas)
end