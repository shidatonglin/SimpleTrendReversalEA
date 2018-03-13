//+------------------------------------------------------------------+
//|                                               CMrdFXStrategy.mqh |
//|                                    Copyright 2017, Erwin Beckers |
//|                                      https://www.erwinbeckers.nl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Erwin Beckers"
#property link      "https://www.erwinbeckers.nl"
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
//extern int        ZigZagCandles                = 10;
//extern int        MBFXCandles                  = 10;

#include <CStrategy.mqh>
//#include <CZigZag.mqh>
//#include <CMBFX.mqh>
//#include <CTrendLine.mqh>
#include <CSupportResistance.mqh>

extern string     __movingaverage__            = " ------- Moving Average Settings ------------";
extern int        MovingAveragePeriod          = 15;
extern int        MovingAverageType            = MODE_SMA;


//bool UseMBFX      = true;
//bool UseSMA15     = true;
//bool UseTrendLine = true;
bool UseMAChannel   = true;
bool UseIchmoku     = true;
bool UseBBMacd      = true;
bool UseHA          = true;

//--------------------------------------------------------------------
class CIchmokuStrategy : public IStrategy
{
private:
   // CSupportResistance* _supportResistanceH1;
   // CSupportResistance* _supportResistanceH4;
   // CSupportResistance* _supportResistanceD1;
   // CSupportResistance* _supportResistanceW1;
   // CZigZag*            _zigZag;         
   // CMBFX*              _mbfx;         
   // CTrendLine*         _trendLine; 
   int                 _indicatorCount;
   CIndicator*         _indicators[];
   CSignal*            _signal;
   string              _symbol;
   
public:
   //--------------------------------------------------------------------
   CMrdFXStrategy(string symbol)
   {
      _symbol              = symbol;
      // _supportResistanceH1 = new CSupportResistance(_symbol, PERIOD_H1);
      // _supportResistanceH4 = new CSupportResistance(_symbol, PERIOD_H4);
      // _supportResistanceD1 = new CSupportResistance(_symbol, PERIOD_D1);
      // _supportResistanceW1 = new CSupportResistance(_symbol, PERIOD_W1);
      // _zigZag              = new CZigZag();
      // _mbfx                = new CMBFX();
      // _trendLine           = new CTrendLine();
      _signal              = new CSignal();
         
      _indicatorCount = 1; // HenAsia
      if (UseMAChannel) _indicatorCount++;
      if (UseIchmoku) _indicatorCount++;
      if (UseBBMacd) _indicatorCount++;
      // if (UseSma200TrendFilter) _indicatorCount++; 
      // if (UseSupportResistanceFilter) _indicatorCount++; 
       
      ArrayResize(_indicators, 10);
      int index=0;
      _indicators[index] = new CIndicator("HenAsia");
      index++;
      
      if (UseMAChannel)
      {
         _indicators[index] = new CIndicator("MAChannel");
         index++;
      }
      
      if (UseIchmoku)
      {
         _indicators[index] = new CIndicator("Ichmoku");
         index++;
      }
      
      if (UseBBMacd) 
      {
         _indicators[index] = new CIndicator("BBMacd");
         index++;
      }
      
      // if (UseSma200TrendFilter)
      // {
      //    _indicators[index] = new CIndicator("MA200");
      //    index++;
      // }
      
      // if (UseSupportResistanceFilter) 
      // {
      //   _indicators[index] = new CIndicator("S&R");
      //   index++;
      // }
   }
   
   //--------------------------------------------------------------------
   ~CMrdFXStrategy()
   {
      // delete _zigZag;
      // delete _mbfx;
      // delete _trendLine;
      // delete _signal;
      // delete _supportResistanceH1;
      // delete _supportResistanceH4;
      // delete _supportResistanceD1;
      // delete _supportResistanceW1;
      
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
      double points = MarketInfo(_symbol, MODE_POINT);
      double digits = MarketInfo(_symbol, MODE_DIGITS);
      double mult   = (digits == 3 || digits == 5) ? 10 : 1;
      _zigZag.Refresh(_symbol);
      
      // find last zigzag arrow
      int zigZagBar = -1;
      ARROW_TYPE arrow = ARROW_NONE;
      for (int bar=0; bar < 200;++bar)
      {
         arrow = _zigZag.GetArrow(bar);
         if (arrow == ARROW_BUY )
         {
            if (OrderType() == OP_BUY) zigZagBar = bar;
            break;
         }
         else if (arrow == ARROW_SELL)
         {
            if (OrderType() == OP_SELL) zigZagBar = bar;
            break;
         }
      }
      if (zigZagBar == 0) zigZagBar=1;
      
      if (zigZagBar > 0)
      {
         if (arrow == ARROW_BUY)
         {
            return iLow(_symbol, 0, zigZagBar);
         }
         else if (arrow == ARROW_SELL)
         {
            return iHigh(_symbol, 0, zigZagBar);
         }
      }
      return 0;
   }
};