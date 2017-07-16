platform = {}
player = {}

local texture, mesh, background, intense, intensemesh


function love.load()

    -- Local variables.
    local joysticks = love.joystick.getJoysticks()
    local baseline = 1.1

    jump_multipler = 3
    absorbed = 0
    absorb_speed = 1

    -- Rain.
    intense = false
    texture = love.graphics.newImage('raintex.png')
    texture:setWrap('repeat','repeat')

    -- Sound
    jump_sound = love.audio.newSource("jump.wav", "static")
    jump_sound:setPitch(0.5)


    local vertices = {
        {
            -- top-left corner
            0, 0, -- position of the vertex
            0, 0, -- texture coordinate at the vertex position
            255, 255, 255, 255 -- color & alpha of the vertex
        },
        {
            -- top-right corner
            texture:getWidth(), 0,
            1, 0, -- texture coordinates are in the range of [0, 1]
            255, 255, 255, 255
        },
        {
            -- bottom-right corner
            texture:getWidth(), texture:getHeight(),
            1, 1,
            255, 255, 255, 255
        },
        {
            -- bottom-left corner
            0, texture:getHeight(),
            0, 1,
            255, 255, 255, 255
        },
    }

    mesh = love.graphics.newMesh(vertices, 'fan')
    mesh:setTexture(texture)

    intensemesh = love.graphics.newMesh(vertices, 'fan')
    intensemesh:setTexture(texture)

    -- My game

    joystick = joysticks[1]

    platform.width = love.graphics.getWidth()
    platform.height = love.graphics.getHeight()

    platform.x = 0
    platform.y = platform.height / baseline

    player.x = love.graphics.getWidth() / baseline
    player.y = love.graphics.getHeight() / baseline

    player.speed = 250

    player.img = love.graphics.newImage('purple.png')

    player.ground = player.y

    player.y_velocity = 0

    player.jump_height = -400
    player.gravity = -3000
end

local function clamp(x,m,s) return math.max(math.min(x,s),m) end
local time = 0.0
local wave = 5.0

function love.update(dt)

    absorbed = absorbed + (absorb_speed * dt)

    time = time + dt * 7

    if intense then
        wave = 5 + math.sin(time) * 1.5
        for i=1,4 do
            u, v = intensemesh:getVertexAttribute(i, 2)
            u, v = u-dt/wave, v-dt*1.3
            intensemesh:setVertexAttribute(i, 2, u, v)
        end
    end

    local u, v

    for i=1,4 do
        u, v = mesh:getVertexAttribute(i, 2)
        u, v = u-dt/5, v-dt
        mesh:setVertexAttribute(i, 2, u, v)
    end


    if joystick:isGamepadDown("dpright") then
        if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
            player.x = player.x + (player.speed * dt)
        end
    elseif joystick:isGamepadDown("dpleft") then
        if player.x > 0 then
            player.x = player.x - (player.speed * dt)
        end
    end

    if joystick:isGamepadDown("a") then
        if player.y_velocity == 0 then
            -- Play sound for jumping.
            jump_sound:play()

            absorbed = absorbed + (1 * jump_multipler)

            player.y_velocity = player.jump_height
        end
    end

    if player.y_velocity ~= 0 then
        player.y = player.y + player.y_velocity * dt
        player.y_velocity = player.y_velocity - player.gravity * dt
    end

    if player.y > player.ground then
        player.y_velocity = 0
        player.y = player.ground
    end
end

function love.keypressed(kc, sc, ir)

    -- print(kc, sc)

    if sc == 'space' or kc == 'space' then
        intense = not intense
    end

    if sc == 'escape' or kc == 'escape' then
        love.event.quit()
    end

end



function love.draw()
    -- Rain
    love.graphics.print('Drops Absorbed: '..math.floor(absorbed), love.graphics.getWidth()/2 - 200, love.graphics.getHeight()/2)
    love.graphics.print('Drops / Second: '..math.floor(absorb_speed), love.graphics.getWidth()/2 - 200, love.graphics.getHeight()/2 + 18)

    love.graphics.draw(mesh, 0, 0, 0, love.graphics.getWidth()/texture:getWidth(), love.graphics.getHeight()/texture:getHeight())
    if intense then
        love.graphics.draw(intensemesh, 0, 0, 0, love.graphics.getWidth()/texture:getWidth(), love.graphics.getHeight()/texture:getHeight())
    end

    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)



    love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, 46)
end