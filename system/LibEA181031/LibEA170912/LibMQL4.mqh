//LibMQL4.mqh for MQL5

//for Indicator functions
#define MODE_MAIN 0
#define MODE_SIGNAL 1
#define MODE_UPPER 1
#define MODE_LOWER 2
#define MODE_PLUSDI 1
#define MODE_MINUSDI 2
#define MODE_GATORJAW 0
#define MODE_GATORTEETH 1
#define MODE_GATORLIPS 2
#define MODE_TENKANSEN 0
#define MODE_KIJUNSEN 1
#define MODE_SENKOUSPANA 2
#define MODE_SENKOUSPANB 3
#define MODE_CHIKOUSPAN 4

//for iHighest() and iLowest()
#define MODE_OPEN 0
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_CLOSE 3

//#define MY_BUFFER_SIZE 1000
#define MY_BUFFER_SIZE 100

//同時にオープンする指標の数
#define MAX_IND 8

double iOpen(string symbol, ENUM_TIMEFRAMES timeframe, int shift)
{
   double buf[1];
   CopyOpen(symbol, timeframe, shift, 1, buf);
   return buf[0];
}

double iLow(string symbol, ENUM_TIMEFRAMES timeframe, int shift)
{
   double buf[1];
   CopyLow(symbol, timeframe, shift, 1, buf);
   return buf[0];
}

double iHigh(string symbol, ENUM_TIMEFRAMES timeframe, int shift)
{
   double buf[1];
   CopyHigh(symbol, timeframe, shift, 1, buf);
   return buf[0];
}

double iClose(string symbol, ENUM_TIMEFRAMES timeframe, int shift)
{
   double buf[1];
   CopyClose(symbol, timeframe, shift, 1, buf);
   return buf[0];
}

datetime iTime(string symbol, ENUM_TIMEFRAMES timeframe, int shift)
{
   datetime buf[1];
   CopyTime(symbol, timeframe, shift, 1, buf);
   return buf[0];
}

long iVolume(string symbol, ENUM_TIMEFRAMES timeframe, int shift)
{
   long buf[1];
   CopyTickVolume(symbol, timeframe, shift, 1, buf);
   return buf[0];
}

int iHighest(string symbol, ENUM_TIMEFRAMES timeframe, int type,
             int count, int start)
{
   double buf[MY_BUFFER_SIZE];
   switch(type)
   {
      case MODE_OPEN:
         CopyOpen(symbol, timeframe, start, count, buf);
         break;
      case MODE_LOW:
         CopyLow(symbol, timeframe, start, count, buf);
         break;
      case MODE_HIGH:
         CopyHigh(symbol, timeframe, start, count, buf);
         break;
      case MODE_CLOSE:
         CopyClose(symbol, timeframe, start, count, buf);
         break;
   }
   return count-1-ArrayMaximum(buf, 0, count)+start;
}

int iLowest(string symbol, ENUM_TIMEFRAMES timeframe, int type,
            int count, int start)
{
   double buf[MY_BUFFER_SIZE];
   switch(type)
   {
      case MODE_OPEN:
         CopyOpen(symbol, timeframe, start, count, buf);
         break;
      case MODE_LOW:
         CopyLow(symbol, timeframe, start, count, buf);
         break;
      case MODE_HIGH:
         CopyHigh(symbol, timeframe, start, count, buf);
         break;
      case MODE_CLOSE:
         CopyClose(symbol, timeframe, start, count, buf);
         break;
   }
   return count-1-ArrayMinimum(buf, 0, count)+start;
}

int Year()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.year;
}

int Month()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.mon;
}

int Day()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.day;
}

int Hour()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.hour;
}

int Minute()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.min;
}

int Seconds()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.sec;
}

int DayOfWeek()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.day_of_week;
}

int DayOfYear()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.day_of_year;
}

int TimeYear(datetime val)
{
   MqlDateTime dt;
   TimeToStruct(val, dt);
   return dt.year;
}

