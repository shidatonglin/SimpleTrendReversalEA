//+------------------------------------------------------------------+
//|                                                       Signal.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

enum ENUM_SIGNAL_TYPE{
   SIGNAL_BUY = 0,
   SIGNAL_SELL = 1,
   SIGNAL_NONE = 2
};

enum ENUM_EXIT_SIGNAL{
   EXIT_BUY = 0,
   EXIT_SELL = 1,
   EXIT_NONE = 2
};


class CSignal{

private:

   ENUM_SIGNAL_TYPE    _signal_type;
   ENUM_EXIT_SIGNAL    _exit_type;
   double              _StopLoss;
   
public:
   
   bool   IsBuy(){ return (_signal_type==SIGNAL_BUY);}
   bool   IsSell(){ return (_signal_type==SIGNAL_SELL);}
   double StopLoss(){ return _StopLoss;}
   bool   ExitBuy(){ return (_exit_type==EXIT_BUY);}
   bool   ExitSell(){ return (_exit_type==EXIT_SELL);}
   
   void buySiganl(){
      _signal_type = SIGNAL_BUY;
   }
   void sellSiganl(){
      _signal_type = SIGNAL_SELL;
   }
   
   void exitBuy(){
      _exit_type==EXIT_BUY;
   }
   
   void exitSell(){
      _exit_type==EXIT_SELL;
   }
   
   //--------------------------------------------------------------------
   void Reset()
   {
      _signal_type = SIGNAL_NONE;
      _exit_type = EXIT_NONE;
      _StopLoss = 0;
      /*
      IsBuy    = false;
      IsSell   = false;
      StopLoss = 0;
      ExitBuy  = false;
      ExitSell = false;
      */
   }
};

/*
enum ENUM_SIGNAL_TYPE{
   SIGNAL_BUY = 0,
   SIGNAL_SELL = 1,
   SIGNAL_NONE = 2
};

enum ENUM_EXIT_SIGNAL{
   EXIT_BUY = 0,
   EXIT_SELL = 1,
   EXIT_NONE = 2
};

class CSignal{

private:

   ENUM_SIGNAL_TYPE  m_signal;
   ENUM_EXIT_SIGNAL  m_exitSignal;
   double            m_stopLoss;
   
public:
   
   void Reset(){
      m_signal = SIGNAL_NONE;
      m_exitSignal = EXIT_NONE;
      m_stopLoss = 0;
   }
   
   void SetSignal(ENUM_SIGNAL_TYPE signal){m_signal = signal;}
   ENUM_SIGNAL_TYPE GetSignal(){return m_signal;}
   
   void SetExitSignal(ENUM_EXIT_SIGNAL exit_signal){m_exitSignal = exit_signal;}
   ENUM_EXIT_SIGNAL GetExitSignal(){return m_exitSignal;}
   
   void SetStopLoss(double sl){m_stopLoss = sl;}
   double GetStopLoss(){return m_stopLoss;}
   
   CSignal(){}
   ~CSignal(){}
};

*/