gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
util.no_globals()

local font = resource.load_font(CONFIG.font or "Roboto-Bold.ttf")

-- Menu items (hardcoded for reliability, editable via CONFIG)
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
            sys.shutdown()  -- Use sys.shutdown() instead of os.execute
        end
    end
end

-- Handle GPIO events
node.event("input", function(topic, payload)
    debug("Received event: " .. topic .. " = " .. payload)
    if topic == "button" then
        handle_button(payload)
    end
end)

-- Render loop
function node.render()
    local bg = util.parse_color(CONFIG.background_color or "#000000")
    local text_color = util.parse_color(CONFIG.text_color or "#FFFFFF")
    gl.clear(bg[1], bg[2], bg[3], bg[4])  -- Clear with config background

    if in_menu then
        for i, item in ipairs(menu_items) do
            local y = 100 + (i-1)*60
            if i == selected then
                font:write(100, y, "> " .. item.label, 40, 1, 1, 0, 1)  -- Yellow highlight
            else
                font:write(100, y, item.label, 40, text_color[1], text_color[2], text_color[3], text_color[4])
            end
        end
    else
        font:write(100, 200, "Playing: " .. (running_item or "None"), 50, 0, 1, 0, 1)  -- Green text
        if current_content then
            current_content:draw(0, 0, NATIVE_WIDTH, NATIVE_HEIGHT)
        end
        font:write(100, 300, "Press MENU to return", 30, text_color[1], text_color[2], text_color[3], text_color[4])
    end
end
