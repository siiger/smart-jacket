/*
 * FRAM_MB85RS_SPI.cpp
 *
 *  Created on: Feb 25, 2021
 *      Author: d
 */

#include <FRAM_MB85RS_SPI.h>
#include <cmath>

//#include "main.h"

/*========================================================================*/
/*                            CONSTRUCTORS                                */
/*========================================================================*/


/*!
///     @brief   FRAM_MB85RS_SPI()
///              Constructor without write protection management
///     @param   cs, chip select pin - active low
**/
FRAM_MB85RS_SPI::FRAM_MB85RS_SPI(uint16_t cs, SPI_HandleTypeDef *hspi){
    _cs = cs;
    _hspi = hspi;
    _wp = false; // No WP pin connected, WP management inactive

    //_csCONFIG();
    _csRELEASE();
    //HAL_Delay(50);
    _framInitialised = false;
}



/*!
///     @brief   FRAM_MB85RS_SPI()
///              Constructor with write protection pin
///     @param   cs, chip select pin - active low
///     @param   wp, write protected pin - active low
**/
FRAM_MB85RS_SPI::FRAM_MB85RS_SPI(uint16_t cs, uint8_t wp, SPI_HandleTypeDef *hspi){
    _cs = cs;
    _hspi = hspi;

    _wp = true; // WP pin connected and Write Protection enabled
    _wpPin = wp;

    // The init WP management status is define under DEFAULT_WP_STATUS
    DEFAULT_WP_STATUS ? enableWP() : disableWP();

    //_csCONFIG();
    _csRELEASE();
    HAL_Delay(50);

    _framInitialised = false;
}

FRAM_MB85RS_SPI::~FRAM_MB85RS_SPI() {
	// TODO Auto-generated destructor stub
}



/*========================================================================*/
/*                           PUBLIC FUNCTIONS                             */
/*========================================================================*/


/*!
///     @brief   init()
///              Inititalize the F-RAM chip
///     @return  if DEBUG_TRACE, provides all the informations on the chip
**/
void FRAM_MB85RS_SPI::init()
{

    bool deviceFound = checkDevice();

    if (deviceFound)
    {
        //Serial.println("Memory Chip initialized");
        _deviceID2Serial();
    }
    else{
    	//Serial.println("ERROR : Memory Chip NOT FOUND\n");
    }

}
/*!
///     @brief   checkDevice()
///              Check if the device is connected
///     @return  0: device not found
///              1: device connected
**/
bool FRAM_MB85RS_SPI::checkDevice()
{
	bool result = _getDeviceID();

	if (result && _manufacturer == FUJITSU_ID && _maxaddress != 0)
    {
		_framInitialised = true;
        return true;
	}

    _framInitialised = false;
    return false;
}



/*!
///     @brief   read()
///              Read a 8-bits value to the specified F-RAM address
///     @param   framAddr, the memory address on 32-bits
///     @param   value, the 8-bits value to read
///     @return  0: error
///              1: ok
**/
bool FRAM_MB85RS_SPI::read( uint32_t framAddr, uint8_t *value )
{
    if (framAddr >= _maxaddress || !_framInitialised)
        return false;

//#ifdef DEBUG_TRACE
//    Serial.print("Read address : ");
//    Serial.println(framAddr, BIN);
//#endif
    uint8_t spiCMD;

    _csASSERT();
        // Read byte operation
        spiCMD = FRAM_READ;
        HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
        _setMemAddr(&framAddr);
        // Read value
        HAL_SPI_Receive(_hspi, value, sizeof(*value), HAL_MAX_DELAY);
    _csRELEASE();

    _lastaddress = framAddr+1;

    return true;
}



/*!
///     @brief   read()
///              Read a 16-bits value to the specified F-RAM address
///     @param   framAddr, the memory address on 32-bits
///     @param   value, the 16-bits value to read
///     @return  0: error
///              1: ok
**/
bool FRAM_MB85RS_SPI::read( uint32_t framAddr, uint16_t *value )
{
    if (framAddr >= _maxaddress || !_framInitialised)
        return false;

    uint8_t buffer[2];
    uint8_t spiCMD;

    _csASSERT();
            // Read byte operation
            spiCMD = FRAM_READ;
            HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
        _setMemAddr(&framAddr);
        // Read value
        HAL_SPI_Receive(_hspi, &buffer[0], sizeof(buffer[0]), HAL_MAX_DELAY);
        HAL_SPI_Receive(_hspi, &buffer[1], sizeof(buffer[1]), HAL_MAX_DELAY);
    _csRELEASE();

    *value = ((uint16_t) buffer[1] << 8) + (uint16_t)buffer[0];

    _lastaddress = framAddr+2;

    return true;
}



