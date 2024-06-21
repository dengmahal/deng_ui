local qsort={}
function qsort.swap(tab, firstindex,secondindex)
    local temp=tab[firstindex]
    tab[firstindex]=tab[secondindex]
    tab[secondindex]=temp
    --temp=nil
end
function qsort.partition(tab,left,right)
    local pivv=tab[right]
    local partitionindex=left
    for i=left,right-1 do
        if tab[i]<pivv then
            qsort.swap(tab,i,partitionindex)
            partitionindex=partitionindex+1
        end
    end
    qsort.swap(tab, right, partitionindex)
    --tab=nil
    --pivv=nil
    --left=nil
    return partitionindex
end
function qsort.quicksort(tab,left,right)
    left=left or 1
    right=right or #tab
    if left >=right then
        return
    end
    local pivi=qsort.partition(tab,left,right)
    qsort.quicksort(tab,left,pivi-1)
    qsort.quicksort(tab,pivi+1,right)
    --left=nil
    --right=nil
    --pivi=nil
    return tab
end
function qsort.dup(tab)
    if #tab>1 then
        local counts={}
        local exists={}
        local storage={}
        for i=1,tab[0] do
            local v=tab[i].zindex
            if counts[v]==nil then
                counts[v]=0
                exists[#exists+1] = v
                storage[v]={}
            end
            counts[v]=counts[v]+1
            storage[v][#storage[v]+1]=tab[i]
        end
        qsort.quicksort(exists)
        local ntab={}
        for i=1,#exists do
            local v=exists[i]
            for ii=1,counts[v] do
                ntab[#ntab+1] = storage[v][ii]
            end
        end
        ntab[0]=#ntab
        --counts=nil
        --exists=nil
        --storage=nil
        return ntab
    else
        return tab
    end
end
local function string_insert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

local function nofunc(button)
    --print("button has no "..button.." function. if its not supposed to have a function, it shouldnt be a button.")
end

local dengui={}
local utf8=require("utf8")
local ui_storage={[0]=0}
local canvases={}
local canvases_to_refresh={}
local current_text_editing={0,0}
local cursor_pos=0
local assets={}
local function warn(message)
    local time = os.date("%Y-%m-%d %H:%M:%S")
    io.stderr:write(string.format("[%s] Warning: %s\n", time, message))
end
local  default_colour ={1,1,1,1}

local lg=love.graphics
local function firstlayercopy(tab)
    local ntab={}
    for i,v in pairs(tab)do
        ntab[i]=v
    end
    return ntab
end
local defaults={
    box={
        type="box",
        position={scale={x=0,y=0},offset={x=0,y=0}},
        size={scale={x=0,y=0},offset={x=0,y=0}},
        anchor={x=0,y=0},
        zindex=0,
        colour={1,1,1,1},
        mode="fill"
    },
    text={
        type="text",
        position={scale={x=0,y=0},offset={x=0,y=0}},
        scale={x=1,y=1},
        anchor={x=0,y=0},
        zindex=0,
        colour={1,1,1,1},
        text="vergessen",
        rotation=0,
        font="",
    },
    textf={
        type="textf",
        position={scale={x=0,y=0},offset={x=0,y=0}},
        size={scale={x=0,y=0},offset={x=100,y=50}},
        scale={x=1,y=1},
        anchor={x=0,y=0},
        zindex=0,
        colour={1,1,1,1},
        text="vergessen",
        alignmode="center",
        rotation=0,
        font="",
    },
    textfb={
        type="textfb",
        position={scale={x=0,y=0},offset={x=0,y=0}},
        size={scale={x=0,y=0},offset={x=100,y=50}},
        scale={x=1,y=1},
        anchor={x=0,y=0},
        zindex=0,
        border_width=20,
        colour={.1,0.1,.1,1},
        border_colour={.9,.9,.9,1},
        background_colour={1,1,1,1},
        text="vergessen",
        alignmode="center",
        rotation=0,
        font="",
    },
    text_edit={
        type="text_edit",
        position={scale={x=0,y=0},offset={x=0,y=0}},
        size={scale={x=0,y=0},offset={x=100,y=50}},
        scale={x=1,y=1},
        anchor={x=0,y=0},
        zindex=0,
        border_width=20,
        colour={.1,0.1,.1,1},
        border_colour={.9,.9,.9,1},
        background_colour={1,1,1,1},
        text="",
        alignmode="center",
        rotation=0,
        font="",                ---img
        background_text="vergessen2",
        limit=100,
        enabled=true,
    },
    text_button={
        type="text_button",
        position={scale={x=0,y=0},offset={x=0,y=0}},
        size={scale={x=0,y=0},offset={x=100,y=50}},
        scale={x=1,y=1},
        anchor={x=0,y=0},
        zindex=0,
        border_width=20,
        colour={.1,0.1,.1,1},
        border_colour={.9,.9,.9,1},
        background_colour={1,1,1,1},
        text="vergessen",
        alignmode="center",
        rotation=0,
        font="",
        ["1_func"]=nofunc,
        ["2_func"]=nofunc,
        ["3_func"]=nofunc,
        enabled=true,
    },
    image={
        type="image",
        position={scale={x=0,y=0},offset={x=0,y=0}},
        size={scale={x=0,y=0},offset={x=0,y=0}},
        anchor={x=0,y=0},
        zindex=0,
        colour={1,1,1,1},
        asset="",
        
    },
}
--love.graphics.setBlendMode( "alpha", "alphamultiply" )
--love.graphics.setBlendState( "add", "zero","one" )
local standart_font=love.graphics.getFont()
print(standart_font)
local function zsort(a,b)
    return a.zindex<b.zindex
end
function dengui.new_canvas(sx,sy,zindex,do_aspect,aspect_ratio,canvas_position)
    do_aspect=do_aspect or false
    aspect_ratio=aspect_ratio or sx/sy
    zindex=zindex or 0
    canvas_position=canvas_position or {scale={x=0.5,y=0.5},offset={x=0,y=0}}
    if do_aspect==true then
        if sx/sy>= aspect_ratio then
            sx=sy/aspect_ratio
        else
            sy=sx*aspect_ratio
        end
    end
    local screenX,screenY=love.graphics.getWidth( ),love.graphics.getHeight( )
    canvases[#canvases+1] = {canvas=lg.newCanvas(sx,sy),x=sx,y=sy,zindex=zindex,do_aspect=do_aspect,aspect_ratio=aspect_ratio,position=canvas_position}
    canvases[0]=#canvases
    ui_storage[canvases[0]]={[0]=0}
    local px=canvas_position.scale.x*screenX+canvas_position.offset.x   -sx*0.5
    local py=canvas_position.scale.y*screenY+canvas_position.offset.y   -sy*0.5
    canvases[canvases[0]].truepos={x=px,y=py}
    canvases=qsort.dup(canvases)
    ---table.sort(canvases,zsort)
    print(canvases[canvases[0]].do_aspect)
    return canvases[0]
end
function dengui.set_size(canvas_id,x,y)
    --reconstruct canvas here
    if canvases[canvas_id] then
        canvases[canvas_id].canvas:release()
        if canvases[canvas_id].do_aspect==true then
            if x/y>= canvases[canvas_id].aspect_ratio then
                x=y/canvases[canvas_id].aspect_ratio
            else
                y=x*canvases[canvas_id].aspect_ratio
            end
        end
        local screenX,screenY=love.graphics.getWidth( ),love.graphics.getHeight( )
        canvases[canvas_id].canvas=lg.newCanvas(x,y)
        canvases[canvas_id].x=x
        canvases[canvas_id].y=y
        local px=canvases[canvas_id].position.scale.x*screenX+canvases[canvas_id].position.offset.x   -x*0.5
        local py=canvases[canvas_id].position.scale.y*screenY+canvases[canvas_id].position.offset.y   -y*0.5
        canvases[canvas_id].truepos={x=px,y=py}
        --canvases[canvas_id]={canvas=lg.newCanvas(x,y),x=x,y=y,canvases[canvas_id].zindex,do_aspect=canvases[canvas_id].do_aspect,aspect_ratio=canvases[canvas_id].aspect_ratio,position=canvases[canvas_id].position}
    else
        warn("canvas_id '"..canvas_id.."' not found")
    end
    dengui.re_render_canvas(canvas_id)
    return true
end
function dengui.set_size_all(x,y)
    --reconstruct canvas here
    for canvas_id=1,canvases[0] do
        if canvases[canvas_id] then
            dengui.set_size(canvas_id,x,y)
        else
            warn("canvas_id '"..canvas_id.."' not found")
        end
        dengui.re_render_canvas(canvas_id)
    end
    return true
end
local cursor_timer=os.clock()
local cursor_state=false
function dengui.draw()
    local screenX,screenY=love.graphics.getWidth( ),love.graphics.getHeight( )
    for i=1,canvases[0] do
        local canv=canvases[i]
        local sx=canv.x
        local sy=canv.y
        local px=canv.position.scale.x*screenX+canv.position.offset.x   -sx*0.5
        local py=canv.position.scale.y*screenY+canv.position.offset.y   -sy*0.5
        lg.draw(canvases[i].canvas,px,py)
    end
    if cursor_timer<os.clock()-1 and current_text_editing[1]~=0 then
        cursor_timer=os.clock()
        cursor_state= not cursor_state
        dengui.re_render_canvas(current_text_editing[1])
    end
    return true
end
function dengui.msgbox(msg,args)
    args=args or ""
    --os.execute("msg "..args.." * "..msg,1000,true)
    io.popen("msg "..args.." * "..msg,"r")
end
function dengui.new_img_asset(filename,storename,settings)
    if filename==nil or love.filesystem.exists(filename)==false then warn(filename.." was not found") return end
    settings=settings or {mipmaps=false,linear=false,dpiscale=1}
    settings.mipmaps=settings.mipmaps or false
    settings.linear=settings.linear or false
    settings.dpiscale=settings.dpiscale or 1
    storename=storename or filename
    local img=lg.newImage(filename,settings)
    if img then
        assets[storename]=img
        print(storename,filename)
    else
        warn(filename.." was unable to load")
    end
    return
end
function dengui.release_img_asset(storename)
    if assets[storename] then
        assets[storename]:release()
        assets[storename]=nil
    else
        warn("cant relase an asset that does not exist")
    end
    return
end
function dengui.new_box(canvas_id,position,size,colour,mode)
    if type(canvas_id)~="number" then warn("invalid canvas_id "..debug.traceback()) end
    --if type(position)~="table" then warn("invalid position "..debug.traceback()) end
    --if type(size)~="table" then warn("invalid size "..debug.traceback()) end
    --if type(colour)~="table" and type(colour)~="nil" then warn("invalid colour "..debug.traceback()) end
    local genbox=firstlayercopy(defaults.box)
    genbox.position=position or defaults.box.position
    genbox.size=size or defaults.box.size
    genbox.colour=colour or defaults.box.colour
    genbox.mode=mode or defaults.box.mode
    ui_storage[canvas_id][ui_storage[canvas_id][0]+1]=genbox
    ui_storage[canvas_id][0]=#ui_storage[canvas_id]
    --dengui.re_render_canvas(canvas_id)
    return genbox
end
local function render_box(canvas_id,box)
    local thiscan=canvases[canvas_id]
    local sx=box.size.scale.x*thiscan.x+box.size.offset.x
    local sy=box.size.scale.y*thiscan.y+box.size.offset.y
    local px=box.position.scale.x*thiscan.x+box.position.offset.x   -sx*box.anchor.x
    local py=box.position.scale.y*thiscan.y+box.position.offset.y   -sy*box.anchor.y
    lg.setColor(box.colour[1],box.colour[2],box.colour[3],box.colour[4])
    lg.rectangle(box.mode, px, py, sx, sy)
    lg.setColor(default_colour[1],default_colour[2],default_colour[3],default_colour[4])
end
function dengui.new_text(canvas_id,text,position,scale,colour)
    if type(canvas_id)~="number" then warn("invalid canvas_id "..debug.traceback()) end
    local gen=firstlayercopy(defaults.text)
    gen.position=position or defaults.text.position
    gen.scale=scale or defaults.text.scale
    gen.colour=colour or defaults.text.colour
    gen.text=text or defaults.text.text
    ui_storage[canvas_id][ui_storage[canvas_id][0]+1]=gen
    ui_storage[canvas_id][0]=#ui_storage[canvas_id]
    --dengui.re_render_canvas(canvas_id)
    return gen
end
local function render_text(canvas_id,obj)
    local thiscan=canvases[canvas_id]
    local thisfont=lg.getFont()
    local sx=thisfont:getWidth(obj.text)*obj.scale.x
    local sy=thisfont:getHeight(obj.text)*obj.scale.y
    local px=obj.position.scale.x*thiscan.x+obj.position.offset.x   -sx*obj.anchor.x
    local py=obj.position.scale.y*thiscan.y+obj.position.offset.y   -sy*obj.anchor.y
    lg.setColor(obj.colour[1],obj.colour[2],obj.colour[3],obj.colour[4])
    lg.print(obj.text, px, py,obj.rotation, obj.scale.x, obj.scale.y)
    lg.setColor(default_colour[1],default_colour[2],default_colour[3],default_colour[4])
end
function dengui.new_textf(canvas_id,text,position,size,scale,colour)
    if type(canvas_id)~="number" then warn("invalid canvas_id "..debug.traceback()) end
    local gen=firstlayercopy(defaults.textf)
    gen.position=position or defaults.textf.position
    gen.scale=scale or defaults.textf.scale
    gen.size=size or defaults.textf.size
    gen.colour=colour or defaults.textf.colour
    gen.text=text or defaults.textf.text
    ui_storage[canvas_id][ui_storage[canvas_id][0]+1]=gen
    ui_storage[canvas_id][0]=#ui_storage[canvas_id]
    --dengui.re_render_canvas(canvas_id)
    return gen
end
local function render_textf(canvas_id,obj)
    local thiscan=canvases[canvas_id]
    --local thisfont=lg.getFont()
    local sx=obj.size.scale.x*thiscan.x+obj.size.offset.x
    local sy=obj.size.scale.y*thiscan.y+obj.size.offset.y
    local px=obj.position.scale.x*thiscan.x+obj.position.offset.x   -sx*obj.anchor.x
    local py=obj.position.scale.y*thiscan.y+obj.position.offset.y   -sy*obj.anchor.y
    lg.setColor(obj.colour[1],obj.colour[2],obj.colour[3],obj.colour[4])
    lg.printf(obj.text, px, py,sx,obj.alignmode,obj.rotation, obj.scale.x, obj.scale.y)
    lg.setColor(default_colour[1],default_colour[2],default_colour[3],default_colour[4])
end
function dengui.new_textfb(canvas_id,text,position,size,scale,colour)
    if type(canvas_id)~="number" then warn("invalid canvas_id "..debug.traceback()) end
    local gen=firstlayercopy(defaults.textfb)
    gen.position=position or defaults.textfb.position
    gen.scale=scale or defaults.textfb.scale
    gen.size=size or defaults.textfb.size
    gen.colour=colour or defaults.textfb.colour
    gen.text=text or defaults.textfb.text
    ui_storage[canvas_id][ui_storage[canvas_id][0]+1]=gen
    ui_storage[canvas_id][0]=#ui_storage[canvas_id]
    --dengui.re_render_canvas(canvas_id)
    return gen
end
local function render_textfb(canvas_id,obj)
    local thiscan=canvases[canvas_id]
    --local thisfont=lg.getFont()
    local sx=obj.size.scale.x*thiscan.x+obj.size.offset.x
    local sy=obj.size.scale.y*thiscan.y+obj.size.offset.y
    local px=obj.position.scale.x*thiscan.x+obj.position.offset.x   -sx*obj.anchor.x
    local py=obj.position.scale.y*thiscan.y+obj.position.offset.y   -sy*obj.anchor.y
    lg.setColor(obj.background_colour[1],obj.background_colour[2],obj.background_colour[3],obj.background_colour[4])
    lg.rectangle("fill", px, py, sx, sy)
    lg.setLineWidth(obj.border_width)
    lg.setColor(obj.border_colour[1],obj.border_colour[2],obj.border_colour[3],obj.border_colour[4])
    lg.rectangle("line", px, py, sx, sy)
    lg.setColor(obj.colour[1],obj.colour[2],obj.colour[3],obj.colour[4])
    lg.printf(obj.text, px, py,sx,obj.alignmode,obj.rotation, obj.scale.x, obj.scale.y)
    lg.setColor(default_colour[1],default_colour[2],default_colour[3],default_colour[4])
end

function dengui.new_text_edit(canvas_id,background_text,position,size,scale,colour)
    if type(canvas_id)~="number" then warn("invalid canvas_id "..debug.traceback()) end
    local gen=firstlayercopy(defaults.text_edit)
    gen.type="text_edit"
    gen.position=position or defaults.text_edit.position
    gen.scale=scale or defaults.text_edit.scale
    gen.size=size or defaults.text_edit.size
    gen.colour=colour or defaults.text_edit.colour
    gen.background_text=background_text or defaults.text_edit.background_text
    ui_storage[canvas_id][ui_storage[canvas_id][0]+1]=gen
    ui_storage[canvas_id][0]=#ui_storage[canvas_id]
    --dengui.re_render_canvas(canvas_id)
    return gen
end
local function render_text_edit(canvas_id,obj)
    local thiscan=canvases[canvas_id]
    --local thisfont=lg.getFont()
    local sx=obj.size.scale.x*thiscan.x+obj.size.offset.x
    local sy=obj.size.scale.y*thiscan.y+obj.size.offset.y
    local px=obj.position.scale.x*thiscan.x+obj.position.offset.x   -sx*obj.anchor.x
    local py=obj.position.scale.y*thiscan.y+obj.position.offset.y   -sy*obj.anchor.y
    lg.setColor(obj.background_colour[1],obj.background_colour[2],obj.background_colour[3],obj.background_colour[4])
    local text_to_render=tostring(obj.text)
    if current_text_editing[1]~=0 then
        if cursor_state==true then
            --text_to_render=text_to_render.."|"--utf8.char(204)
            text_to_render=string_insert(text_to_render,"|",cursor_pos)
        end
    end
    
    lg.rectangle("fill", px, py, sx, sy)
    lg.setLineWidth(obj.border_width)
    lg.setColor(obj.border_colour[1],obj.border_colour[2],obj.border_colour[3],obj.border_colour[4])
    lg.rectangle("line", px, py, sx, sy)
    lg.setColor(obj.colour[1],obj.colour[2],obj.colour[3],obj.colour[4])
    local todisplay=""
    if (obj.text=="" or obj.text==nil) and current_text_editing[1]==0 then
        todisplay=defaults.text_edit.background_text
    else
        todisplay=text_to_render
    end
    lg.printf(todisplay, px, py,sx,obj.alignmode,obj.rotation, obj.scale.x, obj.scale.y)
    lg.setColor(default_colour[1],default_colour[2],default_colour[3],default_colour[4])
end
function dengui.new_text_button(canvas_id,text,position,size,func,scale,colour)
    if type(canvas_id)~="number" then warn("invalid canvas_id "..debug.traceback()) end
    local gen=firstlayercopy(defaults.text_button)
    gen.position=position or defaults.text_button.position
    gen.scale=scale or defaults.text_button.scale
    gen.size=size or defaults.text_button.size
    gen.colour=colour or defaults.text_button.colour
    gen.text=text or defaults.text_button.text
    gen.func=func or defaults.text_button.func
    ui_storage[canvas_id][ui_storage[canvas_id][0]+1]=gen
    ui_storage[canvas_id][0]=#ui_storage[canvas_id]
    --dengui.re_render_canvas(canvas_id)
    return gen
end
local function render_text_button(canvas_id,obj)
    local thiscan=canvases[canvas_id]
    --local thisfont=lg.getFont()
    local sx=obj.size.scale.x*thiscan.x+obj.size.offset.x
    local sy=obj.size.scale.y*thiscan.y+obj.size.offset.y
    local px=obj.position.scale.x*thiscan.x+obj.position.offset.x   -sx*obj.anchor.x
    local py=obj.position.scale.y*thiscan.y+obj.position.offset.y   -sy*obj.anchor.y
    lg.setColor(obj.background_colour[1],obj.background_colour[2],obj.background_colour[3],obj.background_colour[4])
    lg.rectangle("fill", px, py, sx, sy)
    lg.setLineWidth(obj.border_width)
    lg.setColor(obj.border_colour[1],obj.border_colour[2],obj.border_colour[3],obj.border_colour[4])
    lg.rectangle("line", px, py, sx, sy)
    lg.setColor(obj.colour[1],obj.colour[2],obj.colour[3],obj.colour[4])
    lg.printf(obj.text, px, py,sx,obj.alignmode,obj.rotation, obj.scale.x, obj.scale.y)
    lg.setColor(default_colour[1],default_colour[2],default_colour[3],default_colour[4])
end

function dengui.new_image(canvas_id,asset,position,scale,colour)
    if type(canvas_id)~="number" then warn("invalid canvas_id "..debug.traceback()) end
    local gen=firstlayercopy(defaults.image)
    gen.position=position or defaults.image.position
    gen.scale=scale or defaults.image.scale
    gen.colour=colour or defaults.image.colour
    gen.asset=asset or defaults.image.asset
    if assets[asset]==nil then
       dengui.new_img_asset(asset) 
    end
    ui_storage[canvas_id][ui_storage[canvas_id][0]+1]=gen
    ui_storage[canvas_id][0]=#ui_storage[canvas_id]
    --dengui.re_render_canvas(canvas_id)
    return gen
end
local function render_image(canvas_id,obj)
    local thiscan=canvases[canvas_id]
    local sx=obj.size.scale.x*thiscan.x+obj.size.offset.x
    local sy=obj.size.scale.y*thiscan.y+obj.size.offset.y
    local px=obj.position.scale.x*thiscan.x+obj.position.offset.x   -sx*obj.anchor.x
    local py=obj.position.scale.y*thiscan.y+obj.position.offset.y   -sy*obj.anchor.y
    --local img=love.graphics.newImage(obj.asset,obj.settings)
    local img=assets[obj.asset]
    local imgx,imgy=img:getPixelDimensions()
    local ssx=sx/imgx
    local ssy=sy/imgy
    lg.setColor(obj.colour[1],obj.colour[2],obj.colour[3],obj.colour[4])
    lg.draw(img, px, py,obj.rotation, ssx,ssy)
    lg.setColor(default_colour[1],default_colour[2],default_colour[3],default_colour[4])
end


local render_function_list={
    ["box"]=render_box,
    ["text"]=render_text,
    ["textf"]=render_textf,
    ["textfb"]=render_textfb,
    ["text_edit"]=render_text_edit,
    ["text_button"]=render_text_button,
    ["image"]=render_image,
}
function dengui.re_render_all()
    for i=1,canvases[0] do
        dengui.re_render_canvas(i)
    end
end
local last_gc=os.clock()
function dengui.re_render_canvas(canvas_id)
    lg.setCanvas(canvases[canvas_id].canvas)
    lg.clear()
    for i=1,ui_storage[canvas_id][0] do
        local obj=ui_storage[canvas_id][i]
        render_function_list[obj.type](canvas_id,obj)
    end
---@diagnostic disable-next-line: param-type-mismatch
    ui_storage[canvas_id]=qsort.dup(ui_storage[canvas_id])
    lg.setCanvas()
    if os.clock()-last_gc>math.max(math.min((1/ui_storage[canvas_id][0])*600000,60),3) then
        collectgarbage("collect")--> there is a memory leak somewhere. removing the sort makes it better, but making all variables nil after sorting doesnt help????
        last_gc=os.clock()
        print("Garbage collected")
    end
end


function dengui.give_canvasobj(canvas_id)
    return canvases[canvas_id].canvas
end


local str_char_map={
    ["kp/"]="/",
    ["space"]=" ",
    ["return"]="\n",
--    ["ß"]="ß",
--    ["ä"]="ä",
--    ["ö"]="ö",
--    ["´"]="´",
}
--love.keyboard.setKeyRepeat(true)
function dengui.textinput(key)
    if current_text_editing[1]~=0 then
        local sstring=ui_storage[current_text_editing[1]][current_text_editing[2]].text
        --if #key==1 and #sstring<ui_storage[current_text_editing[1]][current_text_editing[2]].limit then
            --[[
            local upper=false
            if love.keyboard.isModifierActive("capslock") then
                upper=not upper
            end
            if love.keyboard.isDown("lshift") then
                upper= not upper
            end
            if upper==true then
                key=string.upper(key)
            end]]
            --ui_storage[current_text_editing[1]][current_text_editing[2]].text=sstring..key
            ui_storage[current_text_editing[1]][current_text_editing[2]].text=string_insert(sstring,key,cursor_pos)
            cursor_pos=cursor_pos+#key
        --end
    end
    if current_text_editing[1]~=0 then
        dengui.re_render_canvas(current_text_editing[1])
    end
end

function dengui.keypressed(key)
    --print(key)
    if current_text_editing[1]~=0 then
        local sstring=ui_storage[current_text_editing[1]][current_text_editing[2]].text
        if #key==1 and #sstring<ui_storage[current_text_editing[1]][current_text_editing[2]].limit then
        elseif key=="backspace" then
            if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
                local lastSpace = string.find(string.reverse(sstring), " ")
                local lastnl = string.find(string.reverse(sstring), "\n")
                if (lastSpace or 0)<(lastnl or 0) then
                    lastSpace=lastnl
                end
                if lastSpace then
                    sstring=string.sub(sstring, 1, #sstring - lastSpace)
                else
                    sstring=""
                end
                ui_storage[current_text_editing[1]][current_text_editing[2]].text=sstring
            else
                local byteoffset = utf8.offset(sstring, -1)
                if byteoffset then
                    sstring=sstring:sub(1,byteoffset-1)
                ui_storage[current_text_editing[1]][current_text_editing[2]].text=sstring
                end
            end
        elseif key=="right" then
            local sst=sstring:sub(cursor_pos+1,-1)
            local byteoffset=sst:match("[%z\1-\127\194-\244][\128-\191]*")
            if byteoffset then
                cursor_pos=cursor_pos+#byteoffset
            end
                --cursor_pos=cursor_pos+1
            if #sstring<cursor_pos then
                cursor_pos=#sstring
            end
            cursor_state=true
            cursor_timer=os.clock()
        elseif key=="left" then
            --local byteoffset=utf8.offset(sstring,cursor_pos-1)
            local byteoffset=utf8.offset(sstring:sub(0,cursor_pos), -1)
            if byteoffset then
            cursor_pos=byteoffset-1
            end
            if 0>cursor_pos then
                cursor_pos=0
            end
            cursor_state=true
            cursor_timer=os.clock()
        elseif str_char_map[key] and #key>4 then
            print(key)
            ui_storage[current_text_editing[1]][current_text_editing[2]].text=string_insert(sstring,str_char_map[key],cursor_pos)
            --ui_storage[current_text_editing[1]][current_text_editing[2]].text=sstring..str_char_map[key]
        end
        dengui.re_render_canvas(current_text_editing[1])
    end
end
function dengui.keyreleased(key)

end
function dengui.is_over_ui(canvas_id,ui_id,x,y)
    local thiscan=canvases[canvas_id]
    local obj=ui_storage[canvas_id][ui_id]
    local sx=obj.size.scale.x*thiscan.x+obj.size.offset.x
    local sy=obj.size.scale.y*thiscan.y+obj.size.offset.y
    local px=obj.position.scale.x*thiscan.x+obj.position.offset.x   -sx*obj.anchor.x
    local py=obj.position.scale.y*thiscan.y+obj.position.offset.y   -sy*obj.anchor.y

    local tx=px+thiscan.truepos.x
    local ty=py+thiscan.truepos.y
    if x>=tx and x<=tx+sx and y>=ty and y<=ty+sy then
        return true
    else
        return false
    end
end

function dengui.mousepressed(x, y, button, isTouch)
    local hit_text_eedit=false
    for i=1,canvases[0] do
        local thiscan=canvases[i]
        for ii=1,#ui_storage[i] do
            if ui_storage[i][ii].type=="text_edit" then
                if dengui.is_over_ui(i,ii,x,y)==true then
                    current_text_editing={i,ii}
                    hit_text_eedit=true
                    cursor_pos=#ui_storage[i][ii].text
                end
            elseif ui_storage[i][ii].type=="text_button" then
                if dengui.is_over_ui(i,ii,x,y)==true then
                    ui_storage[i][ii][button.."_func"](x,y)
                end
            end
        end
    end
    if hit_text_eedit==false then
        if current_text_editing[1]~=0 then
            local tmp=tonumber(current_text_editing[1])
            current_text_editing={0,0}
            dengui.re_render_canvas(tmp)
        end
        current_text_editing={0,0}
    end
end
function dengui.mousereleased(x,y,button,isTouch)

end
function dengui.mousemoved(x,y,dx,dy)

end
function dengui.wheelmoved(x,y)

end
return dengui