/* RP2350-Touch-AMOLED-1.64 pin map
 *
 * Sourced from Waveshare RP2350-Touch-AMOLED-1.64.zip
 * (DEV_Config.h, qspi_pio.h, FatFs hw_config.c, Python boot.py).
 */
#pragma once

#define WS164_I2C_PORT i2c1
#define WS164_I2C_SDA 6
#define WS164_I2C_SCL 7
#define WS164_I2C_FREQ_HZ 400000

#define WS164_TOUCH_ADDR 0x38
#define WS164_TOUCH_INT 4

#define WS164_IMU_ADDR_L 0x6A
#define WS164_IMU_ADDR_H 0x6B
#define WS164_IMU_INT1 8

#define WS164_QSPI_CS 9
#define WS164_QSPI_SCLK 10
#define WS164_QSPI_D0 11
#define WS164_QSPI_D1 12
#define WS164_QSPI_D2 13
#define WS164_QSPI_D3 14
#define WS164_AMOLED_RST 15
#define WS164_AMOLED_WIDTH 280
#define WS164_AMOLED_HEIGHT 456

#define WS164_SD_SPI spi0
#define WS164_SD_SCK 18
#define WS164_SD_MOSI 19
#define WS164_SD_MISO 20
#define WS164_SD_CS 23

#define WS164_SDIO_CLK 18
#define WS164_SDIO_CMD 19
#define WS164_SDIO_D0 20
#define WS164_SDIO_D1 21
#define WS164_SDIO_D2 22
#define WS164_SDIO_D3 23

#define WS164_BAT_ADC 26
#define WS164_BAT_ADC_SCALE 3.0f
