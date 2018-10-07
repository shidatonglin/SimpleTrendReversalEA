//+------------------------------------------------------------------+
//|                                                    Languages.mqh |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLng
  {
private:

public:
                     CLng();
                    ~CLng();
   //--- get text
   virtual string    GetText(const int row);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CLng::CLng()
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CLng::~CLng()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CLng::GetText(const int row)
  {
   string ru[25]=
     {
      "Счёт",                                                     // 0
      "Плечо",                                                    // 1
      "Нагрузка не более, %",                                     // 2
      "Сигналы:",                                                 // 3
      "Прирост, %",                                               // 4
      "Сигнал",                                                   // 5
      "Средства",                                                 // 6
      "Валюта",                                                   // 7
      "Плечо",                                                    // 8
      "Цена, $",                                                  // 9
      "Коэф. копирования",                                        // 10
      "Мин. депозит*",                                            // 11
      "Детали расчёта:",                                          // 12
      "● К1 = Соотношение валют = ",                              // 13
      " (расчёт через ",                                          // 14
      " маппинг невозможен",                                      // 15
      "● К2 = Соотношение балансов = ",                           // 16
      "● К3 = Использование депозита на ",                        // 17
      "● К4 = Плечо Вашего счёта / Плечо Провайдера = ",          // 18
      "● К4 = Коррекция на плечи не производится = 1.0000",       // 19
      "К = K1 * K2 * K3 * K4 = ",                                 // 20
      "Окончательный коэф. копирования = ",                       // 21
      "Сделка провайдера объёмом 1.00 лот будет скопирована как ",// 22
      " лот",                                                     // 23
      "Примечание: \"Мин. депозит\" - это депозит, необходимый для копирования 1:1 при использовании депозита на 95%" //24
     };
   string en[25]=
     {
      "Account",                                                     // 0
      "Leverage",                                                    // 1
      "Load no greater than, %",                                     // 2
      "Signals:",                                                    // 3
      "Growth, %",                                                   // 4
      "Signal",                                                      // 5
      "Funds",                                                       // 6
      "Currency",                                                    // 7
      "Leverage",                                                    // 8
      "Price, $",                                                    // 9
      "Copy ratio",                                                  // 10
      "Min. deposit*",                                               // 11
      "Calculation details:",                                        // 12
      "● К1 = Currency ratio = ",                                    // 13
      " (calculation using ",                                        // 14
      " mapping unavailable",                                        // 15
      "● К2 = Balance ratio = ",                                     // 16
      "● К3 = Using deposit on ",                                    // 17
      "● К4 = Your account leverage / Provider leverage = ",         // 18
      "● К4 = Leverage correction is not performed = 1.0000",        // 19
      "К = K1 * K2 * K3 * K4 = ",                                    // 20
      "Final copy ratio = ",                                         // 21
      "Provider's deal of 1.00 lot is copied as ",                   // 22
      " lot",                                                        // 23
      "Note: \"Min. deposit\" is a deposit necessary for copying 1:1 while using 95% of the deposit" //24
     };
//---
   int size=25;
   if(row<0 || row>size)
     {
      return(NULL);
     }
//---
   string language=TerminalInfoString(TERMINAL_LANGUAGE);
   if(language=="Russian")
     {
      return(ru[row]);
     }
   else
     {
      return(en[row]);
     }
  }
//+------------------------------------------------------------------+
