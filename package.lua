return {
    title = "GPIO Menu Display",
    author = "Your Name",
    version = "1.0",
    desc = "Interactive menu controlled by GPIO buttons for selecting playlists/slideshows.",
    setup = {
        title = "GPIO Menu",
        description = "Select slideshows using GPIO buttons",
        config = {
            gpio_power = {
                title = "Power Button GPIO Pin",
                description = "GPIO pin for the power button (BCM numbering)",
                type = "integer",
                default = 18,
                min = 0,
                max = 27
            },
            gpio_up = {
                title = "Up Button GPIO Pin",
                description = "GPIO pin for the up button (BCM numbering)",
                type = "integer",
                default = 23,
                min = 0,
                max = 27
            },
            gpio_down = {
                title = "Down Button GPIO Pin",
                description = "GPIO pin for the down button (BCM numbering)",
                type = "integer",
                default = 22,
                min = 0,
                max = 27
            },
            gpio_menu = {
                title = "Menu Button GPIO Pin",
                description = "GPIO pin for the menu button (BCM numbering)",
                type = "integer",
                default = 4,
                min = 0,
                max = 27
            },
            gpio_select = {
                title = "Select Button GPIO Pin",
                description = "GPIO pin for the select button (BCM numbering)",
                type = "integer",
                default = 24,
                min = 0,
                max = 27
            }
        }
}
