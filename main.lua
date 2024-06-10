local uisys=require("dengui")
local canvas

function love.load()
    local screenX,screenY=love.graphics.getWidth( ),love.graphics.getHeight( )
    local maincanvas_id=uisys.new_canvas(screenX,screenY)
    print(maincanvas_id)
    local mybox=uisys.new_box(1,{x=0,y=0},{scale={x=0,y=0},offset={x=0,y=0}})
end
local i=0
function love.draw(dt)
    i=i+1
    uisys.draw()
end