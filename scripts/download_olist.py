"""Download the Olist Brazilian E-commerce dataset from Kaggle into ./data."""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

DATASET = "olistbr/brazilian-ecommerce"
DATA_DIR = Path(__file__).resolve().parent.parent / "data"


def main() -> int:
    if not (os.environ.get("KAGGLE_USERNAME") and os.environ.get("KAGGLE_KEY")):
        print(
            "ERROR: set KAGGLE_USERNAME and KAGGLE_KEY in your environment.\n"
            "       Get them from https://www.kaggle.com/settings → API.",
            file=sys.stderr,
        )
        return 1

    DATA_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Downloading {DATASET} into {DATA_DIR} ...")
    subprocess.run(
        ["kaggle", "datasets", "download", "-d", DATASET, "-p", str(DATA_DIR), "--unzip"],
        check=True,
    )
    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
