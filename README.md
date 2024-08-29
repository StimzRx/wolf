# StimzRx/wolf

[![Discord](https://img.shields.io/discord/856434175455133727.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.gg/kRGUDHNHt2)
[![Donate button](https://img.shields.io/badge/Donate-Open%20Collective-blue.svg?color=blue)](https://opencollective.com/games-on-whales/donate)

## ATTENTION
This is a slightly modified (and very unofficial) version of the original [games-on-whales/wolf](https://github.com/games-on-whales/wolf) project. Please give them some
love for this outstanding project! Their discord and dontaions are linked above.

### Description
This unofficial fork of Wolf will allow it to use OverlayFS in its steam container/app. This allows all users that connect to Wolf and use Steam to already have the 
games downloaded for them once they log in, and they can immediately play them (if they own the game). This only works if the host computer has downloaded
the game themselves via steam first.

In addition, it is likely each time a new user connects the first time, they will have to go to `Steam Settings` -> `Compatability` tab -> Turn on `Enable Steam Play for all other titles`
and then restart steam. This should persist for that user going forward.
**Warning:**
> If wolf users cant see some games as downloaded or playable this is likely why!**

> **Note:**
> This setup allows games to be shared, however if a user installs a game this will be written into the default location for the host apps folder.
> - The library folder for steamapps must only contain the common folder that has all games files
> - The library folder for the acf must only contain the *.acf files normally found in steamapps

---

## Prerequisites
- A consolidated folder folder, see below

The `/wolf` directory should be structured as follows:
- Note that you do not need to create any directories under temp, the script will handle this

```
/wolf
├── clients
│   └── temp
│       ├── [container_id_1]
│       │   ├── upper
│       │   ├── work
│       │   └── mounted
│       └── [container_id_2]
│           └── ...
└── library
    └── steam
        ├── acf
        │   └── [shared_acf_files]
        └── steam
            └── common
                └── [shared_game_folders]  
---

### Initial Setup
1) Fully follow/complete the [normal install directions](https://games-on-whales.github.io/wolf/stable/user/quickstart.html)
2) Start the **NORMAL** Wolf image at least once before continuing with `docker compose up` and then stop it(with `docker compose down`)

(skipping this step will cause there to be no `/etc/wolf/cfg/config.toml` file to edit later on!)

### Shared Game Library Setup

3) Create the following directories
Make sure to replace the `<YOUR USERNAME HERE>` with your own linux user name.
```
'/home/<YOUR USERNAME HERE>/wolf/clients/temp'
'/home/<YOUR USERNAME HERE>/wolf/library/steam/acf' < Move the existing acf files under steamapps into this folder
'/home/<YOUR USERNAME HERE>/wolf/library/steam/steamapps/common' < Move your existing game folders into here
```

4) Change the wolf's `docker-compose.yml` file on the
```
- `image: ghcr.io/games-on-whales/wolf:stable` >>>> `image: ghcr.io/stimzrx/wolf:stable`
```
5) Edit `/etc/wolf/cfg/config.toml` under the `Steam` app section to look like this:
```
Note under there are some changes you should make in the env settings
PUID : This should match the GID for the ./wolf directory
PGID : This should match the UID for the ./wolf directory
```
Now you need to bind the wolf directories as per the Binds section
```
env = ["PUID=1000","PGID=1000","PROTON_LOG=1","RUN_SWAY=true","GOW_REQUIRED_DEVICES=/dev/input/* /dev/dri/* /dev/nvidia*"]
base_create_json = """
{
  "Entrypoint": ["/overlayfs-entrypoint.sh"],
  "HostConfig": {
    "Binds": [
      "/home/<YOUR USERNAME HERE>/wolf/clients/overlayfs-entrypoint.sh:/overlayfs-entrypoint.sh:ro",
      "/home/<YOUR USERNAME HERE>/wolf/library/steam:/overlayfs/library:ro",
      "/home/<YOUR USERNAME HERE>/wolf/clients/temp:/overlayfs/user:rw"
    ],
  }
```
Make sure to use the directories made in step 3

6) Make a new file at `/etc/wolf/overlayfs-entrypoint.sh` named exactly that and put the `overlayfs-entrypoint.sh` script [found here](https://github.com/StimzRx/wolf/blob/stable/overlayfs-entrypoint.sh) in it.
7) run the command `sudo chmod +x /etc/wolf/overlayfs-entrypoint.sh` to allow execution of the script or it will crash when opening steam
8) Start the now edited `docker-compose.yml` file with `docker compose up -d` and connect/use as normal. You should see the games you have installed on your host
are already installed in the Wolf containers!

## Acknowledgements

- [@Drakulix](https://github.com/Drakulix) for the incredible help given in developing Wolf
- [@zb140](https://github.com/zb140) for the constant help and support in [GOW](https://github.com/games-on-whales/gow)
- [@loki-47-6F-64](https://github.com/loki-47-6F-64) for creating and
  sharing [Sunshine](https://github.com/loki-47-6F-64/sunshine)
- [@ReenigneArcher](https://github.com/ReenigneArcher) for beying the first stargazer of the project and taking care of
  keeping [Sunshine alive](https://github.com/LizardByte/Sunshine)
- All the guys at the [Moonlight](https://moonlight-stream.org/) Discord channel, for the tireless help they provide to
  anyone