int TimeMonth(datetime val)
{
   MqlDateTime dt;
   TimeToStruct(val, dt);
   return dt.mon;
}

int TimeDay(datetime val)
{
   MqlDateTime dt;
   TimeToStruct(val, dt);
   return dt.day;
}

int TimeHour(datetime val)
{
   MqlDateTime dt;
   TimeToStruct(val, dt);
   return dt.hour;
}

int TimeMinute(datetime val)
{
   MqlDateTime dt;
   TimeToStruct(val, dt);
   return dt.min;
}

int TimeSeconds(datetime val)
{
   MqlDateTime dt;
   TimeToStruct(val, dt);
   return dt.sec;
}

int TimeDayOfWeek(datetime val)
{
   MqlDateTime dt;
   TimeToStruct(val, dt);
   return dt.day_of_week;
}

int TimeDayOfYear(datetime val)
{
   MqlDateTime dt;
   TimeToStruct(val, dt);
   return dt.day_of_year;
}

//ACオシレータ
double iAC(string symbol,
           ENUM_TIMEFRAMES timeframe,
           int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];

   int i;
   for(i=0; i<MAX_IND; i++)
   {   
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]) break;
      }
      else
      {
         handle[i] = iAC(symbol, timeframe);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//A/D
double iAD(string symbol,
           ENUM_TIMEFRAMES timeframe,
           int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];

   int i;
   for(i=0; i<MAX_IND; i++)
   {   
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]) break;
      }
      else
      {
         handle[i] = iAD(symbol, timeframe, VOLUME_TICK);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//ADX
double iADX(string symbol,
            ENUM_TIMEFRAMES timeframe,
            int period,
            ENUM_APPLIED_PRICE applied_price,
            int mode,
            int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]) break;
      }
      else
      {
         handle[i] = iADX(symbol, timeframe, period);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], mode, shift, 1, buf);
   return buf[0];
}

//アリゲーター
double iAlligator(string symbol,
                  ENUM_TIMEFRAMES timeframe,
                  int jaw_period,
                  int jaw_shift,
                  int teeth_period,
                  int teeth_shift,
                  int lips_period,
                  int lips_shift,
                  ENUM_MA_METHOD ma_method,
                  ENUM_APPLIED_PRICE applied_price,
                  int mode,
                  int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _jaw_period[MAX_IND];
   static int _jaw_shift[MAX_IND];
   static int _teeth_period[MAX_IND];
   static int _teeth_shift[MAX_IND];
   static int _lips_period[MAX_IND];
   static int _lips_shift[MAX_IND];
   static ENUM_MA_METHOD _ma_method[MAX_IND];
   static ENUM_APPLIED_PRICE _applied_price[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && jaw_period == _jaw_period[i]
         && jaw_shift == _jaw_shift[i]
         && teeth_period == _teeth_period[i]
         && teeth_shift == _teeth_shift[i]
         && lips_period == _lips_period[i]
         && lips_shift == _lips_shift[i]
         && ma_method == _ma_method[i]
         && applied_price == _applied_price[i]) break;
      }
      else
      {
         handle[i] = iAlligator(symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, applied_price);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _jaw_period[i] = jaw_period;
         _jaw_shift[i] = jaw_shift;
         _teeth_period[i] = teeth_period;
         _teeth_shift[i] = teeth_shift;
         _lips_period[i] = lips_period;
         _lips_shift[i] = lips_shift;
         _ma_method[i] = ma_method;
         _applied_price[i] = applied_price;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], mode, shift, 1, buf);
   return buf[0];
}

