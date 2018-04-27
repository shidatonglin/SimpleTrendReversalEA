//+------------------------------------------------------------------+
//|                                                 TestStrategy.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "Strategy.mqh"

extern bool UseMacd = false;
extern bool UseRSI  = false;
extern bool UseZigZag  = false;

class TestStrategy : public CStrategy{
   
public:
   
   CMACD *   m_macd;
   CRsi *    m_rsi;
   CZigZag * m_zigzag;
   
   TestStrategy(){
      InitIndicators();
   }
   
   void InitIndicators(){
      if(UseMacd){
         m_macd = new CMACD();
         AddIndicator(m_macd);
      }
      if(UseRSI) {
         m_rsi = new CRsi();
         AddIndicator(m_rsi);
      }
      if(UseZigZag){
         m_zigzag = new CZigZag();
         AddIndicator(m_zigzag);
      }
   }
   
};