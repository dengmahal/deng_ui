local dengui=require("dengui")
print(love.getVersion())
local mytext
function love.load()
    local screenX,screenY=love.graphics.getWidth( ),love.graphics.getHeight( )
    local maincanvas_id=dengui.new_canvas(screenX,screenY)
    print(maincanvas_id)
    local mybox=dengui.new_box(maincanvas_id,{scale={x=0.5,y=0.5},offset={x=0,y=0}},{scale={x=0.1,y=0.1},offset={x=0,y=0}},{1,1,1,1})
    mybox.anchor={x=0.5,y=0.5}
    mybox.colour={1,0,1,1}
    mybox.size={scale={x=0,y=0},offset={x=100,y=100}}
    mybox.position={scale={x=0.5,y=0.5},offset={x=0,y=0}}
    mybox.zindex=2
    --dengui.re_render_canvas(maincanvas_id)
    mytext=dengui.new_textfb(maincanvas_id,"text")
    mytext.scale={x=1,y=1}
    mytext.colour={1,1,0,1}
    mytext.background_colour={1,0,0,1}
    mytext.border_colour={0,0,1,0.2}
    mytext.size={scale={x=0,y=0},offset={x=100,y=100}}
    mytext.text=" tes"
    mytext.position={scale={x=0.2,y=0},offset={x=0,y=0}}
    mytext.zindex=3
    for i=1,1000 do
        local a=dengui.new_box(maincanvas_id,{scale={x=0.5,y=0.5},offset={x=0,y=50}},{scale={x=0.1,y=0.4},offset={x=0,y=0}},{0,1,0,0.5})
        a.zindex=-5
    end
    local mytext_edit=dengui.new_text_edit(maincanvas_id,"enter shit here")
    mytext_edit.alignmode="center"
    mytext_edit.scale={x=1,y=1}
    mytext_edit.colour={0,0,0,1}
    mytext_edit.background_colour={1,1,1,1}
    mytext_edit.border_colour={0,0,1,0.2}
    mytext_edit.size={scale={x=0,y=0},offset={x=100,y=100}}
    mytext_edit.position={scale={x=0.2,y=0.2},offset={x=0,y=0}}
    mytext_edit.zindex=2

    dengui.re_render_all()
    dengui.msgbox("loaded","/TIME:1")
    dengui.re_render_all()
end
function love.resize(w, h)
    dengui.set_size_all(w,h)
end
function love.keypressed(key)
    dengui.keypressed(key)
end
function love.textinput(key)
    dengui.textinput(key)
end
function love.keyreleased(key)
    dengui.keyreleased(key)
end
function love.mousepressed(x, y, button, isTouch)
    dengui.mousepressed(x, y, button, isTouch)
end
function love.mousereleased(x,y,button,isTouch)
    dengui.mousereleased(x,y,button,isTouch)
end
function love.mousemoved(x,y,dx,dy)
    dengui.mousemoved(x,y,dx,dy)
end
local dt_list_len=1000
local dt_list={}
for i=1,dt_list_len do
    dt_list[i]=1
end
function love.draw(dt)
    local ndtlist={}
    for i=dt_list_len,2,-1 do
        ndtlist[i-1]=dt_list[i]
    end
    ndtlist[dt_list_len]=dt
    dt_list=ndtlist
    if mytext then
       -- mytext.size={scale={x=0,y=0},offset={x=100,y=i/10}}
        
       --dengui.re_render_all()
    end

    dengui.draw()

    local totdt=0
    for i=1,dt_list_len do
        totdt=totdt+dt_list[i]
    end
    local avgdt=totdt/dt_list_len
    love.graphics.print("fpsavg"..dt_list_len..": "..math.floor(((100/avgdt)+0.5)/100),400,100)
    love.graphics.print("fps: "..math.floor(((love.timer.getFPS()*100)+0.5)/100),400,200)
    local mposx,mposy=love.mouse.getPosition()--love.mouse.getGlobalPosition()
    love.graphics.print("mpos: "..math.floor(((mposx*100)+0.5)/100).." , "..math.floor(((mposy*100)+0.5)/100),600,200)
end



function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
 
    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local lag = 0.0
    local previus_updt=love.timer.getTime() 
    -- Main loop time.
    return function()

        -- Process events.
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end
        local dt=love.timer.step()
        if love.update then love.update(dt) end

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
 
            if love.draw then love.draw(dt) end
            love.graphics.present()
        end

        ---if love.timer then love.timer.sleep(0.001) end
    end
end
