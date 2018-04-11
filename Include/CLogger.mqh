
class CLogger {

private:
  string  _fileName;
  string  _symbol;

public:
  CLogger(string fileName, string symbol){
    _fileName = fileName;
    _symbol = symbol;
  }

  ~CLogger(){

  }

  void log(string String){
  
    int Handle;
    string Filename = "logs\\" + _fileName + " (" + _symbol + ", " + strPeriod( Period() ) + 
                ")\\" + TimeToStr( LocalTime(), TIME_DATE ) + ".txt";
                
    Handle = FileOpen(Filename, FILE_READ|FILE_WRITE|FILE_CSV, "/t");
    if (Handle < 1)
    {
        Print("Error opening audit file: Code ", GetLastError());
        return;
    }

    if (!FileSeek(Handle, 0, SEEK_END))
    {
        Print("Error seeking end of audit file: Code ", GetLastError());
        return;
    }

    if (FileWrite(Handle, TimeToStr(CurTime(), TIME_DATE|TIME_SECONDS) + "  " + String) < 1)
    {
        Print("Error writing to audit file: Code ", GetLastError());
        return;
    }
    FileClose(Handle);
  }

  string strPeriod( int intPeriod )
  {
    switch ( intPeriod )
    {
      case PERIOD_MN1: return("Monthly");
      case PERIOD_W1:  return("Weekly");
      case PERIOD_D1:  return("Daily");
      case PERIOD_H4:  return("H4");
      case PERIOD_H1:  return("H1");
      case PERIOD_M30: return("M30");
      case PERIOD_M15: return("M15");
      case PERIOD_M5:  return("M5");
      case PERIOD_M1:  return("M1");
      case PERIOD_M2:  return("M2");
      case PERIOD_M3:  return("M3");
      case PERIOD_M4:  return("M4");
      case PERIOD_M6:  return("M6");
      case PERIOD_M12:  return("M12");
      case PERIOD_M10:  return("M10");
      default:     return("Offline");
    }
  }
}