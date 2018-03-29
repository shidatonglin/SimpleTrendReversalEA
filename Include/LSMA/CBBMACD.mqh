
extern int   	timeFrame     = PERIOD_D1;
extern int   	fast_period   = 12;
extern int   	slow_period   = 24;
extern int      signal_period = 9;
extern double   std           = 1.0

enum STATUS{
	UP,    // Main value is bigger than the upper band
	DOWN,  // Main value is smaller than the low band
	RANG   // Main value between the upper and low band
}

string BbMacd_Name = "PakuAK_Marblez";


class CBbMacd {

	string _symbol;
	int    _timeFrame;
	int    _fastPeriod;
	int    _slowPeriod;
	int    _signalPeriod;
	double _std;

public:

	double _upperBand;
	double _lowerBand;
	double _mainValue;
	STATUS _status;
	bool   _isUp; // If the current main value bigger than the previous one


	
	// Default Constructor
	// Using the external input parameter to construct the object
	CBbMacd() : _symbol(NULL),
				_timeFrame(timeFrame),
				_fastPeriod(fast_period),
				_slowPeriod(slow_period),
				_signalPeriod(signal_period),
				_std(std){
		Init();
	}

	CBbMacd(string symbol, int tf=0,int fast, int slow, int signal, double stdvalue) 
				: 	_symbol(symbol),
				    _timeFrame(tf),
					_fastPeriod(fast),
					_slowPeriod(slow),
					_signalPeriod(signal),
					_std(stdvalue){
		Init();
	}

	~CBbMacd(){}

	Init(){
		_upperBand=0.0;
		_lowerBand=0.0;
		_mainValue=0.0;
		_status=RANG;
		_isUp=false;
	}

	bool Refersh(int shift){
		double curUp= iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
							,_std, 0, shift);
	    double curDown = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
							,_std, 1, shift);
	    _upperBand = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
							,_std, 2, shift);
	    _lowerBand = iCustom( _symbol, _timeFrame, BbMacd_Name, _fastPeriod,_slowPeriod,_signalPeriod
							,_std, 3, shift);

	    if(curUp==EMPTY_VALUE){
	    	_mainValue = curDown;
	    	_isUp=false;
    	} else {
    		_mainValue = curUp;
    		_isUp=true;
    	}

    	if(_mainValue > _upperBand){
    		_status = UP;
		} else if(_mainValue < _lowerBand){
			_status = DOWN;
		} else {
			_status = RANG;
		}
	}

	

};






