/*!
///     @brief   read()
///              Read a 32-bits value to the specified F-RAM address
///     @param   framAddr, the memory address on 32-bits
///     @param   value, the 32-bits value to read
///     @return  0: error
///              1: ok
**/
bool FRAM_MB85RS_SPI::read( uint32_t framAddr, uint32_t *value )
{
    if (framAddr >= _maxaddress || !_framInitialised)
        return false;

    uint8_t buffer[4];
    uint8_t spiCMD;

    _csASSERT();
                  // Read byte operation
                  spiCMD = FRAM_READ;
                  HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
              _setMemAddr(&framAddr);
              // Read value
              HAL_SPI_Receive(_hspi, &buffer[0], sizeof(buffer[0]), HAL_MAX_DELAY);
              HAL_SPI_Receive(_hspi, &buffer[1], sizeof(buffer[1]), HAL_MAX_DELAY);
              HAL_SPI_Receive(_hspi, &buffer[2], sizeof(buffer[2]), HAL_MAX_DELAY);
              HAL_SPI_Receive(_hspi, &buffer[3], sizeof(buffer[3]), HAL_MAX_DELAY);
    _csRELEASE();

    *value = ( (uint32_t)buffer[2] << 16) + ((uint32_t)buffer[1] << 8) + (uint32_t)buffer[0];

    _lastaddress = framAddr+4;

    return true;
}



/*!
///     @brief   write()
///              Write a 8-bits value to the specified F-RAM address
///     @param   framAddr, the memory address on 32-bits
///     @param   value, the 8-bits value to write
///     @return  0: error
///              1: ok
**/
bool FRAM_MB85RS_SPI::write( uint32_t framAddr, uint8_t value )
{
    if (value > 0xFF || framAddr >= _maxaddress || !_framInitialised)
        return false;


    uint8_t spiCMD;
    // Set Memory Write Enable Latch, otherwise no Write can be achieve
    _csASSERT();
        spiCMD = FRAM_WREN;
        HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
    _csRELEASE();

    // Write byte operation
    _csASSERT();
        spiCMD = FRAM_WRITE;
        HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
        _setMemAddr(&framAddr);
        // Write value
        HAL_SPI_Transmit(_hspi, &value, sizeof(value), HAL_MAX_DELAY);
    _csRELEASE();

    // Reset Memory Write Enable Latch
    _csASSERT();
    spiCMD =FRAM_WRDI;
    HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
    _csRELEASE();

    _lastaddress = framAddr+1;
	return true;
}



/*!
///     @brief   write()
///              Write a 16-bits value to the specified F-RAM address
///     @param   framAddr, the memory address on 32-bits
///     @param   value, the 16-bits value to write
///     @return  0: error
///              1: ok
**/
bool FRAM_MB85RS_SPI::write( uint32_t framAddr, uint16_t value )
{
    if (value > 0xFFFF || framAddr >= _maxaddress || !_framInitialised)
        return false;

    uint8_t buffer[2];
    buffer[0] = (value & 0xFF);
    buffer[1] =((value >> 8) & 0xFF);
    uint8_t spiCMD;
    // Set Memory Write Enable Latch, otherwise no Write can be achieve
    _csASSERT();
         spiCMD = FRAM_WREN;
         HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
    _csRELEASE();

    // Write byte operation
    _csASSERT();
    spiCMD = FRAM_WRITE;
           HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
           _setMemAddr(&framAddr);
           // Write value
           HAL_SPI_Transmit(_hspi, &buffer[0], sizeof(buffer[0]), HAL_MAX_DELAY);
           HAL_SPI_Transmit(_hspi, &buffer[1], sizeof(buffer[1]), HAL_MAX_DELAY);
    _csRELEASE();

    // Reset Memory Write Enable Latch
    _csASSERT();
    spiCMD =FRAM_WRDI;
        HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
    _csRELEASE();

    _lastaddress = framAddr+2;

    return true;
}



