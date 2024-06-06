local dengui={}
local ui_storage={}
local ui_canvas

function dengui.init(x,y)
    ui_canvas=love.graphics.newCanvas(x,y)
end
function dengui.set_size(x,y)
    --reconstruct canvas here
    ui_canvas=love.graphics.newCanvas(x,y)
end

function dengui.update()
    love.graphics.draw(ui_canvas)
end

function dengui.new_box()
    
end


return dengui