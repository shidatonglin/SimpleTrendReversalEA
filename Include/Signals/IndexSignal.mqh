//+------------------------------------------------------------------+
//|                                                HABreakSignal.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include "CBBMACD.mqh"
/*
For Ha break signal


TimeFrame H4

Rules for buy:
1. Ha color changed from Red to White (last three changed candles)
2. Ha price cross over the Ma line (last three cross over candles)
The current bar close over the Ma line and within three bars, there is a candle
close below the Ma line.
3. The 0.6 lagu value start to bigger than the 0.8 lagu value



*/

