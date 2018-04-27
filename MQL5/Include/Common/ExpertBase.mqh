//+------------------------------------------------------------------+
//|                                                   ExpertBase.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "Strategy.mqh";
#include "ExpertFilter.mqh";
#include "ExpertTrade.mqh"

class CExpertBase{
   
private:

   CStrategy*         m_stategy;
   CSymbolInfo*       m_symbol;
   CExpertFilter*     m_filters[];
   int                m_filter_count;
   CSignal *          m_signal;
   ulong              m_magic;
   int                m_max_orders;
   
   CExpertTrade     *m_trade;                    // trading object
   //CExpertMoney     *m_money;                    // money manager object
   //CExpertTrailing  *m_trailing;                 // trailing stops object
   bool              m_check_volume;             // check and decrease trading volume before OrderSend
   //--- indicators
   //CIndicators       m_indicators;               // indicator collection to fast recalculations
   //--- market objects
   CPositionInfo     m_position;                 // position info object
   COrderInfo        m_order;                    // order info object
   
public :
   //--- position select depending on netting or hedging
   virtual bool      SelectPosition(void);
   //--- processing (main method)
   //virtual bool      Processing(void);
   //--- trade open positions check
   virtual bool      CheckOpen(void);
   virtual bool      CheckOpenLong(void);
   virtual bool      CheckOpenShort(void);
   //--- trade open positions processing
   virtual bool      OpenLong(double price,double sl,double tp);
   virtual bool      OpenShort(double price,double sl,double tp);
   //--- trade reverse positions check
   virtual bool      CheckReverse(void);
   virtual bool      CheckReverseLong(void);
   virtual bool      CheckReverseShort(void);
   //--- trade reverse positions processing
   virtual bool      ReverseLong(double price,double sl,double tp);
   virtual bool      ReverseShort(double price,double sl,double tp);
   //--- trade close positions check
   virtual bool      CheckClose(void);
   virtual bool      CheckCloseLong(void);
   virtual bool      CheckCloseShort(void);
   //--- trade close positions processing
   virtual bool      CloseAll(double lot);
   virtual bool      Close(void);
   virtual bool      CloseLong();
   virtual bool      CloseShort();
   //--- trailing stop check
   virtual bool      CheckTrailingStop(void);
   virtual bool      CheckTrailingStopLong(void);
   virtual bool      CheckTrailingStopShort(void);
   //--- trailing stop processing
   virtual bool      TrailingStopLong(double sl,double tp);
   virtual bool      TrailingStopShort(double sl,double tp);
   //--- trailing order check
   virtual bool      CheckTrailingOrderLong(void);
   virtual bool      CheckTrailingOrderShort(void);
   //--- trailing order processing
   virtual bool      TrailingOrderLong(double delta);
   virtual bool      TrailingOrderShort(double delta);
   //--- delete order check
   virtual bool      CheckDeleteOrderLong(void);
   virtual bool      CheckDeleteOrderShort(void);
   //--- delete order processing
   virtual bool      DeleteOrders(void);
   virtual bool      DeleteOrdersLong(void);
   virtual bool      DeleteOrdersShort(void);
   virtual bool      DeleteOrder(void);
   virtual bool      DeleteOrderLong(void);
   virtual bool      DeleteOrderShort(void);
   //--- lot for trade
   double            LotOpenLong(double price,double sl);
   double            LotOpenShort(double price,double sl);
   double            LotReverse(double sl);
   double            LotCheck(double volume,double price,ENUM_ORDER_TYPE order_type);
   
   CExpertBase():m_symbol(NULL),m_filter_count(0),m_max_orders(1){
      m_symbol = new CSymbolInfo;
   }
   
   CExpertBase(string symbol, CStrategy* strategy)
      : m_filter_count(0),m_max_orders(1)
   {
      m_symbol = new CSymbolInfo;
      m_symbol.Name(symbol);
      m_stategy = strategy;   
   }
   
   ~CExpertBase(){
      delete m_stategy;
      delete m_signal;
      for(int i=0; i< m_filter_count; i++){
         delete m_filters[i];
      }
   }
   
   void AddFilter(CExpertFilter * filter){
      m_filters[m_filter_count++] = filter;
   }
   
   bool ApplyFilters(){
      for(int i=0; i<m_filter_count;i++){
         if(!m_filters[i].doFilter()){
            return false;
         }
      }
      return true;
   }
   