/*!
///     @brief   write()
///              Write a 32-bits value to the specified F-RAM address
///     @param   framAddr, the memory address on 32-bits
///     @param   value, the 32-bits value to write
///     @return  0: error
///              1: ok
**/
bool FRAM_MB85RS_SPI::write( uint32_t framAddr, uint32_t value )
{
    if (value > 0xFFFFFFFF || framAddr >= _maxaddress || !_framInitialised)
        return false;

    uint8_t buffer[4];
       buffer[0] = (value & 0xFF);
       buffer[1] = (value & 0xFFFF) >> 8;
       buffer[2] = (value & 0xFFFFFF) >> 16;
       buffer[3] =  value >> 24;
       uint8_t spiCMD;
    // Set Memory Write Enable Latch, otherwise no Write can be achieve
       _csASSERT();
               spiCMD = FRAM_WREN;
               HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
          _csRELEASE();

          // Write byte operation
          _csASSERT();
          spiCMD = FRAM_WRITE;
                 HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
                 _setMemAddr(&framAddr);
                 // Write value
                 HAL_SPI_Transmit(_hspi, &buffer[0], sizeof(buffer[0]), HAL_MAX_DELAY);
                 HAL_SPI_Transmit(_hspi, &buffer[1], sizeof(buffer[1]), HAL_MAX_DELAY);
                 HAL_SPI_Transmit(_hspi, &buffer[2], sizeof(buffer[2]), HAL_MAX_DELAY);
                 HAL_SPI_Transmit(_hspi, &buffer[3], sizeof(buffer[3]), HAL_MAX_DELAY);
          _csRELEASE();

          // Reset Memory Write Enable Latch
          _csASSERT();
          spiCMD =FRAM_WRDI;
              HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
          _csRELEASE();

    _lastaddress = framAddr+4;

    return true;
}



/*!
///     @brief   readArray()
///              Read an array made of 8-bits values from the specified F-RAM address
///     @param   framAddr, the memory address to read from
///     @param   values[], the array of 8-bits value to read
///     @param   nb, the number of elements to read
///     @return  0: error
///              1: ok
///     @note    F-RAM provide a continuous reading with auto-increment of the address
**/
bool FRAM_MB85RS_SPI::readArray( uint32_t startAddr, uint8_t values[], size_t nbItems )
{
    if ( startAddr >= _maxaddress
        || ((startAddr + nbItems - 1) >= _maxaddress)
        || nbItems == 0
        || !_framInitialised )
        return false;

    uint8_t spiCMD;

    _csASSERT();
    // Read byte operation
    spiCMD = FRAM_READ;
    HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
    _setMemAddr(&startAddr);

    // Read values
    for (uint32_t i = 0; i < nbItems; i++)
    {
        HAL_SPI_Receive(_hspi, &values[i], sizeof(values[i]), HAL_MAX_DELAY);
#ifdef DEBUG_TRACE
        //Serial.print("Adr 0x"); Serial.print(startAddr+i, HEX);
        //Serial.print(", Value[");Serial.print(i); Serial.print("] = 0x"); Serial.println(values[i], HEX);
#endif
    }

    _csRELEASE();



    _lastaddress = startAddr + nbItems - 1;

    return true;
}



/*!
 ///     @brief   readArray()
 ///              Read an array made of 16-bits values from the specified F-RAM address
 ///     @param   framAddr, the memory address to read from
 ///     @param   values[], the array of 16-bits value to read
 ///     @param   nb, the number of elements to read
 ///     @return  0: error
 ///              1: ok
 ///     @note    F-RAM provide a continuous reading with auto-increment of the address
 **/
