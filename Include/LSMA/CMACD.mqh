//+------------------------------------------------------------------+
//|                                                        CMACD.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

extern   int               m_fast_ema_period  = 12;
extern   int               m_slow_ema_period  = 26;
extern   int               m_signal_period    = 9;
extern   int               m_applied          = PRICE_CLOSE;

static string LSMA_NAME = "MACD";

enum LSMA_TREND{
   TREND_LONG,
   TREND_SHORT,
   TREND_NONE
};   

class CMACD{

private:

   string           _symbol;
   int              _timeFrame;
   int              _digits;
   int              _fast_ema_period;
   int              _slow_ema_period;
   int              _signal_period;
   int              _applied;
   
public:

   CMACD(string symbol, int timeframe=0):
               _symbol(symbol),
               _timeFrame(timeframe),
               _fast_ema_period(m_fast_ema_period),
               _slow_ema_period(m_slow_ema_period),
               _signal_period(m_signal_period),
               _applied(m_applied){
      //_currentTrend = TREND_NONE;
      //_trendStartBarShift = -1;
      //_currentValue = 0.0;
      _digits = (int)MarketInfo(_symbol,MODE_DIGITS);
   }
   
   ~CMACD(){}

   double  Main(const int index) {
      return iMACD(_symbol,_timeFrame,_fast_ema_period,_slow_ema_period,_signal_period,_applied,0,index);
   }
   double  Signal(const int index) {
      return iMACD(_symbol,_timeFrame,_fast_ema_period,_slow_ema_period,_signal_period,_applied,1,index);
   }
   
};


//+------------------------------------------------------------------+
//| Class CiMACD.                                                    |
//| Purpose: Class of the "Moving Averages                           |
//|          Convergence-Divergence" indicator.                      |
//|          Derives from class CIndicator.                          |
//+------------------------------------------------------------------+
class CiMACD
  {
protected:
   int               m_fast_ema_period;
   int               m_slow_ema_period;
   int               m_signal_period;
   int               m_applied;

public:
                     CiMACD(void);
                    ~CiMACD(void);
   //--- methods of access to protected data
   int               FastEmaPeriod(void)     const { return(m_fast_ema_period); }
   int               SlowEmaPeriod(void)     const { return(m_slow_ema_period); }
   int               SignalPeriod(void)      const { return(m_signal_period);   }
   int               Applied(void)           const { return(m_applied);         }
   //--- method of creation
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const int fast_ema_period,const int slow_ema_period,
                            const int signal_period,const int applied);
   //--- methods of access to indicator data
   double            Main(const int index) const;
   double            Signal(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_MACD); }

protected:
   //--- methods of tuning
   virtual bool      Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[]);
   bool              Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                                const int fast_ema_period,const int slow_ema_period,
                                const int signal_period,const int applied);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiMACD::CiMACD(void) : m_fast_ema_period(-1),
                       m_slow_ema_period(-1),
                       m_signal_period(-1),
                       m_applied(-1)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiMACD::~CiMACD(void)
  {
  }
//+------------------------------------------------------------------+
//| Create the "Moving Averages Convergence-Divergence" indicator    |
//+------------------------------------------------------------------+
bool CiMACD::Create(const string symbol,const ENUM_TIMEFRAMES period,
                    const int fast_ema_period,const int slow_ema_period,
                    const int signal_period,const int applied)
  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
   m_handle=iMACD(symbol,period,fast_ema_period,slow_ema_period,signal_period,applied);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(symbol,period,fast_ema_period,slow_ema_period,signal_period,applied))
     {
      //--- initialization failed
      IndicatorRelease(m_handle);
      m_handle=INVALID_HANDLE;
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize the indicator with universal parameters               |
//+------------------------------------------------------------------+
bool CiMACD::Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[])
  {
   return(Initialize(symbol,period,(int)params[0].integer_value,(int)params[1].integer_value,
          (int)params[2].integer_value,(int)params[3].integer_value));
  }
//+------------------------------------------------------------------+
//| Initialize the indicator with special parameters                 |
//+------------------------------------------------------------------+
bool CiMACD::Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                        const int fast_ema_period,const int slow_ema_period,
                        const int signal_period,const int applied)
  {
   if(CreateBuffers(symbol,period,2))
     {
      //--- string of status of drawing
      m_name  ="MACD";
      m_status="("+symbol+","+PeriodDescription()+","+
               IntegerToString(fast_ema_period)+","+IntegerToString(slow_ema_period)+","+
               IntegerToString(signal_period)+","+PriceDescription(applied)+","+") H="+IntegerToString(m_handle);
      //--- save settings
      m_fast_ema_period=fast_ema_period;
      m_slow_ema_period=slow_ema_period;
      m_signal_period  =signal_period;
      m_applied        =applied;
      //--- create buffers
      ((CIndicatorBuffer*)At(0)).Name("MAIN_LINE");
      ((CIndicatorBuffer*)At(1)).Name("SIGNAL_LINE");
      //--- ok
      return(true);
     }
//--- error
   return(false);
  }
//+------------------------------------------------------------------+
//| Access to Main buffer of "Moving Averages                        |
//|                           Convergence-Divergence"                |
//+------------------------------------------------------------------+
double CiMACD::Main(const int index) const
  {
   CIndicatorBuffer *buffer=At(0);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
//| Access to Signal buffer of "Moving Averages                      |
//|                             Convergence-Divergence"              |
//+------------------------------------------------------------------+
double CiMACD::Signal(const int index) const
  {
   CIndicatorBuffer *buffer=At(1);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }