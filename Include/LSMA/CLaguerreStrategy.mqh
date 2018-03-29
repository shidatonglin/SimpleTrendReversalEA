

extern  string    __LaguerreStrategySetting = "------Laguerre Strategy Setting------";

extern    int     entryBarShiftAllowed = 3;
extern    bool    UseZigZag    = false;
extern    bool    UseCurrent   = false;
extern    bool    UseLaguerre  = true;
extern    bool    UseLSMA      = true;
extern    bool    UseBBMacd    = true;

#include <CStrategy.mqh>
#include <LSMA\CLSMA.mqh>
#include <LSMA\CBBMACD.mqh>
#include <LSMA\CLaguerre.mqh>
#include <CZigZag.mqh>


class CLSMAStrategy : public IStrategy{

private :
	int                  _indicatorCount;
    CIndicator*         _indicators[];
    CSignal*            _signal;
    string              _symbol;
    CLSMA*              _lsmaTrend;
    CLSMA*              _lsmaEntry;
    CZigZag*            _zigZag;
    int                 _index;
    CBBMACD*            _bbMacd;
    CLaguerre*          _laguerre;

public :
	CLSMAStrategy(string symbol){
		_symbol = symbol;
		if(_symbol==NULL) _symbol = Symbol();
		_lsmaTrend      = new CLSMA(_symbol);
		_lsmaEntry      = new CLSMA(_symbol);
		_signal         = new CSignal();
		_zigZag         = new CZigZag();
    _bbMacd         = new CBBMACD(_symbol);
    _laguerre       = new CLaguerre(_symbol);

		_indicatorCount = 0;
		ArrayResize( _indicators, 5 );
		
    if(UseLSMA){
      _indicators[_indicatorCount] = new CIndicator("LSMA" );
      _indicatorCount++;
    }
	 
    if(UseBBMacd){
      _indicators[_indicatorCount] = new CIndicator("bbMacd");
      _indicatorCount++;
    }

    if(UseLaguerre){
      _indicators[_indicatorCount] = new CIndicator("bbMacd");
      _indicatorCount++;
    }   
    if (UseZigZag) {
       _indicators[_indicatorCount] = new CIndicator("ZigZagPercentual");
       _indicatorCount++;
    }
    if(UseCurrent) _index = 0;
    else _index = 1;
	}
	~CLSMAStrategy(){
		delete _zigZag;
    delete _signal;
    delete _lsmaTrend;
    delete _lsmaEntry;
    delete _bbMacd;
    delete _laguerre;
		for (int i=0; i < _indicatorCount;++i){
    	    delete _indicators[i];
        }
        ArrayFree(_indicators);
	}

	CSignal* Refresh(){
	   _signal.Reset();
      LSMA_TREND trend = _lsmaTrend.GetCurrentTrend(_index);
      int barShift = _lsmaTrend.GetTrendStartBarShift(_index);

      // 1. 


      //Print("LSMA_TREND--->"+trend);
      LSMA_TREND entry = _lsmaEntry.GetCurrentTrend(_index);
      int entryBar = _lsmaEntry.GetTrendStartBarShift(_index);
      /*
      if(_symbol=="USDJPY"){
         Print("_index--->"+_index);
         Print("LSMA_TREND--->"+trend);
         Print("LSMA_TREND barShift--->"+trend);
         
         Print("entry--->"+entry);
         Print("entryBar barShift--->"+entryBar);
      }*/
      
      int index = 0;
      _indicators[index].IsValid = true;
      index++;
      if(trend==TREND_LONG){
         _signal.IsBuy = true;
         _signal.StopLoss = iLow(_symbol,Lsma_TF_Trend,barShift);
         
         if(entry==TREND_LONG && entryBar <= entryBarShiftAllowed){
            _indicators[index].IsValid = true;
            index++;
         }
         
      } else if(trend==TREND_SHORT){
         _signal.IsSell = true;
         _signal.StopLoss = iHigh(_symbol,Lsma_TF_Trend,barShift);
         
         if(entry==TREND_SHORT && entryBar <= entryBarShiftAllowed){
            _indicators[index].IsValid = true;
            index++;
         }
      }
      
      return _signal;
	}

	//--------------------------------------------------------------------
    int GetIndicatorCount(){
        return _indicatorCount;
    }
   
   //--------------------------------------------------------------------
    CIndicator* GetIndicator(int indicator){
        return _indicators[indicator];
    }
    
    //--------------------------------------------------------------------
    double GetStopLossForOpenOrder()
    {
        double points = MarketInfo(_symbol, MODE_POINT);
        double digits = MarketInfo(_symbol, MODE_DIGITS);
        double mult   = (digits == 3 || digits == 5) ? 10 : 1;
        _zigZag.Refresh(_symbol);
        
        // find last zigzag arrow
        int zigZagBar = -1;
        ARROW_TYPE arrow = ARROW_NONE;
        for (int bar=0; bar < 200;++bar){
            arrow = _zigZag.GetArrow(bar);
            if (arrow == ARROW_BUY )
            {
                if (OrderType() == OP_BUY) zigZagBar = bar;
                break;
            }
            else if (arrow == ARROW_SELL)
            {
                if (OrderType() == OP_SELL) zigZagBar = bar;
                break;
            }
        }
        if (zigZagBar == 0) zigZagBar=1;
        
        if (zigZagBar > 0)
        {
            if (arrow == ARROW_BUY)
            {
                return iLow(_symbol, 0, zigZagBar);
            }
            else if (arrow == ARROW_SELL)
            {
                return iHigh(_symbol, 0, zigZagBar);
            }
        }
        return 0;
    }
};
