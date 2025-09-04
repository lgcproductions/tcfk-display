util.no_globals()

local menu_items = {
    CONFIG.menu_item1_name,
    CONFIG.menu_item2_name,
    CONFIG.menu_item3_name
}
local contents = {
    CONFIG.menu_item1_content,
    CONFIG.menu_item2_content,
    CONFIG.menu_item3_content
}
local current_index = 1
local in_menu = true
local current_content = nil

local font = resource.load_font(CONFIG.font)
local bg_color = util.parse_color(CONFIG.background_color)
local text_color = util.parse_color(CONFIG.text_color)

node.event("input", function(topic, payload)
    if topic == "button" then
        if payload == "up" and in_menu then
            current_index = (current_index - 2) % #menu_items + 1
        elseif payload == "down" and in_menu then
            current_index = (current_index % #menu_items) + 1
        elseif payload == "select" and in_menu then
            in_menu = false
            current_content = resource.load(contents[current_index])
        elseif payload == "menu" then
            in_menu = true
            current_content = nil
        elseif payload == "power" then
            sys.shutdown()
        end
    end
end)

function node.render()
    gl.clear(bg_color[1], bg_color[2], bg_color[3], bg_color[4])
    
    if in_menu then
        -- Draw menu
        for i, item in ipairs(menu_items) do
            local y = 100 + (i-1) * 100
            if i == current_index then
                resource.create_colored_texture(0.5, 0.5, 0.5, 1):draw(100, y-20, WIDTH-100, y+20)
            end
            font:write(120, y, item, 40, text_color[1], text_color[2], text_color[3], text_color[4])
        end
    elseif current_content then
        -- Play selected content (e.g., slideshow or playlist)
        current_content:draw(0, 0, WIDTH, HEIGHT)
    end
end
