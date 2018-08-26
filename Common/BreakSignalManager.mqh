
#include <BreakSignal.mqh>

string pairs[] = {"EURUSD","USDJPY","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF"
                ,"EURJPY","AUDJPY","GBPJPY","NZDJPY","CADJPY"};



class SignalManager{

private:
public:
    SignalManager();
    ~SignalManager();
    void CheckSignal();
}

void SignalManager::CheckSignal(){

    int size = ArraySize(pairs);
    BreakSignal experts[size];
    for(int i=0; i<size;i++){
        experts[i].Init(pairs[i], PERIOD_H4);
    }

    static pretime = 0;
    int signal = 0;
    string message = "";
    if(pretime != Time[0]){
        for(int i=0;i<size;i++){
            signal = experts[i].getSignal();
            if(signal != 0){
                message = (experts[i].Symbol()) +  " Signal -->" +  (signal==1 ? "Buy" : "Sell");
                SendNotification(message);
                SendMail(message);
            }
        }
        pretime = Time[0];
    }
}