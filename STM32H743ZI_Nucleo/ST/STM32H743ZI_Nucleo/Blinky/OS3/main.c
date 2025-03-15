/*
*********************************************************************************************************
*                                            EXAMPLE CODE
*
*               This file is provided as an example on how to use Micrium products.
*
*               Please feel free to use any application code labeled as 'EXAMPLE CODE' in
*               your application products.  Example code may be used as is, in whole or in
*               part, or may be used as a reference only. This file can be modified as
*               required to meet the end-product requirements.
*
*               Please help us continue to provide the Embedded community with the finest
*               software available.  Your honesty is greatly appreciated.
*
*               You can find our product's user manual, API reference, release notes and
*               more information at https://doc.micrium.com.
*               You can contact us at www.micrium.com.
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*
*                                             uC/OS-III
*                                            EXAMPLE CODE
*
* Filename : main.c
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*                                            INCLUDE FILES
*********************************************************************************************************
*/

#include  <cpu.h>
#include  <lib_mem.h>
#include  <os.h>
#include  <bsp_os.h>
#include  <bsp_clk.h>
#include  <bsp_led.h>
#include  <bsp_int.h>
#include  <stm32h7xx_hal.h>

#include  "os_app_hooks.h"
#include  "../app_cfg.h"

/*
*********************************************************************************************************
*                                            LOCAL DEFINES
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                       LOCAL GLOBAL VARIABLES
*********************************************************************************************************
*/

static  OS_TCB   StartupTaskTCB;
static  CPU_STK  StartupTaskStk[APP_CFG_STARTUP_TASK_STK_SIZE];
/* Creating a task stack & TCB */
static OS_TCB TaskATCB;
static CPU_STK TaskAStk[APP_CFG_DEFAULT_TASK_STK_SIZE];
static OS_TCB TaskBTCB;
static CPU_STK TaskBStk[APP_CFG_DEFAULT_TASK_STK_SIZE];
static OS_MUTEX ArrayMutex;
static OS_SEM ArraySem;
static uint8_t au8_shared_array[8] = {0};
static uint8_t au8_sem_array[2] = {0};

/*
*********************************************************************************************************
*                                         FUNCTION PROTOTYPES
*********************************************************************************************************
*/

static  void  StartupTask (void  *p_arg);
static  void  TaskA (void *p_arg);
static  void  TaskB (void  *p_arg);


/*
*********************************************************************************************************
*                                                main()
*
* Description : This is the standard entry point for C code.  It is assumed that your code will call
*               main() once you have performed all necessary initialization.
*
* Arguments   : none
*
* Returns     : none
*
* Notes       : none
*********************************************************************************************************
*/

