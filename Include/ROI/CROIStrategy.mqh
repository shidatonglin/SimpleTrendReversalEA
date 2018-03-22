

extern  string    __ROIStrategySetting = "------ROI Strategy Setting------";
extern    bool    UseMTFSR = true;
extern    bool    UseT3Clean = true;
extern    bool    UseZigZag  = false;
extern    bool    UseCurrent = false;
extern    int     TimeFrame  = 15;

#include <CStrategy.mqh>
#include <ROI\CMtfSupport.mqh>
#include <ROI\CT3Clean.mqh>
#include <CZigZag.mqh>


class CROIStrategy : public IStrategy{

private :
	int                  _indicatorCount;
    CIndicator*         _indicators[];
    CSignal*            _signal;
    string              _symbol;
    CMtfSupport*        _mtfSupport;
    CT3Clean*           _t3clean;
    CZigZag*            _zigZag;
    int                 _index;

public :
	CROIStrategy(string symbol){
		_symbol = symbol;
		if(_symbol==NULL) _symbol = Symbol();
		_mtfSupport     = new CMtfSupport(_symbol);
		_t3clean        = new CT3Clean(_symbol);
		_signal         = new CSignal();
		_indicatorCount = 0;
		ArrayResize( _indicators, 10 );
		if (UseMTFSR) {
			_indicators[_indicatorCount] = new CIndicator("MtfSR");
            _indicatorCount++;
		}
        if (UseT3Clean) {
            _indicators[_indicatorCount] = new CIndicator("T3Clean");
            _indicatorCount++;
        }
        if (UseZigZag) {
            _indicators[_indicatorCount] = new CIndicator("ZigZagPercentual");
            _indicatorCount++;
        }
        if(UseCurrent) _index = 0;
        else _index = 1;
	}
	~CROIStrategy(){
		delete _zigZag;
	    delete _signal;
		for (int i=0; i < _indicatorCount;++i){
    	    delete _indicators[i];
        }
        ArrayFree(_indicators);
	}

	CSignal* Refresh(){
		bool mtfSrBreakUp = false, mtfSrBreakDown = false, t3CleanOK = false;
		_mtfSupport.Refresh(_index);
		double support = _mtfSupport.GetSupport(_index);
		double resistance = _mtfSupport.GetResistance(_index);
		double closePrice = iClose( _symbol, TimeFrame , _index );
        double closePricePre = iClose( _symbol, TimeFrame , _index + 1);

		if(closePrice > resistance && closePricePre < resistance){
			mtfSrBreakUp = true;
		}
        if(closePrice < support && closePricePre > support){
            mtfSrBreakDown = true;
        }

        double t3clen = _t3clean.getValue(_symbol, _index);
        if(mtfSrBreakUp && closePrice > t3clen){
            t3CleanOK = true;
        }
        if(mtfSrBreakDown && closePrice < t3clen){
            t3CleanOK = true;
        }

        // clear indicators
        for (int i=0; i < _indicatorCount;++i)
        {
            _indicators[i].IsValid = false;
        }
        _signal.Reset();
        int index = 0;
        if(UseMTFSR){
            if(mtfSrBreakUp){
                _signal.IsBuy = true;
                _indicators[index].IsValid = true; 
                index++;
            }
            if(mtfSrBreakDown){
                _signal.IsSell = true;
                _indicators[index].IsValid = true;
                index++;
            }
        }
        if(UseT3Clean){
            _indicators[index].IsValid = t3CleanOK; 
            index++;
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
