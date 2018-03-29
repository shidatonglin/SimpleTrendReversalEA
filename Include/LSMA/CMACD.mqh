//+------------------------------------------------------------------+
//|                                                        CMACD.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

extern   int               m_fast_ema_period  = 12;
extern   int               m_slow_ema_period  = 26;
extern   int               m_signal_period    = 9;
extern   int               m_applied          = PRICE_CLOSE;

static string LSMA_NAME = "MACD";

enum LSMA_TREND{
   TREND_LONG,
   TREND_SHORT,
   TREND_NONE
};   

class CMACD{

private:

   string           _symbol;
   int              _timeFrame;
   int              _digits;
   int              _fast_ema_period;
   int              _slow_ema_period;
   int              _signal_period;
   int              _applied;
   
public:

   CMACD(string symbol, int timeframe=0):
               _symbol(symbol),
               _timeFrame(timeframe),
               _fast_ema_period(m_fast_ema_period),
               _slow_ema_period(m_slow_ema_period),
               _signal_period(m_signal_period),
               _applied(m_applied){
      //_currentTrend = TREND_NONE;
      //_trendStartBarShift = -1;
      //_currentValue = 0.0;
      _digits = (int)MarketInfo(_symbol,MODE_DIGITS);
   }
   
   ~CMACD(){}

   double  Main(const int index) {
      return iMACD(_symbol,_timeFrame,_fast_ema_period,_slow_ema_period,_signal_period,_applied,0,index);
   }
   double  Signal(const int index) {
      return iMACD(_symbol,_timeFrame,_fast_ema_period,_slow_ema_period,_signal_period,_applied,1,index);
   }
   
};

