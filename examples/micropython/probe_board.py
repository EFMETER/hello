"""First-look probe for RP2350-Touch-AMOLED-1.64.

Reads I2C identities, touch coordinates, IMU WhoAmI, and battery ADC.
Does not touch the QSPI AMOLED — that path needs PIO QSPI + CO5300 init
from the official Waveshare demo or a dedicated driver.
"""

import sys
import time

sys.path.insert(0, "/board")
sys.path.insert(0, ".")

try:
    from board.pins import (
        BAT_ADC,
        BAT_ADC_SCALE,
        I2C_FREQ_HZ,
        I2C_ID,
        I2C_SCL,
        I2C_SDA,
        IMU_CHIP_ID,
        IMU_I2C_ADDRS,
        IMU_WHO_AM_I,
        TOUCH_I2C_ADDR,
        TOUCH_INT,
    )
except ImportError:
    from pins import (  # type: ignore
        BAT_ADC,
        BAT_ADC_SCALE,
        I2C_FREQ_HZ,
        I2C_ID,
        I2C_SCL,
        I2C_SDA,
        IMU_CHIP_ID,
        IMU_I2C_ADDRS,
        IMU_WHO_AM_I,
        TOUCH_I2C_ADDR,
        TOUCH_INT,
    )

from machine import ADC, I2C, Pin


def _read_reg(i2c: I2C, addr: int, reg: int, n: int = 1) -> bytes:
    return i2c.readfrom_mem(addr, reg, n)


def probe_touch(i2c: I2C) -> None:
    try:
        chip = _read_reg(i2c, TOUCH_I2C_ADDR, 0xA0)[0]
    except OSError as exc:
        print("FT3168 @ 0x38: not responding ({})".format(exc))
        return
    print("FT3168 @ 0x38: device id 0x{:02X}, INT=GP{}".format(chip, TOUCH_INT))
    fingers = _read_reg(i2c, TOUCH_I2C_ADDR, 0x02)[0] & 0x0F
    xy = _read_reg(i2c, TOUCH_I2C_ADDR, 0x03, 4)
    x = ((xy[0] & 0x0F) << 8) | xy[1]
    y = ((xy[2] & 0x0F) << 8) | xy[3]
    print("  fingers={}  x={}  y={}".format(fingers, x, y))


def probe_imu(i2c: I2C) -> None:
    for addr in IMU_I2C_ADDRS:
        try:
            who = _read_reg(i2c, addr, IMU_WHO_AM_I)[0]
        except OSError:
            continue
        ok = "ok" if who == IMU_CHIP_ID else "unexpected"
        print("QMI8658 @ 0x{:02X}: WhoAmI=0x{:02X} ({})".format(addr, who, ok))
        return
    print("QMI8658: not found on 0x6A/0x6B")


def probe_battery() -> None:
    adc = ADC(Pin(BAT_ADC))
    raw = adc.read_u16() >> 4  # 16-bit helper → ~12-bit
    volts = raw * 3.3 / 4095.0 * BAT_ADC_SCALE
    print("BAT ADC GP{}: raw={}  ~{:.2f} V (divider x{})".format(BAT_ADC, raw, volts, BAT_ADC_SCALE))


def main() -> None:
    i2c = I2C(I2C_ID, sda=Pin(I2C_SDA), scl=Pin(I2C_SCL), freq=I2C_FREQ_HZ)
    print("I2C scan:", ["0x{:02X}".format(a) for a in i2c.scan()] or "empty")
    probe_touch(i2c)
    probe_imu(i2c)
    probe_battery()
    print("AMOLED is QSPI/PIO — use Waveshare C/Arduino demo to light the panel.")
    time.sleep_ms(10)


if __name__ == "__main__":
    main()
