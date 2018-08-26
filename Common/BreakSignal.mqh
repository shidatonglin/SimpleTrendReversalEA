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
   int     m_digits;
   double  m_gamma_small;
   double  m_gamma_big;

public:
   BreakSignal(void);
   BreakSignal(string, int);
   ~BreakSignal();
   bool   Init(string, int);
   void   InitLagu(double, double);
//   bool   InitMa(int,int);
   string Symbol();
   void   Symbol(string symbol);
   double GetHaOpen(int);
   double GetHaClose(int);
   int    GetBuySignal(int, int);
   int    GetSellSignal(int, int);
   int    GetLastBullishBar(int);
   int    GetLastBearishBar(int);
   int    GetLastBarBelowMA(int);
   int    GetLastBarUpMA(int);
   int    GetLastCrossBarIndex(int, int);

   double GetLaguMain(double, int);
   double GetMaValue(int);
   int    GetSignal();
   //double GetHaHigh(int);
   //double GetHaLow(int);
//   double GetMaValue(int,int);
};

BreakSignal::BreakSignal(void):m_symbol(NULL),
                               m_timeframe(PERIOD_H4),
                               m_gamma_small(0.6),
                               m_gamma_big(0.75)
{
   m_digits = MarketInfo(m_symbol, MODE_DIGITS);
}

BreakSignal::BreakSignal(string symbol, int timeframe):m_symbol(symbol),
                                                        m_timeframe(timeframe),
                                                        m_gamma_small(0.6),
                                                        m_gamma_big(0.75)
{

}

BreakSignal::~BreakSignal(void){}

bool BreakSignal::Init(string symbol, int timeframe){
    m_symbol = symbol;
    m_timeframe = timeframe;
    m_digits = MarketInfo(m_symbol, MODE_DIGITS);
    return true;
}

void InitLagu(double gamma_big, double gamma_small){
   //m_gamma_big = gamma_big;
   //m_gamma_small = gamma_small;
}

string BreakSignal::Symbol(){
    return m_symbol;
}

void BreakSignal::Symbol(string symbol){
    m_symbol = symbol;
}


//bool BreakSignal::InitMa(int period, int shift){
//   m_shift_ma = shift;
//   m_period_ma = period;
//   return true;
//}

//double BreakSignal::GetMaValue(int barShift){
//   return iMA(m_symbol, m_timeframe, m_period_ma, m_shift_ma, MODE_EMA,PRICE_CLOSE,barShift);
//}

double BreakSignal::GetHaOpen(int shift=1){
	return NormalizeDouble(iCustom(m_symbol, m_timeframe, "Heiken Ashi", 0,0,0,0, 2, shift),m_digits);
}

double BreakSignal::GetHaClose(int shift=1){
	return NormalizeDouble(iCustom(m_symbol, m_timeframe, "Heiken Ashi", 0,0,0,0, 3, shift),m_digits);
}

int BreakSignal::GetBuySignal(int maxBarShift, int shift = 1){

    // For buy signal
    bool barColorChange = false;
    int lastChangeBar = GetLastBearishBar(shift);

    if(GetHaClose(shift) > GetHaOpen(shift)   // Buy Bar
        && lastChangeBar != -1               //
        && lastChangeBar <= (maxBarShift + shift)
    ){
        barColorChange = true;
    }

    bool maCrossed = false;
    //double maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,shift);
    double maValue = GetMaValue(shift);
    if(GetHaClose(shift) > maValue
        && GetLastBarBelowMA(shift) != -1
        && GetLastBarBelowMA(shift) <= (maxBarShift + shift)){
        maCrossed = true;
    }

    bool laguCross = false;
    double laguSignal = GetLaguMain(m_gamma_small,shift);
    double laguMain   = GetLaguMain(m_gamma_big,shift);
    //Print("shift-->",shift);
    //Print("laguSignal-->",laguSignal);
    //Print("laguMain-->",laguMain);
    if(laguSignal > laguMain
        && GetLastCrossBarIndex(1,shift) != -1
        && GetLastCrossBarIndex(1,shift) < (maxBarShift + shift)){
        laguCross = true;
    }

    //Print("barColorChange-->",barColorChange);

    //Print("maCrossed-->",maCrossed);

    //Print("laguCross-->",laguCross);

    if(barColorChange && maCrossed && laguCross){
        return 1;
    } else {
        return 0;
    }
}

