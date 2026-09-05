import unittest

from board import pins


class PinMapTests(unittest.TestCase):
    def test_qspi_is_contiguous(self) -> None:
        self.assertEqual(
            [
                pins.QSPI_CS,
                pins.QSPI_SCLK,
                pins.QSPI_D0,
                pins.QSPI_D1,
                pins.QSPI_D2,
                pins.QSPI_D3,
                pins.AMOLED_RST,
            ],
            [9, 10, 11, 12, 13, 14, 15],
        )

    def test_i2c_and_touch(self) -> None:
        self.assertEqual((pins.I2C_SDA, pins.I2C_SCL, pins.I2C_ID), (6, 7, 1))
        self.assertEqual(pins.TOUCH_I2C_ADDR, 0x38)
        self.assertEqual(pins.TOUCH_INT, 4)
        self.assertIsNone(pins.TOUCH_RST)

    def test_sd_spi_matches_sdio_base(self) -> None:
        self.assertEqual((pins.SD_SCK, pins.SD_MOSI, pins.SD_MISO, pins.SD_CS), (18, 19, 20, 23))
        self.assertEqual(pins.SDIO_CLK, pins.SD_SCK)
        self.assertEqual(pins.SDIO_CMD, pins.SD_MOSI)
        self.assertEqual(pins.SDIO_D0, pins.SD_MISO)
        self.assertEqual(pins.SDIO_D3, pins.SD_CS)

    def test_onboard_pins_are_unique(self) -> None:
        self.assertEqual(len(pins.ONBOARD_GPIO), len(set(pins.ONBOARD_GPIO)))
        self.assertIn(pins.BAT_ADC, pins.ONBOARD_GPIO)
        self.assertTrue(max(pins.ONBOARD_GPIO) <= 29)

    def test_display_size(self) -> None:
        self.assertEqual((pins.AMOLED_WIDTH, pins.AMOLED_HEIGHT), (280, 456))


if __name__ == "__main__":
    unittest.main()
