//+------------------------------------------------------------------+
//|                                                        CLSMA.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

//---- input parameters
extern double gamma=0.7;
extern int CountBars=950;

static string LAGUERRE_NAME = "Laguerre";
   

class CLaguerre{

private:

   string           _symbol;
   int              _timeFrame;
   int              _digits;
   double           _values[];
   
public:

   CLaguerre(string symbol, int timeframe=0):
               _symbol(symbol),
               _timeFrame(timeframe){
      _digits = (int)MarketInfo(_symbol,MODE_DIGITS);
   }
   
   ~CLaguerre(){
      ArrayFree(_values);
   }

   void Refresh(){
      double L0 = 0;
      double L1 = 0;
      double L2 = 0;
      double L3 = 0;
      double L0A = 0;
      double L1A = 0;
      double L2A = 0;
      double L3A = 0;
      double LRSI = 0;
      double CU = 0;
      double CD = 0;

      int i=CountBars-1;
      while(i>=0)
      {
         L0A = L0;
         L1A = L1;
         L2A = L2;
         L3A = L3;
         L0 = (1 - gamma)*iClose( _symbol, _timeFrame, i ) + gamma*L0A;
         L1 = - gamma *L0 + L0A + gamma *L1A;
         L2 = - gamma *L1 + L1A + gamma *L2A;
         L3 = - gamma *L2 + L2A + gamma *L3A;

         CU = 0;
         CD = 0;
         
         if (L0 >= L1) CU = L0 - L1; else CD = L1 - L0;
         if (L1 >= L2) CU = CU + L1 - L2; else CD = CD + L2 - L1;
         if (L2 >= L3) CU = CU + L2 - L3; else CD = CD + L3 - L2;

         if (CU + CD != 0) LRSI = CU / (CU + CD);
         _values[i] = LRSI;
         i--;
      }
   }

   double GetValue(int index){
      return _values[index];
   }
   
};







   

   