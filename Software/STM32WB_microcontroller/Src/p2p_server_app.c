/* USER CODE BEGIN Header */
/**
 ******************************************************************************
 * File Name          : p2p_server_app.c
 * Description        : P2P Server Application
 ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; Copyright (c) 2021 STMicroelectronics.
  * All rights reserved.</center></h2>
  *
  * This software component is licensed by ST under Ultimate Liberty license
  * SLA0044, the "License"; You may not use this file except in compliance with
  * the License. You may obtain a copy of the License at:
  *                             www.st.com/SLA0044
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
//#include <main.h>

#include <main.h>
#include "app_common.h"
#include "dbg_trace.h"
#include "ble.h"
#include "p2p_server_app.h"
#include "stm32_seq.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

uint8_t flag =0x03;
uint8_t dataTime[16] ={0};
//uint8_t (* dataTimeP)[16];
/* USER CODE END PTD */

/* Private defines ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macros -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
/* USER CODE BEGIN PV */
//unsigned char inputMessage = 0;
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN PFP */
void P2PS_Send_ADC_Notification(void);
void P2PS_Send_Memory_Notification(void);
/* USER CODE END PFP */

/* Functions Definition ------------------------------------------------------*/
void P2PS_STM_App_Notification(P2PS_STM_App_Notification_evt_t *pNotification)
{
/* USER CODE BEGIN P2PS_STM_App_Notification_1 */

/* USER CODE END P2PS_STM_App_Notification_1 */
  switch(pNotification->P2P_Evt_Opcode)
  {
/* USER CODE BEGIN P2PS_STM_App_Notification_P2P_Evt_Opcode */

/* USER CODE END P2PS_STM_App_Notification_P2P_Evt_Opcode */

    case P2PS_STM__NOTIFY_ENABLED_EVT:
/* USER CODE BEGIN P2PS_STM__NOTIFY_ENABLED_EVT */

/* USER CODE END P2PS_STM__NOTIFY_ENABLED_EVT */
      break;

    case P2PS_STM_NOTIFY_DISABLED_EVT:
/* USER CODE BEGIN P2PS_STM_NOTIFY_DISABLED_EVT */

/* USER CODE END P2PS_STM_NOTIFY_DISABLED_EVT */
      break;

    case P2PS_STM_WRITE_EVT:
/* USER CODE BEGIN P2PS_STM_WRITE_EVT */
    	
    	        if(pNotification->DataTransfered.pPayload[0] == 0x00)
    	        {    // get data from ADC
                     flag =0x00;
    	        }
    	        if(pNotification->DataTransfered.pPayload[0] == 0x01)
    	        {    //write data to memory
    	        	unsigned char* inputm = pNotification->DataTransfered.pPayload+1;
                     memcpy((uint8_t *)(&dataTime), (unsigned char*)inputm, 16 );
                     Write_Data_Time_To_Memory(dataTime);
                     flag =0x01;

    	        }
    	        if(pNotification->DataTransfered.pPayload[0] == 0x02)
    	        {    //read data from memory
    	             flag =0x02;
    	             UTIL_SEQ_SetTask( 1<<CFG_TASK_RECEIVE_MEMORY_DATA_ID, CFG_SCH_PRIO_0);
    	        }

/* USER CODE END P2PS_STM_WRITE_EVT */
      break;

    default:
/* USER CODE BEGIN P2PS_STM_App_Notification_default */

/* USER CODE END P2PS_STM_App_Notification_default */
      break;
  }
/* USER CODE BEGIN P2PS_STM_App_Notification_2 */

/* USER CODE END P2PS_STM_App_Notification_2 */
  return;
}

void P2PS_APP_Notification(P2PS_APP_ConnHandle_Not_evt_t *pNotification)
{
/* USER CODE BEGIN P2PS_APP_Notification_1 */

/* USER CODE END P2PS_APP_Notification_1 */
  switch(pNotification->P2P_Evt_Opcode)
  {
/* USER CODE BEGIN P2PS_APP_Notification_P2P_Evt_Opcode */

/* USER CODE END P2PS_APP_Notification_P2P_Evt_Opcode */
  case PEER_CONN_HANDLE_EVT :
/* USER CODE BEGIN PEER_CONN_HANDLE_EVT */

/* USER CODE END PEER_CONN_HANDLE_EVT */
    break;

    case PEER_DISCON_HANDLE_EVT :
/* USER CODE BEGIN PEER_DISCON_HANDLE_EVT */

/* USER CODE END PEER_DISCON_HANDLE_EVT */
    break;

    default:
/* USER CODE BEGIN P2PS_APP_Notification_default */

/* USER CODE END P2PS_APP_Notification_default */
      break;
  }
/* USER CODE BEGIN P2PS_APP_Notification_2 */

/* USER CODE END P2PS_APP_Notification_2 */
  return;
}

void P2PS_APP_Init(void)
{
/* USER CODE BEGIN P2PS_APP_Init */
	UTIL_SEQ_RegTask( 1<< CFG_TASK_RECEIVE_ADC_ID, UTIL_SEQ_RFU, P2PS_Send_ADC_Notification );
	UTIL_SEQ_RegTask( 1<< CFG_TASK_RECEIVE_MEMORY_DATA_ID, UTIL_SEQ_RFU, P2PS_Send_Memory_Notification );
/* USER CODE END P2PS_APP_Init */
  return;
}

/* USER CODE BEGIN FD */

/* USER CODE END FD */

/*************************************************************
 *
 * LOCAL FUNCTIONS
 *
 *************************************************************/
/* USER CODE BEGIN FD_LOCAL_FUNCTIONS*/
void P2PS_Send_ADC_Notification(void)
{  //P2PS_STM_App_Update_Char(P2P_NOTIFY_CHAR_UUID, (uint8_t *)(&value));
    P2PS_STM_App_Update_Int8(P2P_NOTIFY_CHAR_UUID, (uint8_t *)(&value), 4);
}

void P2PS_Send_Memory_Notification(void)
{   uint8_t data_buf[4]={0};
    if(Read_Data_From_Memory((uint8_t *)(data_buf))){
       P2PS_STM_App_Update_Int8(P2P_NOTIFY_CHAR_UUID, (uint8_t *)(&data_buf), 4);
       HAL_Delay(5);
       UTIL_SEQ_SetTask( 1<<CFG_TASK_RECEIVE_MEMORY_DATA_ID, CFG_SCH_PRIO_0);
    }
}
/* USER CODE END FD_LOCAL_FUNCTIONS*/

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
