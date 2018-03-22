
extern  int  timeframe  =  15;

string indicatorName = "T3_clean";
class CT3Clean{

private:
	int  _TimeFrame;
public :
	CT3Clean() : _TimeFrame(timeframe){

	}
	~CT3Clean(){

	}

	double getValue(string symbol, int index){
		return iCustom(symbol,_TimeFrame,indicatorName,10,0,0.618,15,1,index);
	}
}

/*
double value = iCustom(NULL,PERIOD_M15,"T3_clean",10,0,0.618,15,1,1);