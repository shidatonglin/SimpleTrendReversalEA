
extern  string    __mtfSRSetting = "------#MTF SR Setting------";
extern  int       period1 = 60;
extern  int       period2 = 60;
extern  int       period3 = 60;
extern  int       period4 = 60;
//extern  int       tf_sr   = 15;

string  indicatorName = "#MTF SR";

class CMtfSupport{
  private:
    int       _Period1;
    int       _Period2;
    int       _Period3;
    int       _Period4;
    int       _TimeFrame;
    double    _Support;
    double    _Resistance;
    string    _symbol;
  public:
    
    CMtfSupport(string symbol) : _Period1(period1)
                   ,_Period2(period2)
                   ,_Period3(period3)
                   ,_Period4(period4)
                   ,_Support(-1)
                   ,_Resistance(-1)
                   ,_TimeFrame(0)
                   ,_symbol(symbol){
      
    }
    ~CMtfSupport(){

    }

    bool Refresh(int index){
      _Support = -1;
      _Resistance = -1;
      double support = iCustom(_symbol,_TimeFrame,indicatorName,_Period1,_Period2,_Period3,_Period4,
                                true,true,true,true,true,3,index);
      double resistance = iCustom(_symbol,_TimeFrame,indicatorName,_Period1,_Period2,_Period3,_Period4,
                                  true,true,true,true,true,4,index);
      _Support = MathMin( support, resistance );
      _Resistance = MathMax( support, resistance  );
      if(_Support > 0 && _Resistance > 0) return true;
      else return false;
    }

    double GetSupport(int index){
      if(_Support < 0.0) Refresh(index);
      return _Support;
    }

    double GetResistance(int index){
      if(_Resistance < 0.0) Refresh(index);
      return _Resistance;
    }

    bool CompareDoubles(double number1,double number2){
      if(NormalizeDouble(number1-number2,8)==0)
        return(true);
      else
        return(false);
    }
};


/*


void getMTFSR(){
   double value1 = iCustom(NULL,PERIOD_M15,"#MTF SR",60,60,60,60,
      true,true,true,true,true,3,1);
   double value2 = iCustom(NULL,PERIOD_M15,"#MTF SR",60,60,60,60,
      true,true,true,true,true,4,1);
   Print("value1--->"+value1);
   Print("value2--->"+value2);
}


void getT3_clean(){
   double value = iCustom(NULL,PERIOD_M15,"T3_clean",10,0,0.618,15,1,1);
   Print("value--->"+NormalizeDouble(value,5));
}

void getZigArrow(){
   //double value = iCustom(NULL,PERIOD_M15,"precentualzz_victor_Noam",0.04,5,1,1);
   
   //double value = 0;
   for(int i=0; i< 30;i++){
      double value = iCustom(NULL,0,"precentualzz_victor_Noam",0.04,"",5,1,i);
      double value1 = iCustom(NULL,0,"precentualzz_victor_Noam",0.04,"",5,2,i);
       Print("buy signal--->"+value);
       Print("sell signal--->"+value1);
   }
   
   //Print("value--->"+NormalizeDouble(value,5));
}*/