return {
    title = "GPIO Menu Display",
    author = "Your Name",
    version = "1.0",
    desc = "Interactive menu controlled by GPIO buttons for selecting playlists/slideshows.",
    config = {
        { name = "menu_item1_name", type = "string", default = "Wedding fayre", desc = "Name for menu item 1" },
        { name = "menu_item1_content", type = "asset", default = "", desc = "Asset/playlist for Wedding fayre" },
        { name = "menu_item2_name", type = "string", default = "Serving Times (light mode)", desc = "Name for menu item 2" },
        { name = "menu_item2_content", type = "asset", default = "", desc = "Asset/playlist for light mode" },
        { name = "menu_item3_name", type = "string", default = "Serving Times (dark mode)", desc = "Name for menu item 3" },
        { name = "menu_item3_content", type = "asset", default = "", desc = "Asset/playlist for dark mode" },
        { name = "font", type = "font", default = "Roboto-Bold.ttf", desc = "Font for menu text" },
    }
}