//オーサムオシレーター
double iAO(string symbol,
           ENUM_TIMEFRAMES timeframe,
           int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];

   int i;
   for(i=0; i<MAX_IND; i++)
   {   
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]) break;
      }
      else
      {
         handle[i] = iAO(symbol, timeframe);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//ATR
double iATR(string symbol,
            ENUM_TIMEFRAMES timeframe,
            int ma_period,
            int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _ma_period[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && ma_period == _ma_period[i]) break;
      }
      else
      {
         handle[i] = iATR(symbol, timeframe, ma_period);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _ma_period[i] = ma_period;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//ベアパワー
double iBearsPower(string symbol,
                   ENUM_TIMEFRAMES timeframe,
                   int period,
                   ENUM_APPLIED_PRICE applied_price,
                   int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]) break;
      }
      else
      {
         handle[i] = iBearsPower(symbol, timeframe, period);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
} 

//ボリンジャーバンド
double iBands(string symbol,
              ENUM_TIMEFRAMES timeframe,
              int period,
              double deviation,
              int bands_shift,
              ENUM_APPLIED_PRICE applied_price,
              int mode,
              int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];
   static double _deviation[MAX_IND];
   static int _bands_shift[MAX_IND];
   static ENUM_APPLIED_PRICE _applied_price[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]
         && deviation == _deviation[i]
         && bands_shift == _bands_shift[i]
         && applied_price == _applied_price[i]) break;
      }
      else
      {
         handle[i] = iBands(symbol, timeframe, period, bands_shift, deviation, applied_price);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         _deviation[i] = deviation;
         _bands_shift[i] = bands_shift;
         _applied_price[i] = applied_price;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], mode, shift, 1, buf);
   return buf[0];
}

//ブルパワー
double iBullsPower(string symbol,
                   ENUM_TIMEFRAMES timeframe,
                   int period,
                   ENUM_APPLIED_PRICE applied_price,
                   int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]) break;
      }
      else
      {
         handle[i] = iBullsPower(symbol, timeframe, period);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
} 

//CCI
double iCCI(string symbol,
                   ENUM_TIMEFRAMES timeframe,
                   int period,
                   ENUM_APPLIED_PRICE applied_price,
                   int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];
   static ENUM_APPLIED_PRICE _applied_price[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]
         && applied_price == _applied_price[i]) break;
      }
      else
      {
         handle[i] = iCCI(symbol, timeframe, period, applied_price);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         _applied_price[i] = applied_price;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
} 

//デマーカー
double iDeMarker(string symbol,
            ENUM_TIMEFRAMES timeframe,
            int ma_period,
            int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _ma_period[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && ma_period == _ma_period[i]) break;
      }
      else
      {
         handle[i] = iDeMarker(symbol, timeframe, ma_period);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _ma_period[i] = ma_period;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//エンベロープ
double iEnvelopes(string symbol,
                  ENUM_TIMEFRAMES timeframe,
                  int ma_period,
                  ENUM_MA_METHOD ma_method,
                  int ma_shift,
                  ENUM_APPLIED_PRICE applied_price,
                  double deviation,
                  int mode,
                  int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _ma_period[MAX_IND];
   static ENUM_MA_METHOD _ma_method[MAX_IND];
   static int _ma_shift[MAX_IND];
   static ENUM_APPLIED_PRICE _applied_price[MAX_IND];
   static double _deviation[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && ma_period == _ma_period[i]
         && ma_method == _ma_method[i]
         && ma_shift == _ma_shift[i]
         && applied_price == _applied_price[i]
         && deviation == _deviation[i]) break;
      }
      else
      {
         handle[i] = iEnvelopes(symbol, timeframe, ma_period, ma_shift, ma_method, applied_price, deviation);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _ma_period[i] = ma_period;
         _ma_method[i] = ma_method;
         _ma_shift[i] = ma_shift;
         _applied_price[i] = applied_price;
         _deviation[i] = deviation;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], mode, shift, 1, buf);
   return buf[0];
}

//勢力指数
double iForce(string symbol,
           ENUM_TIMEFRAMES timeframe,
           int period,
           ENUM_MA_METHOD ma_method,
           ENUM_APPLIED_PRICE applied_price,
           int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];
   static ENUM_MA_METHOD _ma_method[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]
         && ma_method == _ma_method[i]) break;
      }
      else
      {
         handle[i] = iForce(symbol, timeframe, period, ma_method, VOLUME_TICK);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         _ma_method[i] = ma_method;
         break;
      }
   }
   if(i == MAX_IND) return 0;
   
   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//フラクタル
