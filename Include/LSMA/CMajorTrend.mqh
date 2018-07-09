//+------------------------------------------------------------------+
//|                                                        CLSMA.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

//---- input parameters
//extern double gamma=0.7;
//extern int CountBars=950;

//static string LAGUERRE_NAME = "Laguerre";
   
int gi_76 = 100;

class CMajorTrend{

private:

   string           _symbol;
   int              _timeFrame;
   int              _trend;   // 1: up; -1: down; 0: none;

   
public:

   CMajorTrend(string symbol=NULL, int timeframe=0):
               _symbol(symbol),
               _timeFrame(timeframe){
      _trend = 0;
   }
   
   ~CMajorTrend(){
   }

   int GetMajorTrend(){
      Refresh();
      return _trend;
   }

   void Refresh() {
      int li_12;
      int li_16;
      int li_20;
      int li_24;
      int li_28;
      int li_32;
      color l_color_8 = Gray;
      TrendDirection(li_12, li_16);
      TrendStrength(li_20, li_24);
      TrendHistogram(li_28, li_32);
      string l_text_0 = "Major Trend: No Trend Identified";
      _trend = 0;
      if (li_12 && li_20 && li_28) {
         l_text_0 = "Major Trend: Up";
         l_color_8 = Lime;
         _trend = 1;
      }
      if (!li_12 && !li_20 && !li_28) {
         l_text_0 = "Major Trend: Down";
         l_color_8 = Red;
         _trend = -1;
      }
   }

protected: 

   int TrendHistogram(int &ai_0, int &ai_4) {
      double ld_32;
      double lda_112[];
      double lda_116[];
      double lda_120[];
      double ld_44 = 0;
      double ld_52 = 0;
      double ld_unused_60 = 0;
      double ld_unused_68 = 0;
      double ld_76 = 0;
      double ld_unused_84 = 0;
      double l_low_92 = 0;
      double l_high_100 = 0;
      int li_108 = 15;
      ArrayResize(lda_112, gi_76);
      ArrayResize(lda_116, gi_76);
      ArrayResize(lda_120, gi_76);
      for (int li_124 = 0; li_124 < gi_76; li_124++) {
         l_high_100 = iHigh( _symbol, _timeFrame, iHighest(_symbol, _timeFrame, MODE_HIGH, li_108, li_124));
         l_low_92 = iLow( _symbol, _timeFrame, iLowest(_symbol, _timeFrame, MODE_LOW, li_108, li_124));
         ld_32 = (iHigh( _symbol, _timeFrame, li_124) + iLow( _symbol, _timeFrame,li_124)) / 2.0;
         if (l_high_100 - l_low_92 == 0.0) ld_44 = 0.67 * ld_52 + (-0.33);
         else ld_44 = 0.66 * ((ld_32 - l_low_92) / (l_high_100 - l_low_92) - 0.5) + 0.67 * ld_52;
         ld_44 = MathMin(MathMax(ld_44, -0.999), 0.999);
         if (1 - ld_44 == 0.0) lda_112[li_124] = ld_76 / 2.0 + 0.5;
         else lda_112[li_124] = MathLog((ld_44 + 1.0) / (1 - ld_44)) / 2.0 + ld_76 / 2.0;
         ld_52 = ld_44;
         ld_76 = lda_112[li_124];
      }
      double ld_24 = lda_112[0];
      double ld_16 = lda_112[1];
      bool li_128 = TRUE;
      if ((ld_24 < 0.0 && ld_16 > 0.0) || ld_24 < 0.0) li_128 = FALSE;
      if ((ld_24 > 0.0 && ld_16 < 0.0) || ld_24 > 0.0) li_128 = TRUE;
      if (li_128) {
         ai_0 = 1;
         ai_4 = 0;
      } else {
         ai_0 = 0;
         ai_4 = 1;
      }
      return (0);
   }

   void TrendStrength(int &ai_0, int &ai_4) {
      int l_period_24 = 13;
      double l_iadx_8 = iADX(_symbol, _timeFrame, l_period_24, PRICE_CLOSE, MODE_PLUSDI, 0);
      double l_iadx_16 = iADX(_symbol, _timeFrame, l_period_24, PRICE_CLOSE, MODE_MINUSDI, 0);
      if (l_iadx_8 >= l_iadx_16) {
         ai_0 = 1;
         ai_4 = 0;
         return;
      }
      ai_0 = 0;
      ai_4 = 1;
   }

   void TrendDirection(int &ai_0, int &ai_4) {
      double ld_28;
      double ld_36;
      double ld_44;
      double lda_52[];
      double lda_56[];
      int li_16 = 7;
      double ld_20 = 50.6;
      ArrayResize(lda_52, gi_76);
      ArrayResize(lda_56, gi_76);
      for (int li_8 = gi_76 - li_16; li_8 >= 0; li_8--) {
         ld_28 = iHigh( _symbol, _timeFrame, iHighest(_symbol, _timeFrame, MODE_HIGH, li_16, li_8 - li_16 + 1));
         ld_36 = iLow( _symbol, _timeFrame,iLowest(_symbol, _timeFrame, MODE_LOW, li_16, li_8 - li_16 + 1));
         ld_44 = ld_28 - (ld_28 - ld_36) * ld_20 / 100.0;
         if(li_8 - li_16 + 6>=0)
         lda_52[li_8 - li_16 + 6] = ld_44;
         //Print("---->"+(li_8 - li_16 - 1));
         if(li_8 - li_16 - 1 >= 0)
         lda_56[li_8 - li_16 - 1] = ld_44;
         //if(li_8 - li_16 - 1 == 0) break;
      }
      if (lda_52[0] > lda_56[0]) {
         ai_0 = 1;
         ai_4 = 0;
         return;
      }
      ai_0 = 0;
      ai_4 = 1;
   }

};







   

   