gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local json = require "json"
local font = resource.load_font("Roboto-Bold.ttf")

-- Load menu items from node.json
local settings = {
    menu = {
        items = {
            { id="wedding", label="Wedding fayre" },
            { id="light", label="Serving Times (light mode)" },
            { id="dark", label="Serving Times (dark mode)" }
        }
    }
}

-- Watch for JSON updates in hosted GUI
util.data_mapper{
    ["config.json"] = function(raw)
        settings = json.decode(raw)
    end
}

-- Menu state
local selected = 1
local in_menu = true
local running_playlist = nil

-- Map GPIO pins to actions
local BUTTONS = {
    [18] = "POWER",
    [23] = "UP",
    [22] = "DOWN",
    [4]  = "MENU",
    [24] = "SELECT"
}

-- Handle button events
local function handle_button(action, state)
    if state ~= 0 then return end -- Only act on press (active low)

    if action == "UP" then
        selected = (selected - 2) % #settings.menu.items + 1
    elseif action == "DOWN" then
        selected = (selected) % #settings.menu.items + 1
    elseif action == "SELECT" then
        in_menu = false
        running_playlist = settings.menu.items[selected].label
        start_playlist(settings.menu.items[selected].id)
    elseif action == "MENU" then
        in_menu = true
        running_playlist = nil
    elseif action == "POWER" then
        log("Shutting down...")
        os.execute("poweroff")
    end
end

-- Listen to messages from Python GPIO service
node.event("message", function(msg)
    local pin, state = msg:match("^/gpio:(%d+):(%d+)")
    if pin and state then
        pin = tonumber(pin)
        state = tonumber(state)
        local action = BUTTONS[pin]
        if action then
            handle_button(action, state)
        end
    end
end)

-- Stub for playlist
function start_playlist(id)
    log("Starting playlist: " .. id)
    -- TODO: trigger slideshow/video playback here
end

-- Render loop
function node.render()
    gl.clear(0,0,0,1)

    if in_menu then
        for i, item in ipairs(settings.menu.items) do
            local y = 100 + (i-1)*60
            if i == selected then
                font:write(100, y, "> " .. item.label, 40, 1,1,0,1)
            else
                font:write(100, y, item.label, 40, 1,1,1,1)
            end
        end
    else
        font:write(100, 200, "Playing: " .. running_playlist, 50, 0,1,0,1)
        font:write(100, 300, "Press MENU to return", 30, 1,1,1,1)
    end
end
