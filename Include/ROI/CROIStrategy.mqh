
extern    bool    UseMTFSR = true;
extern    bool    UseT3Clean = true;
extern    bool    UseZigZag  = true;

#include <CStrategy.mqh>
#include <ROI\CMtfSupport.mqh>
#include <ROI\CT3Clean.mqh>


class CROIStrategy : public IStrategy{

private :
	int                 _indicatorCount;
    CIndicator*         _indicators[];
    CSignal*            _signal;
    string              _symbol;
    CMtfSupport*        _mtfSupport;
    CT3Clean*           _t3clean;

public :
	CROIStrategy(string symbol){
		_symbol = symbol;
		_mtfSupport = new CMtfSupport();
		_t3clean  = new CT3Clean();
		_indicatorCount = 0;
		ArrayResize( _indicators, 10 );
		if (UseMTFSR) {
			_indicatorCount++;
			_indicators[_indicatorCount] = new CIndicator("MtfSR");
		}
        if (UseT3Clean) {
        	_indicatorCount++;
        	_indicators[_indicatorCount] = new CIndicator("T3Clean");
        }
        if (UseZigZag) {
        	_indicatorCount++;
        	_indicators[_indicatorCount] = new CIndicator("ZigZagPercentual");
        }

	}
	~CROIStrategy(){
		delete _zigZag;
	    delete _mbfx;
	    delete _trendLine;
	    delete _signal;
		for (int i=0; i < _indicatorCount;++i){
        	delete _indicators[i];
      	}
      	ArrayFree(_indicators);
	}

	CSignal* Refresh(){
		
	}

	//--------------------------------------------------------------------
    int GetIndicatorCount(){
        return _indicatorCount;
    }
   
   //--------------------------------------------------------------------
    CIndicator* GetIndicator(int indicator){
        return _indicators[indicator];
    }
}