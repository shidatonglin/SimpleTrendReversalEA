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

   ENUM_SIGNAL_TYPE    m_entry_signal;
   ENUM_EXIT_SIGNAL    m_exit_signal;
   double              m_stoploss;
   
public:

   bool   IsBuy()    { return (m_entry_signal==SIGNAL_BUY)  ;}
   bool   IsSell()   { return (m_entry_signal==SIGNAL_SELL) ;}
   double StopLoss() { return (m_stoploss)                  ;}
   bool   ExitBuy()  { return (m_exit_signal==EXIT_BUY)     ;}
   bool   ExitSell() { return (m_exit_signal==EXIT_SELL)    ;}
   
   // Set Entry Signal
   void SetEntrySignal(ENUM_SIGNAL_TYPE entrySignal){
      m_entry_signal = entrySignal;
   }

   // Set Exit Signal
   void SetExitSignal(ENUM_EXIT_SIGNAL exitSignal){
      m_exit_signal = exitSignal;
   }
   
   //--------------------------------------------------------------------
   void Reset()
   {
      m_entry_signal = SIGNAL_NONE;
      m_exit_signal = EXIT_NONE;
      m_stoploss = 0;
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