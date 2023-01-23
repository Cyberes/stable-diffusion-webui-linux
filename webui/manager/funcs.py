from pathlib import Path
from typing import Union


def resolve_path(p: Union[str, Path]) -> Path:
    return Path(p).expanduser().absolute().resolve()
