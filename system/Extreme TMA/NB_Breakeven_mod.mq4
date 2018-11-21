
#property copyright "© 2007 RickD/modified by milanese"


#define major   1
#define minor   0

#property indicator_chart_window
#property indicator_buffers 0
extern double BE_Pips=10;
extern bool DrawSymbolChart = true;
extern bool DrawBreakeven = true;
extern int Corner = 0;
extern int FontSize = 8;
extern int dy = 40;

extern color _Header = Gold;
extern color _Text = Gold;
extern color _Data = PowderBlue;
extern color _EquityPositive = Lime;
extern color _EquityNegative = Red;
extern color _Separator = SlateGray;
extern color _Breakeven = PowderBlue;

int multiplier=1;

string prefix = "capital_";
string sepstr = "---------------------------------------------------------------";

void init() 
{
 
  clear();
}

void deinit() 
{
 
  clear();
}

void clear() 
{
  string name;
  int obj_total = ObjectsTotal();
  for (int i=obj_total-1; i>=0; i--)
  {
    name = ObjectName(i);
    if (StringFind(name, prefix) == 0) ObjectDelete(name);
  }
}

void start()
{
  clear();

  string Sym[];
  double Equity[];
  double Lots[];
  color equityColor;
  ArrayResize(Sym, 0);
  ArrayResize(Equity, 0);
  ArrayResize(Lots, 0);
  
  string eq;
  
  int cnt = OrdersTotal();
  for (int i=0; i<cnt; i++)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    
    int type = OrderType();
    if (type != OP_BUY && type != OP_SELL) continue;
    
    bool found = false;
    
    int size = ArraySize(Sym);
    for (int k=0; k<size; k++)
    {
      if (Sym[k] == OrderSymbol()) {
        Equity[k] += OrderProfit() + OrderCommission() + OrderSwap();
        if (type == OP_BUY) Lots[k] += OrderLots();
        if (type == OP_SELL) Lots[k] -= OrderLots();
        found = true;
        break;
      }
    }
    
    if (found) continue;
    
    int ind = ArraySize(Sym);
    ArrayResize(Sym, ind+1);
    Sym[ind] = OrderSymbol();
    
    ArrayResize(Equity, ind+1);
    Equity[ind] = OrderProfit() + OrderCommission() + OrderSwap();
    
    ArrayResize(Lots, ind+1);
    if (type == OP_BUY) Lots[k] = OrderLots();
    if (type == OP_SELL) Lots[k] = -OrderLots();
  }
  
  if (DrawSymbolChart==true){
    nb_drawLabel("symbols",  "Symbol",   30+FontSize, dy,   _Header);
    nb_drawLabel("equities",  "Equity",   130+FontSize,dy,   _Header);
    nb_drawLabel("breakeven","Breakeven",220+FontSize,dy,   _Header);
    nb_drawLabel("tmp1",     sepstr,     20+FontSize, dy+FontSize+2,_Separator);
  }
  
  double sum = 0;
  string level0 = "";
  
  size = ArraySize(Sym);
  for (i=0; i<size; i++)
  {
    if (Lots[i] == 0) {
      level0 = "Lock";
    }
    else {
      int dig = MarketInfo(Sym[i], MODE_DIGITS);
      double point = MarketInfo(Sym[i], MODE_POINT);
      
      double COP = Lots[i]*MarketInfo(Sym[i], MODE_TICKVALUE);
      double val = MarketInfo(Sym[i], MODE_BID) - point*(Equity[i]-BE_Pips)/COP;
      level0 = DoubleToStr(val, dig);
    }
    
    if (Equity[i] > 0) { eq = "+$"+DoubleToStr(MathAbs(Equity[i]),2); equityColor = _EquityPositive; }
    else               { eq = "-$"+DoubleToStr(MathAbs(Equity[i]),2); equityColor = _EquityNegative; }
    
    if (DrawSymbolChart==true){     
      nb_drawLabel("symbol"+i,   Sym[i],30+FontSize, (i+1)*(FontSize*2)+2+dy,_Text);
      nb_drawLabel("equity"+i,   eq,    120+FontSize,(i+1)*(FontSize*2)+2+dy,equityColor);
      nb_drawLabel("breakeven"+i,level0,230+FontSize,(i+1)*(FontSize*2)+2+dy,_Data);
    }
    
    if (Sym[0]==Symbol())
    	if (DrawBreakeven==true){
    		ObjectCreate(prefix+"breakevenline",OBJ_HLINE,0,0,StrToDouble(level0));
    		ObjectSet(prefix+"breakevenline",OBJPROP_COLOR,_Breakeven);
    		ObjectSet(prefix+"breakevenline",OBJPROP_STYLE,STYLE_DASH);
    	}
    
    sum += Equity[i];
  }
	
  if (sum > 0) { eq = "+$"+DoubleToStr(MathAbs(sum),2); equityColor = _EquityPositive; }
  else         { eq = "-$"+DoubleToStr(MathAbs(sum),2); equityColor = _EquityNegative; }
  
  if (DrawSymbolChart==true){
    nb_drawLabel("tmp2",  sepstr, 20+FontSize,  (i+0.6)*(FontSize*2)+dy, _Separator);
    nb_drawLabel("total", "Total",30+FontSize,  (i+1.2)*(FontSize*2)+dy, _Text);
    nb_drawLabel("equity", eq,    120+FontSize, (i+1.2)*(FontSize*2)+dy, equityColor);
  }
  
  // Added by renexxxx 2016-04-25
  double dailyTotal = 0.0;
  datetime today = iTime( Symbol(), PERIOD_D1, 0 );
  for(int iOrder=OrdersHistoryTotal()-1; iOrder >= 0; iOrder--) {
    if ( OrderSelect( iOrder, SELECT_BY_POS, MODE_HISTORY ) ) {
      if ( (OrderType() == OP_BUY) || (OrderType() == OP_SELL) ) {
        if ( OrderCloseTime() >= today ) {
           dailyTotal += OrderProfit() + OrderSwap() + OrderCommission();
        }
      }
    }
  }
  double prevBalance = AccountBalance() - dailyTotal;
  if (DrawSymbolChart==true) {
    nb_drawLabel("dailyTotalLbl", "Daily Total", 30+FontSize, (i+2.5)*(FontSize*2)+dy, _Text);
    nb_drawLabel("dailyTotalTxt", StringFormat("$ %5.2f",dailyTotal), 120+FontSize, (i+2.5)*(FontSize*2)+dy, ( dailyTotal >= 0.0 ) ? _EquityPositive : _EquityNegative );
    nb_drawLabel("dailyPercentLbl", "Daily %", 30+FontSize, (i+3.5)*(FontSize*2)+dy, _Text );
    nb_drawLabel("dailyPercentTxt", StringFormat("  %5.1f %%",100.0*(dailyTotal/prevBalance)), 120+FontSize, (i+3.5)*(FontSize*2)+dy, ( dailyTotal >= 0.0 ) ? _EquityPositive : _EquityNegative );
  }
}

void nb_drawLabel(string name, string text,
                  int xdistance, int ydistance,
                  color fontcolor)
{
	string n = prefix + name;
	if (ObjectFind(n) == -1)
		ObjectCreate(n,OBJ_LABEL,0,0,0);
	ObjectSet(n,OBJPROP_XDISTANCE,xdistance);
	ObjectSet(n,OBJPROP_YDISTANCE,ydistance);
	ObjectSet(n,OBJPROP_CORNER,Corner);
	ObjectSetText(n,text,FontSize,"Tahoma",fontcolor);
}

