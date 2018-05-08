//+------------------------------------------------------------------+
//|                                                   TestSignal.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Expert\ExpertSignal.mqh>

class TestSignal : public CExpertSignal{
   
   public:
                     TestSignal(void);
                     ~TestSignal(void);
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);
};


//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool TestSignal::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_period_fast>=m_period_slow)
     {
      printf(__FUNCTION__+": slow period must be greater than fast period");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool TestSignal::InitIndicators(CIndicators *indicators)
  {
//--- check of pointer is performed in the method of the parent class
//---
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize MACD oscilator
   if(!InitMACD(indicators))
      return(false);
//--- ok
   return(true);
  }
  
