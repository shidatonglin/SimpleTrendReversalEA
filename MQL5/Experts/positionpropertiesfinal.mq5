//+------------------------------------------------------------------+
//|                                      PositionPropertiesPanel.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//---
#define INFOPANEL_SIZE 19 // Size of the array for info panel objects
#define EXPERT_NAME MQL5InfoString(MQL5_PROGRAM_NAME) // Name of the Expert Advisor
//--- Include a class of the Standard Library
#include <Trade/Trade.mqh>
//--- Position properties
struct position_properties
  {
   uint              total_deals;      // Number of deals
   bool              exists;           // Flag of presence/absence of an open position
   string            symbol;           // Symbol
   long              magic;            // Magic number
   string            comment;          // Comment
   double            swap;             // Swap
   double            commission;       // Commission   
   double            first_deal_price; // Price of the first deal in the position
   double            price;            // Current position price
   double            current_price;    // Current price of the position symbol      
   double            last_deal_price;  // Price of the last deal in the position
   double            profit;           // Profit/Loss of the position
   double            volume;           // Current position volume
   double            initial_volume;   // Initial position volume
   double            sl;               // Stop Loss of the position
   double            tp;               // Take Profit of the position
   datetime          time;             // Position opening time
   ulong             duration;         // Position duration in seconds
   long              id;               // Position identifier
   ENUM_POSITION_TYPE type;            // Position type
  };
//--- Symbol properties
struct symbol_properties
  {
   int               digits;        // Number of decimal places in the price
   int               spread;        // Spread in points
   int               stops_level;   // Stops level
   double            point;         // Point value
   double            ask;           // Ask price
   double            bid;           // Bid price
   double            volume_min;    // Minimum volume for a deal
   double            volume_max;    // Maximum volume for a deal
   double            volume_limit;  // Maximum permissible volume for a position and orders in one direction
   double            volume_step;   // Minimum volume change step for a deal
   double            offset;        // Offset from the maximum possible price for a transaction
   double            up_level;      // Upper Stop level price
   double            down_level;    // Lower Stop level price
  };
//--- variables for position and symbol properties
position_properties  pos;
symbol_properties    symb;
//--- Array of names of objects that display the names of position properties
string pos_prop_names[INFOPANEL_SIZE]=
  {
   "name_pos_total_deals",
   "name_pos_symbol",
   "name_pos_magic",
   "name_pos_comment",
   "name_pos_swap",
   "name_pos_commission",
   "name_pos_price_first_deal",
   "name_pos_price",
   "name_pos_cprice",
   "name_pos_price_last_deal",
   "name_pos_profit",
   "name_pos_volume",
   "name_pos_initial_volume",
   "name_pos_sl",
   "name_pos_tp",
   "name_pos_time",
   "name_pos_duration",
   "name_pos_id",
   "name_pos_type"
  };
//--- Array of names of objects that display values of position properties
string pos_prop_values[INFOPANEL_SIZE]=
  {
   "value_pos_total_deals",
   "value_pos_symbol",
   "value_pos_magic",
   "value_pos_comment",
   "value_pos_swap",
   "value_pos_commission",
   "value_pos_price_first_deal",
   "value_pos_price",
   "value_pos_cprice",
   "value_pos_price_last_deal",
   "value_pos_profit",
   "value_pos_volume",
   "value_pos_initial_volume",
   "value_pos_sl",
   "value_pos_tp",
   "value_pos_time",
   "value_pos_duration",
   "value_pos_id",
   "value_pos_type"
  };
//--- Array of position property names
string pos_prop_texts[INFOPANEL_SIZE]=
  {
   "Total deals :",
   "Symbol :",
   "Magic Number :",
   "Comment :",
   "Swap :",
   "Commission :",
   "First Deal Price:",
   "Open Price :",
   "Current Price :",
   "Last Deal Price:",
   "Profit :",
   "Volume :",
   "Initial Volume :",
   "Stop Loss :",
   "Take Profit :",
   "Time :",
   "Duration :",
   "Identifier :",
   "Type :"
  };
//--- Price data arrays
double               close_price[]; // Close (closing prices of the bar)
double               open_price[];  // Open (opening prices of the bar)
double               high_price[];  // High (bar's highs)
double               low_price[];   // Open (bar's lows)
//--- Enumeration of position properties
enum ENUM_POSITION_PROPERTIES
  {
   P_TOTAL_DEALS     = 0,
   P_SYMBOL          = 1,
   P_MAGIC           = 2,
   P_COMMENT         = 3,
   P_SWAP            = 4,
   P_COMMISSION      = 5,
   P_PRICE_FIRST_DEAL= 6,
   P_PRICE_OPEN      = 7,
   P_PRICE_CURRENT   = 8,
   P_PRICE_LAST_DEAL = 9,
   P_PROFIT          = 10,
   P_VOLUME          = 11,
   P_INITIAL_VOLUME  = 12,
   P_SL              = 13,
   P_TP              = 14,
   P_TIME            = 15,
   P_DURATION        = 16,
   P_ID              = 17,
   P_TYPE            = 18,
   P_ALL             = 19
  };
//--- Enumeration of symbol properties
enum ENUM_SYMBOL_PROPERTIES
  {
   S_DIGITS       = 0,
   S_SPREAD       = 1,
   S_STOPSLEVEL   = 2,
   S_POINT        = 3,
   S_ASK          = 4,
   S_BID          = 5,
   S_VOLUME_MIN   = 6,
   S_VOLUME_MAX   = 7,
   S_VOLUME_LIMIT = 8,
   S_VOLUME_STEP  = 9,
   S_FILTER       = 10,
   S_UP_LEVEL     = 11,
   S_DOWN_LEVEL   = 12,
   S_ALL          = 13
  };
//--- Position duration
enum ENUM_POSITION_DURATION
  {
   DAYS     = 0, // Days
   HOURS    = 1, // Hours
   MINUTES  = 2, // Minutes
   SECONDS  = 3  // Seconds
  };
//--- External parameters of the Expert Advisor
sinput   long        MagicNumber=777;     // Magic number
sinput   int         Deviation=10;        // Slippage
input    int         NumberOfBars=2;      // Number of Bullish/Bearish bars for a Buy/Sell
input    double      Lot=0.1;             // Lot
input    double      VolumeIncrease=0.1;  // Position volume increase
input    double      StopLoss=50;         // Stop Loss
input    double      TakeProfit=100;      // Take Profit
input    double      TrailingStop=10;     // Trailing Stop
input    bool        Reverse=true;        // Position reversal
sinput   bool        ShowInfoPanel=true;  // Display of the info panel

