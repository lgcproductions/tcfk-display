#!/usr/bin/python
from hosted import device, node, config

# Pins to monitor
PINS = {
    "POWER": 18,
    "UP": 23,
    "DOWN": 22,
    "MENU": 4,
    "SELECT": 24
}

config.restart_on_update()
device.gpio.monitor(list(PINS.values()))

for pin, state in device.gpio.poll_forever():
    # Send Lua message like /gpio:PIN:STATE
    node.send('/gpio:%d:%d' % (pin, state))
