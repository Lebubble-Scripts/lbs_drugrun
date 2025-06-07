# lbs_drugrun
lbs_drugrun is a FiveM QBCore script that delivers immersive drug run missions to your server. 

## Features
- Engaging drug running missions
- Seamless integration with the QBCore framework

## Dependencies
- QBCore
- ox_lib

## Installation
1. Place the lbs_drugrun resource folder into your server's resources directory.
2. Add the resource to your server configuration below your framework and ox_lib:
    ```
    ensure qb-core
    ensure ox_lib
    ensure lbs_drugrun <---
    ```
3. Update `shared/config.lua`
    - Edit the configuration file (e.g., config.lua) to adjust mission parameters:
      - Reward values
      - Reward Items
      - Run Locations
      - Ped Locations
      - Drug Run mission types
4. Restart your server and enjoy!

## Usage
- Players can initiate a drug run by interacting with any of the peds across the map.
- Players load boxes into a truck, drive to the delievery point, then deliever boxes to the target ped. 

## Troubleshooting
- Verify that the QBCore framework and all necessary dependencies are properly installed.
- Check your server logs for any error messages related to lbs_drugrun during startup.
- Enable Debug mode to check execution
- Join the Discord to receive assistance with any issues not covered in this readme.


## Support

If you enjoy using lbs_drugrun, consider supporting its development:

- **Buy Me a Coffee**: [Support on Buy Me a Coffee](https://www.buymeacoffee.com/lebubble)
- **Ko-fi**: [Donate on Ko-fi](https://ko-fi.com/lebubble)
- **Tebex**: [Purchase scripts on Tebex](https://lebubble-scripts.tebex.io)