//--- To check the value of the NumberOfBars external parameter
int                  AllowedNumberOfBars=0;
//--- Load the class
CTrade trade;
//+------------------------------------------------------------------+
//| Checking for the new bar                                         |
//+------------------------------------------------------------------+
bool CheckNewBar()
  {
//--- Variable for storing the opening time of the current bar
   static datetime new_bar=NULL;
//--- Array for getting the opening time of the current bar
   static datetime time_last_bar[1]={0};
//--- Get the opening time of the current bar
//    If an error occurred when getting the time, print the relevant message
   if(CopyTime(_Symbol,Period(),0,1,time_last_bar)==-1)
     { Print(__FUNCTION__,": Error copying the opening time of the bar: "+IntegerToString(GetLastError())+""); }
//--- If this is a first function call
   if(new_bar==NULL)
     {
      // Set the time
      new_bar=time_last_bar[0];
      Print(__FUNCTION__,": Initialization ["+_Symbol+"][TF: "+TimeframeToString(Period())+"]["
            +TimeToString(time_last_bar[0],TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"]");
      return(false); // Return false and exit 
     }
//--- If the time is different
   if(new_bar!=time_last_bar[0])
     {
      new_bar=time_last_bar[0]; // Set the time and exit 
      return(true); // Store the time and return true
     }
//--- If we have reached this line, then the bar is not new, return false
   return(false);
  }
//+------------------------------------------------------------------+
//| Converting time frame to a string                                |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES timeframe)
  {
   string str="";
//--- If the passed value is incorrect, take the time frame of the current chart
   if(timeframe==WRONG_VALUE|| timeframe== NULL)
      timeframe= Period();
   switch(timeframe)
     {
      case PERIOD_M1  : str="M1";  break;
      case PERIOD_M2  : str="M2";  break;
      case PERIOD_M3  : str="M3";  break;
      case PERIOD_M4  : str="M4";  break;
      case PERIOD_M5  : str="M5";  break;
      case PERIOD_M6  : str="M6";  break;
      case PERIOD_M10 : str="M10"; break;
      case PERIOD_M12 : str="M12"; break;
      case PERIOD_M15 : str="M15"; break;
      case PERIOD_M20 : str="M20"; break;
      case PERIOD_M30 : str="M30"; break;
      case PERIOD_H1  : str="H1";  break;
      case PERIOD_H2  : str="H2";  break;
      case PERIOD_H3  : str="H3";  break;
      case PERIOD_H4  : str="H4";  break;
      case PERIOD_H6  : str="H6";  break;
      case PERIOD_H8  : str="H8";  break;
      case PERIOD_H12 : str="H12"; break;
      case PERIOD_D1  : str="D1";  break;
      case PERIOD_W1  : str="W1";  break;
      case PERIOD_MN1 : str="MN1"; break;
     }
//---
   return(str);
  }
//+------------------------------------------------------------------+
//| Getting bar values                                               |
//+------------------------------------------------------------------+
void GetBarsData()
  {
//--- Adjust the number of bars for the position opening condition
   if(NumberOfBars<=1)
      AllowedNumberOfBars=2;              // At least two bars are required
   if(NumberOfBars>=5)
      AllowedNumberOfBars=5;              // but no more than 5
   else
      AllowedNumberOfBars=NumberOfBars+1; // and always more by one
//--- Reverse the indexing order (... 3 2 1 0)
   ArraySetAsSeries(close_price,true);
   ArraySetAsSeries(open_price,true);
   ArraySetAsSeries(high_price,true);
   ArraySetAsSeries(low_price,true);
//--- Get the closing price of the bar
//    If the number of the obtained values is less than requested, print the relevant message
   if(CopyClose(_Symbol,Period(),0,AllowedNumberOfBars,close_price)<AllowedNumberOfBars)
     {
      Print("Failed to copy the values ("
            +_Symbol+", "+TimeframeToString(Period())+") to the Close price array! "
            "Error "+IntegerToString(GetLastError())+": "+ErrorDescription(GetLastError()));
     }
//--- Get the opening price of the bar
//    If the number of the obtained values is less than requested, print the relevant message
   if(CopyOpen(_Symbol,Period(),0,AllowedNumberOfBars,open_price)<AllowedNumberOfBars)
     {
      Print("Failed to copy the values ("
            +_Symbol+", "+TimeframeToString(Period())+") to the Open price array! "
            "Error "+IntegerToString(GetLastError())+": "+ErrorDescription(GetLastError()));
     }
//--- Get the bar's high
//    If the number of the obtained values is less than requested, print the relevant message
   if(CopyHigh(_Symbol,Period(),0,AllowedNumberOfBars,high_price)<AllowedNumberOfBars)
     {
      Print("Failed to copy the values ("
            +_Symbol+", "+TimeframeToString(Period())+") to the High price array! "
            "Error "+IntegerToString(GetLastError())+": "+ErrorDescription(GetLastError()));
     }
//--- Get the bar's high
//    If the number of the obtained values is less than requested, print the relevant message
   if(CopyLow(_Symbol,Period(),0,AllowedNumberOfBars,low_price)<AllowedNumberOfBars)
     {
      Print("Failed to copy the values ("
            +_Symbol+", "+TimeframeToString(Period())+") to the Low price array! "
            "Error "+IntegerToString(GetLastError())+": "+ErrorDescription(GetLastError()));
     }
  }
//+------------------------------------------------------------------+
//| Determining trading signals                                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE GetTradingSignal()
  {
//--- A Buy signal (ORDER_TYPE_BUY) :
   if(AllowedNumberOfBars==2 && 
      close_price[1]>open_price[1])
      return(ORDER_TYPE_BUY);
   if(AllowedNumberOfBars==3 && 
      close_price[1]>open_price[1] && 
      close_price[2]>open_price[2])
      return(ORDER_TYPE_BUY);
   if(AllowedNumberOfBars==4 && 
      close_price[1]>open_price[1] && 
      close_price[2]>open_price[2] && 
      close_price[3]>open_price[3])
      return(ORDER_TYPE_BUY);
   if(AllowedNumberOfBars==5 && 
      close_price[1]>open_price[1] && 
      close_price[2]>open_price[2] && 
      close_price[3]>open_price[3] && 
      close_price[4]>open_price[4])
      return(ORDER_TYPE_BUY);
   if(AllowedNumberOfBars>=6 && 
      close_price[1]>open_price[1] && 
      close_price[2]>open_price[2] && 
      close_price[3]>open_price[3] && 
      close_price[4]>open_price[4] && 
      close_price[5]>open_price[5])
      return(ORDER_TYPE_BUY);
//--- A Sell signal (ORDER_TYPE_SELL) :
   if(AllowedNumberOfBars==2 && 
      close_price[1]<open_price[1])
      return(ORDER_TYPE_SELL);
   if(AllowedNumberOfBars==3 && 
      close_price[1]<open_price[1] && 
      close_price[2]<open_price[2])
      return(ORDER_TYPE_SELL);
   if(AllowedNumberOfBars==4 && 
      close_price[1]<open_price[1] && 
      close_price[2]<open_price[2] && 
      close_price[3]<open_price[3])
      return(ORDER_TYPE_SELL);
   if(AllowedNumberOfBars==5 && 
      close_price[1]<open_price[1] && 
      close_price[2]<open_price[2] && 
      close_price[3]<open_price[3] && 
      close_price[4]<open_price[4])
      return(ORDER_TYPE_SELL);
   if(AllowedNumberOfBars>=6 && 
      close_price[1]<open_price[1] && 
      close_price[2]<open_price[2] && 
      close_price[3]<open_price[3] && 
      close_price[4]<open_price[4] && 
      close_price[5]<open_price[5])
      return(ORDER_TYPE_SELL);
//--- No signal (WRONG_VALUE):
   return(WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Opening a position                                               |
//+------------------------------------------------------------------+
void OpenPosition(double lot,
                  ENUM_ORDER_TYPE order_type,
                  double price,
                  double sl,
                  double tp,
                  string comment)
  {
   trade.SetExpertMagicNumber(MagicNumber); // Set the magic number in the trading structure
   trade.SetDeviationInPoints(CorrectValueBySymbolDigits(Deviation)); // Set the slippage in points
//--- If the position failed to open, print the relevant message
   if(!trade.PositionOpen(_Symbol,order_type,lot,price,sl,tp,comment))
     { Print("Error opening the position: ",GetLastError()," - ",ErrorDescription(GetLastError())); }
  }
//+------------------------------------------------------------------+
//| Trading block                                                    |
//+------------------------------------------------------------------+
void TradingBlock()
  {
   ENUM_ORDER_TYPE      signal=WRONG_VALUE;                 // Variable for getting a signal
   string               comment="hello :)";                 // Position comment
   double               tp=0.0;                             // Take Profit
   double               sl=0.0;                             // Stop Loss
   double               lot=0.0;                            // Volume for position calculation in case of reverse position
   double               position_open_price=0.0;            // Position opening price
   ENUM_ORDER_TYPE      order_type=WRONG_VALUE;             // Order type for opening a position
   ENUM_POSITION_TYPE   opposite_position_type=WRONG_VALUE; // Opposite position type
//--- Get a signal
   signal=GetTradingSignal();
//--- If there is no signal, exit
   if(signal==WRONG_VALUE)
      return;
//--- Find out if there is a position
   pos.exists=PositionSelect(_Symbol);
//--- Get all symbol properties
   GetSymbolProperties(S_ALL);
//--- Determine values for trade variables
   switch(signal)
     {
      //--- Assign values to variables for a BUY
      case ORDER_TYPE_BUY  :
         position_open_price=symb.ask;
         order_type=ORDER_TYPE_BUY;
         opposite_position_type=POSITION_TYPE_SELL;
         break;
         //--- Assign values to variables for a SELL
      case ORDER_TYPE_SELL :
         position_open_price=symb.bid;
         order_type=ORDER_TYPE_SELL;
         opposite_position_type=POSITION_TYPE_BUY;
         break;
     }
//--- Calculate the Take Profit and Stop Loss levels
   sl=CalculateStopLoss(order_type);
   tp=CalculateTakeProfit(order_type);
//--- If there is no position
   if(!pos.exists)
     {
      //--- Adjust the volume
      lot=CalculateLot(Lot);
      //--- Open a position
      OpenPosition(lot,order_type,position_open_price,sl,tp,comment);
     }
//--- If there is a position
   else
     {
      //--- Get the position type
      GetPositionProperties(P_TYPE);
      //--- If the position is opposite to the signal and the position reverse is enabled
      if(pos.type==opposite_position_type && Reverse)
        {
         //--- Get the position volume
         GetPositionProperties(P_VOLUME);
         //--- Adjust the volume
         lot=pos.volume+CalculateLot(Lot);
         //--- Reverse the position
         OpenPosition(lot,order_type,position_open_price,sl,tp,comment);
         return;
        }
      //--- If the signal is in the direction of the position and the volume increase is enabled, increase the position volume
      if(!(pos.type==opposite_position_type) && VolumeIncrease>0)
        {
         //--- Get the Stop Loss of the current position
         GetPositionProperties(P_SL);
         //--- Get the Take Profit of the current position
         GetPositionProperties(P_TP);
         //--- Adjust the volume
         lot=CalculateLot(VolumeIncrease);
         //--- Increase the position volume
         OpenPosition(lot,order_type,position_open_price,pos.sl,pos.tp,comment);
         return;
        }
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Returning the number of deals in the current position            |
//+------------------------------------------------------------------+
uint CurrentPositionTotalDeals()
  {
   int    total       =0;  // Total deals in the selected history list
   int    count       =0;  // Counter of deals by the position symbol
   string deal_symbol =""; // symbol of the deal
//--- If the position history is obtained
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Get the number of deals in the obtained list
      total=HistoryDealsTotal();
      //--- Iterate over all the deals in the obtained list
      for(int i=0; i<total; i++)
        {
         //--- Get the symbol of the deal
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- If the symbol of the deal and the current symbol are the same, increase the counter
         if(deal_symbol==_Symbol)
            count++;
        }
     }
//---
   return(count);
  }
//+------------------------------------------------------------------+
//| Returning the price of the first deal in the current position    |
//+------------------------------------------------------------------+
double CurrentPositionFirstDealPrice()
  {
   int      total       =0;    // Total deals in the selected history list
   string   deal_symbol ="";   // symbol of the deal
   double   deal_price  =0.0;  // Price of the deal
   datetime deal_time   =NULL; // Time of the deal
//--- If the position history is obtained
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Get the number of deals in the obtained list
      total=HistoryDealsTotal();
      //--- Iterate over all the deals in the obtained list
      for(int i=0; i<total; i++)
        {
         //--- Get the price of the deal
         deal_price=HistoryDealGetDouble(HistoryDealGetTicket(i),DEAL_PRICE);
         //--- Get the symbol of the deal
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- Get the time of the deal
         deal_time=(datetime)HistoryDealGetInteger(HistoryDealGetTicket(i),DEAL_TIME);
         //--- If the time of the deal equals the position opening time, 
         //    and if the symbol of the deal and the current symbol are the same, exit the loop
         if(deal_time==pos.time && deal_symbol==_Symbol)
            break;
        }
     }
//---
   return(deal_price);
  }
//+------------------------------------------------------------------+
//| Returning the price of the last deal in the current position     |
//+------------------------------------------------------------------+
double CurrentPositionLastDealPrice()
  {
   int    total       =0;   // Total deals in the selected history list
   string deal_symbol ="";  // Symbol of the deal 
   double deal_price  =0.0; // Price
//--- If the position history is obtained
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Get the number of deals in the obtained list
      total=HistoryDealsTotal();
      //--- Iterate over all the deals in the obtained list from the last deal in the list to the first deal
      for(int i=total-1; i>=0; i--)
        {
         //--- Get the price of the deal
         deal_price=HistoryDealGetDouble(HistoryDealGetTicket(i),DEAL_PRICE);
         //--- Get the symbol of the deal
         deal_symbol=HistoryDealGetString(HistoryDealGetTicket(i),DEAL_SYMBOL);
         //--- If the symbol of the deal and the current symbol are the same, exit the loop
         if(deal_symbol==_Symbol)
            break;
        }
     }
//---
   return(deal_price);
  }
//+------------------------------------------------------------------+
//| Returning the initial volume of the current position             |
//+------------------------------------------------------------------+
double CurrentPositionInitialVolume()
  {
   int             total       =0;           // Total deals in the selected history list
   ulong           ticket      =0;           // Ticket of the deal
   ENUM_DEAL_ENTRY deal_entry  =WRONG_VALUE; // Position modification method
   bool            inout       =false;       // Flag of position reversal
   double          sum_volume  =0.0;         // Counter of the aggregate volume of all deals, except for the first one
   double          deal_volume =0.0;         // Volume of the deal
   string          deal_symbol ="";          // Symbol of the deal 
   datetime        deal_time   =NULL;        // Deal execution time
//--- If the position history is obtained
   if(HistorySelect(pos.time,TimeCurrent()))
     {
      //--- Get the number of deals in the obtained list
      total=HistoryDealsTotal();
      //--- Iterate over all the deals in the obtained list from the last deal in the list to the first deal
      for(int i=total-1; i>=0; i--)
        {
         //--- If the order ticket by its position is obtained, then...
         if((ticket=HistoryDealGetTicket(i))>0)
           {
            //--- Get the volume of the deal
            deal_volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
            //--- Get the position modification method
            deal_entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
            //--- Get the deal execution time
            deal_time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
            //--- Get the symbol of the deal
            deal_symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
            //--- When the deal execution time is less than or equal to the position opening time, exit the loop
            if(deal_time<=pos.time)
               break;
            //--- otherwise calculate the aggregate volume of deals by the position symbol, except for the first one
            if(deal_symbol==_Symbol)
               sum_volume+=deal_volume;
           }
        }
     }
//--- If the position modification method is a reversal
   if(deal_entry==DEAL_ENTRY_INOUT)
     {
      //--- If the position volume has been increased/decreased
      //    I.e. the number of deals is more than one
      if(fabs(sum_volume)>0)
        {
         //--- Current volume minus the volume of all deals except for the first one
         double result=pos.volume-sum_volume;
         //--- If the resulting value is greater than zero, return the result, otherwise return the current position volume         
         deal_volume=result>0 ? result : pos.volume;
        }
      //--- If there are no more deals, other than the entry,
      if(sum_volume==0)
         deal_volume=pos.volume; // return the current position volume
     }
//--- Return the initial position volume
   return(NormalizeDouble(deal_volume,2));
  }
//+------------------------------------------------------------------+
//| Returning the duration of the current position                   |
//+------------------------------------------------------------------+
ulong CurrentPositionDuration(ENUM_POSITION_DURATION mode)
  {
   ulong     result=0;   // End result
   ulong     seconds=0;  // Number of seconds
//--- Calculate the position duration in seconds
   seconds=TimeCurrent()-pos.time;
//---
   switch(mode)
     {
      case DAYS      : result=seconds/(60*60*24);   break; // Calculate the number of days
      case HOURS     : result=seconds/(60*60);      break; // Calculate the number of hours
      case MINUTES   : result=seconds/60;           break; // Calculate the number of minutes
      case SECONDS   : result=seconds;              break; // No calculations (number of seconds)
      //---
      default        :
         Print(__FUNCTION__,"(): Unknown duration mode passed!");
         return(0);
     }
//--- Return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Converting the position duration to a string                     |
//+------------------------------------------------------------------+
string CurrentPositionDurationToString(ulong time)
  {
//--- A dash if there is no position
   string result="-";
//--- If the position exists
   if(pos.exists)
     {
      //--- Variables for calculation results
      ulong days=0;
      ulong hours=0;
      ulong minutes=0;
      ulong seconds=0;
      //--- 
      seconds=time%60;
      time/=60;
      //---
      minutes=time%60;
      time/=60;
      //---
      hours=time%24;
      time/=24;
      //---
      days=time;
      //--- Generate a string in the specified format DD:HH:MM:SS
      result=StringFormat("%02u d: %02u h : %02u m : %02u s",days,hours,minutes,seconds);
     }
//--- Return result
   return(result);
  }
//+------------------------------------------------------------------+
//| Creating the Edit object                                         |
//+------------------------------------------------------------------+
void CreateEdit(long             chart_id,         // chart id
                int              sub_window,       // (sub)window number
                string           name,             // object name
                string           text,             // displayed text
                ENUM_BASE_CORNER corner,           // chart corner
                string           font_name,        // font
                int              font_size,        // font size
                color            font_color,       // font color
                int              x_size,           // width
                int              y_size,           // height
                int              x_distance,       // X-coordinate
                int              y_distance,       // Y-coordinate
                long             z_order,          // Z-order
                color            background_color, // background color
                bool             read_only)        // Read Only flag
  {
// If the object has been created successfully...
   if(ObjectCreate(chart_id,name,OBJ_EDIT,sub_window,0,0))
     {
      // ...set its properties
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);                 // displayed text
      ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);            // set the chart corner
      ObjectSetString(chart_id,name,OBJPROP_FONT,font_name);            // set the font
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,font_size);       // set the font size
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,font_color);         // font color
      ObjectSetInteger(chart_id,name,OBJPROP_BGCOLOR,background_color); // background color
      ObjectSetInteger(chart_id,name,OBJPROP_XSIZE,x_size);             // width
      ObjectSetInteger(chart_id,name,OBJPROP_YSIZE,y_size);             // height
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,x_distance);     // set the X-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,y_distance);     // set the Y-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);         // cannot select the object if FALSE
      ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,z_order);           // Z-order of the object
      ObjectSetInteger(chart_id,name,OBJPROP_READONLY,read_only);       // Read Only
      ObjectSetInteger(chart_id,name,OBJPROP_ALIGN,ALIGN_LEFT);         // align left
      ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n");              // no tooltip if "\n"
     }
  }