   void SetMagic(ulong magic){
      m_magic = magic;
   }
   
   void MaxOrders(int value){ 
      m_max_orders=value;             
   }
   
   bool IsHedging(){
      return true;
   }
   
   bool Processing(){
   
      if(!ApplyFilters()) return false;
      m_signal = m_stategy.Refresh();
      // Order exit 
      if(SelectPosition()){
         // Close Buy Positions
         if(m_signal.ExitBuy()){
            if(CloseLong()) return true;
            else            return false;
         }
         // Close Sell Positions
         if(m_signal.ExitSell()){
            if(CloseShort()) return true;
            else             return false;
         }
      }

      //--- check the possibility of opening a position/setting pending order
         if(CheckOpen())
            return(true);
      //--- return without operations
         return(false);
   }
   
};

bool CExpertBase::SelectPosition(void)
  {
   bool res=false;
//---
   if(IsHedging())
      res=m_position.SelectByMagic(m_symbol.Name(),m_magic);
   else
      res=m_position.Select(m_symbol.Name());
//---
   return(res);
  }
  
//+------------------------------------------------------------------+
//| Check for position open or limit/stop order set                  |
//+------------------------------------------------------------------+
bool CExpertBase::CheckOpen(void)
  {
   if(CheckOpenLong())
      return(true);
   if(CheckOpenShort())
      return(true);
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for long position open or limit/stop order set             |
//+------------------------------------------------------------------+
bool CExpertBase::CheckOpenLong(void)
  {
   if(m_signal.IsBuy()) return(OpenLong(price,sl,tp));

//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for short position open or limit/stop order set            |
//+------------------------------------------------------------------+
bool CExpertBase::CheckOpenShort(void)
  {
      if(m_signal.IsSell())
      return(OpenShort(price,sl,tp));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Long position open or limit/stop order set                       |
//+------------------------------------------------------------------+
bool CExpertBase::OpenLong(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE)
      return(false);
//--- get lot for open
   double lot=LotOpenLong(price,sl);
//--- check lot for open
   lot=LotCheck(lot,price,ORDER_TYPE_BUY);
   if(lot==0.0)
      return(false);
//---
   return(m_trade.Buy(lot,price,sl,tp));
  }
//+------------------------------------------------------------------+
//| Short position open or limit/stop order set                      |
//+------------------------------------------------------------------+
bool CExpertBase::OpenShort(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE)
      return(false);
//--- get lot for open
   double lot=LotOpenShort(price,sl);
//--- check lot for open
   lot=LotCheck(lot,price,ORDER_TYPE_SELL);
   if(lot==0.0)
      return(false);
//---
   return(m_trade.Sell(lot,price,sl,tp));
  }
//+------------------------------------------------------------------+
//| Check for position reverse                                       |
//+------------------------------------------------------------------+
bool CExpertBase::CheckReverse(void)
  {
   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      //--- check the possibility of reverse the long position
      if(CheckReverseLong())
         return(true);
     }
   else
     {
      //--- check the possibility of reverse the short position
      if(CheckReverseShort())
         return(true);
     }
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for long position reverse                                  |
//+------------------------------------------------------------------+
bool CExpertBase::CheckReverseLong(void)
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=TimeCurrent();
//--- check signal for long reverse operations
   //if(m_signal.CheckReverseLong(price,sl,tp,expiration))
   //   return(ReverseLong(price,sl,tp));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for short position reverse                                 |
//+------------------------------------------------------------------+
bool CExpertBase::CheckReverseShort(void)
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=TimeCurrent();
//--- check signal for short reverse operations
   //if(m_signal.CheckReverseShort(price,sl,tp,expiration))
   //   return(ReverseShort(price,sl,tp));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Long position reverse                                            |
//+------------------------------------------------------------------+
bool CExpertBase::ReverseLong(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE)
      return(false);
//--- get lot for reverse
   double lot=LotReverse(sl);
//--- check lot
   if(lot==0.0)
      return(false);
//---
   bool result=true;
   if(IsHedging())
     {
      //--- first close existing position
      lot-=m_position.Volume();
      result=m_trade.PositionClose(m_position.Ticket());
     }
   if(result)
     {
      lot=LotCheck(lot,price,ORDER_TYPE_SELL);
      if(lot==0.0)
         result=false;
      else
         result=m_trade.Sell(lot,price,sl,tp);
     }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Short position reverse                                           |
//+------------------------------------------------------------------+
bool CExpertBase::ReverseShort(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE)
      return(false);
//--- get lot for reverse
   double lot=LotReverse(sl);
//--- check lot
   if(lot==0.0)
      return(false);
//---
   bool result=true;
   if(IsHedging())
     {
      //--- first close existing position
      lot-=m_position.Volume();
      result=m_trade.PositionClose(m_position.Ticket());
     }
   if(result)
     {
      lot=LotCheck(lot,price,ORDER_TYPE_BUY);
      if(lot==0.0)
         result=false;
      else
         result=m_trade.Buy(lot,price,sl,tp);
     }
//---
   return(result);
  }
  
