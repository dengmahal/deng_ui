local dengui={}
local ui_storage={}
local canvases={}
local function warn(message)
    local time = os.date("%Y-%m-%d %H:%M:%S")
    io.stderr:write("\x1b[31m"..string.format("[%s] Warning: %s\n" .."\x1b[0m", time, message))
end
local function firstlayercopy(tab)
    local ntab={}
    for i,v in pairs(tab)do
        ntab[i]=v
    end
    return ntab
end
local baseUI={
    position={x=0,y=0},
    size={scale={x=0,y=0},offset={x=0,y=0}},
    anchor={x=0,y=0},
    zindex=0,
}
function dengui.new_canvas(sx,sy)
    canvases[#canvases+1] = love.graphics.newCanvas(x,y)
    canvases[0]=#canvases
    return canvases[0]
end
function dengui.set_size(canvas_id,x,y)
    --reconstruct canvas here
    if canvases[canvas_id] then
        canvases[canvas_id]=love.graphics.newCanvas(x,y)
    else
        warn("canvas_id '"..canvas_id.."' not found")
    end
    return true
end

function dengui.draw()
    for i=1,canvases[0] do
        love.graphics.draw(canvases[i])
    end
    return true
end

function dengui.new_box(canvas_id,position,size,colour)
    if type(canvas_id)~="number" then warn("invalid canvas_id "..debug.traceback()) end
    if type(position)~="table" then warn("invalid position "..debug.traceback()) end
    if type(size)~="table" then warn("invalid size "..debug.traceback()) end
    if type(colour)~="table" and type(colour)~="nil" then warn("invalid colour "..debug.traceback()) end

    local genbox=firstlayercopy(baseUI)
    genbox.colour=colour or {1,1,1,1}
    

end

function dengui.re_render_all()

end
function dengui.re_render_canvas(canvas_id)

end


return dengui