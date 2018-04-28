//+------------------------------------------------------------------+
//|                                                     CloseAll.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

void OnStart()
{
  int totalSymbols = SymbolsTotal(false);
    Print(totalSymbols);
    for(int i=0;i<totalSymbols;i++){
      Print(i + " " +SymbolName(i,false));
    }    
}