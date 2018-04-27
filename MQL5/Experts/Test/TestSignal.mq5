//+------------------------------------------------------------------+
//|                                                   TestSignal.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Expert\Signal\SignalMACD.mqh>
#include <pairs.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

CSignalMACD signals[28];
int pairCount = ArraySize(pairs);
int totalSiganls = MathMin(pairCount, 28);

CIndicators indis = new CIndicators();
int OnInit()
  {
//---
   for(int i=0; i<totalSiganls;i++){
      signals[i].SetSymbol(pairs[i]);
      signals[i].createSignal();
      Print(pairs[i] + "  :  shortcondition : " + signals[i].ShortCondition());
      Print(pairs[i] + "  :  Longcondition : " + signals[i].LongCondition());
   }
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
