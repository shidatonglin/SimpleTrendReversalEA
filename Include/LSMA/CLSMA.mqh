//+------------------------------------------------------------------+
//|                                                        CLSMA.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

extern int lsma_period  = 25;
extern bool userMaAngle = false;

static string LSMA_NAME = "LSMA in Color";

enum LSMA_TREND{
   TREND_LONG,
   TREND_SHORT,
   TREND_NONE
};   

class CLSMA{

private:

   string           _symbol;
   int              _timeFrame;
   int              _trendStartBarShift;
   double           _currentValue;
   LSMA_TREND       _currentTrend;
   int              _digits;
   
public:

   CLSMA(string symbol, int timeframe=0):
               _symbol(symbol),
               _timeFrame(timeframe){
      _currentTrend = TREND_NONE;
      _trendStartBarShift = -1;
      _currentValue = 0.0;
      _digits = (int)MarketInfo(_symbol,MODE_DIGITS);
   }
   
   ~CLSMA(){}
   LSMA_TREND GetCurrentTrend(int shift = 1){
      double lsma_up = iCustom(_symbol,_timeFrame,LSMA_NAME,lsma_period,500,1,shift);
      double lsma_down = iCustom(_symbol,_timeFrame,LSMA_NAME,lsma_period,500,2,shift);
      if(lsma_up == EMPTY_VALUE){
         _currentValue = NormalizeDouble( lsma_down, _digits);
         return TREND_SHORT;
      }else if(lsma_down == EMPTY_VALUE){
         _currentValue = NormalizeDouble( lsma_up, _digits);;
         return TREND_LONG;
      }
      return TREND_NONE;
   }
   
   double GetLSMAValue(int shift=1){
      return NormalizeDouble(
         iCustom(_symbol,_timeFrame,LSMA_NAME,lsma_period,500,0,shift)
         ,_digits);
   }
   
   int GetTrendStartBarShift(int shift=1){
      if(_currentTrend == TREND_NONE){
         _currentTrend = GetCurrentTrend(shift);
      }
      double tempValue = EMPTY_VALUE;
      for(int i = shift+1; i < shift + 100; i++){
         if(_currentTrend==TREND_LONG){
            // down value
            tempValue = iCustom(_symbol,_timeFrame,LSMA_NAME,lsma_period,500,2,i);
            if(tempValue != EMPTY_VALUE){
               return i-1;
            }
         }else if(_currentTrend==TREND_SHORT){
            // up value
            tempValue = iCustom(_symbol,_timeFrame,LSMA_NAME,lsma_period,500,1,i);
            if(tempValue != EMPTY_VALUE){
               return i-1;
            }
         }
      }
      return -1;
   }
};