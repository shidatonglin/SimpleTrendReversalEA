// LibOrder5.mqh

// order type extension
#define ORDER_TYPE_NONE -1
#define OP_NONE ORDER_TYPE_NONE
#define OP_BUY ORDER_TYPE_BUY
#define OP_SELL ORDER_TYPE_SELL
#define OP_BUYLIMIT ORDER_TYPE_BUY_LIMIT
#define OP_SELLLIMIT ORDER_TYPE_SELL_LIMIT
#define OP_BUYSTOP ORDER_TYPE_BUY_STOP
#define OP_SELLSTOP ORDER_TYPE_SELL_STOP

// enumuration of pool type
enum ENUM_POOL_TYPE
{
   POOL_NONE,
   POOL_POSITION,
   POOL_ORDER,
};

// MQL4 compatible functions
#include "LibMQL4.mqh"

// MQL4 compatible predefined variables
double Bid, Ask, Open[], Low[], High[], Close[];
datetime Time[];
long Volume[];

//マジックナンバー
long MagicNumber[POSITIONS] = {0};

// pips adjustment
double PipPoint = _Point*10;

// slippage
input double SlippagePips = 1;   //SlippagePips(許容スリッページpips)
ulong Slippage = (ulong)(SlippagePips*10); //許容スリッページpoint

// refresh Bid/Ask
bool RefreshPrice(double &bid, double &ask)
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick)) return false;
   if(tick.bid <= 0 || tick.ask <= 0) return false;
   bid = tick.bid;
   ask = tick.ask;
   return true;
}

// Refresh MQL4 compatible variables
bool RefreshRates()
{
   if(!RefreshPrice(Bid, Ask)) return false;
   if(CopyOpen(_Symbol, PERIOD_CURRENT, 0, MY_BUFFER_SIZE, Open) < MY_BUFFER_SIZE) return false;
   if(CopyLow(_Symbol, PERIOD_CURRENT, 0, MY_BUFFER_SIZE, Low) < MY_BUFFER_SIZE) return false;
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, MY_BUFFER_SIZE, High) < MY_BUFFER_SIZE) return false;
   if(CopyClose(_Symbol, PERIOD_CURRENT, 0, MY_BUFFER_SIZE, Close) < MY_BUFFER_SIZE) return false;
   if(CopyTime(_Symbol, PERIOD_CURRENT, 0, MY_BUFFER_SIZE, Time) < MY_BUFFER_SIZE) return false;
   if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, MY_BUFFER_SIZE, Volume) < MY_BUFFER_SIZE) return false;
   return true;
}

//ポジションの初期化
void InitPosition(int magic=0)
{
   //hedging mode check
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      Print("for hedged account only");
      ExpertRemove();
   }

   // pips adjustment
   if(_Digits == 2 || _Digits == 4)
   {
      Slippage = (ulong)SlippagePips;
      PipPoint = _Point;
   }

   //マジックナンバーの設定
   if(magic == 0) magic = MAGIC;
   for(int i=0; i<POSITIONS; i++) MagicNumber[i] = magic*10+i;

   //時系列配列にセット
   ArraySetAsSeries(Open, true);
   ArraySetAsSeries(Low, true);
   ArraySetAsSeries(High, true);
   ArraySetAsSeries(Close, true);
   ArraySetAsSeries(Time, true);
   ArraySetAsSeries(Volume, true);
}

//ポジションの更新
void UpdatePosition()
{
   if(MagicNumber[0] == 0) InitPosition();
   RefreshRates();
}

// get filling mode
ENUM_ORDER_TYPE_FILLING OrderFilling()
{
   long filling_mode = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   if(filling_mode%2 != 0) return ORDER_FILLING_FOK;
   else if(filling_mode%4 != 0) return ORDER_FILLING_IOC;
   return ORDER_FILLING_RETURN;
}

// send order to open position
bool MyOrderSend(ENUM_ORDER_TYPE type, double lots, double price=0, int pos_id=0)
{
   price = NormalizeDouble(price, _Digits);
   bool ret = false;
   switch(type)
   {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_SELL:
         ret = OrderSendMarket(type, lots, pos_id);
         break;
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_LIMIT:
         ret = OrderSendPending(type, lots, price, pos_id);
         break;
      default:
         Print("MyOrderSend : Unsupported type");
         break;
   }
   return ret;
}

