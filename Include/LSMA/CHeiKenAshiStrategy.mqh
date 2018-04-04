

extern  string    __LSMAStrategySetting = "------HeiKenAshi Strategy Setting------";
extern    int     Lsma_TF_Entry = PERIOD_H1;
extern    int     Lsma_TF_Trend = PERIOD_D1;
extern    int     Lsma_TF_Middle = PERIOD_H4;
extern    int     entryBarShiftAllowed = 3;
extern    bool    UseZigZag  = false;
extern    bool    UseCurrent = false;
extern    bool    UseLagu    = true;

extern    int     TimeFrame = PERIOD_H4;

#include <CStrategy.mqh>
#include <LSMA\CLSMA.mqh>
#include <LSMA\CHeiKenAshi.mqh>
#include <LSMA\CBBMACD.mqh>
#include <LSMA\CLaguerre.mqh>
#include <LSMA\CMaChannal.mqh>
#include <LSMA\CMajorTrend.mqh>

#include <CZigZag.mqh>


class CHeiKenAshiStrategy : public IStrategy{

private :
	int                  _indicatorCount;
    CIndicator*         _indicators[];
    CSignal*            _signal;
    string              _symbol;
    CLSMA*              _lsmaTrend;
    CLSMA*              _lsmaEntry;
    CZigZag*            _zigZag;
    int                 _index;
    CHeiKenAshi*        _heiken;
    CBbMacd*            _bbMacd;
    CMaChannal*         _maChannal;
    CLaguerre*          _laguerre;
    CMajorTrend*        _majorTrend;

public :
	CHeiKenAshiStrategy(string symbol){
		_symbol = symbol;
		if(_symbol==NULL) _symbol = Symbol();
		_lsmaTrend      = new CLSMA(_symbol,Lsma_TF_Trend);
		_lsmaEntry      = new CLSMA(_symbol,Lsma_TF_Entry);
		_signal         = new CSignal();
		_zigZag         = new CZigZag();
		_heiken         = new CHeiKenAshi(_symbol,TimeFrame);
		_bbMacd         = new CBbMacd(_symbol, TimeFrame);
		_maChannal      = new CMaChannal(_symbol, TimeFrame);
		_laguerre       = new CLaguerre(_symbol, TimeFrame);
    _majorTrend     = new CMajorTrend(_symbol, TimeFrame);

		_indicatorCount = 0;
		ArrayResize( _indicators, 10 );
		
		_indicators[_indicatorCount] = new CIndicator("HeiKen" );
      _indicatorCount++;
	
      _indicators[_indicatorCount] = new CIndicator("MaHiLo");
      _indicatorCount++;
      
      _indicators[_indicatorCount] = new CIndicator("bbMacd");
      _indicatorCount++;
      
      if(UseLagu){
         _indicators[_indicatorCount] = new CIndicator("Lagu");
         _indicatorCount++;
      }

      _indicators[_indicatorCount] = new CIndicator("Trend");
      _indicatorCount++;      
        
      if (UseZigZag) {
         _indicators[_indicatorCount] = new CIndicator("ZigZagPercentual");
         _indicatorCount++;
      }
      if(UseCurrent) _index = 0;
      else _index = 1;
	}
	~CHeiKenAshiStrategy(){
		delete _zigZag;
	   delete _signal;
	   delete _lsmaTrend;
	   delete _lsmaEntry;
	   delete       _heiken;
      delete       _bbMacd;
      delete       _maChannal;
      delete       _laguerre;
      delete       _majorTrend;
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
      
      //1. Ha is up and cross up ma channal in three bars
      heikenAshi heikenData = _heiken.Refersh(_index);
      //heikenAshi heikenDataPre = _heiken.Refersh(_index+1);
      //heikenAshi heikenDataPre1 = _heiken.Refersh(_index+2);
      MaData madata = _maChannal.Refersh(_index);
      //MaData madataPre = _maChannal.Refersh(_index+1);
      //MaData madataPre1 = _maChannal.Refersh(_index+2);
      if(
         (
            (heikenData.isUp && heikenData.haClose > madata.high)
              && (GetCrossUpIndex(_index) < 3)
            //&& (heikenDataPre.haClose < madataPre.high)
         )
         /*||
         (
            (heikenDataPre.isUp && heikenDataPre.haClose > madataPre.high)
            && (heikenDataPre1.haClose < madataPre1.high)
         )
         */
        ){
         _signal.IsBuy = true;
         _indicators[index].IsValid = true;
         _signal.ExitSell = true;
         //index++;
      }else
      if(
         (
            (!heikenData.isUp && heikenData.haClose < madata.low)
              && (GetCrossDownIndex(_index) < 3)
            //&& (heikenDataPre.haClose > madataPre.low)
         )
         /*
         ||
         (
            (!heikenDataPre.isUp && heikenDataPre.haClose < madataPre.low)
            && (heikenDataPre1.haClose > madataPre1.low)
         )
         */
        ){
         _signal.IsSell = true;
         _indicators[index].IsValid = true;
         _signal.ExitBuy = true;
         //index++;
      }
      // 2. bb macd value break out the upper band for buy
      //                            the lower band for sell
      index++;
      bbMacdData curbbMacd = _bbMacd.Refersh(_index);
      //Print("current symbol---->"+_symbol);
      /*
      if(_symbol=="CADCHF"){
         if(curbbMacd.isUp)
            Print(_symbol + "break upper band index ---->");
         else
            Print(_symbol + "break lower band index ---->"+_bbMacd.GetBreakLowerBandIndex(_index));
      }*/
      if(curbbMacd.isUp && (curbbMacd.trend==UP) 
         && (_bbMacd.GetBreakUpperBandIndex(_index)<entryBarShiftAllowed)
      ){
         if(_signal.IsBuy){
            _indicators[index].IsValid = true;
            //index++;
         }
         _signal.ExitSell = true;
      }else if(!curbbMacd.isUp && (curbbMacd.trend==DOWN) 
            && (_bbMacd.GetBreakLowerBandIndex(_index)<entryBarShiftAllowed)
      ){
         if(_signal.IsSell){
            _indicators[index].IsValid = true;
            //index++;
         }
         _signal.ExitBuy = true;
      }
      
      // 3. Laguerre value should below 0.5 for buy and within 3 bars, the value get 0
      //                          upper 0.5 for sell and within 3 bars, the value get 1
      
      double lagu[];
      _laguerre.DataArray(lagu,_index,50);
      if(UseLagu){
         index++;
         
         //if(_symbol=="AUDCHF")
         //Print(_symbol+"laguerre---->"+ lagu[0] + ", "+ lagu[1] + ", "+ lagu[2] + ", "+ lagu[3]);
         //if(_symbol=="GBPCHF"){
            //Print("lagu--->"+FindFirstValueIndex(lagu,0.15,false));
         //}
         if(lagu[0]>0.15 && lagu[0]>lagu[1] && FindFirstValueIndex(lagu,0.15,false)<4){
            if(_signal.IsBuy){
               _indicators[index].IsValid = true;
               //index++;
            }
         }else if(lagu[0]<0.85 && lagu[0]<lagu[1] && FindFirstValueIndex(lagu,0.85,true)<4){
            if(_signal.IsSell){
               _indicators[index].IsValid = true;
               //index++;
            }
         }
      }
      if(lagu[0]>0.15 && lagu[1] < 0.15){
        _signal.ExitSell = true;
      }

      if(lagu[0]<0.85 && lagu[1] > 0.85){
        _signal.ExitBuy = true;
      }

      // 4. Major Trend Check
      index++;
      int majorTrend = _majorTrend.GetMajorTrend();

      if(_signal.IsBuy && majorTrend == 1){
        _indicators[index].IsValid = true;
      }

      if(_signal.IsSell && majorTrend == -1){
        _indicators[index].IsValid = true;
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

    int FindFirstValueIndex(double & values[], double value, bool bigger = false){
      int size = ArraySize( values );
      for(int i=0; i<size; i++){
        if(bigger){
          if(values[i] > value){
            return i;
          }
        } else {
          if(values[i] < value){
            return i;
          }
        }
      }
      return 999;
    }
    
    int GetCrossUpIndex(int index){
      for(int i=index+1; i<50;i++){
         heikenAshi newData = _heiken.Refersh(i);
         MaData newMa = _maChannal.Refersh(i);
         if(newData.haClose < newMa.high){
            return i-1;
         }
      }
      return 999;
    }
    
    int GetCrossDownIndex(int index){
      for(int i=index+1; i<50;i++){
         heikenAshi newData = _heiken.Refersh(i);
         MaData newMa = _maChannal.Refersh(i);
         if(newData.haClose > newMa.low){
            return i-1;
         }
      }
      return 999;
    }
};
