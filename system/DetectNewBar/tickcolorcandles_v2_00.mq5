//+------------------------------------------------------------------+
//|                                                 TickColorCandles |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Denis Zyatkevich"
#property description "This indicator builds 'tick candlesticks'"
#property version   "1.00"
// indicator is displayed in a separate window
#property indicator_separate_window
// one graphical plot is used - colored candlesticks
#property indicator_plots 1
// indicator candlesticks require 4 buffers for OHLC prices and one - for color index
#property indicator_buffers 8
// set type of graphical plot - colored candlesticks
#property indicator_type1 DRAW_COLOR_CANDLES
// set colors to paint candlesticks
#property indicator_color1 Gray,Red,Green
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// declare data of enumeration type
enum price_types
  {
   Bid,
   Ask
  };
// input variable ticks_in_candle indicates number of quotes,
// corresponding to one candlestick
input int ticks_in_candle=16;      //Tick Count in Candles
// input variable applied_price of the price_types type shows
// what prices are used to plot indicator - Bid or Ask
input price_types applied_price=0; // Price
// input variable path_prefix sets path and filename prefix
input string path_prefix="";       // FileName Prefix

// variable ticks_stored contains the number of stored quotes
int ticks_stored;
// the TicksBuffer[] array is used to store incoming prices,
// the OpenBuffer[], HighBuffer[], LowBuffer[] and CloseBuffer[] arrays
// are used to store OHLC prices of displayed candlesticks, the
// ColorIndexBuffer[] array is used to store candlesticks color index
double TicksBuffer[],OpenBuffer[],HighBuffer[],LowBuffer[],CloseBuffer[],ColorIndexBuffer[];
double TimeTicks[], TimeCandle[];  //Time of ticks and time of candlestick opening
//+------------------------------------------------------------------+
//| OnInit() function                                                |
//+------------------------------------------------------------------+
void OnInit()
  {
   // the OpenBuffer[] array is indicator buffer
   SetIndexBuffer(0,OpenBuffer,INDICATOR_DATA);
   // the HighBuffer[] array is indicator buffer
   SetIndexBuffer(1,HighBuffer,INDICATOR_DATA);
   // the LowBuffer[] array is indicator buffer
   SetIndexBuffer(2,LowBuffer,INDICATOR_DATA);
   // the CloseBuffer[] array is indicator buffer
   SetIndexBuffer(3,CloseBuffer,INDICATOR_DATA);
   // the ColorIndexBuffer[] array is color index buffer
   SetIndexBuffer(4,ColorIndexBuffer,INDICATOR_COLOR_INDEX);
   // the TimeCandle[] array stores time of candlestick opening
   SetIndexBuffer(5,TimeCandle,INDICATOR_CALCULATIONS);
   // the TimeCandle[] stores ticks time
   SetIndexBuffer(6,TimeTicks,INDICATOR_CALCULATIONS);
   // the TicksBuffer[] is used for intermediate calculations
   SetIndexBuffer(7,TicksBuffer,INDICATOR_CALCULATIONS);
   // the OpenBuffer[] array indexing will be carried out like in timeseries
   ArraySetAsSeries(OpenBuffer,true);
   // the HighBuffer[] array indexing will be carried out like in timeseries
   ArraySetAsSeries(HighBuffer,true);
   // the LowBuffer[] array indexing will be carried out like in timeseries
   ArraySetAsSeries(LowBuffer,true);
   // the CloseBuffer[] array indexing will be carried out like in timeseries
   ArraySetAsSeries(CloseBuffer,true);
   // the ColorIndexBuffer[] array indexing will be carried out like in timeseries
   ArraySetAsSeries(ColorIndexBuffer,true);
   // the TimeCandle[] array indexing will be carried out like in timeseries
   ArraySetAsSeries(TimeCandle,true);
   // zero values in graphical plotting 0 (Open prices) are not plotted
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   // zero values in graphical plotting 1 (High prices) are not plotted
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   // zero values in graphical plotting 2 (Low prices) are not plotted
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   // zero values in graphical plotting 3 (Close prices) are not plotted
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
  }
