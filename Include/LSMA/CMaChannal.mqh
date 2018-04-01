

struct MaData{
   double high;
   double low;
   MaData(){
      high = 0.0;
      low = 0.0;
   }
};

class CMaChannal{

private:

   string                _symbol;
   int                   _timeFrame;
   int                   _maPeriod;
   int                   _digits;
   ENUM_MA_METHOD        _maMode;
   int                   _maShift;
           
public:
   
   CMaChannal(string symbol, int timeFrame):
                     _symbol(symbol),
                     _timeFrame(timeFrame),
                     _maPeriod(10),
                     _maShift(0),
                     _maMode(MODE_SMA){
      _digits = (int)MarketInfo(_symbol,MODE_DIGITS);                
   }
   
   CMaChannal(string symbol, int timeFrame, int period, int shift, ENUM_MA_METHOD mode):
                     _symbol(symbol),
                     _timeFrame(timeFrame),
                     _maPeriod(period),
                     _maShift(shift),
                     _maMode(mode){
      _digits = (int)MarketInfo(_symbol,MODE_DIGITS);                
   }
   
   ~CMaChannal(){
   }
   
   MaData Refersh(int index){
      MaData machannal;
     
      machannal.high = iMA(_symbol,_timeFrame,_maPeriod,_maShift,_maMode,PRICE_HIGH,index);
      machannal.low = iMA(_symbol,_timeFrame,_maPeriod,_maShift,_maMode,PRICE_LOW,index);
      
      return machannal;
   }
};