// send market order to open position
bool OrderSendMarket(ENUM_ORDER_TYPE type, double lots, int i)
{
   if(MyOrderType(i) != ORDER_TYPE_NONE) return true;
   // for no position or order
   MqlTradeRequest request={0};
   MqlTradeResult result={0}; 
   // refresh rate
   double bid, ask;
   RefreshPrice(bid, ask);
   // order request
   if(type == ORDER_TYPE_BUY) request.price = ask;
   if(type == ORDER_TYPE_SELL) request.price = bid;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = lots;
   request.deviation = Slippage;
   request.type = type;
   request.type_filling = OrderFilling();
   request.magic = MagicNumber[i];
   request.comment = "[in]"+IntegerToString(request.magic);
   bool b = OrderSend(request,result);
   // order completed
   if(result.retcode != TRADE_RETCODE_DONE)
   {
      Print("MyOrderSendMarket : ", result.retcode, " ", RetcodeDescription(result.retcode));
      return false;
   }
   return true;
}

// send pending order to open position
bool OrderSendPending(ENUM_ORDER_TYPE type, double lots, double price, int i)
{
   if(MyOrderType(i) != ORDER_TYPE_NONE) return true;
   // for no open position
   MqlTradeRequest request={0};
   MqlTradeResult result={0}; 
   // order request
   request.action = TRADE_ACTION_PENDING;
   request.symbol = _Symbol;
   request.volume = lots;
   request.type = type;
   request.price = price;
   request.type_filling = OrderFilling();
   request.type_time = ORDER_TIME_GTC;
   request.magic = MagicNumber[i];
   request.comment = "[in]"+IntegerToString(request.magic);
   bool b = OrderSend(request,result);
   // order completed
   if(result.retcode != TRADE_RETCODE_DONE)
   {
      Print("MyOrderSendPending : ", result.retcode, " ", RetcodeDescription(result.retcode));
      return false;
   }
   return true;
}

// send close order
bool MyOrderClose(int pos_id=0)
{
   if(MyOrderOpenLots(pos_id) == 0) return true;
   // for open position
   MqlTradeRequest request={0};
   MqlTradeResult result={0}; 
   // refresh rate
   double bid, ask;
   RefreshPrice(bid, ask);
   // order request
   if(MyOrderType(pos_id) == ORDER_TYPE_BUY)
   {
      request.type = ORDER_TYPE_SELL;
      request.price = bid;
   }
   if(MyOrderType(pos_id) == ORDER_TYPE_SELL)
   {
      request.type = ORDER_TYPE_BUY;
      request.price = ask;
   }
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.deviation = Slippage;
   request.volume = MyOrderLots(pos_id);
   request.position = MyOrderTicket(pos_id);
   request.type_filling = OrderFilling();
   request.magic = MagicNumber[pos_id];
   request.comment = "[out]"+IntegerToString(request.magic);
   bool b = OrderSend(request,result);
   // order completed
   if(result.retcode != TRADE_RETCODE_DONE)
   {
      Print("MyOrderClose : ", result.retcode, " ", RetcodeDescription(result.retcode));
      return false;
   }
   return true;
}

// delete pending order
bool MyOrderDelete(int pos_id=0)
{
   if(MyOrderOpenLots(pos_id) != 0 || MyOrderType(pos_id) == ORDER_TYPE_NONE) return true;
   // for pending order
   MqlTradeRequest request={0};
   MqlTradeResult result={0}; 
   // order request
   request.action = TRADE_ACTION_REMOVE;
   request.order = MyOrderTicket(pos_id);
   bool b = OrderSend(request,result);
   // order completed
   if(result.retcode == TRADE_RETCODE_DONE) return true;
   // order error
   else
   {
      Print("MyOrderDelete : ", result.retcode, " ", RetcodeDescription(result.retcode));
      return false;
   }
   return true;
}

// modify order
bool MyOrderModify(double price, double sl, double tp, int pos_id=0)
{
   bool ret = true;
   price = NormalizeDouble(price, _Digits);
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);

   switch(MyOrderSelect(pos_id))
   {
   // for open position
      case POOL_POSITION:
      ret = OrderModifySLTP(sl, tp, pos_id);
      break;      

   // for pending order
      case POOL_ORDER:
      ret = OrderModifyPending(price, sl, tp, pos_id);
      break;
   }
   return ret;
}