/*
//+------------------------------------------------------------------+
//| Check for position close or limit/stop order delete              |
//+------------------------------------------------------------------+
bool CExpertBase::CheckClose(void)
  {
   double lot;
//--- position must be selected before call
   if((lot=m_money.CheckClose(GetPointer(m_position)))!=0.0)
      return(CloseAll(lot));
//--- check for position type
   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      //--- check the possibility of closing the long position / delete pending orders to buy
      if(CheckCloseLong())
        {
         DeleteOrdersLong();
         return(true);
        }
     }
   else
     {
      //--- check the possibility of closing the short position / delete pending orders to sell
      if(CheckCloseShort())
        {
         DeleteOrdersShort();
         return(true);
        }
     }
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for long position close or limit/stop order delete         |
//+------------------------------------------------------------------+
bool CExpertBase::CheckCloseLong(void)
  {
   double price=EMPTY_VALUE;
//--- check for long close operations
   //if(m_signal.CheckCloseLong(price))
   //   return(CloseLong(price));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for short position close or limit/stop order delete        |
//+------------------------------------------------------------------+
bool CExpertBase::CheckCloseShort(void)
  {
   double price=EMPTY_VALUE;
//--- check for short close operations
   //if(m_signal.CheckCloseShort(price))
   //   return(CloseShort(price));
//--- return without operations
   return(false);
  }
  
  */
