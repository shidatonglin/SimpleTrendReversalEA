//+------------------------------------------------------------------+
//|                                                       HeiKen.mqh |
//|                                        Copyright 2018, Tony,Tong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Tony,Tong"
#property link      "https://www.mql5.com"

// 1. Include ExpertSignal Base Class
// 2. A Handle to the Module, Make our signal display in MQL5 Wizard 

#include <Expert\ExpertSignal.mqh> // CExpertSignal is in the file ExpertSignal

// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of indicator Custom Heiken Asia Break Out Signal   |
//| Type=SignalAdvanced                                              |
//| Name=HeiKenAisa                                                      |
//| ShortName=HeiKenAisa                                                |
//| Class=CHeiKenAshi                                                    |
//| Page=Not APPLIED                                                 |
//| Parameter=PeriodMA,int,10,Period of averaging                    |
//| Parameter=Shift,int,1,Time shift                                 |
//+------------------------------------------------------------------+
// wizard description end


class CHeiKenAshi : public CExpertSignal{

public:
   
   CHeiKenAshi();
   
   ~CHeiKenAshi();
   
   void PeriodMA(int value);
   
   void Shift(int value);
   
   int GetMaHeikenLastCross(int direction);
   
   bool              ValidationSettings();
   //--- Creating indicators and timeseries for the module of signals
   bool              InitIndicators(CIndicators *indicators);
   
   virtual int       LongCondition();
   virtual int       ShortCondition();

private:

   int        m_ma_period;
   CiMA       m_maHigh;
   CiMA       m_maLow;
   CiCustom   m_heiKen;
   CiCustom   m_bbMacd;
   
   double bbValue;
   double bbTrend;
   double bbUpper;
   double bbLower;
   double heikenClose;
   double maHigh;
   double maLow;  
   
   bool       InitMA(CIndicators *indicators);
   bool       CreateHeiKen(CIndicators *indicators);
   bool       CreateBbMacd(CIndicators *indicators);
   void       PrepareData();
   
};

CHeiKenAshi::CHeiKenAshi(){
   
}

CHeiKenAshi::~CHeiKenAshi(){
   
}

void CHeiKenAshi::PeriodMA(int value){
   m_ma_period = value;
}

void CHeiKenAshi::Shift(int value){
   //
}

//+------------------------------------------------------------------+
//| Checks input parameters and returns true if everything is OK     |
//+------------------------------------------------------------------+
bool CHeiKenAshi:: ValidationSettings()
  {
   //--- Call the base class method
   if(!CExpertSignal::ValidationSettings())  return(false);
   
   if(m_ma_period < 0){
      PrintFormat("Incorrect value set for MA periods! m_ma_period=%d", m_ma_period);
      return false;
   }
   //--- All checks are completed, everything is ok
   return true;
  }

