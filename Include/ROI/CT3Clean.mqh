
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
	CT3Clean(string symbol) : _TimeFrame(tf_T3)
	                        , _symbol(symbol){

	}
	~CT3Clean(){}

	double getValue(int index){
		double value = iCustom(_symbol,0,T3_CLEAN,t3Period,appliedPrice
		   ,b,_TimeFrame,1,index);
		return value;
	}
};

/*
double value = iCustom(NULL,PERIOD_M15,"T3_clean",10,0,0.618,15,1,1);
*/