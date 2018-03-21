//+------------------------------------------------------------------+
//|                                               CSignalBase.mqh    |
//|                                    Copyright 2018, Tong Tony     |
//|                                      shidatonglin@163.com        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Tony Tong"
#property link      "shidatonglin@163.com"
#property strict

extern string     _srfilter_                   = " ------- S&R Filter ------------";
extern bool        UseSupportResistanceFilter  = false;
extern int         MaxPipsFromSR               = 30;
extern bool        SR_1Hours                   = false;
extern bool        SR_4Hours                   = false;
extern bool        SR_Daily                    = true;
extern bool        SR_Weekly                   = true;

extern string     __trendfilter                = " ------- SMA 200 Daily Trend Filter ------------";
extern bool        UseSma200TrendFilter        = false;

extern string     __signals__                  = " ------- Candles to look back for confirmation ------------";
extern int        ZigZagCandles                = 10;
extern int        MBFXCandles                  = 10;

#include <CStrategy.mqh>
#include <CZigZag.mqh>
#include <CMBFX.mqh>
#include <CTrendLine.mqh>
#include <CSupportResistance.mqh>

extern string     __movingaverage__            = " ------- Moving Average Settings ------------";
extern int        MovingAveragePeriod          = 15;
extern int        MovingAverageType            = MODE_SMA;


//--------------------------------------------------------------------
class CSignalBase : public IStrategy
{
private:
    
   int                 _indicatorCount;
   CIndicator*         _indicators[];
   CSignal*            _signal;
   string              _symbol;

   
public:
   //--------------------------------------------------------------------
   CMrdFXStrategy(string symbol)
   {
      _symbol              = symbol;
      _signal              = new CSignal();
   }
   
   //--------------------------------------------------------------------
   ~CMrdFXStrategy()
   {
      for (int i=0; i < _indicatorCount;++i)
      {
         delete _indicators[i];
      }
      ArrayFree(_indicators);
   }
   
   //--------------------------------------------------------------------
   CSignal* Refresh()
   {
      
      return _signal;
   }

   CSignal* GetHeiKenMaChannelCross(){

   }

   CSignal* GetHeiKenIchimoku(){
      
   }
   
   //--------------------------------------------------------------------
   int GetIndicatorCount()
   {
      return _indicatorCount;
   }
   
   //--------------------------------------------------------------------
   CIndicator* GetIndicator(int indicator)
   {
      return _indicators[indicator];
   }
   
   //--------------------------------------------------------------------
   double GetStopLossForOpenOrder()
   {
      return 0;
   }
};




