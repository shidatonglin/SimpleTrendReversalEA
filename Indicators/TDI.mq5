//+------------------------------------------------------------------+
//|                                                          TDI.mq5 |
//|                                    Copyright 2014, Bullet         |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Bullet"
#property link      ""
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot RedLine
#property indicator_label1  "RedLine"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot GreenLine
#property indicator_label2  "GreenLine"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot YellowLine
#property indicator_label3  "YellowLine"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGold
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//-
#include <MovingAverages.mqh>
#include <Statistics.mqh>

double         RedLineBuffer[];
double         GreenLineBuffer[];
double         YellowLineBuffer[];
double         RsiBuffer[];

int            RsiPeriod = 13;
int            VolatilityBandPeriod = 34;
int            GreenLinePeriod = 2;
int            RedLinePeriod = 7;

int            RsiHandle  = -1;

int OnInit() {
   RsiHandle=iRSI(_Symbol,_Period,RsiPeriod,PRICE_CLOSE);
   if(RsiHandle==INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  _Symbol,
                  EnumToString(_Period),
                  GetLastError());
     
      return(INIT_FAILED);
   }
   
   SetIndexBuffer(0,RedLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,GreenLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,YellowLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,RsiBuffer,INDICATOR_CALCULATIONS);
   
   

   IndicatorSetDouble(INDICATOR_MINIMUM,20);
   IndicatorSetDouble(INDICATOR_MAXIMUM,80);
   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,32);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,68);
   IndicatorSetInteger(INDICATOR_DIGITS,4);
  
   
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrCrimson);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrDarkGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrDarkGreen);

   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DOT);
      
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,RedLinePeriod+RsiPeriod);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,GreenLinePeriod+RsiPeriod);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,VolatilityBandPeriod+RsiPeriod);



   IndicatorSetString(INDICATOR_SHORTNAME,"TDI("+RsiPeriod+","+VolatilityBandPeriod+","+GreenLinePeriod+","+RedLinePeriod+")");
   PlotIndexSetString(0,PLOT_LABEL,"Red");
   PlotIndexSetString(1,PLOT_LABEL,"Green");
   PlotIndexSetString(1,PLOT_LABEL,"Volatlity");

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);

   return(INIT_SUCCEEDED);
}

int    bars_calculated=0;

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[]) {
                
   int values_to_copy;

   int calculated=BarsCalculated(RsiHandle);
   if(calculated<=0) {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
   }

   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1) {
      if(calculated>rates_total) 
         values_to_copy=rates_total;
      else                       
         values_to_copy=calculated;
   }
   else {
         values_to_copy=(rates_total-prev_calculated)+1;
   }

   if(!FillArrayFromBuffer(RsiBuffer,RsiHandle,values_to_copy)) 
      return(0);
      
   double         RSI[];
   double    MA = 0;
   
   ArrayResize(RSI,VolatilityBandPeriod);
   
   for(int i=RsiPeriod+VolatilityBandPeriod; i<rates_total; i++) {
      MA = 0;
      for(int x=i; x>i-VolatilityBandPeriod; x--) {
         RSI[i-x] = RsiBuffer[x];
         MA += RsiBuffer[x]/VolatilityBandPeriod;
      }
      double stddev = StandardDeviation(RSI);
      double diff = (1.6185 * stddev);
      double up = (MA + diff);
      double down = (MA - diff);  
      YellowLineBuffer[i] = ((up+down)/2);
      //PrintFormat("Yellow %f", YellowLineBuffer[i]);
   }
      
   //Calculate derivations
   SimpleMAOnBuffer(rates_total, prev_calculated,RsiPeriod+RedLinePeriod,RedLinePeriod,RsiBuffer,RedLineBuffer);
   SimpleMAOnBuffer(rates_total, prev_calculated,RsiPeriod+GreenLinePeriod,GreenLinePeriod,RsiBuffer,GreenLineBuffer);
//--- form the message
   string comm=StringFormat("%s ==>  Updated value in the indicator %s: %d",
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
                            "TDI",
                            values_to_copy);

   //Comment(comm);

   bars_calculated=calculated;

   return(rates_total);
}

bool FillArrayFromBuffer(double &rsi_buffer[],  // indicator buffer of Relative Strength Index values
                         int ind_handle,        // handle of the iRSI indicator
                         int amount             // number of copied values
                         ) {

   ResetLastError();

   if(CopyBuffer(ind_handle,0,0,amount,rsi_buffer)<0) {
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      return(false);
   }

   return(true);
}
void OnDeinit(const int reason){
   Comment("");
}   