/*
 * FRAM_MB85RS_SPI.h
 *
 *  Created on: Feb 25, 2021
 *      Author: d
 */

#ifndef BSP_FRAM_MB85RS_SPI_H_
#define BSP_FRAM_MB85RS_SPI_H_




#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32wbxx_hal.h"
#include  "stdbool.h"
//#include <math.h>


// IDs - can be extends to any other compatible chip
#define FUJITSU_ID 0x04

// Density codes gives the memory's adressing scheme
#define DENSITY_MB85RS64V  0x03	// 64K
#define DENSITY_MB85RS128B 0x04	// 128K
#define DENSITY_MB85RS256B 0x05	// 256K
#define DENSITY_MB85RS512T 0x06	// 512K
#define DENSITY_MB85RS1MT  0x07	// 1M
#define DENSITY_MB85RS2MT  0x08	// 2M

// OP-CODES
#define FRAM_WRSR  0x01 // 0000 0001 - Write Status Register
#define FRAM_WRITE 0x02 // 0000 0010 - Write Memory
#define FRAM_READ  0x03 // 0000 0011 - Read Memory
#define FRAM_WRDI  0x04 // 0000 0100 - Reset Write Enable Latch
#define FRAM_RDSR  0x05 // 0000 0101 - Read Status Register
#define FRAM_WREN  0x06 // 0000 0110 - Set Write Enable Latch
#define FRAM_FSTRD 0x0B // 0000 1011 - Fast Read
#define FRAM_RDID  0x9F // 1001 1111 - Read Device ID
#define FRAM_SLEEP 0xB9 // 1011 1001 - Sleep mode


// Managing Write protect pin
// false means protection off, write enabled
#define DEFAULT_WP_STATUS false


class FRAM_MB85RS_SPI
{
 public:
    FRAM_MB85RS_SPI(uint16_t cs, SPI_HandleTypeDef *hspi);
    FRAM_MB85RS_SPI(uint16_t cs, uint8_t wp, SPI_HandleTypeDef *hspi);
   ~FRAM_MB85RS_SPI();



    void	init();
    bool	checkDevice();


    bool	read(uint32_t framAddr, uint8_t *value);
    bool	read(uint32_t framAddr, uint16_t *value);
    bool	read(uint32_t framAddr, uint32_t *value);
    bool	write(uint32_t framAddr, uint8_t value);
    bool	write(uint32_t framAddr, uint16_t value);
    bool	write(uint32_t framAddr, uint32_t value);

    bool readArray(uint32_t startAddr, uint8_t values[], size_t nbItems );
    bool readArray(uint32_t startAddr, uint16_t values[], size_t nbItems );
    bool writeArray(uint32_t startAddr, uint8_t values[], size_t nbItems );
    bool writeArray(uint32_t startAddr, uint16_t values[], size_t nbItems );

    bool	isAvailable();
    bool	getWPStatus();
    bool	enableWP();
    bool	disableWP();
    bool	eraseChip();
    uint32_t getMaxMemAdr();
    uint32_t getLastMemAdr();


 private:
    SPI_HandleTypeDef *_hspi;
    bool		_framInitialised;
    uint16_t     _cs;            // CS pin
    bool     _wp;            // WP management
    uint8_t     _wpPin;         // WP pin connected and Write Protection enabled
    bool     _wpStatus;      // WP Status
    uint8_t     _manufacturer;  // Manufacturer ID
    uint16_t	_productID;     // Product ID
    uint8_t     _densitycode;   // Code which represent the size of the chip
    uint16_t	_density;       // Human readable size of F-RAM chip
    uint32_t	_maxaddress;    // Maximum address suported by F-RAM chip
    uint32_t    _lastaddress;   // Last address used in memory

    void        _csCONFIG();
    void        _csASSERT();
    void        _csRELEASE();
    bool     _getDeviceID();
    bool     _deviceID2Serial();
    void        _setMemAddr(uint32_t *framAddr);
};

#ifdef __cplusplus
}
#endif

#endif /* BSP_FRAM_MB85RS_SPI_H_ */
