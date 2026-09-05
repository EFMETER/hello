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

    def test_header_has_seventeen_gpios(self) -> None:
        self.assertEqual(len(pins.HEADER_LEFT), 11)
        self.assertEqual(len(pins.HEADER_RIGHT_GPIO) + len(pins.HEADER_RIGHT_POWER), 11)
        self.assertEqual(len(pins.HEADER_GPIO), 17)
        self.assertEqual(len(set(pins.HEADER_GPIO)), 17)
        self.assertEqual(pins.HEADER_LEFT[0], 29)
        self.assertEqual(pins.HEADER_LEFT[-1], 2)
        self.assertEqual(pins.HEADER_RIGHT_GPIO[:2], (1, 0))
        self.assertEqual(pins.HEADER_RIGHT_GPIO[-2:], (6, 7))
        self.assertEqual(pins.HEADER_RIGHT_POWER, ("GND", "3V3", "BAT", "GND", "5V"))

    def test_header_shares_i2c_and_sdio(self) -> None:
        self.assertTrue(pins.HEADER_SHARED_I2C <= set(pins.HEADER_GPIO))
        self.assertTrue(pins.HEADER_SHARED_SDIO <= set(pins.HEADER_GPIO))
        self.assertIn(pins.TOUCH_INT, pins.HEADER_GPIO)
        self.assertNotIn(pins.BAT_ADC, pins.HEADER_GPIO)
        self.assertNotIn(pins.IMU_INT1, pins.HEADER_GPIO)
        self.assertTrue(pins.HEADER_SAFE_GPIO.isdisjoint({4, 6, 7}))
        self.assertTrue({0, 1, 2, 3, 5, 16, 17, 21, 22, 24, 25, 27, 28, 29} <= pins.HEADER_SAFE_GPIO)


if __name__ == "__main__":
    unittest.main()