// modify SL/TP of open position
bool OrderModifySLTP(double sl, double tp, int pos_id=0)
{
   if(sl == 0) sl = MyOrderStopLoss(pos_id);    //ポジションの損切り値
   if(tp == 0) tp = MyOrderTakeProfit(pos_id);  //ポジションの利食い値

   //損切り値、利食い値の変更がない場合
   if(MyOrderStopLoss(pos_id) == sl && MyOrderTakeProfit(pos_id) == tp) return true;

   MqlTradeRequest request={0};
   MqlTradeResult result={0};
   // order request
   request.action = TRADE_ACTION_SLTP;
   request.symbol = _Symbol;
   request.position = MyOrderTicket(pos_id);
   request.sl = sl;
   request.tp = tp;
   bool b = OrderSend(request,result);
   // order completed
   if(result.retcode == TRADE_RETCODE_DONE) return true;
   // order error
   else
   {
      Print("MyOrderModifySLTP : ", result.retcode, " ", RetcodeDescription(result.retcode));
      return false;
   }
   return true;
}

// modify pending order
bool OrderModifyPending(double price, double sl, double tp, int pos_id=0)
{
   if(price == 0) price = MyOrderOpenPrice(pos_id); //ポジションの価格
   if(sl == 0) sl = MyOrderStopLoss(pos_id);    //ポジションの損切り値
   if(tp == 0) tp = MyOrderTakeProfit(pos_id);  //ポジションの利食い値

   //価格、損切り値、利食い値の変更がない場合
   if(MyOrderOpenPrice(pos_id) == price
      && MyOrderStopLoss(pos_id) == sl && MyOrderTakeProfit(pos_id) == tp) return true;

   MqlTradeRequest request={0};
   MqlTradeResult result={0};
   // order request
   request.action = TRADE_ACTION_MODIFY;
   request.symbol = _Symbol;
   request.order = MyOrderTicket(pos_id);
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.type_time = ORDER_TIME_GTC;
   bool b = OrderSend(request,result);
   // order completed
   if(result.retcode == TRADE_RETCODE_DONE) return true;
   // order error
   else
   {
      Print("MyOrderModifyPending : ", result.retcode, " ", RetcodeDescription(result.retcode));
      return false;
   }
   return true;
}

//ポジションの選択
ENUM_POOL_TYPE MyOrderSelect(int pos_id=0)
{
   for(int i=0; i<PositionsTotal(); i++)//オープンポジション
   {
      if(PositionGetSymbol(i) == _Symbol
         && PositionGetInteger(POSITION_MAGIC) == MagicNumber[pos_id]) return POOL_POSITION; //正常終了
   }
   for(int i=0; i<OrdersTotal(); i++)//待機注文
   {
      if(OrderGetTicket(i) > 0
         && OrderGetString(ORDER_SYMBOL) == _Symbol
         && OrderGetInteger(ORDER_MAGIC) == MagicNumber[pos_id]) return POOL_ORDER; //正常終了
   }
   return POOL_NONE; //ポジション選択なし
}

//チケット番号の取得
ulong MyOrderTicket(int pos_id=0)
{
   ulong ticket = 0;
   switch(MyOrderSelect(pos_id))
   {
      case POOL_POSITION:
      ticket = PositionGetInteger(POSITION_TICKET);
      break;
      
      case POOL_ORDER:
      ticket = OrderGetInteger(ORDER_TICKET);
      break;
   }
   return ticket;
}

// get order type
ENUM_ORDER_TYPE MyOrderType(int pos_id=0)
{
   ENUM_ORDER_TYPE type = ORDER_TYPE_NONE;
   ENUM_POSITION_TYPE ptype;
   switch(MyOrderSelect(pos_id))
   {
      case POOL_POSITION:
      ptype = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(ptype == POSITION_TYPE_BUY) type = ORDER_TYPE_BUY;
      if(ptype == POSITION_TYPE_SELL) type = ORDER_TYPE_SELL;
      break;
      
      case POOL_ORDER:
      type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      break;
   }
   return type;
}

