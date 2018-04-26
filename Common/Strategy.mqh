//+------------------------------------------------------------------+
//|                                                     Strategy.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "Indicator.mqh"

interface IStrategy
{
   CSignal*       Refresh();
   int            GetIndicatorCount();
   CIndicator*    GetIndicator(int indicator);
   double         GetStopLossForOpenOrder();
};

class CStrategy{
   
public:

   CIndicator*    m_indicators[];
   int            m_count;
   CSignal   *    m_signal;
   string         m_symbol;
   int            m_timeFrame;
   
   CStrategy():m_symbol(NULL),m_timeFrame(0){
      Init();
   }
   
   CStrategy(string symbol, int timeframe){
      m_symbol = symbol;
      m_timeFrame = timeframe;
      Init();
   }
   
   void Init(){
      m_count = 0;
      m_signal = new CSignal();
   }
   
   ~CStrategy(){
      delete m_signal;
      for(int i=0; i<m_count; i++){
         delete m_indicators[i];
      }
   }
   
   void AddIndicator(CIndicator* indicator){
      m_indicators[m_count++] = indicator;
   }
   
   CSignal * Refresh(){
      // Clear last calculated signal
      m_signal.Reset();
      // Reset all indicators to false
      IndicatorsReset();
      // Get Entry Signal
      GetSignal();
      // Get Exit Signal
      GetExitSignal();
      // Return Signal
      return m_signal;
      
   }
   
   void GetSignal(){
      
      int buy = 0, sell = 0;
      for(int i=0; i< m_count; i++){
         m_indicators[i].GetSignal();
         if(m_indicators[i].m_signal.IsBuy()) buy++;
         if(m_indicators[i].m_signal.IsSell()) sell++;
      }
      
      if(buy==m_count) m_signal.SetEntrySignal(SIGNAL_BUY);
      if(sell==m_count) m_signal.SetEntrySignal(SIGNAL_SELL);
      
      //return m_signal;
   }
   
   void GetExitSignal(){
      
      int buy = 0, sell = 0, total = 0;
      for(int i=0; i< m_count; i++){
         if(m_indicators[i].m_exitSignal){
            m_indicators[i].GetExitSignal();
            if(m_indicators[i].m_signal.ExitBuy()) buy++;
            if(m_indicators[i].m_signal.ExitSell()) sell++;
            total ++;
         }
      }
      
      if(buy==total) m_signal.SetEntrySignal(SIGNAL_BUY);
      if(sell==total) m_signal.SetEntrySignal(SIGNAL_SELL);
      
      //return m_signal;
   }
   
   void IndicatorsReset(){
      for(int i=0;i<m_count;i++){
         m_indicators[i].ResetSignal();
      }
   }
   
};