//+------------------------------------------------------------------+
//| Creates indicators                                               |
//| Input:  a pointer to a collection of indicators                  |
//| Output: true if successful, otherwise false                      |
//+------------------------------------------------------------------+
bool CHeiKenAshi::InitIndicators(CIndicators* indicators)
  {
//--- Standard check of the collection of indicators for NULL
   if(indicators==NULL)                           return(false);
//--- Initializing indicators and timeseries in additional filters
   if(!CExpertSignal::InitIndicators(indicators)) return(false);
//--- Creating our MA indicators
   //--- create and initialize MA indicator
   if(!InitMA(indicators)) return(false);
   
   if(!CreateHeiKen(indicators))                  return(false);
   if(!CreateBbMacd(indicators))                  return(false);
   
//--- Reached this part, so the function was successful, return true
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Create MA indicators.                                            |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CHeiKenAshi::InitMA(CIndicators *indicators)
  {
//--- add MA indicator to collection
   if(!indicators.Add(GetPointer(m_maHigh)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize MA indicator
   if(!m_maHigh.Create(m_symbol.Name(),m_period,m_ma_period,0,MODE_SMMA,PRICE_HIGH))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- resize MA buffer
   m_maHigh.BufferResize(30);
   
   //--- add MA indicator to collection
   if(!indicators.Add(GetPointer(m_maLow)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize MA indicator
   if(!m_maLow.Create(m_symbol.Name(),m_period,m_ma_period,0,MODE_SMMA,PRICE_LOW))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- resize MA buffer
   m_maLow.BufferResize(30);
//--- ok
   return(true);
  }
  
bool CHeiKenAshi::CreateHeiKen(CIndicators *indicators){
   //--- Checking the pointer
   if(indicators==NULL) return(false);
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(m_heiKen)))
     {
      printf(__FUNCTION__+": Error adding an object of the HeiKen");
      return(false);
     }
//--- Setting parameters of the fast MA
   MqlParam parameters[1];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Examples\\Heiken_Ashi.ex5";
   
//--- Object initialization  
   if(!m_heiKen.Create(m_symbol.Name(),m_period,IND_CUSTOM,1,parameters))
     {
      printf(__FUNCTION__+": Error initializing the object of the HeiKen");
      return(false);
     }
//--- Number of buffers
   if(!m_heiKen.NumBuffers(4)) return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
}


bool CHeiKenAshi::CreateBbMacd(CIndicators *indicators){
    //--- Checking the pointer
   if(indicators==NULL) return(false);
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(m_bbMacd)))
     {
      printf(__FUNCTION__+": Error adding an object of the BB_MACD");
      return(false);
     }
//--- Setting parameters of the fast MA
   MqlParam parameters[6];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="BB_MACD.ex5";

   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=12;

   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=26;

   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=10;
   
   parameters[4].type=TYPE_INT;
   parameters[4].integer_value=400;
   
   parameters[5].type=TYPE_DOUBLE;
   parameters[5].double_value=1.0;
   
//--- Object initialization  
   if(!m_bbMacd.Create(m_symbol.Name(),m_period,IND_CUSTOM,6,parameters))
     {
      printf(__FUNCTION__+": Error initializing the object of the BB_MACD");
      return(false);
     }
//--- Number of buffers
   if(!m_bbMacd.NumBuffers(4)) return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
}
  
//+------------------------------------------------------------------+
//| Returns the strength of the buy signal                           |
//+------------------------------------------------------------------+
int CHeiKenAshi::LongCondition()
  {
   int signal=0;
//--- For operation with ticks idx=0, for operation with formed bars idx=1
   //int idx=StartIndex();
//--- Values of MAs at the last formed bar
   
   PrepareData();
   if(heikenClose > maHigh && GetMaHeikenLastCross(1) < 3){
      if(bbTrend==0 && bbValue > bbUpper){
         signal= 30;
      }
   }
   Print("LongCondition Print Start");
   Print("signal->"+IntegerToString(signal));
   Print("GetLastCross 1->"+IntegerToString(GetMaHeikenLastCross(-1)));
   Print("GetLastCross -1->"+IntegerToString(GetMaHeikenLastCross(1)));
   Print("LongCondition Print End");
//--- Return the signal value
   return(signal);
  }
  
int CHeiKenAshi::ShortCondition(){
   int signal=0;
//--- For operation with ticks idx=0, for operation with formed bars idx=1
   PrepareData();
//--- Values of MAs at the last formed bar
   if(heikenClose < maLow && GetMaHeikenLastCross(-1) < 6){
      if(bbTrend==1 && bbValue < bbLower){
         signal= 30;
      }
   }
   Print("ShortCondition Print Start");
   Print("signal->"+IntegerToString(signal));
   Print("GetLastCross 1->"+IntegerToString(GetMaHeikenLastCross(-1)));
   Print("GetLastCross -1->"+IntegerToString(GetMaHeikenLastCross(1)));
   Print("ShortCondition Print End");
//--- Return the signal value
   return(signal);
}

void CHeiKenAshi::PrepareData(){
   
   int idx=StartIndex();
   bbValue = m_bbMacd.GetData(0,idx);// bbMacd value
   bbTrend = m_bbMacd.GetData(1,idx);// bbMacd trend 0:up trend; 1:down trend
   bbUpper = m_bbMacd.GetData(2,idx);// upper band
   bbLower = m_bbMacd.GetData(3,idx);// lower band
  
   //double heiken0 = m_heiKen.GetData(0,idx);// Open
   //double heiken1 = m_heiKen.GetData(1,idx);// High
   //double heiken2 = m_heiKen.GetData(2,idx);// Low
   heikenClose = m_heiKen.GetData(3,idx);// Close
   
   maHigh = m_maHigh.Main(idx);
   maLow = m_maLow.Main(idx);
}

int CHeiKenAshi::GetMaHeikenLastCross(int direction){
   double hkclose;// Close
   double high;
   double low;
   for(int i=2; i < 30; i++){
      hkclose = m_heiKen.GetData(3,i);
      high = m_maHigh.Main(i);
      low = m_maLow.Main(i);
      if(direction==1){
         if(hkclose < high){
            return i+1;
         }
      } else if(direction==-1){
         if(hkclose > low){
            return i+1;
         }
      }
   }
   return 999;
}
  
