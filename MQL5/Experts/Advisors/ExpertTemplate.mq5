//+------------------------------------------------------------------+
//|                                                   ExpertMACD.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009-2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Expert\Trailing\TrailingNone.mqh>
#include <Expert\Money\MoneyNone.mqh>

#include <Pairs.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string Inp_Expert_Title            ="ExpertMACD";
int          Expert_MagicNumber          =10981;
bool         Expert_EveryTick            =false;
//--- inputs for signal
input int    Inp_Signal_MACD_PeriodFast  =12;
input int    Inp_Signal_MACD_PeriodSlow  =24;
input int    Inp_Signal_MACD_PeriodSignal=9;
input int    Inp_Signal_MACD_TakeProfit  =50;
input int    Inp_Signal_MACD_StopLoss    =20;
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
const int pairCount = ArraySize(pairs);

CExpert experts[28];

int OnInit(void)
  {
   
   
   Print("found " + IntegerToString( pairCount ) + " pairs");
   
   for(int i=0;i<pairCount;i++){
      //--- Initializing expert
      if(!experts[i].Init(pairs[i],Period(),Expert_EveryTick,Expert_MagicNumber,Inp_Expert_Title))
        {
         //--- failed
         printf(__FUNCTION__+": error initializing expert");
         experts[i].Deinit();
         return(-1);
        }
   //--- Creation of signal object
      CSignalMACD *signal=new CSignalMACD;
      if(signal==NULL)
        {
         //--- failed
         printf(__FUNCTION__+": error creating signal");
         experts[i].Deinit();
         return(-2);
        }
   //--- Add signal to expert (will be deleted automatically))
      if(!experts[i].InitSignal(signal))
        {
         //--- failed
         printf(__FUNCTION__+": error initializing signal");
         experts[i].Deinit();
         return(-3);
        }
   //--- Set signal parameters
      signal.PeriodFast(Inp_Signal_MACD_PeriodFast);
      signal.PeriodSlow(Inp_Signal_MACD_PeriodSlow);
      signal.PeriodSignal(Inp_Signal_MACD_PeriodSignal);
      signal.TakeLevel(Inp_Signal_MACD_TakeProfit);
      signal.StopLevel(Inp_Signal_MACD_StopLoss);
   //--- Check signal parameters
      if(!signal.ValidationSettings())
        {
         //--- failed
         printf(__FUNCTION__+": error signal parameters");
         experts[i].Deinit();
         return(-4);
        }
   //--- Creation of trailing object
      CTrailingNone *trailing=new CTrailingNone;
      if(trailing==NULL)
        {
         //--- failed
         printf(__FUNCTION__+": error creating trailing");
         experts[i].Deinit();
         return(-5);
        }
   //--- Add trailing to expert (will be deleted automatically))
      if(!experts[i].InitTrailing(trailing))
        {
         //--- failed
         printf(__FUNCTION__+": error initializing trailing");
         experts[i].Deinit();
         return(-6);
        }
   //--- Set trailing parameters
   //--- Check trailing parameters
      if(!trailing.ValidationSettings())
        {
         //--- failed
         printf(__FUNCTION__+": error trailing parameters");
         experts[i].Deinit();
         return(-7);
        }
   //--- Creation of money object
      CMoneyNone *money=new CMoneyNone;
      if(money==NULL)
        {
         //--- failed
         printf(__FUNCTION__+": error creating money");
         experts[i].Deinit();
         return(-8);
        }
   //--- Add money to expert (will be deleted automatically))
      if(!experts[i].InitMoney(money))
        {
         //--- failed
         printf(__FUNCTION__+": error initializing money");
         experts[i].Deinit();
         return(-9);
        }
   //--- Set money parameters
   //--- Check money parameters
      if(!money.ValidationSettings())
        {
         //--- failed
         printf(__FUNCTION__+": error money parameters");
         experts[i].Deinit();
         return(-10);
        }
   //--- Tuning of all necessary indicators
      if(!experts[i].InitIndicators())
        {
         //--- failed
         printf(__FUNCTION__+": error initializing indicators");
         experts[i].Deinit();
         return(-11);
        }
      //experts[i]=ExtExpert;
   }
   

//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=0; i< pairCount;i++)
   experts[i].Deinit();
  }
//+------------------------------------------------------------------+
//| Function-event handler "tick"                                    |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   for(int i=0; i< pairCount;i++){
      experts[i].OnTick();
   }
  }
//+------------------------------------------------------------------+
//| Function-event handler "trade"                                   |
//+------------------------------------------------------------------+
void OnTrade(void)
  {
   for(int i=0; i< pairCount;i++){
      experts[i].OnTrade();
   }
  }
//+------------------------------------------------------------------+
//| Function-event handler "timer"                                   |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
   for(int i=0; i< pairCount;i++){
      experts[i].OnTimer();
   }
  }
//+------------------------------------------------------------------+
