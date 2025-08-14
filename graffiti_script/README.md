# Graffiti Script for FiveM (ESX)

This script allows players to spray graffiti on walls in the game world. It features a UI for selecting motifs, persistent graffiti that are saved to the database, and various configuration options. This version has been significantly overhauled to be stable and feature-rich.

## Features

- **Persistent Graffiti:** Graffiti are saved to the database and are visible to all players. They persist through server restarts.
- **Motif Selection UI:** A clean user interface allows players to select a graffiti motif after using a spray can item.
- **Usable Spray Can Items:** The script uses ESX's item system. Players must have a spray can (e.g., `spraycan_red`) in their inventory to spray. Cans are consumed upon use.
- **Shops & Black Market:** The script is designed to work with shops where players can buy standard spray cans and black markets for exclusive colors.
- **Anti-Spam:** Prevents players from spraying graffiti too close to each other. The minimum distance is configurable.
- **High Configurability:** Most settings, including item prices, colors, motifs, and distances, can be easily changed in `config.lua`.

## Requirements

- **ESX:** Built for the ESX framework (tested with es_extended 1.2).
- **oxmysql:** The script uses `oxmysql` for database operations.

## Installation

1.  **Download & Place:** Download the `graffiti_script` folder and place it in your server's `resources` directory.
2.  **Database:** Execute the `sql.sql` file in your database. This will create the `graffiti` table and add all the spray can items to your `items` table.
3.  **Texture Dictionary (`.ytd`):** This script requires a texture dictionary file (`.ytd`) to load the graffiti images.
    - Create a folder named `assets` inside the `graffiti_script` folder.
    - Place your texture dictionary file named `graffiti_textures.ytd` inside the `assets` folder.
    - This `.ytd` file must contain the textures named in `config.lua` (e.g., `graffiti_tribal_sun`).
4.  **Configuration:** Review the `config.lua` file and adjust settings like prices, motifs, and the anti-spam distance to your liking.
5.  **Server CFG:** Add `ensure graffiti_script` to your `server.cfg` file.
6.  **Restart Server:** Restart your FiveM server or start the resource manually.

## How it Works

1.  A player buys a spray can from a shop.
2.  The player uses the spray can from their inventory.
3.  A UI appears, showing the available graffiti motifs (from `config.lua`).
4.  The player selects a motif.
5.  The script performs a raycast to find a wall in front of the player.
6.  If the location is not too close to another graffiti, the decal is placed on the wall and its location is saved to the database.
7.  The graffiti is now visible to all players and will be reloaded on server restart.
