"""Mount the onboard MicroSD slot (SPI mode).

Requires MicroPython's sdcard.py helper on the board (official demo
ships one under Python/01-SD/). Format the card as FAT32 first.
"""

import sys

sys.path.insert(0, "/board")
sys.path.insert(0, ".")

try:
    from board.pins import SD_CS, SD_MISO, SD_MOSI, SD_SCK, SD_SPI_ID
except ImportError:
    from pins import SD_CS, SD_MISO, SD_MOSI, SD_SCK, SD_SPI_ID  # type: ignore

import os
from machine import SPI, Pin

import sdcard  # type: ignore


def main() -> None:
    cs = Pin(SD_CS, Pin.OUT)
    spi = SPI(
        SD_SPI_ID,
        baudrate=10_000_000,
        polarity=0,
        phase=0,
        bits=8,
        firstbit=SPI.MSB,
        sck=Pin(SD_SCK),
        mosi=Pin(SD_MOSI),
        miso=Pin(SD_MISO),
    )
    sd = sdcard.SDCard(spi, cs, baudrate=5_000_000)
    os.mount(sd, "/sd")
    print("mounted /sd:", os.listdir("/sd"))


if __name__ == "__main__":
    main()
