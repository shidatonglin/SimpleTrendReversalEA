//+------------------------------------------------------------------+
//|                                                     CloseAll.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
#include <trade/trade.mqh>

void OnStart()
  {
   CTrade trade;
   int i=PositionsTotal()-1;
   while (i>=0)
     {
      if (trade.PositionClose(PositionGetSymbol(i))) i--;
     }
  }