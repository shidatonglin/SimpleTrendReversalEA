extern double atr_p = 15;                           //ATR/HiLo period for dynamic SL/TP/TS
extern double atr_x = 1;                            //ATR weight in SL/TP/TS
extern double hilo_x = 0.5;                         //HiLo weight in SL/TP/TS
double sl_p = 0;                                    //Raw pips offset

extern double pf = 20;                             //Targeted profit factor (x times SL)
extern double tf = 0.8;                             //Trailing factor (x times Sl)


class CStopeBase{

private:

    string      m_symbol;
    int         m_timeframe;
    double      m_spread;
    int         m_digits;
    double      m_points;


public:

    CStopeBase();
    CStopeBase(string, int);
    void Init();
    double GetStopLoss();
    double GetTakeProfit();
    ~CStopeBase();
};

CStopeBase::CStopeBase():m_symbol(NULL),
                         m_timeframe(0)
{
    Init();
}

CStopeBase::CStopeBase(string symbol, int timeframe):m_symbol(symbol),
                                                     m_timeframe(timeframe)
{
    Init();
}

CStopeBase::~CStopeBase(){}

void CStopeBase::Init(){
    m_points = MarketInfo (m_symbol, MODE_POINT);
    m_spread = MarketInfo(m_symbol, MODE_SPREAD) * m_points;
    m_digits = MarketInfo (m_symbol, MODE_DIGITS);
}

double CStopeBase::GetStopLoss(){
    double atr1 = iATR(m_symbol,m_timeframe,atr_p,0);// Period 15
    double atr2 = iATR(m_symbol,m_timeframe,2*atr_p,0);// Period 30
    double atr3 = NormalizeDouble(((atr1+atr2)/2)*atr_x,m_digits);// Atr weight 1 in SL?TP/TSL

    double ma1 = iMA(m_symbol,m_timeframe,atr_p*2,0,MODE_LWMA,PRICE_HIGH,0);// 30 MA High
    double ma2 = iMA(m_symbol,m_timeframe,atr_p*2,0,MODE_LWMA,PRICE_LOW,0);// 30 Ma Low
    double ma3 = NormalizeDouble(hilo_x*(ma1 - ma2),m_digits);// HiLo weight 0.5 in SL/TP/TSL

    //--- SL & TP calculation
    double sl_p1 = NormalizeDouble(m_points*sl_p/((1/(iClose(symbol,0)+(m_spread/2)))),m_digits);
    SLp = sl_p1 + atr3 + ma3;// (atr15+atr30)/2 + (ma30High-ma30Low)/2
    TPp = NormalizeDouble(pf*(SLp),m_digits); // 3.5 SLP
    TSp = NormalizeDouble(tf*(SLp),m_digits); //0.8 SLP
}

