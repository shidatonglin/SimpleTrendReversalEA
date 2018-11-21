
#property indicator_chart_window

extern color Line_50_barsColor  = Crimson;//Yellow
extern int   Line_50_barsStyle = 2;
extern int   Line_50_barsWidth = 1;
extern bool  Draw_as_Background=TRUE;

int init(){return(0);}
int deinit(){
ObjectDelete ("50_bars"); 
return(0);}

int start(){
ObjectDelete("50_bars");
ObjectCreate("50_bars",OBJ_VLINE,0,Time[50],Bid);
ObjectSet   ("50_bars",OBJPROP_COLOR,Line_50_barsColor);
ObjectSet   ("50_bars",OBJPROP_STYLE,Line_50_barsStyle);
ObjectSet   ("50_bars",OBJPROP_WIDTH,Line_50_barsWidth);
ObjectSet   ("50_bars",OBJPROP_BACK,Draw_as_Background);

return(0);}
//+------------------------------------------------------------------+