//+------------------------------------------------------------------+
//|                                               Example5NewBar.mq5 |
//|                                            Copyright 2010, Lizar |
//|                                               Lizar-2010@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Lizar"
#property link      "Lizar-2010@mail.ru"
#property version   "1.00"

#include <Lib CisNewBar.mqh>

CisNewBar newbar_ind; // instance of the CisNewBar class: detect new tick candlestick
int HandleIndicator;  // indicator handle
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Get indicator handle
   HandleIndicator=iCustom(_Symbol,_Period,"TickColorCandles v2.00",16,0,""); 
   if(HandleIndicator==INVALID_HANDLE)
     {
      Alert(" Error when creating indicator handle, error code: ",GetLastError());
      Print(" Incorrect initialization of Expert Advisor. Trade is not allowed.");
      return(1);
     }

//--- Attach indicator to chart:  
   if(!ChartIndicatorAdd(ChartID(),1,HandleIndicator))
     {
      Alert(" Error when attaching indicator to chart, error code: ",GetLastError());
      return(1);
     }
//--- If you passed until here, initialization was successful     
   Print(" Successful initialization of Expert Advisor. Trade is allowed.");
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double iTime[1];

//--- Get time of opening last unfinished tick candlestick:
   if(CopyBuffer(HandleIndicator,5,0,1,iTime)<=0)
     {
      Print(" Failed to get time value of indicator. "+
            "\nNext attempt to get indicator values will be made on the next tick.",GetLastError());
      return;
     }
//--- Detect the next tick candlestick:
   if(newbar_ind.isNewBar((datetime)iTime[0]))
     {
      PrintFormat("New bar. Opening time: %s  Time of last tick: %s",TimeToString((datetime)iTime[0],TIME_SECONDS),TimeToString(TimeCurrent(),TIME_SECONDS));
     }
  }
  
 
