
#property indicator_chart_window

extern color Line_200_barsColor  = Green;//Yellow
extern int   Line_200_barsStyle = 2;
extern int   Line_200_barsWidth = 1;
extern bool  Draw_as_Background=TRUE;

int init(){return(0);}
int deinit(){
ObjectDelete ("200_bars"); 
return(0);}

int start(){
ObjectDelete("200_bars");
ObjectCreate("200_bars",OBJ_VLINE,0,Time[200],Bid);
ObjectSet   ("200_bars",OBJPROP_COLOR,Line_200_barsColor);
ObjectSet   ("200_bars",OBJPROP_STYLE,Line_200_barsStyle);
ObjectSet   ("200_bars",OBJPROP_WIDTH,Line_200_barsWidth);
ObjectSet   ("200_bars",OBJPROP_BACK,Draw_as_Background);

return(0);}
//+------------------------------------------------------------------+