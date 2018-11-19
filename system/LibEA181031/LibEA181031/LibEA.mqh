//LibEA.mqh
#property copyright "Copyright (c) 2018, Toyolab FX"
#property link      "http://forex.toyolab.com/"
#property version   "181.031"

#ifndef POSITIONS
   #define POSITIONS 10  //最大ポジション数
#endif

#ifndef MAGIC
   sinput int MAGIC = 1;  //MAGIC(基本マジックナンバー)
#endif

#ifndef SlippagePips
   sinput double SlippagePips = 1;   //SlippagePips(許容スリッページpips)
#endif

#ifndef UseOrderComment
   string MagicToComment(long magic){return IntegerToString(magic);}
#endif

#ifdef __MQL4__
   #include "LibOrder4.mqh"
#endif

#ifdef __MQL5__
   #include "LibOrder5.mqh"   //for hedging mode
#endif

#ifndef UseOnTick
//ティック時実行関数
void OnTick()
{
   UpdatePosition();
   Tick();
}
#endif

//シグナルによる成行注文
void MyOrderSendMarket(int sig_entry, int sig_exit, double lots, int pos_id=0)
{
   //ポジション決済
   MyOrderCloseMarket(sig_entry, sig_exit, pos_id);
   //買い注文
   if(sig_entry > 0) MyOrderSend(OP_BUY, lots, 0, pos_id);
   //売り注文
   if(sig_entry < 0) MyOrderSend(OP_SELL, lots, 0, pos_id);
}

//シグナルによる待機注文
void MyOrderSendPending(int sig_entry, int sig_exit, double lots, double limit_pips, int pend_min=0, int pos_id=0)
{
   //ポジション決済
   MyOrderCloseMarket(sig_entry, sig_exit, pos_id);
   //注文キャンセル
   double pend_lots = MyOrderPendingLots(pos_id);
   if((pend_lots != 0 && pend_min > 0 && TimeCurrent() >= MyOrderOpenTime(pos_id) + pend_min*60)
      || pend_lots*sig_exit < 0) MyOrderDelete(pos_id);
   if(limit_pips > 0)
   {
      //指値買い注文
      if(sig_entry > 0) MyOrderSend(OP_BUYLIMIT, lots, Ask-limit_pips*PipPoint, pos_id);
      //指値売り注文
      if(sig_entry < 0) MyOrderSend(OP_SELLLIMIT, lots, Bid+limit_pips*PipPoint, pos_id);
   }
   else if(limit_pips < 0)
   {
      //逆指値買い注文
      if(sig_entry > 0) MyOrderSend(OP_BUYSTOP, lots, Ask-limit_pips*PipPoint, pos_id);
      //逆指値売り注文
      if(sig_entry < 0) MyOrderSend(OP_SELLSTOP, lots, Bid+limit_pips*PipPoint, pos_id);
   }
}

//シグナルによるポジション決済
void MyOrderCloseMarket(int sig_entry, int sig_exit, int pos_id=0)
{
   //同時シグナル
   if(sig_entry*sig_exit < 0) return;
   //決済注文
   if(MyOrderOpenLots(pos_id)*sig_exit < 0) MyOrderClose(pos_id);
}

//オープンポジションのロット数（符号付）を取得
double MyOrderOpenLots(int pos_id=0)
{
   double lots = 0;
   int type = MyOrderType(pos_id);
   double newlots = MyOrderLots(pos_id); 
   if(type == OP_BUY) lots = newlots;   //買いポジションはプラス
   if(type == OP_SELL) lots = -newlots; //売りポジションはマイナス
   return lots;   
}

//待機注文のロット数（符号付）の取得
double MyOrderPendingLots(int pos_id=0)
{
   double lots = 0;
   int type = MyOrderType(pos_id);
   double newlots = MyOrderLots(pos_id); 
   if(type == OP_BUYLIMIT || type == OP_BUYSTOP) lots = newlots;   //買い注文はプラス
   if(type == OP_SELLLIMIT || type == OP_SELLSTOP) lots = -newlots; //売り注文はマイナス
   return lots;   
}

//オープンポジションの一定利益となる決済価格の取得
double MyOrderShiftPrice(double sftpips, int pos_id=0) 
{
   double price = 0;
   //買いポジション
   if(MyOrderType(pos_id) == OP_BUY)
   {
      price = MyOrderOpenPrice(pos_id) + sftpips*PipPoint;
   }
   //売りポジション
   if(MyOrderType(pos_id) == OP_SELL)
   {
      price = MyOrderOpenPrice(pos_id) - sftpips*PipPoint;
   }
   return price;
}

//オープンポジションの一定価格における損益(pips)の取得
double MyOrderShiftPips(double price, int pos_id=0)
{
   double sft = 0;
   //買いポジション
   if(MyOrderType(pos_id) == OP_BUY)
   {
      sft = price - MyOrderOpenPrice(pos_id);
   }
   //売りポジション
   if(MyOrderType(pos_id) == OP_SELL)
   {
      sft = MyOrderOpenPrice(pos_id) - price;
   }
   return sft/PipPoint; //pips値に変換   
}

//売買ロット数の正規化
double NormalizeLots(double lots)
{
   //最小ロット数
   double lots_min = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   //最大ロット数
   double lots_max = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   //ロット数刻み幅
   double lots_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   //ロット数の小数点以下の桁数
   int lots_digits = (int)MathLog10(1.0/lots_step);
   lots = NormalizeDouble(lots, lots_digits); //ロット数の正規化
   if(lots < lots_min) lots = lots_min; //最小ロット数を下回った場合
   if(lots > lots_max) lots = lots_max; //最大ロット数を上回った場合
   return lots;
}

//待機注文の有効期限
bool PendingOrderExpiration(int min, int pos_id=0)
{
   int type = MyOrderType(pos_id);  // 注文の種類
   //待機注文でない場合
   if(type == OP_NONE || type == OP_BUY || type == OP_SELL) return false;
   //有効期限を過ぎた場合
   if(TimeCurrent() >= MyOrderOpenTime(pos_id) + min*60) return true;
   return false;  //有効期限内
}

//シグナル待機フィルタ
int WaitSignal(int signal, int min, int pos_id=0)
{
   int ret = 0; //シグナルの初期化
   if(MyOrderOpenLots(pos_id) != 0 //オープンポジションがある場合
      //待機時間が経過した場合
      && TimeCurrent() >= MyOrderOpenTime(pos_id) + min*60)
         ret = signal;

   return ret; //シグナルの出力
}
