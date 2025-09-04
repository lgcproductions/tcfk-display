gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
util.no_globals()

local font = resource.load_font("Roboto-Bold.ttf")  -- Ensure font is in resources/ or uploaded

-- Menu items
local menu_items = {
    { id = "wedding", label = CONFIG.menu_item1_name or "Wedding fayre" },
    { id = "light", label = CONFIG.menu_item2_name or "Serving Times (light mode)" },
    { id = "dark", label = CONFIG.menu_item3_name or "Serving Times (dark mode)" }
}
local contents = {
    CONFIG.menu_item1_content,
    CONFIG.menu_item2_content,
    CONFIG.menu_item3_content
}
local selected = 1
local in_menu = true
local running_item = nil
local current_content = nil

-- Debug function
local function debug(msg)
    print("DEBUG: " .. msg)
end

-- Handle button actions
local function handle_button(action)
    debug("Handling action: " .. action)
    if in_menu then
        if action == "up" then
            selected = (selected - 2) % #menu_items + 1
        elseif action == "down" then
            selected = selected % #menu_items + 1
        elseif action == "select" then
            in_menu = false
            running_item = menu_items[selected].label
            if contents[selected] and contents[selected] ~= "" then
                current_content = resource.load(contents[selected])
                debug("Loaded content for: " .. running_item)
            else
                debug("No content for: " .. running_item)
            end
        end
    else
        if action == "menu" then
            in_menu = true
            running_item = nil
            current_content = nil
            debug("Returned to menu")
        elseif action == "power" then
            debug("Shutting down")
            sys.shutdown()
        end
    end
end

-- Map GPIO messages
util.data_mapper{
    up = function(state)
        debug("Received up: " .. state)
        if tonumber(state) == 0 then handle_button("up") end
    end,
    down = function(state)
        debug("Received down: " .. state)
        if tonumber(state) == 0 then handle_button("down") end
    end,
    select = function(state)
        debug("Received select: " .. state)
        if tonumber(state) == 0 then handle_button("select") end
    end,
    menu = function(state)
        debug("Received menu: " .. state)
        if tonumber(state) == 0 then handle_button("menu") end
    end,
    power = function(state)
        debug("Received power: " .. state)
        if tonumber(state) == 0 then handle_button("power") end
    end,
}

-- Render loop
function node.render()
    gl.clear(0, 0, 0, 1)  -- Black background
    if in_menu then
        for i, item in ipairs(menu_items) do
            local y = 100 + (i-1)*60
            if i == selected then
                font:write(100, y, "> " .. item.label, 40, 1, 1, 0, 1)  -- Yellow highlight
            else
                font:write(100, y, item.label, 40, 1, 1, 1, 1)  -- White text
            end
        end
    else
        font:write(100, 200, "Playing: " .. (running_item or "None"), 50, 0, 1, 0, 1)  -- Green text
        if current_content then
            current_content:draw(0, 0, NATIVE_WIDTH, NATIVE_HEIGHT)
        end
        font:write(100, 300, "Press MENU to return", 30, 1, 1, 1, 1)  -- White text
    end
end