//+------------------------------------------------------------------+
//| Creating the Label object                                        |
//+------------------------------------------------------------------+
void CreateLabel(long               chart_id,   // chart id
                 int                sub_window, // (sub)window number
                 string             name,       // object name
                 string             text,       // displayed text
                 ENUM_ANCHOR_POINT  anchor,     // anchor point
                 ENUM_BASE_CORNER   corner,     // chart corner
                 string             font_name,  // font
                 int                font_size,  // font size
                 color              font_color, // font color
                 int                x_distance, // X-coordinate
                 int                y_distance, // Y-coordinate
                 long               z_order)    // Z-order
  {
// If the object has been created successfully...
   if(ObjectCreate(chart_id,name,OBJ_LABEL,sub_window,0,0))
     {
      // ...set its properties
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);              // displayed text
      ObjectSetString(chart_id,name,OBJPROP_FONT,font_name);         // set the font
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,font_color);      // set the font color
      ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,anchor);         // set the anchor point
      ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);         // set the chart corner
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,font_size);    // set the font size
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,x_distance);  // set the X-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,y_distance);  // set the Y-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);      // cannot select the object if FALSE
      ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,z_order);        // Z-order of the object
      ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n");           // no tooltip if "\n"
     }
  }
//+------------------------------------------------------------------+
//|   Deleting the object by name                                    |
//+------------------------------------------------------------------+
void DeleteObjectByName(string name)
  {
   int  sub_window=0;      // Returned number of the subwindow where the object is located
   bool res       =false;  // Result following an attempt to delete the object
//--- Find the object by name
   sub_window=ObjectFind(ChartID(),name);
//---
   if(sub_window>=0) // If it has been found,..
     {
      res=ObjectDelete(ChartID(),name); // ...delete it
      //---
      // If an error occurred when deleting the object, print the relevant message
      if(!res)
         Print("Error deleting the object: ("+IntegerToString(GetLastError())+"): "+ErrorDescription(GetLastError()));
     }
  }
