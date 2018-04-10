

extern  string    __LSMAStrategySetting = "------Three Screen Strategy Setting------";

extern    int     entryBarShiftAllowed = 3;
extern    bool    UseZigZag  = false;
extern    bool    UseCurrent = false;
extern    bool    UseLagu    = true;

extern    int     TimeFrame = PERIOD_H1;

#include <CStrategy.mqh>

#include <LSMA\CLaguerre.mqh>
#include <CZigZag.mqh>


class CThreeScreenStrategy : public IStrategy{

private :
	int                  _indicatorCount;
    CIndicator*         _indicators[];
    CSignal*            _signal;
    string              _symbol;
    CZigZag*            _zigZag;
    CLaguerre*          _laguerre;
    int                 _index;

public :
	CThreeScreenStrategy(string symbol){
		_symbol = symbol;
		if(_symbol==NULL) _symbol = Symbol();
		_signal         = new CSignal();
      _zigZag         = new CZigZag();
    _laguerre       = new CLaguerre(_symbol, TimeFrame);
		_indicatorCount = 0;
		ArrayResize( _indicators, 5 );
		
		_indicators[_indicatorCount] = new CIndicator("W_MACD" );
      _indicatorCount++;
	
      _indicators[_indicatorCount] = new CIndicator("D_MACD");
      _indicatorCount++;
      
      _indicators[_indicatorCount] = new CIndicator("WPR");
      _indicatorCount++;
      
      if(UseLagu){
         _indicators[_indicatorCount] = new CIndicator("Lagu");
         _indicatorCount++;
      }
      /*
      _indicators[_indicatorCount] = new CIndicator("Trend");
      _indicatorCount++;      
        
      if (UseZigZag) {
         _indicators[_indicatorCount] = new CIndicator("ZigZagPercentual");
         _indicatorCount++;
      }
      */
      if(UseCurrent) _index = 0;
      else _index = 1;
	}
	~CThreeScreenStrategy(){
		delete       _laguerre;
    delete _zigZag;
    delete _signal;
		for (int i=0; i < _indicatorCount;++i){
    	    delete _indicators[i];
        }
        ArrayFree(_indicators);
	}

	CSignal* Refresh(){

      // clear indicators
      for (int i=0; i < _indicatorCount;++i)
      {
        _indicators[i].IsValid = false;
      }
     
     // Reset Signal
	   _signal.Reset();
      
	   int index = 0;
      _indicators[index].IsValid = true;
      index++;
      
      
      //1. Weekly MACD Signal
      double macd_week = iCustom(_symbol, 10080 , "macd_adjustable", 12 , 24 , 9 , 3 
                                 , True , True , 0, 1);
      double macd_down_week = iCustom(_symbol, 10080 , "macd_adjustable", 12 , 24 , 9 , 3 
                                 , True , True , 1, 1);
      //2. Daily MACD Signal
      double macd_day = iCustom(_symbol, 1440 , "macd_adjustable", 12 , 24 , 9 , 3 
                                 , True , True , 0, 1);
      double macd_down_day = iCustom(_symbol, 1440 , "macd_adjustable", 12 , 24 , 9 , 3 
                                 , True , True , 1, 1);                          
      if( macd_week > 0 && macd_day > 0){
         _signal.IsBuy = true;
         _indicators[index].IsValid = true;
      } else if(macd_down_week < 0 && macd_down_day < 0){
         _signal.IsSell = true;
         _indicators[index].IsValid = true;
      }
      
      //3. H1 Wpr Signal
      index++;
      double wpr = iWPR(_symbol, 60 , 14 , 1);
      if(wpr < -80 && _signal.IsBuy){
         _indicators[index].IsValid = true;
      }
      
      if(wpr > -20 && _signal.IsSell){
         _indicators[index].IsValid = true;
      }

      double lagu[];
      _laguerre.DataArray(lagu,_index,50);
      if(UseLagu){
         index++;
         if(lagu[0]>0.15 && lagu[1]<0.15){
            if(_signal.IsBuy){
               _indicators[index].IsValid = true;
               //index++;
            }
         }else if(lagu[0]<0.85 && lagu[1]>0.85){
            if(_signal.IsSell){
               _indicators[index].IsValid = true;
               //index++;
            }
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
