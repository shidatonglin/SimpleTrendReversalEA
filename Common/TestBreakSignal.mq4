//+------------------------------------------------------------------+
//|                                              TestBreakSignal.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <BreakSignal.mqh>

BreakSignal signal;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //TestLagu();
   //TestBreakSignal();
   TestSignal(3);
   //TestBarSignal(81,4);
   //TestLagu();
   //TestBarSellSignal(67,4);
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

void TestLagu(){
   for(int i =0 ; i< 120;i++){
      double aguSignal = iCustom(NULL, 0, "Laguerre-ACS1", 0.6, 1000,2, 0, i);
      Print((i) , "----> ",NormalizeDouble(aguSignal,2));
   }
}

void TestBreakSignal(int i=1){
   Print("GetHaOpen---->",signal.GetHaOpen(i));
   Print("GetHaClose---->",signal.GetHaClose(i));
   //GetLastBearishBar
   Print("GetLastBearishBar---->",signal.GetLastBearishBar(i));
   //GetLastBullishBar
   Print("GetLastBullishBar---->",signal.GetLastBullishBar(i));
   //GetLastBarBelowMA
   Print("GetLastBarBelowMA---->",signal.GetLastBarBelowMA(i));
   //GetLastBarUpMA
   Print("GetLastBarUpMA---->",signal.GetLastBarUpMA(i));
   //GetLastCrossBarIndex
   Print("GetLastCrossBarIndex 1---->",signal.GetLastCrossBarIndex(1,i));
   Print("GetLastCrossBarIndex -1---->",signal.GetLastCrossBarIndex(-1,i));
}

void TestSignal(int maxBarCount=3){
   int result = 0;
   for(int i=0; i< 100;i++){

      result = signal.GetBuySignal(maxBarCount,i);
      if(result != 0)
         Print("GetBuySignal ",( i ),"---->",result);

      result = signal.GetSellSignal(maxBarCount,i);
      if(result != 0)
         Print("GetSellSignal ",( i ),"---->",result);
   }
   //TestBreakSignal(40);
   //
   //Print("GetBuySignal ",( 52 ),"---->",signal.GetBuySignal(3,52));
}

void TestBarSignal(int shift, int maxBarCount=3){
   Print("GetBuySignal ",( shift ),"---->",signal.GetBuySignal(maxBarCount,shift));
}

void TestBarSellSignal(int shift, int maxBarCount=3){
   Print("GetSellSignal ",( shift ),"---->",signal.GetSellSignal(maxBarCount,shift));
}