// get order lots
double MyOrderLots(int pos_id=0)
{
   double lots = 0;
   switch(MyOrderSelect(pos_id))
   {
      case POOL_POSITION:
      lots = PositionGetDouble(POSITION_VOLUME);
      break;
      
      case POOL_ORDER:
      lots = OrderGetDouble(ORDER_VOLUME_CURRENT);
      break;
   }
   return lots;
}

// get order open price
double MyOrderOpenPrice(int pos_id=0)
{
   double price = 0;
   switch(MyOrderSelect(pos_id))
   {
      case POOL_POSITION:
      price = PositionGetDouble(POSITION_PRICE_OPEN);
      break;
      
      case POOL_ORDER:
      price = OrderGetDouble(ORDER_PRICE_OPEN);
      break;
   }
   return price;
}

// get order open time
datetime MyOrderOpenTime(int pos_id=0)
{
   datetime opentime = 0;
   switch(MyOrderSelect(pos_id))
   {
      case POOL_POSITION:
      opentime = (datetime)PositionGetInteger(POSITION_TIME);
      break;
      
      case POOL_ORDER:
      opentime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
      break;
   }
   return opentime;
}

// get order stop loss
double MyOrderStopLoss(int pos_id=0)
{
   double sl = 0;
   switch(MyOrderSelect(pos_id))
   {
      case POOL_POSITION:
      sl = PositionGetDouble(POSITION_SL);
      break;
      
      case POOL_ORDER:
      sl = OrderGetDouble(ORDER_SL);
      break;
   }
   return sl;
}

// get order take profit
double MyOrderTakeProfit(int pos_id=0)
{
   double tp = 0;
   switch(MyOrderSelect(pos_id))
   {
      case POOL_POSITION:
      tp = PositionGetDouble(POSITION_TP);
      break;
      
      case POOL_ORDER:
      tp = OrderGetDouble(ORDER_TP);
      break;
   }
   return tp;
}

// get close price of open position
double MyOrderClosePrice(int pos_id=0)
{
   double bid, ask;
   RefreshPrice(bid, ask);
   ENUM_ORDER_TYPE type = MyOrderType(pos_id);
   double price = 0;
   if(type == ORDER_TYPE_BUY
     || type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP) price = bid;
   if(type == ORDER_TYPE_SELL
     || type == ORDER_TYPE_SELL_LIMIT || type == ORDER_TYPE_SELL_STOP) price = ask;
   return price;
}

// get profit of open position
double MyOrderProfit(int pos_id=0)
{
   double profit = 0;
   if(MyOrderSelect(pos_id) == POOL_POSITION) profit = PositionGetDouble(POSITION_PROFIT);
   return profit;
}

// get profit of open position in pips
double MyOrderProfitPips(int pos_id=0)
{
   double profit = 0;
   ENUM_ORDER_TYPE type = MyOrderType(pos_id);
   if(type == ORDER_TYPE_BUY) profit = MyOrderClosePrice(pos_id)
                                     - MyOrderOpenPrice(pos_id);
   if(type == ORDER_TYPE_SELL) profit = MyOrderOpenPrice(pos_id)
                                      - MyOrderClosePrice(pos_id);
   return profit/PipPoint;
}

//ポジション履歴の選択(out)
ulong MyHistoryOrderSelect(int shift, int pos_id=0)
{
   ulong ticket = 0;
   if(shift > 0) //過去のポジションの選択
   {
      HistorySelect(0, TimeCurrent());
      for(int i=HistoryDealsTotal()-1; i>=0; i--)
      {
         ticket = HistoryDealGetTicket(i);
         if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol
            && HistoryDealGetInteger(ticket, DEAL_MAGIC) == MagicNumber[pos_id]
            && HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
         {
            shift--;
            if(shift <= 0) break;
         }
      }
   }
   return ticket;
}

