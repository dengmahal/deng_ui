local dengui=require("dengui")
print(love.getVersion())
local mytext
local currpm=0
local screenX,screenY=love.graphics.getWidth( ),love.graphics.getHeight( )
local scroll_canv_id,scroll_canv_data=dengui.new_canvas(screenX,screenY,2,false)
local maincanvas_id,maincanvas_data=dengui.new_canvas(screenX,screenY,3,true,1,{scale={x=0.5,y=0.5},offset={x=0,y=0}},{x=0.5,y=0.5})

local tachoid,tacho_data=dengui.new_canvas(700,700,4,true,1,{scale={x=0.5,y=1},offset={x=0,y=0}},{x=0.5,y=1})
local tacholineid,tacholine_data=dengui.new_canvas(700,700,255,true,1,{scale={x=0.5,y=1},offset={x=0,y=0}},{x=0.5,y=1})
local tachcent={x=0.5,y=0.9}
local tach_line=dengui.new_boxr(tacholineid,{scale={x=tachcent.x,y=tachcent.y},offset={x=0,y=0}},{scale={x=0.008,y=0.19},offset={x=0,y=0}})
tach_line.colour={1,0,0,1}
tach_line.anchor={x=0.5,y=0.1}
tach_line.zindex=100

local maxrpm=7000
function love.load(arg,arg2)
    local screenX,screenY=love.graphics.getWidth( ),love.graphics.getHeight( )
    print("maincanvas_id",maincanvas_id)
    local mybox=dengui.new_box(maincanvas_id,{scale={x=0.5,y=0.5},offset={x=0,y=0}},{scale={x=0.1,y=0.1},offset={x=0,y=0}},{1,1,1,1})
    mybox.anchor={x=0.5,y=0.5}
    mybox.colour={.1,0,.1,1}
    mybox.size={scale={x=.9,y=.9},offset={x=0,y=0}}
    mybox.position={scale={x=0.5,y=0.5},offset={x=0,y=0}}
    mybox.zindex=-6

    dengui.new_img_asset("snekobread.png","snekobread")
    local my_image=dengui.new_image(maincanvas_id,"snekobread")
    my_image.colour={1,1,1,.1}
    my_image.size={scale={x=0.5,y=0.5},offset={x=0,y=0}}
    my_image.position={scale={x=0.1,y=0.4},offset={x=0,y=0}}
    my_image.zindex=-4
    dengui.re_render_all()
    dengui.msgbox("loaded","/TIME:1")
    dengui.re_render_all()
    --dengui.release_img_asset("snekobread")
    --for i=0,1 do
    --    local line=dengui.new_boxr(maincanvas_id,{scale={x=0.5,y=0.5},offset={x=0,y=0}},{scale={x=0.055,y=0.7},offset={x=0,y=0}})
    --    line.anchor={x=0.5,y=0}
    --    line.zindex=10
    --    line.rotation=math.rad(i*180)-math.rad(90)
    --end
    --tacho
    local berlin=love.graphics.newFont("fonts/BRLNSB.TTF", 64)
    local linecount=7*5
    for i=0,linecount do
        local angle=i*math.rad(180)/linecount
        local xs=0.05
        local sx=math.cos(angle)*0.2
        local sy=-(math.sin(angle)*0.2)
        if i%5 ==0 then
            xs=0.065
            local xss=xs*1.5
            local num=dengui.new_textf(tachoid,math.floor(0.5+(linecount-i)*(maxrpm/linecount)/100))
            num.scale={x=0.4,y=0.4}
            local font_scale={x=num.scale.x*berlin:getWidth("1234")/700,y=num.scale.y*berlin:getWidth("1234")/700}
            num.position={scale={x=sx*(xss+1)*(font_scale.x+1)+tachcent.x,y=sy*(xss+1)*(font_scale.y+1)+tachcent.y},offset={x=0,y=0}}
            num.font=berlin
            num.alignmode="center"
            num.size={scale={x=5*font_scale.x,y=font_scale.y},offset={x=0,y=0}}
            num.anchor={x=num.scale.x*0.5,y=num.scale.y*0.5}
            print(i,num.size.scale.x,num.anchor.x)
            --print(i)
        end
        local line=dengui.new_boxr(tachoid,{scale={x=sx+tachcent.x,y=sy+tachcent.y},offset={x=0,y=0}},{scale={x=0.0055,y=xs},offset={x=0,y=0}})
        line.anchor={x=0.5,y=0}
        line.zindex=10
        line.rotation=-angle +math.rad(90)
        if i==0 or i==linecount then
            print("sx",sx,sy,math.deg(angle))
        end
        --print(angle)
    end
    --scrollable canvas
    
    --print(maincanvas_id,tachoid,tacholineid,scroll_canv_id)
    --print(maincanvas_data.do_aspect,tacho_data.do_aspect,tacholine_data.do_aspect,scroll_canv_data.do_aspect)
    --print(maincanvas_data.aspect_ratio,tacho_data.aspect_ratio,tacholine_data.aspect_ratio,scroll_canv_data.aspect_ratio)
    dengui.re_render_all()
end
function love.resize(w, h)
    dengui.set_size(maincanvas_id,w,h)
    dengui.set_size(tachoid,w*0.75,h*0.75)
    dengui.set_size(tacholineid,w*0.75,h*0.75)
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
function love.wheelmoved(x,y)
    dengui.wheelmoved(x,y)
end
local dt_list_len=1000
local dt_list={}
for i=1,dt_list_len do
    dt_list[i]=1
end
function love.textedited( text, start, length )
    --print("ed",text,start,length)
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
    if love.keyboard.isDown("w") then
        currpm=currpm +3000*dt
        tach_line.rotation=(currpm/maxrpm)*math.pi +math.rad(90)
        dengui.re_render_canvas(tacholineid)
    elseif love.keyboard.isDown("s") then
        currpm=currpm -3000*dt
        tach_line.rotation=(currpm/maxrpm)*math.pi +math.rad(90)
        dengui.re_render_canvas(tacholineid)
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

        --if love.timer then love.timer.sleep(0.1) end
    end
end
