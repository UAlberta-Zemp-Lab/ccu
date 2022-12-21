# CCU Firmware

The CCU facilitates communication between the main PC/Verasonics Vantage
System and the πCards. It has two onboard Teesny 4.0s. The main control
Teensy is referred to by the board's namesake `ccu`. The second, referred
to as `sig-gen`, controls the off board power supplies and handles
synchronization signals between all system components.

## Building

This project uses [platformio](https://platformio.org/) for building
and installing. To build the project run:

```
pio run
```

Note that this will only build the default env (`ccu`). To build other
envs specify the `-e` option as in `pio run -e [env]`.

## Flashing
To flash the a board use the `upload` target:

```
pio run --target upload
```