//ポジション履歴の選択(in & out)
bool MyHistoryOrderSelect(int shift, ulong& in, ulong& out, int pos_id=0)
{
   in = 0; out = 0;
   if(shift > 0) //過去のポジションの選択
   {
      HistorySelect(0, TimeCurrent());
      for(int i=HistoryDealsTotal()-1; i>=0; i--)
      {
         ulong ticket = HistoryDealGetTicket(i);
         if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol
            && HistoryDealGetInteger(ticket, DEAL_MAGIC) == MagicNumber[pos_id])
         {   
            if(HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
            {
               shift--;
               if(shift <= 0) out = ticket;
            }
            if(out > 0 && HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_IN)
            {
               in = ticket;
               return true;
            }
         }
      }
   }
   return false;
}

// get order type of last position
ENUM_ORDER_TYPE MyOrderLastType(int pos_id=0)
{
   ENUM_ORDER_TYPE type = ORDER_TYPE_NONE;
   ulong ticket = MyHistoryOrderSelect(1, pos_id);
   if(ticket > 0)
   {
      ENUM_DEAL_TYPE dtype = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(dtype == DEAL_TYPE_SELL) type = ORDER_TYPE_BUY;
      if(dtype == DEAL_TYPE_BUY) type = ORDER_TYPE_SELL;
   }
   return type;
}

// get order lots of last position
double MyOrderLastLots(int pos_id=0)
{
   double lots = 0;
   ulong ticket = MyHistoryOrderSelect(1, pos_id);
   if(ticket > 0) lots = HistoryDealGetDouble(ticket, DEAL_VOLUME);
   return lots;
}

// get openprice of last position
double MyOrderLastOpenPrice(int pos_id=0)
{
   double price = 0;
   ulong in, out;
   if(MyHistoryOrderSelect(1, in, out, pos_id)) price = HistoryDealGetDouble(in, DEAL_PRICE);
   return price;
}

// get closeprice of last position
double MyOrderLastClosePrice(int pos_id=0)
{
   double price = 0;
   ulong ticket = MyHistoryOrderSelect(1, pos_id);
   if(ticket > 0) price = HistoryDealGetDouble(ticket, DEAL_PRICE);
   return price;
}

// get order open time of last position
datetime MyOrderLastOpenTime(int pos_id=0)
{
   datetime opentime = 0;
   ulong in, out;
   if(MyHistoryOrderSelect(1, in, out, pos_id)) opentime = (datetime)HistoryDealGetInteger(in, DEAL_TIME);
   return opentime;   
}

// get order close time of last position
datetime MyOrderLastCloseTime(int pos_id=0)
{
   datetime closetime = 0;
   ulong ticket = MyHistoryOrderSelect(1, pos_id);
   if(ticket > 0) closetime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
   return closetime;
}

// get profit of last position in pips
double MyOrderLastProfitPips(int pos_id=0)
{
   double profit = 0;
   ulong in, out;
   if(MyHistoryOrderSelect(1, in, out, pos_id))
   {
      double openprice = HistoryDealGetDouble(in, DEAL_PRICE);      
      double closeprice = HistoryDealGetDouble(out, DEAL_PRICE);      
      ENUM_DEAL_TYPE dtype = (ENUM_DEAL_TYPE)HistoryDealGetInteger(in, DEAL_TYPE);
      if(dtype == DEAL_TYPE_BUY) profit = closeprice - openprice;
      if(dtype == DEAL_TYPE_SELL) profit = openprice - closeprice;
   }
   return profit/PipPoint;
}

// get profit of last position
double MyOrderLastProfit(int pos_id=0)
{
   double profit = 0;
   ulong ticket = MyHistoryOrderSelect(1, pos_id);
   if(ticket > 0) profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
   return profit;
}

