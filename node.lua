gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
util.no_globals()

local font = resource.load_font("Roboto-Bold.ttf")

-- Menu setup
local menu_items = {
    { id="wedding", label="Wedding fayre" },
    { id="light", label="Serving Times (light mode)" },
    { id="dark", label="Serving Times (dark mode)" }
}
local selected = 1
local in_menu = true
local running_item = nil

-- Handle button actions
local function handle_button(action)
    print("Lua handling action:", action)  -- DEBUG
    if in_menu then
        if action == "UP" then
            selected = (selected - 2) % #menu_items + 1
        elseif action == "DOWN" then
            selected = selected % #menu_items + 1
        elseif action == "SELECT" then
            in_menu = false
            running_item = menu_items[selected].label
        end
    else
        if action == "MENU" then
            in_menu = true
            running_item = nil
        elseif action == "POWER" then
            os.execute("poweroff")
        end
    end
end

-- Map GPIO messages using demo-compatible util.data_mapper
util.data_mapper{
    up = function(state)
        print("Lua received UP:", state)  -- DEBUG
        if tonumber(state) == 0 then handle_button("UP") end
    end,
    down = function(state)
        print("Lua received DOWN:", state)  -- DEBUG
        if tonumber(state) == 0 then handle_button("DOWN") end
    end,
    select = function(state)
        print("Lua received SELECT:", state)  -- DEBUG
        if tonumber(state) == 0 then handle_button("SELECT") end
    end,
    menu = function(state)
        print("Lua received MENU:", state)  -- DEBUG
        if tonumber(state) == 0 then handle_button("MENU") end
    end,
    power = function(state)
        print("Lua received POWER:", state)  -- DEBUG
        if tonumber(state) == 0 then handle_button("POWER") end
    end,
}

-- Render loop
function node.render()
    gl.clear(0,0,0,1) -- black background

    if in_menu then
        for i, item in ipairs(menu_items) do
            local y = 100 + (i-1)*60
            if i == selected then
                font:write(100, y, "> " .. item.label, 40, 1,1,0,1) -- yellow highlight
            else
                font:write(100, y, item.label, 40, 1,1,1,1)
            end
        end
    else
        font:write(100, 200, "Playing: " .. running_item, 50, 0,1,0,1)
        font:write(100, 300, "Press MENU to return", 30, 1,1,1,1)
    end
end
