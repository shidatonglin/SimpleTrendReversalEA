//+------------------------------------------------------------------+
//|                                                HABreakSignal.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <Utility\CUtility.mqh>

class SignalBase{

private:
    string  m_symbol;
    int     m_low_tf;
    int     m_high_tf;
    int     m_digits;
public:
    SignalBase();
    ~SignalBase();
    void Init(string, int, int);
};

SignalBase::SignalBase():m_symbol(NULL),
                         m_low_tf(0){
    m_high_tf = CUtility.NextHigherTF(m_low_tf);
}

SignalBase::~SignalBase(){

}

void SignalBase::Init(string symbol, int low_tf, int high_tf){
    m_symbol = symbol;
    m_low_tf = low_tf;
    m_high_tf = high_tf;
}


