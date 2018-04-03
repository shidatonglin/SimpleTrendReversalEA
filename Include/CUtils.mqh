//+------------------------------------------------------------------+
//|                                                     CAccount.mqh |
//|                                    Copyright 2017, Erwin Beckers |
//|                                      https://www.erwinbeckers.nl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Erwin Beckers"
#property link      "https://www.erwinbeckers.nl"
#property strict

class CNotify
{
   public: 
      string   symbol;
      string   text;
      string   key;
      
      CNotify(string sym, string txt, string uniquekey)
      {
         symbol = sym;
         text   = txt;
         key    = uniquekey;
      }
};

class CNotifyManager
{
private:
   CNotify* _notifies[];
   int      _notifyCount;
   
private:
   //--------------------------------------------------------------------
   int GetIndex(string symbol)
   {
      for (int i=0; i < _notifyCount;++i)
      {
         if (_notifies[i].symbol == symbol) return i;
      }
      return -1;
   }
   
   //--------------------------------------------------------------------
   void OnNotifySend(string symbol, string text, string uniquekey)
   {
     int index = GetIndex(symbol);
     if (index < 0)
     {
         ArrayResize(_notifies, _notifyCount + 1);
         _notifies[_notifyCount] = new CNotify(symbol, text, uniquekey);
         _notifyCount++;
         return;
     }
     _notifies[index].key = uniquekey;
     _notifies[index].text= text;
   }
      
   //--------------------------------------------------------------------
   bool CanSendNotify(string symbol, string uniquekey)
   {
     int index = GetIndex(symbol);
     if (index < 0) return true;
     
     if (_notifies[index].key != uniquekey) return true;
     return false;
   }
   
public:
   //--------------------------------------------------------------------
   CNotifyManager()
   {
      _notifyCount = 0;
   }
   
   ~CNotifyManager(){
      int total = ArraySize(_notifies);
      for(int i=0; i<total; i++){
         delete _notifies[i];
      }
   }
   
   //--------------------------------------------------------------------
   void SendNotify(string symbol, string uniquekey, bool sendEmail,  string text)
   {
      if (CanSendNotify(symbol, uniquekey))
      {
         OnNotifySend(symbol, text, uniquekey);
         if (text != "")
         {
            SendNotification(symbol+":" + text);
            Alert(symbol + ":" + text);
            if (sendEmail)
            {
               SendMail("Daily trend reversal alert", symbol+ ":" +text);
            }
         }
      }
   }      
};


class CScreenshot{

   string _SavedChartsFolder;
   string _SubFolder;

public:
   CScreenshot(string subFolder){
      _SubFolder = subFolder;
      _SavedChartsFolder = "ScreenShot/";
   }

   ~CScreenshot(){

   }


   string PeriodDesc(int TF_0) {
      switch (TF_0) {
      case 1:
         return ("M1");
      case 5:
         return ("M5");
      case 15:
         return ("M15");
      case 30:
         return ("M30");
      case 60:
         return ("H1");
      case 240:
         return ("H4");
      case 1440:
         return ("D1");
      case 10080:
         return ("W1");
      case 43200:
         return ("MN");
      }
      return ("Unknown TF");
   }
   
   string DateTimeReformat(string dat_0) {
      string dat_8;
      string dat_ret_16 = "";
      dat_0 = " " + dat_0;
      int dat_len_24 = StringLen(dat_0);
      for (int dat_28 = 0; dat_28 < dat_len_24; dat_28++) {
         dat_8 = StringSetChar(dat_8, 0, StringGetChar(dat_0, dat_28));
         if (dat_8 != ":" && dat_8 != " " && dat_8 != ".") dat_ret_16 = dat_ret_16 + dat_8;
      }
      return (dat_ret_16);
   } 
   
 
   int TakeScreenShot() {   

      string pretxt_40 = _SavedChartsFolder + Symbol() + "_" + PeriodDesc(Period()) + "_" + _SubFolder
         +"_" + DateTimeReformat(TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
      WindowScreenShot(pretxt_40 + ".png",1028, 768, 0, -1, -1); // * careful with file type
      //PlaySound ("shutter.wav");            
   }
};

      
class CUtils
{
private:
   datetime         _prevTime;
   double           _pipValue;
   CNotifyManager*  _notifyMgr;
   
public:
   double PointValue;
   bool   IsNewBar;
   
   CUtils(void)
   {
      _notifyMgr = new CNotifyManager();
      _pipValue  = 1;
      if (Digits ==3 || Digits==5) _pipValue = 10;
      
      PointValue = Point() * _pipValue;
   }
   
   ~CUtils()
   {
      delete _notifyMgr;
   }
   
   //------------------------------------------------------------------------------------
   // GetTimeFrame()
   //------------------------------------------------------------------------------------
   string GetTimeFrame(int timePeriod)
   {  
      string timeframe="";
      switch (timePeriod)
      {
         case 1: timeframe="M1";break;
         case 5: timeframe="M5";break;
         case 15: timeframe="M15";break;
         case 30: timeframe="M30";break;
         case 60: timeframe="H1";break;
         case 240: timeframe="H4";break;
         case 1440: timeframe="D1";break;
         case 10080: timeframe="W1";break;
      }
      return timeframe;
   }
   
   //------------------------------------------------------------------------------------
   // SendNotify
   //------------------------------------------------------------------------------------
   void SendNotify(string symbol, string uniquekey, bool email, string text)
   {
      _notifyMgr.SendNotify(symbol, uniquekey, email, text);
   }
   
   
   //------------------------------------------------------------------------------------
   // Convert pips to price
   //------------------------------------------------------------------------------------
   double PipsToPrice(double pips)
   {
      return pips * PointValue;
   }
   
   //------------------------------------------------------------------------------------
   // Convert price to pips
   //------------------------------------------------------------------------------------
   double PriceToPips(double points)
   {
      return points / PointValue;
   }
   

   //------------------------------------------------------------------------------------
   // return current spread
   //------------------------------------------------------------------------------------
   double Spread()
   {
   	return PriceToPips(Ask - Bid);
   }  
   
   //------------------------------------------------------------------------------------
   // Refresh()
   //------------------------------------------------------------------------------------
   void Refresh()
   {
   	datetime now = Time[0];
   	if (now != _prevTime)
   	{
   		IsNewBar = true;
   		_prevTime = now;
   	}
   	else
   	{
   		IsNewBar = false;
   	}
   }
};

//CUtils* _utils = new CUtils();