bool FRAM_MB85RS_SPI::readArray( uint32_t startAddr, uint16_t values[], size_t nbItems )
{
    if ( startAddr >= _maxaddress
        || ((startAddr + (nbItems*2) - 2) >= _maxaddress)
        || nbItems == 0
        || !_framInitialised )
        return false;

    uint8_t spiCMD;


       _csASSERT();
        // Read byte operation
        spiCMD = FRAM_READ;
        HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
        _setMemAddr(&startAddr);

        // Read values
        for (uint32_t i = 0; i < nbItems; i++)
        {   uint8_t buffer[2];
        	HAL_SPI_Receive(_hspi, &buffer[0], sizeof(buffer[0]), HAL_MAX_DELAY);
        	HAL_SPI_Receive(_hspi, &buffer[1], sizeof(buffer[1]), HAL_MAX_DELAY);
            values[i] = ((uint16_t) buffer[1] << 8) + (uint16_t)buffer[0];

#ifdef DEBUG_TRACE
            //Serial.print("Adr 0x"); Serial.print(startAddr+(i*2), HEX);
            //Serial.print(", Value[");Serial.print(i); Serial.print("] = 0x"); Serial.println(values[i], HEX);
#endif
        }
    _csRELEASE();

    _lastaddress = startAddr + (nbItems*2) - 2;

    return true;
}



/*!
///     @brief   writeArray()
///              Write an array made of 8-bits values from the specified F-RAM address
///     @param   framAddr, the memory address to write from
///     @param   values[], the array of 8-bits value to write
///     @param   nb, the number of elements to write
///     @return  0: error
///              1: ok
///     @note    F-RAM provide a continuous writing with auto-increment of the address
**/
bool FRAM_MB85RS_SPI::writeArray( uint32_t startAddr, uint8_t values[], size_t nbItems )
{
    if ( startAddr >= _maxaddress
        || ((startAddr + nbItems - 1) >= _maxaddress)
        || nbItems == 0
        || !_framInitialised )
        return false;

    uint8_t spiCMD;
       // Set Memory Write Enable Latch, otherwise no Write can be achieve
          _csASSERT();
            spiCMD = FRAM_WREN;
            HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
         _csRELEASE();

    // Write byte operation
    _csASSERT();
           spiCMD = FRAM_WRITE;
           HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
         _setMemAddr(&startAddr);
        // Write values
        for (uint32_t i = 0; i < nbItems; i++)
        	HAL_SPI_Transmit(_hspi, &values[i], sizeof(values[i]), HAL_MAX_DELAY);
    _csRELEASE();

    // Reset Memory Write Enable Latch
    _csASSERT();
          spiCMD =FRAM_WRDI;
          HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
    _csRELEASE();

    _lastaddress = startAddr + nbItems - 1;

    return true;
}



/*!
 ///     @brief   writeArray()
 ///              Write an array made of 16-bits values from the specified F-RAM address
 ///     @param   framAddr, the memory address to write from
 ///     @param   values[], the array of 16-bits value to write
 ///     @param   nb, the number of elements to write
 ///     @return  0: error
 ///              1: ok
 ///     @note    F-RAM provide a continuous writing with auto-increment of the address
 **/
bool FRAM_MB85RS_SPI::writeArray( uint32_t startAddr, uint16_t values[], size_t nbItems )
{
    if ( startAddr >= _maxaddress
        || ((startAddr + (nbItems*2) - 2) >= _maxaddress)
        || nbItems == 0
        || !_framInitialised )
        return false;


        uint8_t spiCMD;
           // Set Memory Write Enable Latch, otherwise no Write can be achieve
         _csASSERT();
           spiCMD = FRAM_WREN;
           HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
        _csRELEASE();

    // Write byte operation
    _csASSERT();
          spiCMD = FRAM_WRITE;
          HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
        _setMemAddr(&startAddr);

        // Write values
        for (uint32_t i = 0; i < nbItems; i++)
        {
           uint8_t buffer[2];
           buffer[0] = (values[i] & 0xFF);
           buffer[1] =((values[i] >> 8) & 0xFF);
           HAL_SPI_Transmit(_hspi, &buffer[0], sizeof(buffer[0]), HAL_MAX_DELAY);
           HAL_SPI_Transmit(_hspi, &buffer[1], sizeof(buffer[1]), HAL_MAX_DELAY);
        }
    _csRELEASE();

    // Reset Memory Write Enable Latch
    _csASSERT();
           spiCMD =FRAM_WRDI;
           HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
    _csRELEASE();

    _lastaddress = startAddr + (nbItems*2) - 2;

    return true;
}



/*!
///    @brief   isAvailable()
///             Returns the readiness of the memory chip
///    @return  0: ready
///             1: unavailable
**/
bool FRAM_MB85RS_SPI::isAvailable()
{
	if ( _framInitialised && HAL_GPIO_ReadPin(GPIOB,_cs) == GPIO_PIN_SET )
        return true;

    return false;
}