double iFractals(string symbol,
                 ENUM_TIMEFRAMES timeframe,
                 int mode,
                 int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];

   int i;
   for(i=0; i<MAX_IND; i++)
   {   
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]) break;
      }
      else
      {
         handle[i] = iFractals(symbol, timeframe);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], mode-1, shift, 1, buf);
   return buf[0];
}

//ゲーターオシレーター
double iGator(string symbol,
              ENUM_TIMEFRAMES timeframe,
              int jaw_period,
              int jaw_shift,
              int teeth_period,
              int teeth_shift,
              int lips_period,
              int lips_shift,
              ENUM_MA_METHOD ma_method,
              ENUM_APPLIED_PRICE applied_price,
              int mode,
              int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _jaw_period[MAX_IND];
   static int _jaw_shift[MAX_IND];
   static int _teeth_period[MAX_IND];
   static int _teeth_shift[MAX_IND];
   static int _lips_period[MAX_IND];
   static int _lips_shift[MAX_IND];
   static ENUM_MA_METHOD _ma_method[MAX_IND];
   static ENUM_APPLIED_PRICE _applied_price[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && jaw_period == _jaw_period[i]
         && jaw_shift == _jaw_shift[i]
         && teeth_period == _teeth_period[i]
         && teeth_shift == _teeth_shift[i]
         && lips_period == _lips_period[i]
         && lips_shift == _lips_shift[i]
         && ma_method == _ma_method[i]
         && applied_price == _applied_price[i]) break;
      }
      else
      {
         handle[i] = iGator(symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, applied_price);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _jaw_period[i] = jaw_period;
         _jaw_shift[i] = jaw_shift;
         _teeth_period[i] = teeth_period;
         _teeth_shift[i] = teeth_shift;
         _lips_period[i] = lips_period;
         _lips_shift[i] = lips_shift;
         _ma_method[i] = ma_method;
         _applied_price[i] = applied_price;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], (mode-1)*2, shift, 1, buf);
   return buf[0];
}

//一目均衡表
double iIchimoku(string symbol,
                 ENUM_TIMEFRAMES timeframe,
                 int tenkan_sen,
                 int kijun_sen,
                 int senkou_span_b,
                 int mode,
                 int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _tenkan_sen[MAX_IND];
   static int _kijun_sen[MAX_IND];
   static int _senkou_span_b[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && tenkan_sen == _tenkan_sen[i]
         && kijun_sen == _kijun_sen[i]
         && senkou_span_b == _senkou_span_b[i]) break;
      }
      else
      {
         handle[i] = iIchimoku(symbol, timeframe, tenkan_sen, kijun_sen, senkou_span_b);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _tenkan_sen[i] = tenkan_sen;
         _kijun_sen[i] = kijun_sen;
         _senkou_span_b[i] = senkou_span_b;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], mode, shift, 1, buf);
   return buf[0];
}