//+------------------------------------------------------------------+
//| Position close and orders delete                                 |
//+------------------------------------------------------------------+
bool CExpertBase::CloseAll(double lot)
  {
   bool result=false;
//--- check for close operations
   if(IsHedging())
      result=m_trade.PositionClose(m_position.Ticket());
   else
     {
      if(m_position.PositionType()==POSITION_TYPE_BUY)
         result=m_trade.Sell(lot,0,0,0);
      else
         result=m_trade.Buy(lot,0,0,0);
     }
   result|=DeleteOrders();
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Position close                                                   |
//+------------------------------------------------------------------+
bool CExpertBase::Close(void)
  {
   return(m_trade.PositionClose(m_symbol.Name()));
  }
//+------------------------------------------------------------------+
//| Long position close                                              |
//+------------------------------------------------------------------+
bool CExpertBase::CloseLong()
  {
   bool result=false;
//---
   //if(price==EMPTY_VALUE)
     // return(false);
   if(IsHedging())
      result=m_trade.PositionClose(m_position.Ticket());
   else
      result=m_trade.Sell(m_position.Volume(),m_symbol.Ask(),0,0);
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Short position close                                             |
//+------------------------------------------------------------------+
bool CExpertBase::CloseShort()
  {
   bool result=false;
//---
   //if(price==EMPTY_VALUE)
   //   return(false);
   if(IsHedging())
      result=m_trade.PositionClose(m_position.Ticket());
   else
      result=m_trade.Buy(m_position.Volume(),m_symbol.Bid(),0,0);
//---
   return(result);
  }
  
/*
//+------------------------------------------------------------------+
//| Check for trailing stop/profit position                          |
//+------------------------------------------------------------------+
bool CExpertBase::CheckTrailingStop(void)
  {
//--- position must be selected before call
   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      //--- check the possibility of modifying the long position
      if(CheckTrailingStopLong())
         return(true);
     }
   else
     {
      //--- check the possibility of modifying the short position
      if(CheckTrailingStopShort())
         return(true);
     }
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for trailing stop/profit long position                     |
//+------------------------------------------------------------------+
bool CExpertBase::CheckTrailingStopLong(void)
  {
   double sl=EMPTY_VALUE;
   double tp=EMPTY_VALUE;
//--- check for long trailing stop operations
   if(m_trailing.CheckTrailingStopLong(GetPointer(m_position),sl,tp))
     {
      double position_sl=m_position.StopLoss();
      double position_tp=m_position.TakeProfit();
      if(sl==EMPTY_VALUE)
         sl=position_sl;
      else
         sl=m_symbol.NormalizePrice(sl);
      if(tp==EMPTY_VALUE)
         tp=position_tp;
      else
         tp=m_symbol.NormalizePrice(tp);
      if(sl==position_sl && tp==position_tp)
         return(false);
      //--- long trailing stop operations
      return(TrailingStopLong(sl,tp));
     }
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for trailing stop/profit short position                    |
//+------------------------------------------------------------------+
bool CExpertBase::CheckTrailingStopShort(void)
  {
   double sl=EMPTY_VALUE;
   double tp=EMPTY_VALUE;
//--- check for short trailing stop operations
   if(m_trailing.CheckTrailingStopShort(GetPointer(m_position),sl,tp))
     {
      double position_sl=m_position.StopLoss();
      double position_tp=m_position.TakeProfit();
      if(sl==EMPTY_VALUE)
         sl=position_sl;
      else
         sl=m_symbol.NormalizePrice(sl);
      if(tp==EMPTY_VALUE)
         tp=position_tp;
      else
         tp=m_symbol.NormalizePrice(tp);
      if(sl==position_sl && tp==position_tp)
         return(false);
      //--- short trailing stop operations
      return(TrailingStopShort(sl,tp));
     }
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Trailing stop/profit long position                               |
//+------------------------------------------------------------------+
bool CExpertBase::TrailingStopLong(double sl,double tp)
  {
   bool result;
//---
   if(IsHedging())
      result=m_trade.PositionModify(m_position.Ticket(),sl,tp);
   else
      result=m_trade.PositionModify(m_symbol.Name(),sl,tp);
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Trailing stop/profit short position                              |
//+------------------------------------------------------------------+
bool CExpertBase::TrailingStopShort(double sl,double tp)
  {
   bool result;
//---
   if(IsHedging())
      result=m_trade.PositionModify(m_position.Ticket(),sl,tp);
   else
      result=m_trade.PositionModify(m_symbol.Name(),sl,tp);
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Check for trailing long limit/stop order                         |
//+------------------------------------------------------------------+
bool CExpertBase::CheckTrailingOrderLong(void)
  {
   double price;
//--- check the possibility of modifying the long order
   if(m_signal.CheckTrailingOrderLong(GetPointer(m_order),price))
      return(TrailingOrderLong(m_order.PriceOpen()-price));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for trailing short limit/stop order                        |
//+------------------------------------------------------------------+
bool CExpertBase::CheckTrailingOrderShort(void)
  {
   double price;
//--- check the possibility of modifying the short order
   if(m_signal.CheckTrailingOrderShort(GetPointer(m_order),price))
      return(TrailingOrderShort(m_order.PriceOpen()-price));
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Trailing long limit/stop order                                   |
//+------------------------------------------------------------------+
bool CExpertBase::TrailingOrderLong(double delta)
  {
   ulong  ticket=m_order.Ticket();
   double price =m_symbol.NormalizePrice(m_order.PriceOpen()-delta);
   double sl    =m_symbol.NormalizePrice(m_order.StopLoss()-delta);
   double tp    =m_symbol.NormalizePrice(m_order.TakeProfit()-delta);
//--- modifying the long order
   return(m_trade.OrderModify(ticket,price,sl,tp,m_order.TypeTime(),m_order.TimeExpiration()));
  }
//+------------------------------------------------------------------+
//| Trailing short limit/stop order                                  |
//+------------------------------------------------------------------+
bool CExpertBase::TrailingOrderShort(double delta)
  {
   ulong  ticket=m_order.Ticket();
   double price =m_symbol.NormalizePrice(m_order.PriceOpen()-delta);
   double sl    =m_symbol.NormalizePrice(m_order.StopLoss()-delta);
   double tp    =m_symbol.NormalizePrice(m_order.TakeProfit()-delta);
//--- modifying the short order
   return(m_trade.OrderModify(ticket,price,sl,tp,m_order.TypeTime(),m_order.TimeExpiration()));
  }
//+------------------------------------------------------------------+
//| Check for delete long limit/stop order                           |
//+------------------------------------------------------------------+
bool CExpertBase::CheckDeleteOrderLong(void)
  {
   double price;
//--- check the possibility of deleting the long order
   if(m_expiration!=0 && TimeCurrent()>m_expiration)
     {
      m_expiration=0;
      return(DeleteOrderLong());
     }
   if(m_signal.CheckCloseLong(price))
      return(DeleteOrderLong());
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Check for delete short limit/stop order                          |
//+------------------------------------------------------------------+
bool CExpertBase::CheckDeleteOrderShort(void)
  {
   double price;
//--- check the possibility of deleting the short order
   if(m_expiration!=0 && TimeCurrent()>m_expiration)
     {
      m_expiration=0;
      return(DeleteOrderShort());
     }
   if(m_signal.CheckCloseShort(price))
      return(DeleteOrderShort());
//--- return without operations
   return(false);
  }
//+------------------------------------------------------------------+
//| Delete all limit/stop orders                                     |
//+------------------------------------------------------------------+
bool CExpertBase::DeleteOrders(void)
  {
   bool result=true;
   int  total=OrdersTotal();
//---
   for(int i=total-1;i>=0;i--)
      if(m_order.Select(OrderGetTicket(i)))
        {
         if(m_order.Symbol()!=m_symbol.Name())
            continue;
         result&=DeleteOrder();
        }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Delete all limit/stop long orders                                |
//+------------------------------------------------------------------+
bool CExpertBase::DeleteOrdersLong(void)
  {
   bool result=true;
   int  total=OrdersTotal();
//---
   for(int i=total-1;i>=0;i--)
      if(m_order.Select(OrderGetTicket(i)))
        {
         if(m_order.Symbol()!=m_symbol.Name())
            continue;
         if(m_order.OrderType()!=ORDER_TYPE_BUY_STOP &&
            m_order.OrderType()!=ORDER_TYPE_BUY_LIMIT)
            continue;
         result&=DeleteOrder();
        }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Delete all limit/stop orders                                     |
//+------------------------------------------------------------------+
bool CExpertBase::DeleteOrdersShort(void)
  {
   bool result=true;
   int  total=OrdersTotal();
//---
   for(int i=total-1;i>=0;i--)
      if(m_order.Select(OrderGetTicket(i)))
        {
         if(m_order.Symbol()!=m_symbol.Name())
            continue;
         if(m_order.OrderType()!=ORDER_TYPE_SELL_STOP &&
            m_order.OrderType()!=ORDER_TYPE_SELL_LIMIT)
            continue;
         result&=DeleteOrder();
        }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Delete limit/stop order                                          |
//+------------------------------------------------------------------+
bool CExpertBase::DeleteOrder(void)
  {
   return(m_trade.OrderDelete(m_order.Ticket()));
  }
//+------------------------------------------------------------------+
//| Delete long limit/stop order                                     |
//+------------------------------------------------------------------+
bool CExpertBase::DeleteOrderLong(void)
  {
   return(m_trade.OrderDelete(m_order.Ticket()));
  }
//+------------------------------------------------------------------+
//| Delete short limit/stop order                                    |
//+------------------------------------------------------------------+
bool CExpertBase::DeleteOrderShort(void)
  {
   return(m_trade.OrderDelete(m_order.Ticket()));
  }
//+------------------------------------------------------------------+
//| Method of getting the lot for open long position.                |
//+------------------------------------------------------------------+
double CExpertBase::LotOpenLong(double price,double sl)
  {
   return(m_money.CheckOpenLong(price,sl));
  }
//+------------------------------------------------------------------+
//| Method of getting the lot for open short position.               |
//+------------------------------------------------------------------+
double CExpertBase::LotOpenShort(double price,double sl)
  {
   return(m_money.CheckOpenShort(price,sl));
  }
//+------------------------------------------------------------------+
//| Method of getting the lot for reverse position.                  |
//+------------------------------------------------------------------+
double CExpertBase::LotReverse(double sl)
  {
   return(m_money.CheckReverse(GetPointer(m_position),sl));
  }
//+------------------------------------------------------------------+
//| Check volume before OrderSend to avoid "not enough money" error  |
//+------------------------------------------------------------------+
double CExpertBase::LotCheck(double volume,double price,ENUM_ORDER_TYPE order_type)
  {
   if(m_check_volume)
      return(m_trade.CheckVolume(m_symbol.Name(),volume,price,order_type));
   return(volume);
  }
  
  
  */