//+------------------------------------------------------------------+
//| Zeroing out variables for position properties                    |
//+------------------------------------------------------------------+
void ZeroPositionProperties()
  {
   pos.symbol ="";
   pos.comment="";
   pos.magic=0;
   pos.price=0.0;
   pos.current_price=0.0;
   pos.sl=0.0;
   pos.tp         =0.0;
   pos.type       =WRONG_VALUE;
   pos.volume     =0.0;
   pos.commission =0.0;
   pos.swap       =0.0;
   pos.profit     =0.0;
   pos.time       =NULL;
   pos.id         =0;
  }
//+------------------------------------------------------------------+
//| Converting position type to a string                             |
//+------------------------------------------------------------------+
string PositionTypeToString(ENUM_POSITION_TYPE type)
  {
   string str="";
//---
   if(type==POSITION_TYPE_BUY)
      str="buy";
   else if(type==POSITION_TYPE_SELL)
      str="sell";
   else
      str="wrong value";
//---
   return(str);
  }
//+------------------------------------------------------------------+
//| Getting position properties                                      |
//+------------------------------------------------------------------+
void GetPositionProperties(ENUM_POSITION_PROPERTIES position_property)
  {
//--- Find out if there is a position
   pos.exists=PositionSelect(_Symbol);
//--- If a position exists, get its properties
   if(pos.exists)
     {
      switch(position_property)
        {
         case P_TOTAL_DEALS      :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.total_deals=CurrentPositionTotalDeals();                                           break;
         case P_SYMBOL           : pos.symbol=PositionGetString(POSITION_SYMBOL);                  break;
         case P_MAGIC            : pos.magic=PositionGetInteger(POSITION_MAGIC);                   break;
         case P_COMMENT          : pos.comment=PositionGetString(POSITION_COMMENT);                break;
         case P_SWAP             : pos.swap=PositionGetDouble(POSITION_SWAP);                      break;
         case P_COMMISSION       : pos.commission=PositionGetDouble(POSITION_COMMISSION);          break;
         case P_PRICE_FIRST_DEAL :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.first_deal_price=CurrentPositionFirstDealPrice();                                  break;
         case P_PRICE_OPEN       : pos.price=PositionGetDouble(POSITION_PRICE_OPEN);               break;
         case P_PRICE_CURRENT    : pos.current_price=PositionGetDouble(POSITION_PRICE_CURRENT);    break;
         case P_PRICE_LAST_DEAL  :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.last_deal_price=CurrentPositionLastDealPrice();                                    break;
         case P_PROFIT           : pos.profit=PositionGetDouble(POSITION_PROFIT);                  break;
         case P_VOLUME           : pos.volume=PositionGetDouble(POSITION_VOLUME);                  break;
         case P_INITIAL_VOLUME   :
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.initial_volume=CurrentPositionInitialVolume();                                     break;
         case P_SL               : pos.sl=PositionGetDouble(POSITION_SL);                          break;
         case P_TP               : pos.tp=PositionGetDouble(POSITION_TP);                          break;
         case P_TIME             : pos.time=(datetime)PositionGetInteger(POSITION_TIME);           break;
         case P_DURATION         : pos.duration=CurrentPositionDuration(SECONDS);                  break;
         case P_ID               : pos.id=PositionGetInteger(POSITION_IDENTIFIER);                 break;
         case P_TYPE             : pos.type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); break;
         case P_ALL              :
            pos.symbol=PositionGetString(POSITION_SYMBOL);
            pos.magic=PositionGetInteger(POSITION_MAGIC);
            pos.comment=PositionGetString(POSITION_COMMENT);
            pos.swap=PositionGetDouble(POSITION_SWAP);
            pos.commission=PositionGetDouble(POSITION_COMMISSION);
            pos.price=PositionGetDouble(POSITION_PRICE_OPEN);
            pos.current_price=PositionGetDouble(POSITION_PRICE_CURRENT);
            pos.profit=PositionGetDouble(POSITION_PROFIT);
            pos.volume=PositionGetDouble(POSITION_VOLUME);
            pos.sl=PositionGetDouble(POSITION_SL);
            pos.tp=PositionGetDouble(POSITION_TP);
            pos.time=(datetime)PositionGetInteger(POSITION_TIME);
            pos.id=PositionGetInteger(POSITION_IDENTIFIER);
            pos.type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            pos.total_deals=CurrentPositionTotalDeals();
            pos.first_deal_price=CurrentPositionFirstDealPrice();
            pos.last_deal_price=CurrentPositionLastDealPrice();
            pos.initial_volume=CurrentPositionInitialVolume();
            pos.duration=CurrentPositionDuration(SECONDS);                                      break;
         default: Print("The passed position property is not listed in the enumeration!");               return;
        }
     }