//BWMFI
double iBWMFI(string symbol,
              ENUM_TIMEFRAMES timeframe,
              int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];

   int i;
   for(i=0; i<MAX_IND; i++)
   {   
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]) break;
      }
      else
      {
         handle[i] = iBWMFI(symbol, timeframe, VOLUME_TICK);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//モメンタム
double iMomentum(string symbol,
                 ENUM_TIMEFRAMES timeframe,
                 int period,
                 ENUM_APPLIED_PRICE applied_price,
                 int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];
   static ENUM_APPLIED_PRICE _applied_price[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]
         && applied_price == _applied_price[i]) break;
      }
      else
      {
         handle[i] = iMomentum(symbol, timeframe, period, applied_price);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         _applied_price[i] = applied_price;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//MFI
double iMFI(string symbol,
            ENUM_TIMEFRAMES timeframe,
            int period,
            int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];

   int i;
   for(i=0; i<MAX_IND; i++)
   {   
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]) break;
      }
      else
      {
         handle[i] = iMFI(symbol, timeframe, period, VOLUME_TICK);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//移動平均
double iMA(string symbol,
           ENUM_TIMEFRAMES timeframe,
           int period,
           int ma_shift,
           ENUM_MA_METHOD ma_method,
           ENUM_APPLIED_PRICE applied_price,
           int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];
   static int _ma_shift[MAX_IND];
   static ENUM_MA_METHOD _ma_method[MAX_IND];
   static ENUM_APPLIED_PRICE _applied_price[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]
         && ma_shift == _ma_shift[i]
         && ma_method == _ma_method[i]
         && applied_price == _applied_price[i]) break;
      }
      else
      {
         handle[i] = iMA(symbol, timeframe, period, ma_shift, ma_method, applied_price);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         _ma_shift[i] = ma_shift;
         _ma_method[i] = ma_method;
         _applied_price[i] = applied_price;
         break;
      }
   }
   if(i == MAX_IND) return 0;
   
   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//移動平均オシレーター
double iOsMA(string symbol,
             ENUM_TIMEFRAMES timeframe,
             int fast_ema_period,
             int slow_ema_period,
             int signal_period,
             ENUM_APPLIED_PRICE applied_price,
             int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _fast_ema_period[MAX_IND];
   static int _slow_ema_period[MAX_IND];
   static int _signal_period[MAX_IND];
   static ENUM_APPLIED_PRICE _applied_price[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && fast_ema_period == _fast_ema_period[i]
         && slow_ema_period == _slow_ema_period[i]
         && signal_period == _signal_period[i]
         && applied_price == _applied_price[i]) break;
      }
      else
      {
         handle[i] = iOsMA(symbol, timeframe, fast_ema_period, slow_ema_period, signal_period, applied_price);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _fast_ema_period[i] = fast_ema_period;
         _slow_ema_period[i] = slow_ema_period;
         _signal_period[i] = signal_period;
         _applied_price[i] = applied_price;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//MACD
double iMACD(string symbol,
             ENUM_TIMEFRAMES timeframe,
             int fast_ema_period,
             int slow_ema_period,
             int signal_period,
             ENUM_APPLIED_PRICE applied_price,
             int mode,
             int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _fast_ema_period[MAX_IND];
   static int _slow_ema_period[MAX_IND];
   static int _signal_period[MAX_IND];
   static ENUM_APPLIED_PRICE _applied_price[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && fast_ema_period == _fast_ema_period[i]
         && slow_ema_period == _slow_ema_period[i]
         && signal_period == _signal_period[i]
         && applied_price == _applied_price[i]) break;
      }
      else
      {
         handle[i] = iMACD(symbol, timeframe, fast_ema_period, slow_ema_period, signal_period, applied_price);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _fast_ema_period[i] = fast_ema_period;
         _slow_ema_period[i] = slow_ema_period;
         _signal_period[i] = signal_period;
         _applied_price[i] = applied_price;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], mode, shift, 1, buf);
   return buf[0];
}