/*!
///    @brief   getWPStatus()
///             Returns the Write Protect status
///    @return  0: WP is disable
///             1: WP is enable
**/
bool FRAM_MB85RS_SPI::getWPStatus()
{
	return _wpStatus;
}



/*!
///    @brief   enableWP()
///             Enable write protect function of the chip by pulling up WP pin
///    @return  0: error, WP is not managed
///             1: success, WP is enable
**/
bool FRAM_MB85RS_SPI::enableWP(void)
{
	if (_wp)
    {
		HAL_GPIO_WritePin(GPIOB,_wpPin,GPIO_PIN_SET);
		_wpStatus = true;
        return true;
	}

    return false;
}



/*!
///    @brief   disableWP()
///             Disable write protect function of the chip by pulling down WP pin
///    @return  0: error, WP is not managed
///             1: success, WP is disable
**/
bool FRAM_MB85RS_SPI::disableWP()
{
	if (_wp)
    {
		HAL_GPIO_WritePin(GPIOB,_wpPin,GPIO_PIN_RESET);
		_wpStatus = false;
        return true;
	}

    return false;
}


/*!
///    @brief   eraseChip()
///             Erase chip by overwriting it to 0x00
///             Output on Serial if active
///    @return  0: error
///             1: ok
**/
bool FRAM_MB85RS_SPI::eraseChip()
{
    if ( !_framInitialised )
        return false;

    uint32_t i = 0;
    bool result = true;

    #ifdef DEBUG_TRACE
        //Serial.println("Start erasing device");
    #endif

    while( i < _maxaddress && result )
        result = write(i++, (uint8_t)0);

    #ifdef DEBUG_TRACE
        if ( !result )
        {
            //Serial.print("ERROR: Device erasing stopped at position ");
            //Serial.println(i-1, DEC);
        } else
            //Serial.print("Erased from address 0x00 to 0x"); Serial.println(i-1, HEX);
            //Serial.println("Device erased!");
    #endif

    _lastaddress = _maxaddress;

    return result;
}


/*!
///    @brief   getMaxMemAdr()
///             Return the maximum memory address available
///    @return  _maxaddress
**/
uint32_t FRAM_MB85RS_SPI::getMaxMemAdr()
{
    return _maxaddress;
}



/*!
 ///    @brief   getLastMemAdr()
 ///             Return the last memory address writen or read
 ///    @return  _lastaddress
 **/
uint32_t FRAM_MB85RS_SPI::getLastMemAdr()
{
#ifdef DEBUG_TRACE
    //Serial.print("Last address used in memory: 0x");
    //Serial.println(_lastaddress, HEX);
#endif
    return _lastaddress;
}




/*========================================================================*/
/*                           PRIVATE FUNCTIONS                            */
/*========================================================================*/


/*!
///     @brief   _csCONFIG()
///              initialize the chip select line
**/
/*
 void FRAM_MB85RS_SPI::_csCONFIG()
{
    pinMode(_cs, OUTPUT);
}
*/



/*!
///     @brief   _csASSERT()
///              initialize SPI transactionnal mode and set the chip select
///              line as active for data transmission/reception
**/
void FRAM_MB85RS_SPI::_csASSERT()
{
	HAL_GPIO_WritePin(GPIOB, _cs, GPIO_PIN_RESET);

}



/*!
///     @brief   _csRELEASE(), ends SPI transactionnal mode
///              and set the chip select line inactive
**/
void FRAM_MB85RS_SPI::_csRELEASE()
{
	HAL_GPIO_WritePin(GPIOB, _cs, GPIO_PIN_SET);
}



/*!
///     @brief   _getDeviceID()
///              Reads the Manufacturer ID and the Product ID and populate
///              class' variables for devices supporting that feature.
///              _manufacturerID: The 8-bit manufacturer ID (Fujitsu = 0x04)
///              _productID: seems useless
///              _densitycode: Memory density (bytes 5..0)
///                            from 0x03 (64K chip) to 0x08 (2M chip)
///              _density: Human readable memory density, from 64 to 1024K
///              _maxaddress: The memory max address of storage slot
///     @return  0: error
///              1: ok
**/
bool FRAM_MB85RS_SPI::_getDeviceID()
{
	uint8_t buffer[3] = { 0, 0, 0 };
	uint8_t spiCMD;
    _csASSERT();

    spiCMD = FRAM_RDID;
    HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
    HAL_SPI_Receive(_hspi, &_manufacturer, sizeof(_manufacturer), HAL_MAX_DELAY);
    HAL_SPI_Receive(_hspi, &buffer[0], sizeof(buffer[0]), HAL_MAX_DELAY);
    HAL_SPI_Receive(_hspi, &buffer[1], sizeof(buffer[1]), HAL_MAX_DELAY);
    HAL_SPI_Receive(_hspi, &buffer[2], sizeof(buffer[2]), HAL_MAX_DELAY);

    _csRELEASE();

    /*_csASSERT();
       // Read byte operation
       spiCMD = FRAM_RDSR;
       HAL_SPI_Transmit(_hspi, &spiCMD, sizeof(spiCMD), HAL_MAX_DELAY);
       _csRELEASE();
    */
	/* Shift values to separate IDs */
	_densitycode = buffer[1] &= (1<<5)-1; // Only the 5 first bits
	_productID = (buffer[2] << 8) + buffer[3]; // Is really necessary to read this info ?

	if (_manufacturer == FUJITSU_ID)
    {
        switch (_densitycode)
        {
            case DENSITY_MB85RS64V:
            case DENSITY_MB85RS128B:
            case DENSITY_MB85RS256B:
            case DENSITY_MB85RS512T:
            case DENSITY_MB85RS1MT:
            case DENSITY_MB85RS2MT:
                _density = std::pow(2, _densitycode+3);
                _maxaddress = _density*128;
                break;

            default:
                // F-RAM chip unidentified
                _density = 0;
                _maxaddress = 0;
                return false;
                break;
        }
    } else {
        // F-RAM chip unidentified
        _density = 0;
        _maxaddress = 0;
        return false;
	}


  return true;
}



/*!
///     @brief   _deviceID2Serial()
///              Print out F-RAM characteristics
///
///     @return  0: error, no DEBUG_TRACE available
///              1: ok, print out all the datas
**/
bool FRAM_MB85RS_SPI::_deviceID2Serial()
{   /*
    if (!Serial)
        return false; // Serial not available

	#ifdef CHIP_TRACE
        Serial.println("\n** F-RAM Device IDs");
        Serial.print("Manufacturer 0x"); Serial.println(_manufacturer, HEX);
        Serial.print("ProductID 0x"); Serial.println(_productID, HEX);
        Serial.print("Density code 0x"); Serial.print(_densitycode, HEX);
        Serial.print(", Chip density "); Serial.print(_density, DEC); Serial.println("KBits");
        Serial.print("Max address : 0 to "); Serial.print(_maxaddress-1, DEC); Serial.print(" / "); Serial.println(_maxaddress-1, HEX);
        Serial.println("Device identfied automatically");
    #else
        return false;
    #endif
    */

	return true;
}



/*!
///     @brief   _setMemAddr()
///              Set the memory address coded on 24-bits over SPI
///              Only chip of 1Mbit or above have their address on 24bit,
///              all the other chip are addressed on 16-bits only.
///     @param   framAddr, the 32bit address to send
**/
void FRAM_MB85RS_SPI::_setMemAddr( uint32_t *framAddr )
{
	uint8_t spiAddrByte;

    if (_densitycode >= DENSITY_MB85RS1MT){
    	spiAddrByte =(*framAddr >> 16) & 0xFF;
        HAL_SPI_Transmit(_hspi, &spiAddrByte, sizeof(spiAddrByte), HAL_MAX_DELAY);// Bits 16 to 23
    }
        spiAddrByte =(*framAddr >> 8) & 0xFF;
        HAL_SPI_Transmit(_hspi, &spiAddrByte, sizeof(spiAddrByte), HAL_MAX_DELAY);// Bits 8 to 15

        spiAddrByte = *framAddr & 0xFF;
        HAL_SPI_Transmit(_hspi, &spiAddrByte, sizeof(spiAddrByte), HAL_MAX_DELAY);// MSB, Bits 0 to 7
    _lastaddress = *framAddr;
}