//ポジション情報の表示
void MyOrderPrint(int pos_id=0)
{
   //ロット数の刻み幅
   double lots_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   //ロット数の小数点以下桁数
   int lots_digits = (int)MathLog10(1.0/lots_step);
   string stype[] = {"buy", "sell", "buy limit", "sell limit",
                     "buy stop", "sell stop"};
   string s = "MyPos[";
   s = s + IntegerToString(pos_id) + "] ";  //ポジション番号
   if(MyOrderType(pos_id) == OP_NONE) s = s + "No position";
   else
   {
      s = s + "#"
            + IntegerToString(MyOrderTicket(pos_id)) //チケット番号
            + " ["
            + TimeToString(MyOrderOpenTime(pos_id)) //売買日時
            + "] "
            + stype[MyOrderType(pos_id)]  //注文タイプ
            + " "
            + DoubleToString(MyOrderLots(pos_id), lots_digits) //ロット数
            + " "
            + _Symbol //通貨ペア
            + " at " 
            + DoubleToString(MyOrderOpenPrice(pos_id), _Digits); //売買価格
      //損切り価格
      if(MyOrderStopLoss(pos_id) != 0) s = s + " sl "
         + DoubleToString(MyOrderStopLoss(pos_id), _Digits);
      //利食い価格
      if(MyOrderTakeProfit(pos_id) != 0) s = s + " tp " 
         + DoubleToString(MyOrderTakeProfit(pos_id), _Digits);
      s = s + " magic " + IntegerToString(MagicNumber[pos_id]); //マジックナンバー
   }
   Print(s); //出力
}

// OrderSend retcode description
string RetcodeDescription(int retcode)
{
   switch(retcode)
   {
      case TRADE_RETCODE_REQUOTE:
           return("リクオート");
      case TRADE_RETCODE_REJECT:
           return("リクエストの拒否");
      case TRADE_RETCODE_CANCEL:
           return("トレーダーによるリクエストのキャンセル");
      case TRADE_RETCODE_PLACED:
           return("注文が出されました");
      case TRADE_RETCODE_DONE:
           return("リクエスト完了");
      case TRADE_RETCODE_DONE_PARTIAL:
           return("リクエストが一部のみ完了");
      case TRADE_RETCODE_ERROR:
           return("リクエスト処理エラー");
      case TRADE_RETCODE_TIMEOUT:
           return("リクエストが時間切れでキャンセル");
      case TRADE_RETCODE_INVALID:
           return("無効なリクエスト");
      case TRADE_RETCODE_INVALID_VOLUME:
           return("リクエスト内の無効なボリューム");
      case TRADE_RETCODE_INVALID_PRICE:
           return("リクエスト内の無効な価格");
      case TRADE_RETCODE_INVALID_STOPS:
           return("リクエスト内の無効なストップ");
      case TRADE_RETCODE_TRADE_DISABLED:
           return("取引が無効化されています");
      case TRADE_RETCODE_MARKET_CLOSED:
           return("市場が閉鎖中");
      case TRADE_RETCODE_NO_MONEY:
           return("リクエストを完了するのに資金が不充分");
      case TRADE_RETCODE_PRICE_CHANGED:
           return("価格変更");
      case TRADE_RETCODE_PRICE_OFF:
           return("リクエスト処理に必要な相場が不在");
      case TRADE_RETCODE_INVALID_EXPIRATION:
           return("リクエスト内の無効な注文有効期限");
      case TRADE_RETCODE_ORDER_CHANGED:
           return("注文状態の変化");
      case TRADE_RETCODE_TOO_MANY_REQUESTS:
           return("頻繁過ぎるリクエスト");
      case TRADE_RETCODE_NO_CHANGES:
           return("リクエストに変更なし");
      case TRADE_RETCODE_SERVER_DISABLES_AT:
           return("サーバが自動取引を無効化");
      case TRADE_RETCODE_CLIENT_DISABLES_AT:
           return("クライアントが自動取引を無効化");
      case TRADE_RETCODE_LOCKED:
           return("リクエストが処理のためにロック中");
      case TRADE_RETCODE_FROZEN:
           return("注文やポジションが凍結");
      case TRADE_RETCODE_INVALID_FILL:
           return("無効な注文執行タイプ");
      case TRADE_RETCODE_CONNECTION:
           return("取引サーバに未接続");
      case TRADE_RETCODE_ONLY_REAL:
           return("操作は、ライブ口座のみで許可");
      case TRADE_RETCODE_LIMIT_ORDERS:
           return("待機注文の数が上限に達しました");
      case TRADE_RETCODE_LIMIT_VOLUME:
           return("注文やポジションのボリュームが上限に達しました");
      case TRADE_RETCODE_INVALID_ORDER:
           return("不正または禁止された注文の種類");
      case TRADE_RETCODE_POSITION_CLOSED:
           return("指定されたPOSITION識別子をもつポジションがすでに閉鎖");
   }
   return IntegerToString(retcode) + " Unknown Retcode";
}
