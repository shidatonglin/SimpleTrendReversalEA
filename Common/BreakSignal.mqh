//+------------------------------------------------------------------+
//|                                                HABreakSignal.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

/*
For Ha break signal


TimeFrame H4

Rules for buy:
1. Ha color changed from Red to White (last three changed candles)
2. Ha price cross over the Ma line (last three cross over candles)
The current bar close over the Ma line and within three bars, there is a candle
close below the Ma line.
3. The 0.6 lagu value start to bigger than the 0.8 lagu value



*/
const int MAX_SEARCH_BAR = 20;
class BreakSignal{

private:

//   int     m_period_ma;
//   int     m_shift_ma;
   string  m_symbol;
   int     m_timeframe;

public:
   BreakSignal();
   ~BreakSignal();
   bool   Init(string);
//   bool   InitMa(int,int);
   double GetHaOpen(int);
   double GetHaClose(int);
   int    GetBuySignal(int, int);
   int    GetSellSignal(int, int);
   int    GetLastBullishBar(int);
   int    GetLastBearishBar(int);
   int    GetLastBarBelowMA(int);
   int    GetLastBarUpMA(int);
   int    GetLastCrossBarIndex(int, int);
   //double GetHaHigh(int);
   //double GetHaLow(int);
//   double GetMaValue(int,int);
};

BreakSignal::BreakSignal(void):m_symbol(NULL),
                                m_timeframe(PERIOD_H4)
{

}

BreakSignal::~BreakSignal(void){}

bool BreakSignal::Init(string symbol){
   m_symbol = symbol;
   return true;
}

//bool BreakSignal::InitMa(int period, int shift){
//   m_shift_ma = shift;
//   m_period_ma = period;
//   return true;
//}

//double BreakSignal::GetMaValue(int barShift){
//   return iMA(m_symbol, m_timeframe, m_period_ma, m_shift_ma, MODE_EMA,PRICE_CLOSE,barShift);
//}

double BreakSignal::GetHaOpen(int shift){
	return iCustom(m_symbol, m_timeframe, "Heiken Ashi", 0,0,0,0, 2, 1);
}

double BreakSignal::GetHaClose(int shift){
	return iCustom(m_symbol, m_timeframe, "Heiken Ashi", 0,0,0,0, 3, 1);
}

int BreakSignal::GetBuySignal(int shift, int maxBarShift){

    // For buy signal
    bool barColorChange = false;
    int lastChangeBar = GetLastBearishBar();
    if(GetHaClose(shift) > GetHaOpen(shift)   // Buy Bar
        && lastChangeBar != -1               //
        && lastChangeBar <= maxBarShift
    ){
        barColorChange = true;
    }

    bool maCrossed = false;
    double maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,shift);
    if(GetHaClose(shift) > maValue
        && GetLastBarBelowMA() != -1
        && GetLastBarBelowMA() <= maxBarShift){
        maCrossed = true;
    }

    bool laguCross = false;
    double laguSignal = iCustom(m_symbol, m_timeframe, "Laguerre-ACS1", 0.6, 100,2, 1, 1);
    double laguMain   = iCustom(m_symbol, m_timeframe, "Laguerre-ACS1", 0.75,100,2, 1, 1);
    if(laguSignal > laguMain
        && GetLastCrossBarIndex(1) != -1
        && GetLastCrossBarIndex(1) < maxBarShift){
        laguCross = true;
    }

    if(barColorChange && maCrossed && laguCross){
        return 1;
    } else {
        return 0;
    }
}

int BreakSignal::GetSellSignal(int shift, int maxBarShift){
    // For Sell signal
    bool barColorChange = false;
    int lastChangeBar = GetLastBearishBar();
    if(GetHaClose(shift) < GetHaOpen(shift)   // Buy Bar
        && lastChangeBar != -1               //
        && lastChangeBar >= maxBarShift
    ){
        barColorChange = true;
    }

    bool maCrossed = false;
    double maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,shift);
    if(GetHaClose(shift) < maValue
        && GetLastBarBelowMA() != -1
        && GetLastBarBelowMA() >= maxBarShift){
        maCrossed = true;
    }

    bool laguCross = false;
    double laguSignal = iCustom(m_symbol, m_timeframe, "Laguerre-ACS1", 0.6, 100,2, 1, 1);
    double laguMain   = iCustom(m_symbol, m_timeframe, "Laguerre-ACS1", 0.75,100,2, 1, 1);
    if(laguSignal < laguMain
        && GetLastCrossBarIndex(-1) != -1
        && GetLastCrossBarIndex(-1) < maxBarShift){
        laguCross = true;
    }

    if(barColorChange && maCrossed && laguCross){
        return 1;
    } else {
        return 0;
    }
}

int BreakSignal::GetLastBearishBar(int start = 1){
    for(int i=start+1; i< MAX_SEARCH_BAR; i++){
        if(GetHaClose(i) < GetHaOpen(i)){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastBullishBar(int start = 1){
    for(int i=start+1; i< MAX_SEARCH_BAR; i++){
        if(GetHaClose(i) > GetHaOpen(i)){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastBarBelowMA(int start = 1){
    double maValue = 0.0;
    for(int i=start+1; i< MAX_SEARCH_BAR; i++){
        maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,i);
        if(GetHaClose(i) < maValue){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastBarUpMA(int start = 1){
    double maValue = 0.0;
    for(int i=start+1; i< MAX_SEARCH_BAR; i++){
        maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,i);
        if(GetHaClose(i) > maValue){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastCrossBarIndex(int direction, int start = 1){
    double laguSignal = 0, laguMain = 0;
    for(int i=start+1; i< MAX_SEARCH_BAR; i++){
        laguSignal = iCustom(m_symbol, m_timeframe, "Laguerre-ACS1", 0.6, 100,2, 1, i);
        laguMain   = iCustom(m_symbol, m_timeframe, "Laguerre-ACS1", 0.75,100,2, 1, i);
        if(direction == 1 && laguSignal < laguMain){
            return i;
        }
        if(direction == -1 && laguSignal > laguMain){
            return i;
        }
    }
    return -1;
}