//--- If there is no position, zero out variables for position properties
   else
      ZeroPositionProperties();
  }
//+------------------------------------------------------------------+
//| Adjusting the value based on the number of digits in the price (int)|
//+------------------------------------------------------------------+
int CorrectValueBySymbolDigits(int value)
  {
   return(symb.digits==3 || symb.digits==5) ? value*=10 : value;
  }
//+------------------------------------------------------------------+
//| Adjusting the value based on the number of digits in the price (double)|
//+------------------------------------------------------------------+
double CorrectValueBySymbolDigits(double value)
  {
   return(symb.digits==3 || symb.digits==5) ? value*=10 : value;
  }
//+------------------------------------------------------------------+
//| Getting symbol properties                                        |
//+------------------------------------------------------------------+
void GetSymbolProperties(ENUM_SYMBOL_PROPERTIES symbol_property)
  {
   int lot_offset=1; // Number of points for the offset from the Stops level
//---
   switch(symbol_property)
     {
      case S_DIGITS        : symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);                   break;
      case S_SPREAD        : symb.spread=(int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);                   break;
      case S_STOPSLEVEL    : symb.stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);   break;
      case S_POINT         : symb.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);                           break;
      //---
      case S_ASK           :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),symb.digits);                       break;
      case S_BID           :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),symb.digits);                       break;
         //---
      case S_VOLUME_MIN    : symb.volume_min=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);                 break;
      case S_VOLUME_MAX    : symb.volume_max=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);                 break;
      case S_VOLUME_LIMIT  : symb.volume_limit=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT);             break;
      case S_VOLUME_STEP   : symb.volume_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);               break;
      //---
      case S_FILTER        :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         symb.offset=NormalizeDouble(CorrectValueBySymbolDigits(lot_offset*symb.point),symb.digits);        break;
         //---
      case S_UP_LEVEL      :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         symb.ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),symb.digits);
         symb.up_level=NormalizeDouble(symb.ask+symb.stops_level*symb.point,symb.digits);                     break;
         //---
      case S_DOWN_LEVEL    :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         symb.bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),symb.digits);
         symb.down_level=NormalizeDouble(symb.bid-symb.stops_level*symb.point,symb.digits);                   break;
         //---
      case S_ALL           :
         symb.digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
         symb.spread=(int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
         symb.stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
         symb.point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         symb.ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),symb.digits);
         symb.bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),symb.digits);
         symb.volume_min=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
         symb.volume_max=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
         symb.volume_limit=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT);
         symb.volume_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
         symb.offset=NormalizeDouble(CorrectValueBySymbolDigits(lot_offset*symb.point),symb.digits);
         symb.up_level=NormalizeDouble(symb.ask+symb.stops_level*symb.point,symb.digits);
         symb.down_level=NormalizeDouble(symb.bid-symb.stops_level*symb.point,symb.digits);                   break;
         //---
      default: Print("The passed symbol property is not listed in the enumeration!"); return;
     }
  }
//+------------------------------------------------------------------+
//| Calculating position lot                                         |
//+------------------------------------------------------------------+
double CalculateLot(double lot)
  {
//--- To adjust as per the step
   double corrected_lot=0.0;
//---
   GetSymbolProperties(S_VOLUME_MIN);  // Get the minimum possible lot
   GetSymbolProperties(S_VOLUME_MAX);  // Get the maximum possible lot
   GetSymbolProperties(S_VOLUME_STEP); // Get the lot increase/decrease step
//--- Adjust as per the lot step
   corrected_lot=MathRound(lot/symb.volume_step)*symb.volume_step;
//--- If less than the minimum, return the minimum
   if(corrected_lot<symb.volume_min)
      return(NormalizeDouble(symb.volume_min,2));
//--- If greater than the maximum, return the maximum
   if(corrected_lot>symb.volume_max)
      return(NormalizeDouble(symb.volume_max,2));
//---
   return(NormalizeDouble(corrected_lot,2));
  }
