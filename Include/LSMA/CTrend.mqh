
extern int   timeFrame    = PERIOD_D1;
extern int   calculateBar = 100;
extern int   FastLen      = 12;
extern int   SlowLen      = 24;
extern int   Length       = 9;
extern double StDv        = 1.1;

enum TREND {
	TREND_LONG,
	TREND_SHORT,
	TREND_NONE
}



class CTrend{

protected:

	datetime    _startDate;
	datetime    _endDate;
	TREND       _trend;
	int         _timeFrame;
	int         _maxBars;

public:

	double     bbMacd[];
	double     Upperband[];
	double     Lowerband[];
	double     avg[];
	int        direction[];
	double     sDev;
	
	CTrend() : _timeFrame(timeFrame)
	          ,_bars(calculateBar){
	    ArrayResize(bbMacd , _maxBars + 5, 0);
      	ArrayResize(Upperband, _maxBars + 5, 0);
      	ArrayResize(Lowerband , _maxBars + 5, 0);
      	ArrayResize(avg, _maxBars + 5, 0);
      	ArrayResize(direction , _maxBars + 5, 0);
	}

	~CTrend(){
		ArrayFree(bbMacd);
      	ArrayFree(Upperband);
      	ArrayFree(Lowerband);
      	ArrayFree(avg);
      	ArrayFree(direction);
	}

	void Refresh(){
		for(int i=0; i<limit; i++)
        	bbMacd[i]=iMA(NULL,0,FastLen,0,MODE_EMA,PRICE_CLOSE,i) 
        			- iMA(NULL,0,SlowLen,0,MODE_EMA,PRICE_CLOSE,i);
      	for(i=0; i<limit; i++){

	        avg[i]=iMAOnArray(bbMacd,0,Length,0,MODE_EMA,i);
	        
	        sDev = iStdDevOnArray(bbMacd,0,Length,MODE_EMA,0,i);  
	               
	        Upperband[i] = avg[i] + (StDv * sDev);
	        Lowerband[i] = avg[i] - (StDv * sDev);
		    
		    direction = 0;
		    if (bbMacd[i]>bbMacd[i+1])
		    {
		    	direction[i]=1;
		    }
		      
		    if (bbMacd[i]<bbMacd[i+1])
			{
		    	direction[i]=-1;
		    }
		}
	}
}