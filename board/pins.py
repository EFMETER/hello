"""RP2350-Touch-AMOLED-1.64 pin map.

Onboard numbers come from Waveshare's official demo package
(RP2350-Touch-AMOLED-1.64.zip). Header order matches the official
pinout silkscreen (docs/pinout.png).
"""

# Shared I2C1: FT3168 touch + QMI8658 IMU
I2C_ID = 1
I2C_SDA = 6
I2C_SCL = 7
I2C_FREQ_HZ = 400_000

TOUCH_I2C_ADDR = 0x38
TOUCH_INT = 4
TOUCH_RST = None  # not wired on this board

IMU_I2C_ADDRS = (0x6A, 0x6B)
IMU_WHO_AM_I = 0x00
IMU_CHIP_ID = 0x05
IMU_INT1 = 8

# CO5300 AMOLED over PIO QSPI
QSPI_CS = 9
QSPI_SCLK = 10
QSPI_D0 = 11
QSPI_D1 = 12
QSPI_D2 = 13
QSPI_D3 = 14
AMOLED_RST = 15
AMOLED_WIDTH = 280
AMOLED_HEIGHT = 456

# MicroSD, SPI mode (official Python example)
SD_SPI_ID = 0
SD_SCK = 18
SD_MOSI = 19
SD_MISO = 20
SD_CS = 23

# MicroSD, SDIO mode (official FatFs example)
SDIO_CLK = 18
SDIO_CMD = 19
SDIO_D0 = 20
SDIO_D1 = 21
SDIO_D2 = 22
SDIO_D3 = 23

# Battery divider on ADC0. Waveshare LCD demo uses 3.3V * 3 / 4096.
# GP26 is not brought out; GP27–29 on the header are ADC1–3.
BAT_ADC = 26
BAT_ADC_SCALE = 3.0

# Dual 11-pin headers, USB-C at the top, looking at the pin side.
# Left column top → bottom; right column GPIO then power.
HEADER_LEFT = (29, 28, 27, 22, 21, 17, 16, 5, 4, 3, 2)
HEADER_RIGHT_GPIO = (1, 0, 25, 24, 6, 7)
HEADER_RIGHT_POWER = ("GND", "3V3", "BAT", "GND", "5V")
HEADER_GPIO = HEADER_LEFT + HEADER_RIGHT_GPIO

# Header GPIOs that are also wired to onboard chips.
HEADER_SHARED_I2C = frozenset({I2C_SDA, I2C_SCL})  # also FT3168 + QMI8658
HEADER_SHARED_TOUCH_INT = frozenset({TOUCH_INT})
HEADER_SHARED_SDIO = frozenset({SDIO_D1, SDIO_D2})  # free if SD is SPI-only

# GPIOs claimed by onboard peripherals. Do not reuse for jumper wires
# unless you have disconnected that function.
ONBOARD_GPIO = frozenset(
    {
        TOUCH_INT,
        I2C_SDA,
        I2C_SCL,
        IMU_INT1,
        QSPI_CS,
        QSPI_SCLK,
        QSPI_D0,
        QSPI_D1,
        QSPI_D2,
        QSPI_D3,
        AMOLED_RST,
        SD_SCK,
        SD_MOSI,
        SD_MISO,
        SD_CS,
        BAT_ADC,
    }
)

# Comfortable jumper set: display + I2C sensors + SPI SD all in use.
# GP6/7 stay on I2C1 (extra devices OK). GP21/22 OK because SPI SD
# does not use SDIO D1/D2. GP4 is touch INT — leave it alone.
HEADER_SAFE_GPIO = frozenset(HEADER_GPIO) - {
    TOUCH_INT,
    I2C_SDA,
    I2C_SCL,
}