//+------------------------------------------------------------------+
//| Calculating the Take Profit value                                |
//+------------------------------------------------------------------+
double CalculateTakeProfit(ENUM_ORDER_TYPE order_type)
  {
//--- If Take Profit is required
   if(TakeProfit>0)
     {
      //--- For the calculated Take Profit value
      double tp=0.0;
      //--- If you need to calculate the value for a SELL position
      if(order_type==ORDER_TYPE_SELL)
        {
         //--- Calculate the level
         tp=NormalizeDouble(symb.bid-CorrectValueBySymbolDigits(TakeProfit*symb.point),symb.digits);
         //--- Return the calculated value if it is lower than the lower limit of the Stops level
         //    If the value is higher or equal, return the adjusted value
         return(tp<symb.down_level ? tp : symb.down_level-symb.offset);
        }
      //--- If you need to calculate the value for a BUY position
      if(order_type==ORDER_TYPE_BUY)
        {
         //--- Calculate the level
         tp=NormalizeDouble(symb.ask+CorrectValueBySymbolDigits(TakeProfit*symb.point),symb.digits);
         //--- Return the calculated value if it is higher that the upper limit of the Stops level
         //    If the value is lower or equal, return the adjusted value
         return(tp>symb.up_level ? tp : symb.up_level+symb.offset);
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Calculating the Stop Loss value                                  |
//+------------------------------------------------------------------+
double CalculateStopLoss(ENUM_ORDER_TYPE order_type)
  {
//--- If Stop Loss is required
   if(StopLoss>0)
     {
      //--- For the calculated Stop Loss value
      double sl=0.0;
      //--- If you need to calculate the value for a BUY position
      if(order_type==ORDER_TYPE_BUY)
        {
         // Calculate the level
         sl=NormalizeDouble(symb.ask-CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
         //--- Return the calculated value if it is lower than the lower limit of the Stops level
         //    If the value is higher or equal, return the adjusted value
         return(sl<symb.down_level ? sl : symb.down_level-symb.offset);
        }
      //--- If you need to calculate the value for a SELL position
      if(order_type==ORDER_TYPE_SELL)
        {
         //--- Calculate the level
         sl=NormalizeDouble(symb.bid+CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
         //--- Return the calculated value if it is higher that the upper limit of the Stops level
         //    If the value is lower or equal, return the adjusted value
         return(sl>symb.up_level ? sl : symb.up_level+symb.offset);
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Calculating the Trailing Stop value                              |
//+------------------------------------------------------------------+
double CalculateTrailingStop(ENUM_POSITION_TYPE position_type)
  {
//--- Variables for calculations
   double            level       =0.0;
   double            buy_point   =low_price[1];    // The Low value for a Buy
   double            sell_point  =high_price[1];   // The High value for a Sell
//--- Calculate the level for a BUY position
   if(position_type==POSITION_TYPE_BUY)
     {
      //--- Bar's low minus the specified number of points
      level=NormalizeDouble(buy_point-CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
      //--- If the calculated level is lower than the lower limit of the Stops level, 
      //    the calculation is complete, return the current value of the level
      if(level<symb.down_level)
         return(level);
      //--- If it is not lower, try to calculate based on the bid price
      else
        {
         level=NormalizeDouble(symb.bid-CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
         //--- If the calculated level is lower than the limit, return the current value of the level
         //    Otherwise set the nearest possible value
         return(level<symb.down_level ? level : symb.down_level-symb.offset);
        }
     }
//--- Calculate the level for a SELL position
   if(position_type==POSITION_TYPE_SELL)
     {
      // Bar's high plus the specified number of points
      level=NormalizeDouble(sell_point+CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
      //--- If the calculated level is higher than the upper limit of the Stops level, 
      //    the calculation is complete, return the current value of the level
      if(level>symb.up_level)
         return(level);
      //--- If it is not higher, try to calculate based on the ask price
      else
        {
         level=NormalizeDouble(symb.ask+CorrectValueBySymbolDigits(StopLoss*symb.point),symb.digits);
         //--- If the calculated level is higher than the limit, return the current value of the level
         //    Otherwise set the nearest possible value
         return(level>symb.up_level ? level : symb.up_level+symb.offset);
        }
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Modifying the Trailing Stop level                                |
//+------------------------------------------------------------------+
void ModifyTrailingStop()
  {
//--- If the Trailing Stop and Stop Loss are set
   if(TrailingStop>0 && StopLoss>0)
     {
      double         new_sl=0.0;       // For calculating the new Stop Loss level
      bool           condition=false;  // For checking the modification condition
      //--- Get the flag of presence/absence of the position
      pos.exists=PositionSelect(_Symbol);
      //--- If the position exists
      if(pos.exists)
        {
         //--- Get the symbol properties
         GetSymbolProperties(S_ALL);
         //--- Get the position properties
         GetPositionProperties(P_ALL);
         //--- Get the Stop Loss level
         new_sl=CalculateTrailingStop(pos.type);
         //--- Depending on the position type, check the relevant condition for the Trailing Stop modification
         switch(pos.type)
           {
            case POSITION_TYPE_BUY  :
               //--- If the new Stop Loss value is higher
               //    than the current value plus the set step
               condition=new_sl>pos.sl+CorrectValueBySymbolDigits(TrailingStop*symb.point);
               break;
            case POSITION_TYPE_SELL :
               //--- If the new Stop Loss value is lower
               //    than the current value minus the set step
               condition=new_sl<pos.sl-CorrectValueBySymbolDigits(TrailingStop*symb.point);
               break;
           }
         //--- If there is a Stop Loss, compare the values before modification
         if(pos.sl>0)
           {
            //--- If the condition for the order modification is met, i.e. the new value is lower/higher 
            //    than the current one, modify the Trailing Stop of the position
            if(condition)
              {
               if(!trade.PositionModify(_Symbol,new_sl,pos.tp))
                  Print("Error modifying the position: ",GetLastError()," - ",ErrorDescription(GetLastError()));
              }
           }
         //--- If there is no Stop Loss, simply set it
         if(pos.sl==0)
           {
            if(!trade.PositionModify(_Symbol,new_sl,pos.tp))
               Print("Error modifying the position: ",GetLastError()," - ",ErrorDescription(GetLastError()));
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Returning the testing flag                                       |
//+------------------------------------------------------------------+
bool IsTester()
  {
   return(MQL5InfoInteger(MQL5_TESTER));
  }
//+------------------------------------------------------------------+
//| Returning the optimization flag                                  |
//+------------------------------------------------------------------+
bool IsOptimization()
  {
   return(MQL5InfoInteger(MQL5_OPTIMIZATION));
  }
//+------------------------------------------------------------------+
//| Returning the visual testing mode flag                           |
//+------------------------------------------------------------------+
bool IsVisualMode()
  {
   return(MQL5InfoInteger(MQL5_VISUAL_MODE));
  }
//+------------------------------------------------------------------+
//| Returning the flag for real time mode outside the Strategy Tester|
//| if all conditions are met                                        |
//+------------------------------------------------------------------+
bool IsRealtime()
  {
   if(!IsTester() && !IsOptimization() && !IsVisualMode())
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Setting the info panel                                           |
//|------------------------------------------------------------------+
void SetInfoPanel()
  {
//--- Visualization or real time modes
   if(IsVisualMode() || IsRealtime())
     {
      int               y_bg=18;             // Y-coordinate for the background and header
      int               y_property=32;       // Y-coordinate for the list of properties and their values
      int               line_height=12;      // Line height
      //---
      int               font_size=8;         // Font size
      string            font_name="Calibri"; // Font
      color             font_color=clrWhite; // Font color
      //---
      ENUM_ANCHOR_POINT anchor=ANCHOR_RIGHT_UPPER; // Anchor point in the top right corner
      ENUM_BASE_CORNER  corner=CORNER_RIGHT_UPPER; // Origin of coordinates in the top right corner of the chart
      //--- X-coordinates
      int               x_first_column=120;  // First column (names of properties)
      int               x_second_column=10;  // Second column (values of properties)
      //--- Testing in the visualization mode
      if(IsVisualMode())
        {
         y_bg=2;
         y_property=16;
        }
      //--- Array of Y-coordinates for the names of position properties and their values
      int               y_prop_array[INFOPANEL_SIZE]={0};
      //--- Fill the array with coordinates for each line on the info panel
      for(int i=0; i<INFOPANEL_SIZE; i++)
        {
         if(i==0) y_prop_array[i]=y_property;
         else     y_prop_array[i]=y_property+line_height*i;
        }
      //--- Background of the info panel
      CreateEdit(0,0,"InfoPanelBackground","",corner,font_name,8,clrWhite,230,250,231,y_bg,0,C'15,15,15',true);
      //--- Header of the info panel
      CreateEdit(0,0,"InfoPanelHeader","  POSITION  PROPERTIES",corner,font_name,8,clrWhite,230,14,231,y_bg,1,clrFireBrick,true);
      //--- List of the names of position properties and their values
      for(int i=0; i<INFOPANEL_SIZE; i++)
        {
         //--- Property name
         CreateLabel(0,0,pos_prop_names[i],pos_prop_texts[i],anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[i],2);
         //--- Property value
         CreateLabel(0,0,pos_prop_values[i],GetPropertyValue(i),anchor,corner,font_name,font_size,font_color,x_second_column,y_prop_array[i],2);
        }
      //---
      ChartRedraw(); // Redraw the chart
     }
  }
//+------------------------------------------------------------------+
//| Deleting the info panel                                          |
//+------------------------------------------------------------------+
void DeleteInfoPanel()
  {
   DeleteObjectByName("InfoPanelBackground");   // Delete the panel background
   DeleteObjectByName("InfoPanelHeader");       // Delete the panel header
//--- Delete position properties and their values
   for(int i=0; i<INFOPANEL_SIZE; i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      DeleteObjectByName(pos_prop_names[i]);    // Delete the property
      DeleteObjectByName(pos_prop_values[i]);   // Delete the value
     }
//---
   ChartRedraw(); // Redraw the chart
  }
//+------------------------------------------------------------------+
//| Returning the string with position property value                |
//+------------------------------------------------------------------+
string GetPropertyValue(int number)
  {
//--- Sign indicating the lack of an open position or a certain property
//    E.g. the lack of a comment, Stop Loss or Take Profit
   string empty="-";
//--- If an open position exists, return the value of the requested property
   if(pos.exists)
     {
      switch(number)
        {
         case 0   : return(IntegerToString(pos.total_deals));                     break;
         case 1   : return(pos.symbol);                                           break;
         case 2   : return(IntegerToString((int)pos.magic));                      break;
         //--- return the value of the comment, if any, otherwise return the sign indicating the lack of comment
         case 3   : return(pos.comment!="" ? pos.comment : empty);                break;
         case 4   : return(DoubleToString(pos.swap,2));                           break;
         case 5   : return(DoubleToString(pos.commission,2));                     break;
         case 6   : return(DoubleToString(pos.first_deal_price,_Digits));         break;
         case 7   : return(DoubleToString(pos.price,_Digits));                    break;
         case 8   : return(DoubleToString(pos.current_price,_Digits));            break;
         case 9   : return(DoubleToString(pos.last_deal_price,_Digits));          break;
         case 10  : return(DoubleToString(pos.profit,2));                         break;
         case 11  : return(DoubleToString(pos.volume,2));                         break;
         case 12  : return(DoubleToString(pos.initial_volume,2));                 break;
         case 13  : return(pos.sl!=0.0 ? DoubleToString(pos.sl,_Digits) : empty); break;
         case 14  : return(pos.tp!=0.0 ? DoubleToString(pos.tp,_Digits) : empty); break;
         case 15  : return(TimeToString(pos.time,TIME_DATE|TIME_MINUTES));        break;
         case 16  : return(CurrentPositionDurationToString(pos.duration));        break;
         case 17  : return(IntegerToString((int)pos.id));                         break;
         case 18  : return(PositionTypeToString(pos.type));                       break;

         default : return(empty);
        }
     }
//---
// If there is no open position, return the sign indicating the lack of the open position "-"
   return(empty);
  }
//+------------------------------------------------------------------+
//| Returning a textual description of the deinitialization reason code|
//+------------------------------------------------------------------+
string GetDeinitReasonText(int reason_code)
  {
   string text="";
//---
   switch(reason_code)
     {
      case REASON_PROGRAM :     // 0
         text="The Expert Advisor has stopped working calling the ExpertRemove() function.";      break;
      case REASON_REMOVE :      // 1
         text="The '"+EXPERT_NAME+"' program has been removed from the chart.";                   break;
      case REASON_RECOMPILE :   // 2
         text="The '"+EXPERT_NAME+"' program has been recompiled.";                               break;
      case REASON_CHARTCHANGE : // 3
         text="Chart symbol or period has been changed.";                                         break;
      case REASON_CHARTCLOSE :  // 4
         text="The chart is closed.";                                                             break;
      case REASON_PARAMETERS :  // 5
         text="Input parameters have been changed by the user.";                                  break;
      case REASON_ACCOUNT :     // 6
         text="A different account has been activated.";                                          break;
      case REASON_TEMPLATE :    // 7
         text="A different chart template has been applied.";                                     break;
      case REASON_INITFAILED :  // 8
         text="A flag specifying that the OnInit() handler returned zero value.";                 break;
      case REASON_CLOSE :       // 9
         text="The terminal has been closed.";                                                    break;
      default : text="The reason is undefined.";
     }
//---
   return text;
  }
//+------------------------------------------------------------------+
//| Returning the error description                                  |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
  {
   string error_string="";
//---
   switch(error_code)
     {
      //--- Trade server return codes

      case 10004: error_string="Requote";                                                                 break;
      case 10006: error_string="Request rejected";                                                        break;
      case 10007: error_string="Request canceled by trader";                                              break;
      case 10008: error_string="Order placed";                                                            break;
      case 10009: error_string="Request executed";                                                        break;
      case 10010: error_string="Request executed partially";                                              break;
      case 10011: error_string="Request processing error";                                                break;
      case 10012: error_string="Request timed out";                                                       break;
      case 10013: error_string="Invalid request";                                                         break;
      case 10014: error_string="Invalid request volume";                                                  break;
      case 10015: error_string="Invalid request price";                                                   break;
      case 10016: error_string="Invalid Stop orders in the request";                                      break;
      case 10017: error_string="Trading forbidden";                                                       break;
      case 10018: error_string="Market is closed";                                                        break;
      case 10019: error_string="Insufficient funds";                                                      break;
      case 10020: error_string="Prices changed";                                                          break;
      case 10021: error_string="No quotes to process the request";                                        break;
      case 10022: error_string="Invalid order expiration in the request";                                 break;
      case 10023: error_string="Order status changed";                                                    break;
      case 10024: error_string="Too many requests";                                                       break;
      case 10025: error_string="No changes in the request";                                               break;
      case 10026: error_string="Automated trading is disabled by trader";                                 break;
      case 10027: error_string="Automated trading is disabled by the client terminal";                    break;
      case 10028: error_string="Request blocked for processing";                                          break;
      case 10029: error_string="Order or position frozen";                                                break;
      case 10030: error_string="The specified type of order execution by balance is not supported";       break;
      case 10031: error_string="No connection with trade server";                                         break;
      case 10032: error_string="Transaction is allowed for live accounts only";                           break;
      case 10033: error_string="You have reached the maximum number of pending orders";                   break;
      case 10034: error_string="You have reached the maximum order and position volume for this symbol";  break;

      //--- Runtime errors

      case 0:  // The operation performed successfully
      case 4001: error_string="Unexpected internal error";                                                                                                             break;
      case 4002: error_string="Incorrect parameter in the internal call of the client terminal function";                                                              break;
      case 4003: error_string="Incorrect parameter in the call of the system function";                                                                                break;
      case 4004: error_string="Not enough memory to perform the system function";                                                                                      break;
      case 4005: error_string="The structure contains string and/or dynamic array objects and/or structures with such objects and/or classes";                         break;
      case 4006: error_string="Invalid type or size of the array or corrupted dynamic array object";                                                                   break;
      case 4007: error_string="Not enough memory to reallocate the array or an attempt to change the dynamic array size";                                              break;
      case 4008: error_string="Not enough memory to reallocate the string";                                                                                            break;
      case 4009: error_string="Uninitialized string";                                                                                                                  break;
      case 4010: error_string="Invalid time and/or date value";                                                                                                        break;
      case 4011: error_string="Requested array size exceeds 2 GB";                                                                                                     break;
      case 4012: error_string="Incorrect pointer";                                                                                                                     break;
      case 4013: error_string="Incorrect pointer type";                                                                                                                break;
      case 4014: error_string="System function cannot be called";                                                                                                      break;
      //-- Charts
      case 4101: error_string="Incorrect chart identifier";                                                                                                            break;
      case 4102: error_string="Chart not responding";                                                                                                                  break;
      case 4103: error_string="Chart not found";                                                                                                                       break;
      case 4104: error_string="No Expert Advisor on the chart to handle the event";                                                                                    break;
      case 4105: error_string="Chart opening error";                                                                                                                   break;
      case 4106: error_string="Error when changing chart symbol and period";                                                                                           break;
      case 4107: error_string="Incorrect timer value";                                                                                                                 break;
      case 4108: error_string="Error when creating the timer";                                                                                                         break;
      case 4109: error_string="Incorrect chart property identifier";                                                                                                   break;
      case 4110: error_string="Error when creating the screenshot";                                                                                                    break;
      case 4111: error_string="Chart navigation error";                                                                                                                break;
      case 4112: error_string="Template application error";                                                                                                            break;
      case 4113: error_string="Subwindow with the specified indicator not found";                                                                                      break;
      case 4114: error_string="Error when adding indicator to the chart";                                                                                              break;
      case 4115: error_string="Error when removing indicator from the chart";                                                                                          break;
      case 4116: error_string="The indicator not found in the specified chart";                                                                                        break;
      //-- Graphical objects
      case 4201: error_string="Error when working with the graphical object";                                                                                          break;
      case 4202: error_string="The graphical object not found";                                                                                                        break;
      case 4203: error_string="Incorrect identifier of the graphical object property";                                                                                 break;
      case 4204: error_string="Unable to get the date corresponding to the value";                                                                                     break;
      case 4205: error_string="Unable to get the value corresponding to the date";                                                                                     break;
      //-- MarketInfo
      case 4301: error_string="Unknown symbol";                                                                                                                        break;
      case 4302: error_string="The symbol not selected in MarketWatch";                                                                                                break;
      case 4303: error_string="Incorrect symbol property identifier";                                                                                                  break;
      case 4304: error_string="Unknown time of the last tick (no ticks)";                                                                                              break;
      //-- Access to history
      case 4401: error_string="Requested history not found!";                                                                                                          break;
      case 4402: error_string="Incorrect history property identifier";                                                                                                 break;
      //-- Global_Variables
      case 4501: error_string="Global variable of the client terminal not found";                                                                                      break;
      case 4502: error_string="Global variable of the client terminal with this name already exists";                                                                  break;
      case 4510: error_string="Failed to send the message";                                                                                                            break;
      case 4511: error_string="Failed to play the sound";                                                                                                              break;
      case 4512: error_string="Incorrect program property identifier";                                                                                                 break;
      case 4513: error_string="Incorrect terminal property identifier";                                                                                                break;
      case 4514: error_string="Failed to export the file by ftp";                                                                                                      break;
      //-- Buffers of custom indicators
      case 4601: error_string="Not enough memory to allocate indicator buffers";                                                                                       break;
      case 4602: error_string="Incorrect index of the custom indicator buffer";                                                                                        break;
      //-- Custom indicator properties
      case 4603: error_string="Incorrect custom indicator property identifier";                                                                                        break;
      //-- Account
      case 4701: error_string="Incorrect account property identifier";                                                                                                 break;
      case 4751: error_string="Incorrect trading property identifier";                                                                                                 break;
      case 4752: error_string="The Expert Advisor is not allowed to trade";                                                                                            break;
      case 4753: error_string="The position not found";                                                                                                                break;
      case 4754: error_string="The order not found";                                                                                                                   break;
      case 4755: error_string="The trade not found";                                                                                                                   break;
      case 4756: error_string="Failed to send the trade request";                                                                                                      break;
      //-- Indicators
      case 4801: error_string="Unknown symbol";                                                                                                                        break;
      case 4802: error_string="Unable to create the indicator";                                                                                                        break;
      case 4803: error_string="Not enough memory to add the indicator";                                                                                                break;
      case 4804: error_string="Unable to apply the indicator to another indicator";                                                                                    break;
      case 4805: error_string="Error when adding the indicator";                                                                                                       break;
      case 4806: error_string="Requested data not found";                                                                                                              break;
      case 4807: error_string="Incorrect indicator handle";                                                                                                            break;
      case 4808: error_string="Invalid number of parameters when creating the indicator";                                                                              break;
      case 4809: error_string="No parameters to create the indicator";                                                                                                 break;
      case 4810: error_string="Custom indicator name should be the first parameter in the array";                                                                      break;
      case 4811: error_string="Invalid parameter type in the array when creating the indicator";                                                                       break;
      case 4812: error_string="Incorrect index of the requested indicator buffer";                                                                                     break;
      //-- Depth of market
      case 4901: error_string="Unable to add the depth of market";                                                                                                     break;
      case 4902: error_string="Unable to delete the depth of market";                                                                                                  break;
      case 4903: error_string="Unable to get data from the depth of market";                                                                                           break;
      case 4904: error_string="Error when subscribing to get new data from the depth of market";                                                                       break;
      //-- File operations
      case 5001: error_string="The number of files open at the same time cannot exceed 64";                                                                            break;
      case 5002: error_string="Invalid file name";                                                                                                                     break;
      case 5003: error_string="File name too long";                                                                                                                    break;
      case 5004: error_string="File opening error";                                                                                                                    break;
      case 5005: error_string="Not enough memory to cache read";                                                                                                       break;
      case 5006: error_string="File deleting error";                                                                                                                   break;
      case 5007: error_string="The file with this handle has already been closed or has never been opened";                                                            break;
      case 5008: error_string="Incorrect file handle";                                                                                                                 break;
      case 5009: error_string="The file must be open for writing";                                                                                                     break;
      case 5010: error_string="The file must be open for reading";                                                                                                     break;
      case 5011: error_string="The file must be open in binary mode";                                                                                                  break;
      case 5012: error_string="The file must be open in text mode";                                                                                                    break;
      case 5013: error_string="The file must be open in text mode or CSV format";                                                                                      break;
      case 5014: error_string="The file must be open in CSV format";                                                                                                   break;
      case 5015: error_string="File reading error";                                                                                                                    break;
      case 5016: error_string="String size must be specified for the file that is open in binary mode";                                                                break;
      case 5017: error_string="There must be text file for string arrays and a binary file for all other arrays";                                                      break;
      case 5018: error_string="This is not a file, it is a directory";                                                                                                 break;
      case 5019: error_string="The file does not exist";                                                                                                               break;
      case 5020: error_string="The file cannot be rewritten";                                                                                                          break;
      case 5021: error_string="Incorrect directory name";                                                                                                              break;
      case 5022: error_string="The directory does not exist";                                                                                                          break;
      case 5023: error_string="This is not a directory, it is a file";                                                                                                 break;
      case 5024: error_string="The directory cannot be deleted";                                                                                                       break;
      case 5025: error_string="Failed to clear the directory (can happen if one or more files is blocked and the deletion was not successful)";                        break;
      //-- String formatting
      case 5030: error_string="No date in the string";                                                                                                                 break;
      case 5031: error_string="Incorrect date in the string";                                                                                                          break;
      case 5032: error_string="Incorrect time in the string";                                                                                                          break;
      case 5033: error_string="Error converting string to date";                                                                                                       break;
      case 5034: error_string="Not enough memory for the string";                                                                                                      break;
      case 5035: error_string="String length is less than expected";                                                                                                   break;
      case 5036: error_string="Number too large, bigger than ULONG_MAX";                                                                                               break;
      case 5037: error_string="Incorrect format string";                                                                                                               break;
      case 5038: error_string="The number of format specifiers is bigger than the number of parameters";                                                               break;
      case 5039: error_string="The number of parameters is bigger than the number of format specifiers";                                                               break;
      case 5040: error_string="Corrupted string type parameter";                                                                                                       break;
      case 5041: error_string="Position outside of the string";                                                                                                        break;
      case 5042: error_string="0 added to the end of the string, content-free operation";                                                                              break;
      case 5043: error_string="Unknown data type when converting to string";                                                                                           break;
      case 5044: error_string="Corrupted string object";                                                                                                               break;
      //-- Operations with arrays
      case 5050: error_string="Cannot copy incompatible arrays. String array can only be copied to another string array and numeric array to another numeric array";   break;
      case 5051: error_string="The receiving array is declared as AS_SERIES and its size is not sufficient";                                                           break;
      case 5052: error_string="Array too small, the starting position is outside of the array";                                                                        break;
      case 5053: error_string="Zero length array";                                                                                                                     break;
      case 5054: error_string="The array must be numeric";                                                                                                             break;
      case 5055: error_string="The array must be one-dimensional";                                                                                                     break;
      case 5056: error_string="The time series cannot be used";                                                                                                        break;
      case 5057: error_string="The array must be of the double type";                                                                                                  break;
      case 5058: error_string="The array must be of the float type";                                                                                                   break;
      case 5059: error_string="The array must be of the long type";                                                                                                    break;
      case 5060: error_string="The array must be of the int type";                                                                                                     break;
      case 5061: error_string="The array must be of the short type";                                                                                                   break;
      case 5062: error_string="The array must be of the char type";                                                                                                    break;
      //-- User errors

      default: error_string="The error is undefined";
     }
//---
   return(error_string);
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialize the new bar
   CheckNewBar();
//--- Get the properties and set the panel
   GetPositionProperties(P_ALL);
//--- Set the info panel
   SetInfoPanel();
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Print the deinitialization reason to the journal
   Print(GetDeinitReasonText(reason));
//--- When deleting from the chart
   if(reason==REASON_REMOVE)
      //--- Delete all objects relating to the info panel from the chart
      DeleteInfoPanel();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- If the bar is not new, exit
   if(!CheckNewBar())
     {
      if(IsVisualMode() || IsRealtime())
        {
         //--- Get the properties and update the values on the panel
         GetPositionProperties(P_ALL);
         //--- Update the info panel
        }

      SetInfoPanel();
      return;
     }

//--- If there is a new bar
   else
     {
      GetBarsData();          // Get bar data
      TradingBlock();         // Check the conditions and trade
      ModifyTrailingStop();   // Modify the Trailing Stop level
     }
//--- Get the properties and update the values on the panel
   GetPositionProperties(P_ALL);
//--- Update the info panel
   SetInfoPanel();
  }
//+------------------------------------------------------------------+
//| Trade event                                                      |
//+------------------------------------------------------------------+
void OnTrade()
  {
//--- Get position properties and update the values on the panel
   GetPositionProperties(P_ALL);
//--- Update the info panel
   SetInfoPanel();
  }
//+------------------------------------------------------------------+
