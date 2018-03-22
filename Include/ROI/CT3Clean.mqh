
extern  string    __T3CleanSetting       = "------T3 Clean Setting------";
extern  int                 tf_T3        =  30;
extern  int                 t3Period     =  10;
extern  ENUM_APPLIED_PRICE  appliedPrice =  PRICE_CLOSE;
extern  double              b            =  0.618;


string T3_CLEAN = "T3_clean";
class CT3Clean{

private:
	int    _TimeFrame;
	string _symbol;
public :
	CT3Clean(string symbol) : _TimeFrame(0)
	                        , _symbol(symbol){

	}
	~CT3Clean(){}

	double getValue(string symbol, int index){
		return iCustom(_symbol,_TimeFrame,T3_CLEAN,t3Period,appliedPrice,b,tf_T3,1,index);
	}
};

/*
double value = iCustom(NULL,PERIOD_M15,"T3_clean",10,0,0.618,15,1,1);
*/