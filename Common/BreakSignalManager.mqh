
#include <BreakSignal.mqh>

string pairs[] = {"EURUSD","USDJPY","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF"
                ,"EURJPY","AUDJPY","GBPJPY","NZDJPY","CADJPY","AUDCAD","AUDNZD"
                ,"EURCAD","EURAUD","NZDCAD"
                ,"Gold"
                ,"JP225Cash","HK50Cash","CHI50Cash"
                ,"EU50Cash","FRA40Cash","GER30Cash","UK100Cash"
                ,"US100Cash","US30Cash","US500Cash"};



class SignalManager{

private:
public:
    SignalManager();
    ~SignalManager();
    void CheckSignal();
    void SendMassage(string);
};

SignalManager::SignalManager(){}

SignalManager::~SignalManager(){}

void SignalManager::CheckSignal(){

    int size = ArraySize(pairs);
    BreakSignal experts[30];
    Print("Total trade pairs:" ,size);
    for(int i=0; i<size;i++){
        experts[i].Init(pairs[i], PERIOD_H4);
    }

    static int pretime = 0;
    int signal = 0;
    string message = "";
    if(pretime != Time[0]){
        for(int i=0;i<size;i++){
            signal = experts[i].GetSignal();
            if(signal != 0){
                message = (experts[i].Symbol()) +  " Signal -->" +  (signal==1 ? "Buy" : "Sell");
                SendMassage(message);
                //SendNotification(message);
                //SendMail("Signal Notifications", message);
            } else {
               message = (experts[i].Symbol()) +  " Signal -->" + signal;
            }
            SendMassage(message);
        }
        pretime = Time[0];
    }
}

SignalManager::SendMassage(string message){
   SendNotification(message);
   SendMail("Signal Notifications", message);
}