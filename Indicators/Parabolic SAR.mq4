#property copyright "TRENDPOWER"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_color1  C'20,150,255';
#property indicator_color2  Red
#property indicator_color3  C'0,20,70';
#property indicator_color4  C'45,0,0';
#property indicator_width1  15
#property indicator_width2  15
#property indicator_width3  15
#property indicator_width4  15

//
//
//
//
//

extern string TimeFrame       = "Current Time Frame";
extern int    AdxPeriod       = 14;
extern double Psar_Step       = 0.08;
extern double Psar_Maximum    = 0.2;

extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = false;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

//
//
//
//
//

double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double trend1[];
double trend2[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
// 
//
//
//
//

int init()
{
   IndicatorBuffers(6);
   SetIndexBuffer(0,Buffer1); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Buffer2); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Buffer3); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,Buffer4); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,trend1);
   SetIndexBuffer(5,trend2);
   
       //
       //
       //
       //
       //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
       
       //
       //
       //
       //
       // 

       //
     IndicatorShortName(timeFrameToString(timeFrame)+"TrendPower");  
return(0);
}
//
//
//

int deinit()  { return(0);  }

//
//
//
//
//
  
int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit = MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { Buffer1[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame==Period())
   {
      for (i=limit;i>=0;i--)
      {
   
         double PADX = iADX(NULL,0,AdxPeriod,PRICE_CLOSE,MODE_PLUSDI,i);
         double NADX = iADX(NULL,0,AdxPeriod,PRICE_CLOSE,MODE_MINUSDI,i);
         double Psar = iSAR(NULL,0,Psar_Step,Psar_Maximum,i);
   
         Buffer1[i]=EMPTY_VALUE;
         Buffer2[i]=EMPTY_VALUE;
         Buffer3[i]=EMPTY_VALUE;
         Buffer4[i]=EMPTY_VALUE;
         trend1[i] = trend1[i+1];
         trend2[i] = trend2[i+1]; 
   
         if (Psar < Close[i])  trend1[i] = 1;   
         if (Psar > Close[i])  trend1[i] =-1; 
         if (PADX > NADX)      trend2[i] = 1;
         if (NADX > PADX)      trend2[i] =-1;
         if (trend1[i] == 1 && trend2[i] == 1)   Buffer1[i] = 1;
         if (trend1[i] ==-1 && trend2[i] ==-1)   Buffer2[i] = 1;
         if (trend1[i] == 1 && trend2[i] ==-1)   Buffer3[i] = 1;
         if (trend1[i] ==-1 && trend2[i] == 1)   Buffer4[i] = 1;
         
       }
    manageAlerts();
    return(0);
    }   

   //
   //
   //
   //
   //

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         Buffer1[i] = EMPTY_VALUE;
         Buffer2[i] = EMPTY_VALUE;
         Buffer3[i] = EMPTY_VALUE;
         Buffer4[i] = EMPTY_VALUE;
         trend1[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",AdxPeriod,Psar_Step,Psar_Maximum,4,y); 
         trend2[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",AdxPeriod,Psar_Step,Psar_Maximum,5,y); 
            if (trend1[i] == 1 && trend2[i] == 1)   Buffer1[i] = 1;
            if (trend1[i] ==-1 && trend2[i] ==-1)   Buffer2[i] = 1;
            if (trend1[i] == 1 && trend2[i] ==-1)   Buffer3[i] = 1;
            if (trend1[i] ==-1 && trend2[i] == 1)   Buffer4[i] = 1;
   }
   manageAlerts();    
return(0);
}
 
//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      
      //
      //
      //
      //
      //
      
      
         if (trend1[whichBar] != trend1[whichBar+1] || trend2[whichBar] != trend2[whichBar+1])
         {
            if (trend1[whichBar] == 1 && trend2[whichBar] == 1) doAlert(whichBar,"strong up");
            if (trend1[whichBar] ==-1 && trend2[whichBar] ==-1) doAlert(whichBar,"strong down");
            if (trend1[whichBar] == 1 && trend2[whichBar] ==-1) doAlert(whichBar,"weak up");
            if (trend1[whichBar] ==-1 && trend2[whichBar] == 1) doAlert(whichBar,"weak down");
         }                
   }
}   

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Flat Trend ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Flat Trend"),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
} 
 
   

