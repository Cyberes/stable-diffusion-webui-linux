import argparse
import os
import sys
from pathlib import Path

from funcs import resolve_path

parser = argparse.ArgumentParser()
parser.add_argument('model_storage_dir')
parser.add_argument('repo_dir')
parser.add_argument('--link-novelai-anime-vae', action='store_true')
args = parser.parse_args()

model_storage_dir = resolve_path(args.model_storage_dir)
repo_storage_dir = resolve_path(args.repo_dir)

if not model_storage_dir.exists():
    print('Your model storage directory does not exist:', model_storage_dir)
    sys.exit(1)

webui_root_model_path = Path(repo_storage_dir, 'models')
webui_sd_model_path = Path(webui_root_model_path, 'Stable-diffusion')
webui_hypernetwork_path = Path(webui_root_model_path, 'hypernetworks')
webui_vae_path = Path(webui_root_model_path, 'VAE')


def delete_broken_symlinks(dir):
    deleted = False
    dir = Path(dir)
    for file in dir.iterdir():
        if file.is_symlink() and not file.exists():
            print('Symlink broken, removing:', file)
            file.unlink()
            deleted = True
    if deleted:
        print('')


def create_symlink(source, dest):
    if os.path.isdir(dest):
        dest = Path(dest, os.path.basename(source))
    if not dest.exists():
        os.symlink(source, dest)
    print(source, '->', Path(dest).absolute())


# Check for broken symlinks and remove them
print('Removing broken symlinks...')
delete_broken_symlinks(webui_sd_model_path)
delete_broken_symlinks(webui_hypernetwork_path)
delete_broken_symlinks(webui_vae_path)


def link_ckpts(source_path):
    # Link .ckpt and .safetensor/.st files (recursive)
    print('\nLinking .ckpt and .safetensor/.safetensors/.st files in', source_path)
    source_path = Path(source_path)
    for file in [p for p in source_path.rglob('*') if p.suffix in ['.ckpt', '.safetensor', '.safetensors', '.st']]:
        if Path(file).parent.parts[-1] not in ['hypernetworks', 'vae']:
            if not (webui_sd_model_path / file.name):
                print('New model:', file.name)
            create_symlink(file, webui_sd_model_path)
    # Link config yaml files
    print('\nLinking config .yaml files in', source_path)
    for file in model_storage_dir.glob('*.yaml'):
        create_symlink(file, webui_sd_model_path)


link_ckpts(model_storage_dir)

# Link hypernetworks
print('\nLinking hypernetworks...')
hypernetwork_source_path = Path(model_storage_dir, 'hypernetworks')
if hypernetwork_source_path.is_dir():
    for file in hypernetwork_source_path.iterdir():
        create_symlink(hypernetwork_source_path / file, webui_hypernetwork_path)
else:
    print('Hypernetwork storage directory not found:', hypernetwork_source_path)

# Link VAEs
print('\nLinking VAEs...')
vae_source_path = Path(model_storage_dir, 'vae')
if vae_source_path.is_dir():
    for file in vae_source_path.iterdir():
        create_symlink(vae_source_path / file, webui_vae_path)
else:
    print('VAE storage directory not found:', vae_source_path)

# Link the NovelAI files for each of the NovelAI models
print('\nLinking NovelAI files for each of the NovelAI models...')
for model in model_storage_dir.glob('novelai-*.ckpt'):
    yaml = model.stem + '.yaml'
    if os.path.exists(yaml):
        print('New NovelAI model config:', yaml)
        create_symlink(yaml, webui_sd_model_path)

if args.link_novelai_anime_vae:
    print('\nLinking NovelAI anime VAE...')
    for model in model_storage_dir.glob('novelai-*.ckpt'):
        if (model_storage_dir / 'hypernetworks' / 'animevae.pt').is_file():
            vae = model.stem + '.vae.pt'
            if not os.path.exists(webui_vae_path):
                print(f'Linking NovelAI {vae} and {model}')
            create_symlink(model_storage_dir / 'hypernetworks' / 'animevae.pt', webui_vae_path)
        else:
            print(f'{model_storage_dir}/hypernetworks/animevae.pt not found!')