//+------------------------------------------------------------------+
//| OnCalculate() function                                           |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   // the file_handle variable - is file handle;
   // BidPosition and AskPosition - position of beginning of Bid and Ask prices in a string;
   // line_string_len - string length, calculated from file,
   // CandleNumber - number of candlestick, for which values of OHLC prices are calculated,
   // i - loop counter;
   int file_handle,BidPosition,AskPosition,line_string_len,CandleNumber,i;
   // the last_price_bid variable - last Bid quote
   double last_price_bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   // the last_price_ask variable - last Ask quote
   double last_price_ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   // the filename variable - filename, file_buffer - buffer for
   // string written into and read from file
   string filename,file_buffer;
   // set size of the TicksBuffer[] array
   ArrayResize(TicksBuffer,ArraySize(CloseBuffer));
   // set size of the TimeCandle[] array
   ArrayResize(TimeCandle,ArraySize(CloseBuffer));
   // set size of the TimeTicks[] array
   ArrayResize(TimeTicks,ArraySize(CloseBuffer));
   // generating filename from the path_prefix variable, name of
   // symbol and ".txt"
   StringConcatenate(filename,path_prefix,Symbol(),".txt");
   // open file to read and write, ANSI encoding, shared read access
   file_handle=FileOpen(filename,FILE_READ|FILE_WRITE|FILE_ANSI|FILE_SHARE_READ);
   if(prev_calculated==0)
     {
      // read first string from file and calculate string length
      line_string_len=StringLen(FileReadString(file_handle))+2;
      // if file is big (contains more quotes than rates_total/2)
      if(FileSize(file_handle)>(ulong)line_string_len*rates_total/2)
        {
         // set file handle to read last (rates_total/2) quotes
         FileSeek(file_handle,-line_string_len*rates_total/2,SEEK_END);
         // move file handle to the beginning of next string
         FileReadString(file_handle);
        }
      // if file is not big
      else
        {
         // move file handle to the beginning of file
         FileSeek(file_handle,0,SEEK_SET);
        }
      // reset counter of stored quotes
      ticks_stored=0;
      // read until the end of file
      while(FileIsEnding(file_handle)==false)
        {
         // read string from file
         file_buffer=FileReadString(file_handle);
         // processing calculated string if its size is less than 6 characters
         if(StringLen(file_buffer)>6)
           {
            // find the beginning of Bid price in string
            BidPosition=StringFind(file_buffer," ",StringFind(file_buffer," ")+1)+1;
            // find the beginning of Ask price in string
            AskPosition=StringFind(file_buffer," ",BidPosition)+1;
            // if Bid prices are used, put Bid price into the TicksBuffer[] array
            if(applied_price==0) TicksBuffer[ticks_stored]=StringToDouble(StringSubstr(file_buffer,BidPosition,AskPosition-BidPosition-1));
            // if Ask prices are used, put Ask price into the TicksBuffer[] array
            if(applied_price==1) TicksBuffer[ticks_stored]=StringToDouble(StringSubstr(file_buffer,AskPosition));
            // increment counter of stored quotes
            ticks_stored++;
           }
        }
     }
   // if data from file have been already read
   else
     {
      // move file handle to the end of file
      FileSeek(file_handle,0,SEEK_END);
      // add tick time to array
      TimeTicks[ticks_stored]=TimeCurrent();
      // generate string to be written to file
      StringConcatenate(file_buffer,TimeTicks[ticks_stored]," ",DoubleToString(last_price_bid,_Digits)," ",DoubleToString(last_price_ask,_Digits));
      // write string to file
      FileWrite(file_handle,file_buffer);
      // if Bid prices are used, add last Bid price into TicksBuffer[] array
      if(applied_price==0) TicksBuffer[ticks_stored]=last_price_bid;
      // if Ask prices are used, add last Ask price into TicksBuffer[] array
      if(applied_price==1) TicksBuffer[ticks_stored]=last_price_ask;
      // increment counter of stored quotes
      ticks_stored++;
     }
   // close file
   FileClose(file_handle);
   // if number of quotes is more than or equal to the number of bars on chart
   if(ticks_stored>=rates_total)
     {
      // delete first (tick_stored/2) quotes and shift other quotes
      for(i=ticks_stored/2;i<ticks_stored;i++)
        {
         // shift data in the TicksBuffer[] array by (tick_stored/2) to the beginning
         TicksBuffer[i-ticks_stored/2]=TicksBuffer[i];
         TimeTicks[i-ticks_stored/2]=TimeTicks[i];
        }
      // change counter of quotes
      ticks_stored-=ticks_stored/2;
     }
   // put number of non-existent candlestick into CandleNumber variable
   CandleNumber=-1;
   // search all available price data to generate candlesticks
   for(i=0;i<ticks_stored;i++)
     {
      // if current candlestick is being generated
      if(CandleNumber==(int)(MathFloor((ticks_stored-1)/ticks_in_candle)-MathFloor(i/ticks_in_candle)))
        {
         // current quote so far is the price of current candlestick's closing
         CloseBuffer[CandleNumber]=TicksBuffer[i];
         // if current quote is more than maximal price of current candlestick, then it will be the new value of candlestick's maximal price
         if(TicksBuffer[i]>HighBuffer[CandleNumber]) HighBuffer[CandleNumber]=TicksBuffer[i];
         // if current quote is less than minimal price of current candlestick, then it will be the new value of candlestick's minimal price
         if(TicksBuffer[i]<LowBuffer[CandleNumber]) LowBuffer[CandleNumber]=TicksBuffer[i];
         // if candlestick is growing, it will have color with index 2 (green)
         if(CloseBuffer[CandleNumber]>OpenBuffer[CandleNumber]) ColorIndexBuffer[CandleNumber]=2;
         // if candlestick is falling, it will have color with index 1 (red)
         if(CloseBuffer[CandleNumber]<OpenBuffer[CandleNumber]) ColorIndexBuffer[CandleNumber]=1;
         // if opening and closing prices of candlestick are equal, then candlestick will have color with index 0 (gray)
         if(CloseBuffer[CandleNumber]==OpenBuffer[CandleNumber]) ColorIndexBuffer[CandleNumber]=0;
        }
      // if this candlestick has not been calculated
      else
        {
         // determine candlestick number
         CandleNumber=(int)(MathFloor((ticks_stored-1)/ticks_in_candle)-MathFloor(i/ticks_in_candle));
         // current quote will be the price of candlestick's opening
         OpenBuffer[CandleNumber]=TicksBuffer[i];
         // current quote will be the maximal price of candlestick
         HighBuffer[CandleNumber]=TicksBuffer[i];
         // current quote will be the minimal price of candlestick
         LowBuffer[CandleNumber]=TicksBuffer[i];
         // current quote so far is the price of current candlestick's closing
         CloseBuffer[CandleNumber]=TicksBuffer[i];
         // candlestick will have color with index 0 (gray)
         ColorIndexBuffer[CandleNumber]=0;
         // remember time of candlestick's opening:
         TimeCandle[CandleNumber]=TimeTicks[i];
        }
     }
   // return from the OnCalculate() function, returns nonzero value
   return(rates_total);
  }
//+------------------------------------------------------------------+
