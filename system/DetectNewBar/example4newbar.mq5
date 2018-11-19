//+------------------------------------------------------------------+
//|                                               Example4NewBar.mq5 |
//|                                            Copyright 2010, Lizar |
//|                                               Lizar-2010@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Lizar"
#property link      "Lizar-2010@mail.ru"
#property version   "1.00"

#include <Lib CisNewBar.mqh>

CisNewBar current_chart;   // instance of the CisNewBar class: current chart
CisNewBar gbpusd_M1_chart; // instance of the CisNewBar class: GBPUSD chart, period M1
CisNewBar usdjpy_M2_chart; // instance of the CisNewBar class: USDJPY chart, period M2

datetime start_time;

void OnInit()
  {
   //--- initialization of class members for current chart:
   current_chart.SetSymbol(Symbol());
   current_chart.SetPeriod(Period()); 
   //--- initialization of class members for GBPUSD chart, period M1:
   start_time=TimeCurrent();
   gbpusd_M1_chart.SetSymbol("GBPUSD");
   gbpusd_M1_chart.SetPeriod(PERIOD_M1); 
   //--- initialization of class members for USDJPY chart, period M2:
   usdjpy_M2_chart.SetSymbol("USDJPY");
   usdjpy_M2_chart.SetPeriod(PERIOD_M2); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   string          symbol;
   ENUM_TIMEFRAMES period;
   int             new_bars;
   string          comment;
//--- Examine the current_chart instance of class:
   symbol = current_chart.GetSymbol();       // Get chart symbol, associated with current class instance
   period = current_chart.GetPeriod();       // Get chart period, associated with current class instance
   if(current_chart.isNewBar())              // Make request for new bar using the isNewBar() method, associated with current class instance
     {     
      comment=current_chart.GetComment();    // Get comment of executing method, associated with current class instance
      new_bars = current_chart.GetNewBars(); // Get number of new bars, associated with current class instance
      Print(symbol,GetPeriodName(period),comment," Number of new bars = ",new_bars," Time = ",TimeToString(TimeCurrent(),TIME_SECONDS));
      
      //---  Examine the gbpusd_M1_chart instance of class:
         symbol = gbpusd_M1_chart.GetSymbol();       // Get chart symbol, associated with current class instance
         period = gbpusd_M1_chart.GetPeriod();       // Get chart period, associated with current class instance
         gbpusd_M1_chart.SetLastBarTime(start_time); // Initialize m_lastbar_time with time of Expert Advisor start
         if(gbpusd_M1_chart.isNewBar())              // Make request for new bar using the isNewBar() method, associated with current class instance
           {     
            new_bars = gbpusd_M1_chart.GetNewBars(); // Get number of new bars, associated with current class instance
            Print(symbol,GetPeriodName(period)," Number of bars since Expert Advisor start = ",new_bars," Time = ",TimeToString(TimeCurrent(),TIME_SECONDS));
           }
      //---
      
      //---  Examine the gbpusd_M1_chart instance of class:
         symbol = usdjpy_M2_chart.GetSymbol();       // Get chart symbol, associated with current class instance
         period = usdjpy_M2_chart.GetPeriod();       // Get chart period, associated with current class instance
         usdjpy_M2_chart.SetLastBarTime(0);          // Initialize m_lastbar_time with zero value, thus artificially creating situation of first start
         if(usdjpy_M2_chart.isNewBar())              // Make request for new bar using the isNewBar() method, associated with current class instance
           {     
            new_bars = usdjpy_M2_chart.GetNewBars(); // Get number of new bars, associated with current class instance
            Print(symbol,GetPeriodName(period)," Number of new bars = ",new_bars," Time = ",TimeToString(TimeCurrent(),TIME_SECONDS));
           }     
         else
           {
            comment=usdjpy_M2_chart.GetComment();    // Get comment of executing method, associated with current class instance
            uint error=usdjpy_M2_chart.GetRetCode(); // Get code of error, associated with current class instance
            Print(symbol,GetPeriodName(period),comment," Error ",error," Time = ",TimeToString(TimeCurrent(),TIME_SECONDS));
           }
     }
   else
     {
      uint error=current_chart.GetRetCode(); // Get code of error, associated with current class instance
      if(error!=0)
        {
         comment=current_chart.GetComment();    // Get comment of executing method, associated with current class instance
         Print(symbol,GetPeriodName(period),comment," Error ",error," Time = ",TimeToString(TimeCurrent(),TIME_SECONDS));
        }
     }
  }

//+------------------------------------------------------------------+
//| returns string value of the period                               |
//+------------------------------------------------------------------+
string GetPeriodName(ENUM_TIMEFRAMES period)
  {
   if(period==PERIOD_CURRENT) period=Period();
//---
   switch(period)
     {
      case PERIOD_M1:  return(" M1 ");
      case PERIOD_M2:  return(" M2 ");
      case PERIOD_M3:  return(" M3 ");
      case PERIOD_M4:  return(" M4 ");
      case PERIOD_M5:  return(" M5 ");
      case PERIOD_M6:  return(" M6 ");
      case PERIOD_M10: return(" M10 ");
      case PERIOD_M12: return(" M12 ");
      case PERIOD_M15: return(" M15 ");
      case PERIOD_M20: return(" M20 ");
      case PERIOD_M30: return(" M30 ");
      case PERIOD_H1:  return(" H1 ");
      case PERIOD_H2:  return(" H2 ");
      case PERIOD_H3:  return(" H3 ");
      case PERIOD_H4:  return(" H4 ");
      case PERIOD_H6:  return(" H6 ");
      case PERIOD_H8:  return(" H8 ");
      case PERIOD_H12: return(" H12 ");
      case PERIOD_D1:  return(" Daily ");
      case PERIOD_W1:  return(" Weekly ");
      case PERIOD_MN1: return(" Monthly ");
     }
//---
   return("unknown period");
  }
  
/*     else
     {
      uint error=current_chart.GetRetCode();
      if(error!=0)
        {
         Print(symbol,GetPeriodName(period),comment," Error ",error," Time = ",TimeToString(TimeCurrent(),TIME_SECONDS));
        }
     }*/