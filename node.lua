local json = require "json"
local gpio = require "gpio"
local font = resource.load_font("Roboto-Bold.ttf")

-- Load menu items from node.json
local settings = {
    menu = {
        items = {
            { id="wedding", label="Wedding fayre" },
            { id="light", label="Serving Times (light mode)" },
            { id="dark", label="Serving Times (dark mode)" },
        }
    }
}

util.data_mapper{
    ["config.json"] = function(raw)
        settings = json.decode(raw)
    end
}

-- Menu state
local selected = 1
local in_menu = true
local running_playlist = nil

-- GPIO Pins
local BUTTONS = {
    POWER  = 18,
    UP     = 23,
    DOWN   = 22,
    MENU   = 4,
    SELECT = 24,
}

-- Button handler
local function handle_button(pin)
    if pin == BUTTONS.UP then
        selected = (selected - 2) % #settings.menu.items + 1

    elseif pin == BUTTONS.DOWN then
        selected = (selected) % #settings.menu.items + 1

    elseif pin == BUTTONS.SELECT then
        in_menu = false
        running_playlist = settings.menu.items[selected].label
        start_playlist(settings.menu.items[selected].id)

    elseif pin == BUTTONS.MENU then
        in_menu = true
        running_playlist = nil

    elseif pin == BUTTONS.POWER then
        log("Shutting down...")
        os.execute("poweroff")
    end
end

-- Setup GPIO
for _, pin in pairs(BUTTONS) do
    gpio.setup(pin, "in", "both")
    gpio.watch(pin, function(value)
        if value == 0 then -- button pressed (active low)
            handle_button(pin)
        end
    end)
end

-- Playlist launcher stub
function start_playlist(id)
    log("Starting playlist: " .. id)
    -- TODO: trigger slideshow/video here
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
