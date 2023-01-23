# stable-diffusion-webui-linux
*Super basic scripts to get you set up on Linux.*



I needed to run the WebUI on my Linux server so I whipped up these quick-n-dirty scripts to streamline the process. I basically took the [stable-diffusion-paperspace](https://github.com/Engineer-of-Stuff/stable-diffusion-paperspace) repository and converted it to Bash. I'm sharing this as the "Linux version" of the notebook. Have fun.



## Install

I expect you to pretty much have your environment already set up.

```bash
./install.sh <path to where you want to clone the WebUI to>
```

The installer will create a Python Venv and run the WebUI installer.

Some helper scripts will also be copied to the WebUI folder:

- `start.sh` to launch the WebUI.
- `export.sh` to export your generations.
- `launch-config.sh` to set your options.

If you need to build Xformers, use `./xformers.sh <path to your WebUI>`



## Use

Make sure to `launch-config.sh` before you launch the WebUI. Then do:

```bash
./start.sh
```