//オンバランスボリューム
double iOBV(string symbol,
            ENUM_TIMEFRAMES timeframe,
            ENUM_APPLIED_PRICE applied_price,
            int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];

   int i;
   for(i=0; i<MAX_IND; i++)
   {   
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]) break;
      }
      else
      {
         handle[i] = iOBV(symbol, timeframe, VOLUME_TICK);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//パラボリックSAR
double iSAR(string symbol,
            ENUM_TIMEFRAMES timeframe,
            double step,
            double maximum,
            int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static double _step[MAX_IND];
   static double _maximum[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && step == _step[i]
         && maximum == _maximum[i]) break;
      }
      else
      {
         handle[i] = iSAR(symbol, timeframe, step, maximum);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _step[i] = step;
         _maximum[i] = maximum;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//RSI
double iRSI(string symbol,
            ENUM_TIMEFRAMES timeframe,
            int period,
            ENUM_APPLIED_PRICE applied_price,
            int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];
   static ENUM_APPLIED_PRICE _applied_price[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]
         && applied_price == _applied_price[i]) break;
      }
      else
      {
         handle[i] = iRSI(symbol, timeframe, period, applied_price);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         _applied_price[i] = applied_price;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//相対活力指数
double iRVI(string symbol,
            ENUM_TIMEFRAMES timeframe,
            int period,
            int mode,
            int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]) break;
      }
      else
      {
         handle[i] = iRVI(symbol, timeframe, period);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], mode, shift, 1, buf);
   return buf[0];
}

//標準偏差
double iStdDev(string symbol,
               ENUM_TIMEFRAMES timeframe,
               int period,
               int ma_shift,
               ENUM_MA_METHOD ma_method,
               ENUM_APPLIED_PRICE applied_price,
               int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _period[MAX_IND];
   static int _ma_shift[MAX_IND];
   static ENUM_MA_METHOD _ma_method[MAX_IND];
   static ENUM_APPLIED_PRICE _applied_price[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && period == _period[i]
         && ma_shift == _ma_shift[i]
         && ma_method == _ma_method[i]
         && applied_price == _applied_price[i]) break;
      }
      else
      {
         handle[i] = iStdDev(symbol, timeframe, period, ma_shift, ma_method, applied_price);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _period[i] = period;
         _ma_shift[i] = ma_shift;
         _ma_method[i] = ma_method;
         _applied_price[i] = applied_price;
         break;
      }
   }
   if(i == MAX_IND) return 0;
   
   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}

//ストキャスティックス
double iStochastic(string symbol,
                   ENUM_TIMEFRAMES timeframe,
                   int Kperiod,
                   int Dperiod,
                   int slowing,
                   ENUM_MA_METHOD ma_method,
                   ENUM_STO_PRICE price_field,
                   int mode,
                   int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _Kperiod[MAX_IND];
   static int _Dperiod[MAX_IND];
   static int _slowing[MAX_IND];
   static ENUM_MA_METHOD _ma_method[MAX_IND];
   static ENUM_STO_PRICE _price_field[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && Kperiod == _Kperiod[i]
         && Dperiod == _Dperiod[i]
         && slowing == _slowing[i]
         && ma_method == _ma_method[i]
         && price_field == _price_field[i]) break;
      }
      else
      {
         handle[i] = iStochastic(symbol, timeframe, Kperiod, Dperiod, slowing, ma_method, price_field);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _Kperiod[i] = Kperiod;
         _Dperiod[i] = Dperiod;
         _slowing[i] = slowing;
         _ma_method[i] = ma_method;
         _price_field[i] = price_field;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], mode, shift, 1, buf);
   return buf[0];
}

//ウィリアムパーセントレンジ
double iWPR(string symbol,
            ENUM_TIMEFRAMES timeframe,
            int ma_period,
            int shift)
{
   static int handle[MAX_IND];
   static string _symbol[MAX_IND];
   static ENUM_TIMEFRAMES _timeframe[MAX_IND];
   static int _ma_period[MAX_IND];
   
   int i;
   for(i=0; i<MAX_IND; i++)
   {
      if(handle[i] > 0)
      {
         if(symbol == _symbol[i]
         && timeframe == _timeframe[i]
         && ma_period == _ma_period[i]) break;
      }
      else
      {
         handle[i] = iWPR(symbol, timeframe, ma_period);
         _symbol[i] = symbol;
         _timeframe[i] = timeframe;
         _ma_period[i] = ma_period;
         break;
      }
   }
   if(i == MAX_IND) return 0;

   double buf[1];
   CopyBuffer(handle[i], 0, shift, 1, buf);
   return buf[0];
}
