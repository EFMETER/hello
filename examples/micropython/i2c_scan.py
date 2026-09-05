"""Scan the onboard I2C1 bus.

Expect:
  0x38  FT3168 capacitive touch
  0x6A or 0x6B  QMI8658 IMU
"""

import sys

sys.path.insert(0, "/board")
sys.path.insert(0, ".")

try:
    from board.pins import I2C_FREQ_HZ, I2C_ID, I2C_SCL, I2C_SDA
except ImportError:
    from pins import I2C_FREQ_HZ, I2C_ID, I2C_SCL, I2C_SDA  # type: ignore

from machine import I2C, Pin


def main() -> None:
    i2c = I2C(I2C_ID, sda=Pin(I2C_SDA), scl=Pin(I2C_SCL), freq=I2C_FREQ_HZ)
    found = list(i2c.scan())
    print("I2C1 SDA=GP{} SCL=GP{}".format(I2C_SDA, I2C_SCL))
    if not found:
        print("no devices — check 3V3, firmware, and that you are on this board")
        return
    names = {
        0x38: "FT3168 touch",
        0x6A: "QMI8658 IMU (SA0 low)",
        0x6B: "QMI8658 IMU (SA0 high)",
    }
    for addr in found:
        print("  0x{:02X}  {}".format(addr, names.get(addr, "unknown")))


if __name__ == "__main__":
    main()