int  main (void)
{
    OS_ERR  os_err;


    HAL_Init();                                                 /* Initialize STM32Cube HAL Library                     */
    BSP_ClkInit();                                              /* Initialize the main clock                            */
    BSP_IntInit();                                              /* Initialize RAM interrupt vector table.               */
    BSP_OS_TickInit();                                          /* Initialize kernel tick timer                         */

    Mem_Init();                                                 /* Initialize Memory Managment Module                   */
    CPU_IntDis();                                               /* Disable all Interrupts                               */
    CPU_Init();                                                 /* Initialize the uC/CPU services                       */

    OSInit(&os_err);                                            /* Initialize uC/OS-III                                 */
    if (os_err != OS_ERR_NONE) {
        while (1);
    }

    App_OS_SetAllHooks();                                       /* Set all applications hooks                           */
    
    OSMutexCreate((OS_MUTEX  *)&ArrayMutex,                       /* Create Mutex */
                 (CPU_CHAR   *)"My Array. Mutex",
                 (OS_ERR     *)&os_err);
    
    /* Create a Semaphore */
    OSSemCreate((OS_SEM *)&ArraySem,
                 (CPU_CHAR *)"My Array Sem",
                 (OS_SEM_CTR )0u,
                 (OS_ERR *)&os_err);

    OSTaskCreate(&StartupTaskTCB,                               /* Create the startup task                              */
                 "Startup Task",
                  StartupTask,
                  0u,
                  APP_CFG_STARTUP_TASK_PRIO,
                 &StartupTaskStk[0u],
                  StartupTaskStk[APP_CFG_STARTUP_TASK_STK_SIZE / 10u],
                  APP_CFG_STARTUP_TASK_STK_SIZE,
                  0u,
                  0u,
                  0u,
                 (OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                 &os_err);
    if (os_err != OS_ERR_NONE) {
        while (1);
    }

    OSStart(&os_err);                                           /* Start multitasking (i.e. give control to uC/OS-III)  */

    while (DEF_ON) {                                            /* Should Never Get Here.                               */
        ;
    }
}


/*
*********************************************************************************************************
*                                            STARTUP TASK
*
* Description : This is an example of a startup task.  As mentioned in the book's text, you MUST
*               initialize the ticker only once multitasking has started.
*
* Arguments   : p_arg   is the argument passed to 'StartupTask()' by 'OSTaskCreate()'.
*
* Returns     : none
*
* Notes       : 1) The first line of code is used to prevent a compiler warning because 'p_arg' is not
*                  used.  The compiler should not generate any code for this statement.
*********************************************************************************************************
*/

static  void  StartupTask (void *p_arg)
{
    OS_ERR  os_err;
    OS_ERR  taskA_err;
    OS_ERR  taskB_err;
    CPU_TS ts;


   (void)p_arg;


    OS_TRACE_INIT();                                            /* Initialize the OS Trace recorder                     */

    BSP_OS_TickEnable();                                        /* Enable the tick timer and interrupt                  */

    BSP_LED_Init();                                             /* Initialize LEDs                                      */

#if OS_CFG_STAT_TASK_EN > 0u
    OSStatTaskCPUUsageInit(&os_err);                            /* Compute CPU capacity with no task running            */
#endif

#ifdef CPU_CFG_INT_DIS_MEAS_EN
    CPU_IntDisMeasMaxCurReset();
#endif
    /* Create Task A and B */
    OSTaskCreate(
        &TaskATCB,
        "Task A",
        TaskA,
        NULL,
        APP_CFG_TASKA_TASK_PRIO,
        &TaskAStk[0],
        APP_CFG_DEFAULT_TASK_STK_SIZE/10,
        APP_CFG_DEFAULT_TASK_STK_SIZE,
        0u,
        0u,
        0u,
        (OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
        &taskA_err);
        
    if (taskA_err != OS_ERR_NONE) {
        while (1);
    }

    OSTaskCreate(
        &TaskBTCB,
        "Task B",
        TaskB,
        NULL,
        APP_CFG_TASKB_TASK_PRIO,
        &TaskBStk[0],
        APP_CFG_DEFAULT_TASK_STK_SIZE/10,
        APP_CFG_DEFAULT_TASK_STK_SIZE,
        0u,
        0u,
        0u,
        (OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
        &taskB_err);
    
    if (taskB_err != OS_ERR_NONE) {
        while (1);
    }
    
    while (DEF_TRUE) {                                          /* Task body, always written as an infinite loop.       */
        OSTimeDlyHMSM(0u, 0u, 1u, 0u,
            OS_OPT_TIME_HMSM_STRICT,
            &os_err);
        OSMutexPend((OS_MUTEX  *)&ArrayMutex,
            (OS_TICK    )0,
            (OS_OPT     )OS_OPT_PEND_NON_BLOCKING,
            (CPU_TS    *)&ts,
            (OS_ERR    *)&os_err);
        /* Access shared resource is resource is available  */                                 
        if(os_err == OS_ERR_NONE)
        {
            /* Resource was available */
            Mem_Set(au8_shared_array, 0xc5u, 8u);
            HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_14);
            
            /* Release the resource since we are done using it */
            OSMutexPost((OS_MUTEX  *)&ArrayMutex,                         
                (OS_OPT     )OS_OPT_POST_NONE,
                (OS_ERR    *)&os_err);
        }
    }
}

static  void  TaskA (void *p_arg)
{
   OS_ERR  os_err;
   CPU_TS ts;

   (void)p_arg;
   
    while (DEF_TRUE) {                                          /* Task body, always written as an infinite loop.       */
        OSTimeDlyHMSM(0u, 0u, 1u, 0u,
            OS_OPT_TIME_HMSM_STRICT,
            &os_err);
        OSMutexPend((OS_MUTEX  *)&ArrayMutex,                    
            (OS_TICK    )0,
            (OS_OPT     )OS_OPT_PEND_NON_BLOCKING,
            (CPU_TS    *)&ts,
            (OS_ERR    *)&os_err);
        /* Access shared resource after checking if mutex was available */                                 
        if(os_err == OS_ERR_NONE)
        {
            /* Resource was available */
            Mem_Set(au8_shared_array, 0xdeu, 8u);

           /*  HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_0); */
            
            /* Release the resource since we are done using it */
            OSMutexPost((OS_MUTEX  *)&ArrayMutex,                         
                (OS_OPT     )OS_OPT_POST_NONE,
                (OS_ERR    *)&os_err);
        }
        /* Wait for a signal from Task B */
        OSSemPend((OS_SEM  *)&ArraySem,                    
            (OS_TICK    )0,
            (OS_OPT     )OS_OPT_PEND_NON_BLOCKING,
            (CPU_TS    *)&ts,
            (OS_ERR    *)&os_err);
        if(os_err == OS_ERR_NONE)
        {
            /* Task B signalled, now the array can be written */
            Mem_Set(au8_sem_array, 0xafu, 2u);
            HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_0);
        }
    }
}

static  void  TaskB (void *p_arg)
{
   OS_ERR  os_err;

   (void)p_arg;
   
    while (DEF_TRUE) {                                          /* Task body, always written as an infinite loop.       */
        OSTimeDlyHMSM(0u, 0u, 5u, 0u,
            OS_OPT_TIME_HMSM_STRICT,
            &os_err);
        

        /* Every 5 seconds the Sem will be posted */
        OSSemPost((OS_SEM  *)&ArraySem,                         
            (OS_OPT     )OS_OPT_POST_NONE,
            (OS_ERR    *)&os_err);
    }
}
