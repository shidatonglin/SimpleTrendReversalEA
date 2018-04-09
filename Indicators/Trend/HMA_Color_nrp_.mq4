//+------------------------------------------------------------------+
//|                                                HMA color nrp.mq4 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link ""

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2

//
//
//
//
//

extern int HMA_Period   = 20;
extern int HMA_PriceType = 0;
extern int VerticalShift = 0;
int    digits;

//
//
//
//
//

double ind_buffer0[];
double ind_buffer1[];
double ind_buffer2[];
double ind_buffer3[];
double ind_buffer4[];
double buffer[];


//+------------------------------------------------------------------
//|                                                                 |
//+------------------------------------------------------------------

int init()
{
   digits = MarketInfo(Symbol(),MODE_DIGITS)+1;
   
   //
   //
   //
   //
   //
   
   IndicatorShortName("HMA("+HMA_Period+")");
   IndicatorDigits(digits);
   IndicatorBuffers(6);
   SetIndexBuffer(0,ind_buffer0);
   SetIndexBuffer(1,ind_buffer1);
   SetIndexBuffer(2,ind_buffer2);
   SetIndexBuffer(3,ind_buffer3);
   SetIndexBuffer(4,ind_buffer4);
   SetIndexBuffer(5,buffer);

   int draw_begin=HMA_Period+MathFloor(MathSqrt(HMA_Period));
   for (int i = 0; i < indicator_buffers; i++)
   {
         SetIndexDrawBegin(i,draw_begin);
         SetIndexLabel(i,"Hull Moving Average");
   }         
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
{
   int HalfPeriod   = MathFloor(HMA_Period/2);
   int HullPeriod   = MathFloor(MathSqrt(HMA_Period));
   int counted_bars = IndicatorCounted();
   int limit,i;
   

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
      limit=Bars-counted_bars;


   //
   //
   //
   //
   //
   
   if (ind_buffer0[limit] > ind_buffer0[limit+1]) CleanPoint(limit,ind_buffer1,ind_buffer2);
   if (ind_buffer0[limit] < ind_buffer0[limit+1]) CleanPoint(limit,ind_buffer3,ind_buffer4);

   //
   //
   //
   //
   //
   
   for(i=limit; i>=0; i--)
         buffer[i]=iMA(NULL,0,HalfPeriod,0,MODE_LWMA,HMA_PriceType,i)*2-
                   iMA(NULL,0,HMA_Period,0,MODE_LWMA,HMA_PriceType,i);
   for(i=limit; i>=0; i--)
   {
      ind_buffer0[i] = NormalizeDouble(iMAOnArray(buffer,0,HullPeriod,0,MODE_LWMA,i),digits)+VerticalShift*Point;
      ind_buffer1[i] = EMPTY_VALUE;
      ind_buffer2[i] = EMPTY_VALUE;
      ind_buffer3[i] = EMPTY_VALUE;
      ind_buffer4[i] = EMPTY_VALUE;
      
      //
      //
      //
      //
      //
            
      if (ind_buffer0[i] > ind_buffer0[i+1]) PlotPoint(i,ind_buffer1,ind_buffer2,ind_buffer0);
      if (ind_buffer0[i] < ind_buffer0[i+1]) PlotPoint(i,ind_buffer3,ind_buffer4,ind_buffer0);
   }
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
      if (first[i+2] == EMPTY_VALUE) {
          first[i]    = from[i];
          first[i+1]  = from[i+1];
          second[i]   = EMPTY_VALUE;
         }
      else {
          second[i]   = from[i];
          second[i+1] = from[i+1];
          first[i]    = EMPTY_VALUE;
         }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}