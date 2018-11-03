//+------------------------------------------------------------------+
//|                                                   TestLogger.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Logger.mqh>

//--- initialize a logger
void InitLogger()
  {
//--- set logging levels: 
//--- DEBUG level for writing messages in a log file
//--- ERROR-level for notification
   CLogger::SetLevels(LOG_LEVEL_DEBUG,LOG_LEVEL_ERROR);
//--- set a notification type as PUSH notification
   CLogger::SetNotificationMethod(NOTIFICATION_METHOD_NONE);
//--- set logging method as an external file writing
   CLogger::SetLoggingMethod(LOGGING_OUTPUT_METHOD_EXTERN_FILE);
//--- set a name for log files
   CLogger::SetLogFileName("my_log");
//--- set log file restrictions as "new log file for every new day"
   CLogger::SetLogFileLimitType(LOG_FILE_LIMIT_TYPE_ONE_DAY);
  }
  
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   InitLogger();
//---
   CLogger::Add(LOG_LEVEL_INFO,"");
   CLogger::Add(LOG_LEVEL_INFO,"---------- OnInit() -----------");
   LOG(LOG_LEVEL_DEBUG,"Example of debug message");
   LOG(LOG_LEVEL_INFO,"Example of info message");
   LOG(LOG_LEVEL_WARNING,"Example of warning message");
   LOG(LOG_LEVEL_ERROR,"Example of error message");
   LOG(LOG_LEVEL_FATAL,"Example of fatal message");
   MainProcess();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

void MainProcess(){
   LOG(LOG_LEVEL_DEBUG,"This is a test");
}