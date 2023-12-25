function love.load()
    screenW, screenH = love.graphics.getDimensions()
    love.graphics.setDefaultFilter("nearest", "nearest")
    smallFont = love.graphics.newFont(10)
    bigFont = love.graphics.newFont(40)
    a = 1
    q = 0
    p = 0
    zoom = 100
    smoothZoom = 100
    points = {}
    inversePoints = {}
    yf = 1
    xf = 1
    inverseFunction = false
    inputMode = false
    aInput = ""
    calcGraph()
    love.graphics.setBackgroundColor(1, 1, 1) 
end

function calcGraph()
    for x=1, screenW/2 do
        rx = x/zoom
        points[x] = {rx, math.sqrt(a*rx)}
    end
end

function love.draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.line({screenW/2, 0, screenW/2, screenH})
    love.graphics.line({0, screenH/2, screenW, screenH/2})
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.line({screenW/2+p*smoothZoom, 0, screenW/2+p*smoothZoom, screenH})
    love.graphics.line({0, screenH/2-q*smoothZoom, screenW, screenH/2-q*smoothZoom})

    love.graphics.setColor(0, 0, 255)
    for i=1, #points do
        point = points[i]
        point2 = {0, 0}
        if i > 1 then
            point2 = points[i-1]
        end
        love.graphics.line({screenW/2+(point[1]*yf+p)*smoothZoom, screenH/2-(point[2]*xf+q)*smoothZoom, screenW/2+(point2[1]*yf+p)*smoothZoom, screenH/2-(point2[2]*xf+q)*smoothZoom})
    end
    if inverseFunction then
        love.graphics.setColor(255, 0, 0)
        for i=1, #points do
            point = points[i]
            point2 = {0, 0}
            if i > 1 then
                point2 = points[i-1]
            end
            love.graphics.line({screenW/2+(point[2]*yf+p)*smoothZoom, screenH/2-(point[1]*xf+q)*smoothZoom, screenW/2+(point2[2]*yf+p)*smoothZoom, screenH/2-(point2[1]*xf+q)*smoothZoom})
        end
    end
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(smallFont)
    love.graphics.print("0", screenW/2, screenH/2)
    for x=1, screenW/smoothZoom/2 do
        love.graphics.print(tostring(math.floor(x)), x*smoothZoom+screenW/2, screenH/2)
        love.graphics.print(tostring(math.floor(-x)), -x*smoothZoom+screenW/2, screenH/2)
    end
    for y=1, screenH/smoothZoom/2 do
        love.graphics.print(tostring(math.floor(-y)),  screenW/2, y*smoothZoom+screenH/2)
        love.graphics.print(tostring(math.floor(y)), screenW/2, -y*smoothZoom+screenH/2)
    end
    yfs = ""
    if yf < 0 then
        yfs = "-"
    end
    xfs = ""
    if xf < 0 then
        xfs = "-"
    end
    as = ""
    if a ~= 1 then
        if a == nil then
            as = "_"
        elseif a == -1 then
            as = "-"
        else
            as = tostring(a)
        end
    end
    ps = tostring(-p)
    if ps == "-0" then
        ps = ""
    elseif -p > 0 then
        ps = "+"..ps
    end
    qs = tostring(q)
    if qs == "0" then
        qs = ""
    elseif q > 0 then
        qs = "+"..qs
    end
    love.graphics.setFont(bigFont)
    if ps == "0" then
        if as == "" then
            love.graphics.print("y = "..xfs.."sqrt("..yfs.."x)"..qs, 40, 40)
        else
            love.graphics.print("y = "..xfs.."sqrt("..yfs..as.."(x))"..qs, 40, 40)
        end
    else
        if as == "" then
            if yfs == "" then
                love.graphics.print("y = "..xfs.."sqrt("..yfs..as.."x"..ps..")"..qs, 40, 40)
            else
                love.graphics.print("y = "..xfs.."sqrt("..yfs..as.."(x"..ps.."))"..qs, 40, 40)
            end
        else
            love.graphics.print("y = "..xfs.."sqrt("..yfs..as.."(x"..ps.."))"..qs, 40, 40)
        end
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        zoom = zoom+10
    elseif y < 0 then
        zoom = zoom-10
    end
    if zoom < 10 then
        zoom = 10
    elseif zoom > 150 then
        zoom = 150
    end
    calcGraph()
end

function love.update(dt)
    local dt = dt*60
    smoothZoom = smoothZoom+(zoom-smoothZoom)/5*dt
end

function love.keypressed(key)
    if inputMode then
        if key == "return" then
            inputMode = false
            calcGraph()
            if a == nil then
                a = 1
            end
        end
        if key == "backspace" then
            aInput = string.sub(aInput, 0, #aInput-1)
            a = tonumber(aInput)
            if a == nil then
                a = 1
            end
        end
        if tonumber(key) ~= nil then
            aInput = aInput..key
            a = tonumber(aInput)
            calcGraph()
            if a == nil then
                a = 1
            end
        end
    else
        if key == "y" then
            yf = -yf
            calcGraph()
        end
        if key == "x" then
            xf = -xf
            calcGraph()
        end
        if key == "i" then
            inverseFunction = not inverseFunction
        end
        if key == "return" then
            inputMode = true
            aInput = ""
            a = tonumber(aInput)
            if a == nil then
                a = 1
            end
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        p = math.floor((x-screenW/2)/zoom)
        q = math.floor(-(y-screenH/2)/zoom)
        calcGraph()
    end
end 

function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end