int BreakSignal::GetSellSignal(int maxBarShift, int shift = 1){
    // For Sell signal
    bool barColorChange = false;
    int lastChangeBar = GetLastBullishBar(shift);
    //Print("lastChangeBar-->",lastChangeBar);
    //Print("GetHaClose(shift)-->",GetHaClose(shift));
    //Print("GetHaOpen(shift)-->",GetHaOpen(shift));
    if(GetHaClose(shift) < GetHaOpen(shift)   // Buy Bar
        && lastChangeBar != -1               //
        && lastChangeBar <= (maxBarShift + shift)
    ){
        barColorChange = true;
    }

    bool maCrossed = false;
    //double maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,shift);
    double maValue = GetMaValue(shift);
    //Print("maValue-->",maValue);
    //Print("GetHaClose(shift)-->",GetHaClose(shift));
    //Print("GetLastBarUpMA(shift)-->",GetLastBarUpMA(shift));
    if(GetHaClose(shift) < maValue
        && GetLastBarUpMA(shift) != -1
        && GetLastBarUpMA(shift) <= (maxBarShift + shift)){
        maCrossed = true;
    }

    bool laguCross = false;
    double laguSignal = GetLaguMain(m_gamma_small,shift);
    double laguMain   = GetLaguMain(m_gamma_big,shift);
    //Print("laguSignal-->",laguSignal);
    //Print("laguMain-->",laguMain);
    //Print("GetLastCrossBarIndex(-1,shift)-->",GetLastCrossBarIndex(-1,shift));
    if(laguSignal < laguMain
        && GetLastCrossBarIndex(-1,shift) != -1
        && GetLastCrossBarIndex(-1,shift) <= (maxBarShift + shift)){
        laguCross = true;
    }

    //Print("barColorChange-->",barColorChange);

    //Print("maCrossed-->",maCrossed);

    //Print("laguCross-->",laguCross);

    if(barColorChange && maCrossed && laguCross){
        return 1;
    } else {
        return 0;
    }
}

int BreakSignal::GetLastBearishBar(int start = 1){
    for(int i=start+1; i< start+MAX_SEARCH_BAR; i++){
        if(GetHaClose(i) < GetHaOpen(i)){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastBullishBar(int start = 1){
    for(int i=start+1; i< start+MAX_SEARCH_BAR; i++){
        if(GetHaClose(i) > GetHaOpen(i)){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastBarBelowMA(int start = 1){
    double maValue = 0.0;
    for(int i=start+1; i< start+MAX_SEARCH_BAR; i++){
        //maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,i);
        maValue = GetMaValue(i);
        //Print((i),"--->",maValue);
        if(GetHaClose(i) < maValue){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastBarUpMA(int start = 1){
    double maValue = 0.0;
    for(int i=start+1; i< start+MAX_SEARCH_BAR; i++){
        //maValue = iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,i);
        maValue = GetMaValue(i);
        if(GetHaClose(i) > maValue){
            return i;
        }
    }
    return -1;
}

int BreakSignal::GetLastCrossBarIndex(int direction, int start = 1){
    double laguSignal = 0, laguMain = 0;
    for(int i=start+1; i< start+MAX_SEARCH_BAR; i++){
        //laguSignal = iCustom(m_symbol, m_timeframe, "Laguerre-ACS1", 0.6, 1000,2, 0, i);
        //laguMain   = iCustom(m_symbol, m_timeframe, "Laguerre-ACS1", 0.75,1000,2, 0, i);
        laguSignal = GetLaguMain(0.6,i);
        laguMain = GetLaguMain(0.75,i);
        //Print((i),"--->",laguSignal);
        if(direction == 1 && laguSignal <= laguMain){
            return i;
        }
        if(direction == -1 && laguSignal >= laguMain){
            return i;
        }
    }
    return -1;
}

double BreakSignal::GetLaguMain(double gamma,int shift=1){
   return NormalizeDouble(iCustom(m_symbol, m_timeframe, "Laguerre-ACS1",
                                 gamma,500,2, 0, shift),2);
}


double BreakSignal::GetMaValue(int shift=1){
   return NormalizeDouble(iMA(m_symbol, m_timeframe, 5, 2, MODE_EMA,PRICE_CLOSE,shift), m_digits);
}

int BreakSignal::GetSignal(){
    if(GetBuySignal(3) > 0) return 1;
    if(GetSellSignal(3) > 0) return -1;
    return 0;
}
