//+------------------------------------------------------------------+
//|                                                    Indicator.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "Signal.mqh"
class CIndicator{
   
public:

   string                     m_name;
   bool                       m_valid;
   bool                       m_exitSignal;
   CSignal *                  m_signal;
   
   //virtual ENUM_SIGNAL_TYPE   GetSignal();
   
   //virtual ENUM_EXIT_SIGNAL   GetExitSignal();
   virtual void               GetSignal();
   virtual void               GetExitSignal();
   void ResetSignal(){
      m_signal.Reset();
   }
   
   CIndicator(string name){
      m_name = name;
      m_valid = false;
      m_exitSignal = false;
      m_signal = new CSignal();
   }
   
   ~CIndicator(){
      delete m_signal;
   }
};


class CMACD : public CIndicator{

   void GetSignal(){
      //m_signal.Reset();
      m_signal.buySiganl();
   }
   
};

class CRsi : public CIndicator{

   void   GetSignal(){
      //m_signal.Reset();
      m_signal.sellSiganl();
   }
};

class CZigZag : public CIndicator{

   void   GetSignal(){
      //m_signal.Reset();
      m_signal.sellSiganl();
   }
};
