//+------------------------------------------------------------------+
//|                                Сalculator for signals Dialog.mqh |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "2.044"
#include <Controls\Dialog.mqh>
#include <Controls\Label.mqh>
#include <Controls\Edit.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\Button.mqh>
#include <Controls\TableListView.mqh>
#include <Controls\BmpButton.mqh>
#include <Canvas\Canvas.mqh>
#include "Languages.mqh"
#include "LineTable.mqh"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for combo boxes
#define COMBOBOX_WIDTH                      (60)      // size by X coordinate
#define COMBOBOX_HEIGHT                     (20)      // size by Y coordinate
//--- for list view
#define LIST_HEIGHT                         (102)     // size by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (72)      // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_WIDTH                          (60)      // size by X coordinate
#define EDIT_HEIGHT                         (20)      // size by Y coordinate
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct AccountInfo
  {
   long              login;            // Account login
   double            balance;          // Account balance in the deposit currency
   long              dep_perc;         // Deposit percent (%)
   long              leverage;         // Account leverage
   string            currency;         // Account currency
  };
AccountInfo AccInfo;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct SignalInfo
  {
   double            balance;          // Signal balance
   long              leverage;         // Signal leverage
   string            currency;         // Signal currency
   double            gain;             // Signal gain
   double            price;            // Signal subscription price
   long              id;               // Signal ID   
  };
SignalInfo SigInfo;
//+------------------------------------------------------------------+
//| Class CoSDialog                                                  |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CoSDialog : public CAppDialog
  {
private:
   CLabel            m_label1;                        // the label object
   CEdit             m_edit1;                         // the display field object
   CComboBox         m_combo_box1;                    // the combo box object
   CLabel            m_label2;                        // the label object
   CComboBox         m_combo_box2;                    // the combo box object
   CLabel            m_label3;                        // the label object
   CComboBox         m_combo_box3;                    // the combo box object
   CLabel            m_label4;                        // the label object
   CButton           m_button1;                       // the bmp_button object
   CButton           m_button2;                       // the bmp_button object
   CButton           m_button3;                       // the bmp_button object
   CButton           m_button4;                       // the bmp_button object
   CButton           m_button5;                       // the bmp_button object
   CButton           m_button6;                       // the bmp_button object
   CButton           m_button7;                       // the bmp_button object
   CButton           m_button8;                       // the bmp_button object
   CTableListView    m_table_list_view1;              // the table list_view object
   CLabel            m_label5;                        // the label object
   CBmpButton        m_bmp_button1;                   // the bmp_button object
   CCanvas           m_canvas1;                       // the canvas object
   CLng              m_languages;                     // the languages object
   CArrayObj         m_table;                         // the table object
                                                      //string            m_arr_signals[][2];              // array of signals
   int               m_tab;                           // tab length  
   bool              m_error;                         // true -> error in the program

public:
                     CoSDialog(void);
                    ~CoSDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- refresh lists
   virtual void      Refresh(void);

protected:
   //--- create dependent controls
   bool              CreateLabel1(void);     // create the "Trading account" Label   
   bool              CreateEdit1(void);      // create the "Balanc" Edit
   bool              CreateComboBox1(void);  // create the combo box "Currency"    
   bool              CreateLabel2(void);     // create the "Leverage" Label 
   bool              CreateComboBox2(void);  // create the combo box "Leverage" 
   bool              CreateLabel3(void);     // create the "Deposit percent (%)" Label 
   bool              CreateComboBox3(void);  // create the combo box "Deposit percent (%)" 
   bool              CreateLabel4(void);     // create the "Signals" Label 
   bool              CreateButton1(void);    // create the "Growth, %" Button
   bool              CreateButton2(void);    // create the "Signal" Button
   bool              CreateButton3(void);    // create the "Funds" Button
   bool              CreateButton4(void);    // create the "Currency" Button
   bool              CreateButton5(void);    // create the "Leverage" Button
   bool              CreateButton6(void);    // create the "Price" Button
   bool              CreateButton7(void);    // create the "Percentage of copy" Button
   bool              CreateButton8(void);    // create the "Percentage of copy 1:1" Button
   bool              CreateTableListView1(void);  // create the "Signals" TableListView
   bool              CreateBmpButton1(void);
   //--- init structurs
   bool              InitStructurs(void);
   //--- exchange rate
   double            ExchangeRate(AccountInfo &account,SignalInfo &signal,const bool details=false);
   //--- fill dependent controls
   bool              FillListsView(void);
   //--- handlers of the dependent controls events
   void              OnChangeEdit1(void);
   void              OnChangeComboBox1(void);
   void              OnChangeComboBox2(void);
   void              OnChangeComboBox3(void);
   void              OnClickTableListView1(void);

private:

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CoSDialog::CoSDialog(void) : m_tab(10),
                             m_error(true)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CoSDialog::~CoSDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CoSDialog)
ON_EVENT(ON_END_EDIT,m_edit1,OnChangeEdit1)
ON_EVENT(ON_CHANGE,m_combo_box1,OnChangeComboBox1)
ON_EVENT(ON_CHANGE,m_combo_box2,OnChangeComboBox2)
ON_EVENT(ON_CHANGE,m_combo_box3,OnChangeComboBox3)
ON_EVENT(ON_CLICK,m_table_list_view1,OnClickTableListView1)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CoSDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
//---
   m_error=true;
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//---
   AccInfo.login=AccountInfoInteger(ACCOUNT_LOGIN);                     // Account login
   AccInfo.balance=AccountInfoDouble(ACCOUNT_BALANCE);                  // Account balance in the deposit currency
   AccInfo.dep_perc=SignalInfoGetInteger(SIGNAL_INFO_DEPOSIT_PERCENT);  // Deposit percent (%)
   AccInfo.leverage=AccountInfoInteger(ACCOUNT_LEVERAGE);               // Account leverage
   AccInfo.currency=AccountInfoString(ACCOUNT_CURRENCY);                // Account currency
//---
   if(!CreateBmpButton1())
      return(false);
   if(!InitStructurs())
      return(false);
   if(!CreateLabel1())
      return(false);
   if(!CreateEdit1())
      return(false);
   if(!CreateComboBox1())
      return(false);
   if(!CreateLabel2())
      return(false);
   if(!CreateComboBox2())
      return(false);
   if(!CreateLabel3())
      return(false);
   if(!CreateComboBox3())
      return(false);
   if(!CreateLabel4())
      return(false);
   if(!CreateButton1())
      return(false);
   if(!CreateButton2())
      return(false);
   if(!CreateButton3())
      return(false);
   if(!CreateButton4())
      return(false);
   if(!CreateButton5())
      return(false);
   if(!CreateButton6())
      return(false);
   if(!CreateButton7())
      return(false);
   if(!CreateButton8())
      return(false);
   if(!CreateTableListView1())
      return(false);
   if(!FillListsView())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Init Structurs                                                   |
//+------------------------------------------------------------------+
bool CoSDialog::InitStructurs(void)
  {
//---
   m_table.Clear();
   m_table.Sort(SORT_BY_NUMBER);
//---
   SigInfo.balance=SignalBaseGetDouble(SIGNAL_BASE_BALANCE);            // Signal balance
   SigInfo.leverage=SignalBaseGetInteger(SIGNAL_BASE_LEVERAGE);         // Signal leverage
   SigInfo.currency=SignalBaseGetString(SIGNAL_BASE_CURRENCY);          // Signal currency
   SigInfo.gain=SignalBaseGetDouble(SIGNAL_BASE_GAIN);                  // Signal gain
   SigInfo.price=SignalBaseGetDouble(SIGNAL_BASE_PRICE);                // Signal subscription price
   SigInfo.id=SignalBaseGetInteger(SIGNAL_BASE_ID);                     // Signal ID
//--- get total amount of signals in the terminal 
   int total=SignalBaseTotal();
//--- process all signals 
   for(int i=0;i<total;i++)
     {
      //--- select the signal by index 
      if(SignalBaseSelect(i))
        {
         string name=SignalBaseGetString(SIGNAL_BASE_NAME);             // имя сигнала 
         SigInfo.balance=SignalBaseGetDouble(SIGNAL_BASE_BALANCE);      // Signal balance
         SigInfo.leverage=SignalBaseGetInteger(SIGNAL_BASE_LEVERAGE);   // Signal leverage
         SigInfo.currency=SignalBaseGetString(SIGNAL_BASE_CURRENCY);    // Signal currency
         SigInfo.gain=SignalBaseGetDouble(SIGNAL_BASE_GAIN);            // Signal gain
         SigInfo.price=SignalBaseGetDouble(SIGNAL_BASE_PRICE);          // Signal subscription price
         SigInfo.id=SignalBaseGetInteger(SIGNAL_BASE_ID);                     // Signal ID
         double rate=ExchangeRate(AccInfo,SigInfo);
         double min_deposit=-1;
         long prev_dep_perc=-1;
         if(AccInfo.dep_perc!=95)
           {
            prev_dep_perc=AccInfo.dep_perc;
            AccInfo.dep_perc=95;
            min_deposit=ExchangeRate(AccInfo,SigInfo);
            min_deposit=AccInfo.balance/min_deposit*100.0;
            AccInfo.dep_perc=prev_dep_perc;
           }
         else
           {
            min_deposit=AccInfo.balance/rate*100.0;
           }
         //Print("Insert : ",name,"; ",rate,"; ",min_deposit); 
         m_table.InsertSort(new CLineTable(name,rate,min_deposit));
         //for(int m=0;m<m_table.Total();m++)
         //  {
         //   CLineTable *line=m_table.At(m);
         //   Print("row #",m,": ",line.Text(),"; ",line.Number(),"; ",line.Number1());
         //  }
        }
      else PrintFormat("Error in call of SignalBaseSelect. Error code=%d",GetLastError());
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Exchange Rate                                                    |
//+------------------------------------------------------------------+
double CoSDialog::ExchangeRate(AccountInfo &account,SignalInfo &signal,const bool details)
  {
//---
   double exchange_ratio=-1.0;
   string currency=NULL;
   string acc_cur=StringSubstr(account.currency,0,3);
   if(acc_cur==NULL)
     {
      //--- extracted substring is empty
      exchange_ratio=0.0;
      Print("StringSubstr Account return NULL");
      return(exchange_ratio);
     }
   string sig_cur=StringSubstr(signal.currency,0,3);
   if(sig_cur==NULL)
     {
      //--- extracted substring is empty
      exchange_ratio=0.0;
      Print("StringSubstr Signal return NULL");
      return(exchange_ratio);
     }
//--- converts all characters to uppercase
   ResetLastError();
   if(!StringToUpper(acc_cur))
     {
      exchange_ratio=0.0;
      Print("StringToUpper Account error ",GetLastError());
      return(exchange_ratio);
     }
   if(!StringToUpper(sig_cur))
     {
      exchange_ratio=0.0;
      Print("StringToUpper Signal error ",GetLastError());
      return(exchange_ratio);
     }
//--- currencies are the same?
   if(sig_cur==acc_cur)
     {
      exchange_ratio=1.0;
     }
   else
     {
      //--- first two characters the same? (RUR <-> RUB)
      string value=StringSubstr(sig_cur,0,2);
      if(value==NULL)
        {
         //--- extracted substring is empty
         exchange_ratio=0.0;
         Print("StringSubstr Signal return NULL");
         return(exchange_ratio);
        }
      //--- find "value" (first two characters) in account.currency
      int find=StringFind(acc_cur,value,0);
      if(find!=-1)
        {
         exchange_ratio=1.0;
        }
      else
        {
         //--- find currency "account currency"+"signal currency" or
         //--- "signal currency"+"account currency" in a MarketWatch
         string find_currency=StringSubstr(acc_cur+sig_cur,0,5);
         string inverse_find_currency=StringSubstr(sig_cur+acc_cur,0,5);
         //Print("find_currency=",find_currency,"; inverse_find_currency=",inverse_find_currency);
         int symbols_total=SymbolsTotal(false);
         for(int i=0;i<symbols_total;i++)
           {
            string symbol_name=SymbolName(i,false);
            if(StringLen(symbol_name)==6)
              {
               if(StringFind(symbol_name,find_currency,0)!=-1)
                 {
                  SymbolSelect(symbol_name,true);
                  Sleep(1000);
                  MqlTick last_tick;
                  //--- 
                  ResetLastError();
                  if(SymbolSelect(symbol_name,true))
                    {
                     if(!SymbolInfoTick(symbol_name,last_tick))
                       {
                        exchange_ratio=0.0;
                        Print("SymbolInfoTick #1(",symbol_name,") failed, error = ",GetLastError());
                        return(exchange_ratio);
                       }
                     else
                       {
                        if(last_tick.bid==0)
                           return(-1);
                        exchange_ratio=last_tick.bid;
                        currency=symbol_name;
                       }
                    }
                 }
               if(StringFind(symbol_name,inverse_find_currency,0)!=-1)
                 {
                  if(!SymbolSelect(symbol_name,true))
                    {
                     Print("SymbolSelect ",symbol_name," false");
                     Sleep(1000);
                    }
                  MqlTick last_tick;
                  ResetLastError();
                  if(SymbolSelect(symbol_name,true))
                    {
                     if(!SymbolInfoTick(symbol_name,last_tick))
                       {
                        exchange_ratio=0.0;
                        Print("SymbolInfoTick #2(",symbol_name,") failed, error = ",GetLastError());
                        return(exchange_ratio);
                       }
                     else
                       {
                        if(last_tick.bid==0)
                          {
                           Sleep(1000);
                           if(!SymbolInfoTick(symbol_name,last_tick))
                             {
                              exchange_ratio=0.0;
                              Print("SymbolInfoTick #3(",symbol_name,") failed, error = ",GetLastError());
                              return(exchange_ratio);
                             }
                           if(last_tick.bid==0)
                              return(-1);
                          }
                        exchange_ratio=1.0/last_tick.bid;
                        currency=symbol_name;
                       }
                    }
                 }
              }
           }
        }
     }
   if(exchange_ratio==-1.0)
     {
      Print("Error find symbols: (Account currency ",AccInfo.currency,", Signal currency ",SigInfo.currency,")");
      return(-1);
     }
//--- coordinates canvas and variable
   int x1=0;
   int y1=0;
   int text_width=0;
   string text="";
   if(details)
     {
      x1=INDENT_LEFT;
      y1=INDENT_TOP;
      text_width=0;
      //--- text line №0
      text=m_languages.GetText(12);
      m_canvas1.Erase(ColorToARGB(C'0xF7,0xF7,0xF7',255));
      m_canvas1.TextOut(x1,y1,text,C'0x3B,0x29,0x28',TA_LEFT|TA_TOP);
     }
   if(details)
     {
      //--- text line №1
      y1+=COMBOBOX_HEIGHT+CONTROLS_GAP_Y;
      if(exchange_ratio==1.0)
        {
         text=m_languages.GetText(13)+AccInfo.currency+" / "+SigInfo.currency+
              " = "+DoubleToString(exchange_ratio,4);
        }
      else
        {
         if(currency!=NULL)
           {
            text=m_languages.GetText(13)+AccInfo.currency+" / "+SigInfo.currency+
                 " = "+DoubleToString(exchange_ratio,4)+m_languages.GetText(14)+currency+")";
           }
         else
           {
            text=m_languages.GetText(13)+AccInfo.currency+" / "+SigInfo.currency+
                 " = "+m_languages.GetText(15);
           }
        }
      m_canvas1.TextOut(x1,y1,text,C'0x3B,0x29,0x28',TA_LEFT|TA_TOP);
     }
//--- balances ratio
   double balances_ratio=(AccInfo.balance*AccInfo.dep_perc/100.0)/SigInfo.balance;
   if(details)
     {
      //--- text line №2
      y1+=COMBOBOX_HEIGHT+CONTROLS_GAP_Y;
      text=m_languages.GetText(16)+DoubleToString(AccInfo.balance,0)+" / "+DoubleToString(SigInfo.balance,0)+
           " = "+DoubleToString(AccInfo.balance/SigInfo.balance,4);
      m_canvas1.TextOut(x1,y1,text,C'0x3B,0x29,0x28',TA_LEFT|TA_TOP);
      //--- text line №3
      y1+=COMBOBOX_HEIGHT+CONTROLS_GAP_Y;
      text=m_languages.GetText(17)+IntegerToString(AccInfo.dep_perc)+"% = "+DoubleToString(AccInfo.dep_perc/100.0,4);
      m_canvas1.TextOut(x1,y1,text,C'0x3B,0x29,0x28',TA_LEFT|TA_TOP);
     }
//---
   if(AccInfo.leverage<SigInfo.leverage)
     {
      balances_ratio*=AccInfo.leverage*1.0/SigInfo.leverage;
      if(details)
        {
         //--- text line №4
         y1+=COMBOBOX_HEIGHT+CONTROLS_GAP_Y;
         text=m_languages.GetText(18)+"1:"+IntegerToString(AccInfo.leverage)+" / "+
              "1:"+IntegerToString(SigInfo.leverage)+" = "+DoubleToString(AccInfo.leverage*1.0/SigInfo.leverage,4);
         m_canvas1.TextOut(x1,y1,text,C'0x3B,0x29,0x28',TA_LEFT|TA_TOP);
        }
     }
   else
     {
      if(details)
        {
         //--- text line №4
         y1+=COMBOBOX_HEIGHT+CONTROLS_GAP_Y;
         text=m_languages.GetText(19);
         m_canvas1.TextOut(x1,y1,text,C'0x3B,0x29,0x28',TA_LEFT|TA_TOP);
        }
     }
//---
   balances_ratio*=exchange_ratio;
   if(details)
     {
      //--- text line №5
      y1+=COMBOBOX_HEIGHT+CONTROLS_GAP_Y;
      text=m_languages.GetText(20)+DoubleToString(balances_ratio,4)+" = "+
           DoubleToString(balances_ratio*100.0,2)+"%";
      m_canvas1.TextOut(x1,y1,text,C'0x3B,0x29,0x28',TA_LEFT|TA_TOP);
     }
//+------------------------------------------------------------------+
//| Если значение меньше 0.01%, то оно округляется до 0.001%, т.е. считается равным 0.001%. Примеры: 0.007% => 0.001%, 0.000099 => 0.001%.
//| Если значение больше 0.01% и меньше 0.1%, то оно округляется до сотых долей. Примеры: 0.063% =>0.06%, 0.045 => 0.05%.
//| Если значение больше 0.1% и меньше 1%, то оно округляется до десятых долей. Примеры: 0.11 => 0.1%, 0.25% => 0.3%.
//| Если значение больше 1% и меньше 10%, то оно округляется в меньшую сторону до целого значения. Примеры: 6.25% => 6%, 7.79% =>7%.
//| Если значение больше 10% и меньше 100%, то оно округляется в меньшую сторону до целого значения с шагом 5%. Пример: 29.7% => 25%.
//| Если значение больше 100%, то оно округляется в меньшую сторону до целого значения с шагом 10%. Пример: 129.6% => 120%.
//+------------------------------------------------------------------+
//| If the value is less than 0.01%, it is rounded to 0.001%, i.e. it is assumed to be 0.001%. Examples: 0.007% => 0.001%, 0.000099 => 0.001%.
//| If the value is greater than 0.01% and is less than 0.1%, it is rounded to hundredths. Examples: 0.063% =>0.06%, 0.045 => 0.05%. 
//| If the value is greater than 0.1% and is less than 1%, it is rounded to tenths. Examples: 0.11 => 0.1%, 0.25% => 0.3%.
//| If the value is greater than 1% and is less than 10%, it is rounded down to the nearest whole number. Examples: 6.25% => 6%, 7.79% =>7%.
//| If the value is greater than 10% and is less than 100%, it is rounded down to the nearest whole number with step of 5%. Example: 29.7% => 25%.
//| If the value is greater than 100%, it is rounded down to the nearest whole number with step of 10%. Example: 129.6% => 120%.
//+------------------------------------------------------------------+
   balances_ratio*=100;
   if(balances_ratio<0.01)
      balances_ratio=0.001;
   else if(balances_ratio<0.1)
      balances_ratio=NormalizeDouble(balances_ratio,2);
   else if(balances_ratio<1)
      balances_ratio=NormalizeDouble(balances_ratio,1);
   else if(balances_ratio<10)
      balances_ratio=MathFloor(balances_ratio);
   else if(balances_ratio<100)
      balances_ratio=5*MathFloor(balances_ratio/5);
   else if(balances_ratio>100)
      balances_ratio=10*MathFloor(balances_ratio/10);
//---
   if(details)
     {
      //--- text line №6
      y1+=COMBOBOX_HEIGHT+CONTROLS_GAP_Y;
      text=m_languages.GetText(21)+DoubleToString(balances_ratio,2)+"%";
      m_canvas1.TextOut(x1,y1,text,C'0x3B,0x29,0x28',TA_LEFT|TA_TOP);
      //--- text line №7
      y1+=COMBOBOX_HEIGHT+CONTROLS_GAP_Y;
      text=m_languages.GetText(22)+DoubleToString(1.0*balances_ratio/100.0,2)+m_languages.GetText(23);
      m_canvas1.TextOut(x1,y1,text,C'0x3B,0x29,0x28',TA_LEFT|TA_TOP);
      //--- text line №8
      y1+=COMBOBOX_HEIGHT+CONTROLS_GAP_Y;
      text=m_languages.GetText(24);
      m_canvas1.TextOut(x1,y1,text,C'0x3B,0x29,0x28',TA_LEFT|TA_TOP);
     }
   m_canvas1.Update();
//---
   return(balances_ratio);
  }
//+------------------------------------------------------------------+
//| Create the "Trading account" Label                               |
//+------------------------------------------------------------------+
bool CoSDialog::CreateLabel1(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+100;
   int y2=y1+COMBOBOX_HEIGHT;
//--- create
   if(!m_label1.Create(m_chart_id,m_name+"Label1",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label1.Text(m_languages.GetText(0)+" #"+IntegerToString(AccInfo.login)))
      return(false);
   if(!Add(m_label1))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Balanc" Edit                                         |
//+------------------------------------------------------------------+
bool CoSDialog::CreateEdit1(void)
  {
//--- coordinates
   uint text_width1;        // buffer width in pixels 
   uint text_height;       // buffer height in pixels 
   TextSetFont("Trebuchet MS",-100,FW_THIN);
   TextGetSize(m_label1.Text(),text_width1,text_height);
   int x1=INDENT_LEFT+(int)text_width1+CONTROLS_GAP_Y;
   int y1=INDENT_TOP;
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_edit1.Create(m_chart_id,m_name+"Edit1",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_edit1.TextAlign(ALIGN_RIGHT))
      return(false);
   if(!m_edit1.ReadOnly(false))
      return(false);
   m_edit1.Text(DoubleToString(AccInfo.balance,0));
   if(!Add(m_edit1))
      return(false);
   m_error=false;
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the combo box "Currency"                                  |
//+------------------------------------------------------------------+
bool CoSDialog::CreateComboBox1(void)
  {
   uint text_width1;       // buffer width in pixels 
   uint text_height;       // buffer height in pixels 
   TextSetFont("Trebuchet MS",-100,FW_THIN);
   TextGetSize(m_label1.Text(),text_width1,text_height);
   int x1=INDENT_LEFT+(int)text_width1+CONTROLS_GAP_Y+EDIT_WIDTH+CONTROLS_GAP_Y;
//--- coordinates
   int y1=INDENT_TOP;
   int x2=x1+COMBOBOX_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_combo_box1.Create(m_chart_id,m_name+"ComboBox1",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_combo_box1.ItemAdd("AUD"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("BGN"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("BRL"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("CAD"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("CHF"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("CNH"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("CNY"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("CZK"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("EUC"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("EUR"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("GBP"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("HUF"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("JPY"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("PLN"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("RUB"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("RUR"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("SGD"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("THB"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("UAH"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("USC"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("USD"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("USD100"))// signal name
      return(false);
   if(!m_combo_box1.ItemAdd("XGD"))// signal name
      return(false);
   if(!Add(m_combo_box1))
      return(false);
//--- attempt to find a currency trading account
   if(!m_combo_box1.SelectByText(AccInfo.currency))
     {
      m_combo_box1.SelectByText("USD");
      AccInfo.currency="USD";
     }
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Leverage" Label                                      |
//+------------------------------------------------------------------+
bool CoSDialog::CreateLabel2(void)
  {
   uint text_width1;        // buffer width in pixels 
   uint text_height;       // buffer height in pixels 
   TextSetFont("Trebuchet MS",-100,FW_THIN);
   TextGetSize(m_label1.Text(),text_width1,text_height);
   int x1=INDENT_LEFT+(int)text_width1+CONTROLS_GAP_Y+EDIT_WIDTH+CONTROLS_GAP_Y+
          2*COMBOBOX_WIDTH+CONTROLS_GAP_Y;
//--- coordinates
//int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+100;
   int y2=y1+COMBOBOX_HEIGHT;
//--- create
   if(!m_label2.Create(m_chart_id,m_name+"Label2",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label2.Text(m_languages.GetText(1)))
      return(false);
   if(!Add(m_label2))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the combo box "Leverage"                                  |
//+------------------------------------------------------------------+
bool CoSDialog::CreateComboBox2(void)
  {
   uint text_width1;       // buffer width in pixels 
   uint text_height;       // buffer height in pixels 
   TextSetFont("Trebuchet MS",-100,FW_THIN);
   TextGetSize(m_label1.Text(),text_width1,text_height);
   uint text_width2;       // buffer width in pixels 
   TextGetSize(m_label2.Text(),text_width2,text_height);
   int x1=INDENT_LEFT+(int)text_width1+CONTROLS_GAP_Y+EDIT_WIDTH+CONTROLS_GAP_Y+
          2*COMBOBOX_WIDTH+CONTROLS_GAP_Y+(int)text_width2+CONTROLS_GAP_Y;
//--- coordinates
   int y1=INDENT_TOP;
   int x2=x1+COMBOBOX_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_combo_box2.Create(m_chart_id,m_name+"ComboBox2",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_combo_box2.ItemAdd("1:1",1))// signal name
      return(false);
   if(!m_combo_box2.ItemAdd("1:5",5))// signal name
      return(false);
   if(!m_combo_box2.ItemAdd("1:10",10))// signal name
      return(false);
   if(!m_combo_box2.ItemAdd("1:15",15))// signal name
      return(false);
   if(!m_combo_box2.ItemAdd("1:25",25))// signal name
      return(false);
   if(!m_combo_box2.ItemAdd("1:50",50))// signal name
      return(false);
   if(!m_combo_box2.ItemAdd("1:75",75))// signal name
      return(false);
   if(!m_combo_box2.ItemAdd("1:100",100))// signal name
      return(false);
   if(!m_combo_box2.ItemAdd("1:200",200))// signal name
      return(false);
   if(!m_combo_box2.ItemAdd("1:300",300))// signal name
      return(false);
   if(!m_combo_box2.ItemAdd("1:500",500))// signal name
      return(false);
   if(!Add(m_combo_box2))
      return(false);
//--- attempt to find a leverage trading account
   if(!m_combo_box2.SelectByValue(AccInfo.leverage))
     {
      m_combo_box2.SelectByValue(100);
      AccInfo.leverage=100;
     }
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Deposit percent (%)" Label                           |
//+------------------------------------------------------------------+
bool CoSDialog::CreateLabel3(void)
  {
   uint text_width1;       // buffer width in pixels 
   uint text_height;       // buffer height in pixels 
   TextSetFont("Trebuchet MS",-100,FW_THIN);
   TextGetSize(m_label1.Text(),text_width1,text_height);
   uint text_width2;       // buffer width in pixels 
   TextGetSize(m_label2.Text(),text_width2,text_height);
   int x1=INDENT_LEFT+(int)text_width1+CONTROLS_GAP_Y+EDIT_WIDTH+CONTROLS_GAP_Y+
          2*COMBOBOX_WIDTH+CONTROLS_GAP_Y+(int)text_width2+CONTROLS_GAP_Y+
          2*COMBOBOX_WIDTH+CONTROLS_GAP_Y;
//--- coordinates
//int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+100;
   int y2=y1+COMBOBOX_HEIGHT;
//--- create
   if(!m_label3.Create(m_chart_id,m_name+"Label3",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label3.Text(m_languages.GetText(2)))
      return(false);
   if(!Add(m_label3))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the combo box "Deposit percent (%)"                       |
//+------------------------------------------------------------------+
bool CoSDialog::CreateComboBox3(void)
  {
   uint text_width1;       // buffer width in pixels 
   uint text_height;       // buffer height in pixels 
   TextSetFont("Trebuchet MS",-100,FW_THIN);
   TextGetSize(m_label1.Text(),text_width1,text_height);
   uint text_width2;       // buffer width in pixels 
   TextGetSize(m_label2.Text(),text_width2,text_height);
   uint text_width3;       // buffer width in pixels 
   TextGetSize(m_label3.Text(),text_width3,text_height);
   int x1=INDENT_LEFT+(int)text_width1+CONTROLS_GAP_Y+EDIT_WIDTH+CONTROLS_GAP_Y+
          2*COMBOBOX_WIDTH+CONTROLS_GAP_Y+(int)text_width2+CONTROLS_GAP_Y+
          2*COMBOBOX_WIDTH+CONTROLS_GAP_Y+(int)text_width3+CONTROLS_GAP_Y;
//--- coordinates
   int y1=INDENT_TOP;
   int x2=x1+COMBOBOX_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_combo_box3.Create(m_chart_id,m_name+"ComboBox3",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_combo_box3.AddItem(IntegerToString(5),5))
      return(false);
   for(int i=1;i<9;i++)
     {
      if(!m_combo_box3.AddItem(IntegerToString(i*10),i*10))
         return(false);
     }
   if(!m_combo_box3.AddItem(IntegerToString(95),95))
      return(false);
   m_combo_box3.ListViewItems(11);
   if(!Add(m_combo_box3))
      return(false);
//--- attempt to find a leverage trading account
   if(!m_combo_box3.SelectByValue(AccInfo.dep_perc))
     {
      m_combo_box3.SelectByValue(95);
      AccInfo.dep_perc=95;
     }
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Signals" Label                                       |
//+------------------------------------------------------------------+
bool CoSDialog::CreateLabel4(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+COMBOBOX_HEIGHT+CONTROLS_GAP_Y;
   int x2=x1+100;
   int y2=y1+COMBOBOX_HEIGHT;
//--- create
   if(!m_label4.Create(m_chart_id,m_name+"Label4",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label4.Text(m_languages.GetText(3)))
      return(false);
   if(!Add(m_label4))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Growth, %" Button                                    |
//+------------------------------------------------------------------+
bool CoSDialog::CreateButton1(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+2*(COMBOBOX_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button1.Create(m_chart_id,m_name+"Button1",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button1.Text(m_languages.GetText(4)))
      return(false);
   if(!Add(m_button1))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Signal" Button                                       |
//+------------------------------------------------------------------+
bool CoSDialog::CreateButton2(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+BUTTON_WIDTH;
   int y1=INDENT_TOP+2*(COMBOBOX_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+3*BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button2.Create(m_chart_id,m_name+"Button2",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button2.Text(m_languages.GetText(5)))
      return(false);
   if(!Add(m_button2))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Funds" Button                                        |
//+------------------------------------------------------------------+
bool CoSDialog::CreateButton3(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+BUTTON_WIDTH+3*BUTTON_WIDTH;
   int y1=INDENT_TOP+2*(COMBOBOX_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+2*BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button3.Create(m_chart_id,m_name+"Button3",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button3.Text(m_languages.GetText(6)))
      return(false);
   if(!Add(m_button3))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Currency" Button                                     |
//+------------------------------------------------------------------+
bool CoSDialog::CreateButton4(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+BUTTON_WIDTH+3*BUTTON_WIDTH+2*BUTTON_WIDTH;
   int y1=INDENT_TOP+2*(COMBOBOX_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button4.Create(m_chart_id,m_name+"Button4",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button4.Text(m_languages.GetText(7)))
      return(false);
   if(!Add(m_button4))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Leverage" Button                                     |
//+------------------------------------------------------------------+
bool CoSDialog::CreateButton5(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+BUTTON_WIDTH+3*BUTTON_WIDTH+2*BUTTON_WIDTH+BUTTON_WIDTH;
   int y1=INDENT_TOP+2*(COMBOBOX_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button5.Create(m_chart_id,m_name+"Button5",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button5.Text(m_languages.GetText(8)))
      return(false);
   if(!Add(m_button5))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Price" Button                                        |
//+------------------------------------------------------------------+
bool CoSDialog::CreateButton6(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+BUTTON_WIDTH+3*BUTTON_WIDTH+2*BUTTON_WIDTH+BUTTON_WIDTH+
          BUTTON_WIDTH;
   int y1=INDENT_TOP+2*(COMBOBOX_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button6.Create(m_chart_id,m_name+"Button6",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button6.Text(m_languages.GetText(9)))
      return(false);
   if(!Add(m_button6))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Percentage of copy" Button                           |
//+------------------------------------------------------------------+
bool CoSDialog::CreateButton7(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+BUTTON_WIDTH+3*BUTTON_WIDTH+2*BUTTON_WIDTH+BUTTON_WIDTH+
          BUTTON_WIDTH+BUTTON_WIDTH;
   int y1=INDENT_TOP+2*(COMBOBOX_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+2*BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button7.Create(m_chart_id,m_name+"Button7",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button7.Text(m_languages.GetText(10)))
      return(false);
   if(!Add(m_button7))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Percentage of copy 1:1" Button                       |
//+------------------------------------------------------------------+
bool CoSDialog::CreateButton8(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+BUTTON_WIDTH+3*BUTTON_WIDTH+2*BUTTON_WIDTH+BUTTON_WIDTH+
          BUTTON_WIDTH+BUTTON_WIDTH+BUTTON_WIDTH+BUTTON_WIDTH;
   int y1=INDENT_TOP+2*(COMBOBOX_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+2*BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button8.Create(m_chart_id,m_name+"Button8",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button8.Text(m_languages.GetText(11)))
      return(false);
   if(!Add(m_button8))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Signals" TableListView                               |
//+------------------------------------------------------------------+
bool CoSDialog::CreateTableListView1(void)
  {
   Delete(m_table_list_view1);
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+3*(COMBOBOX_HEIGHT+CONTROLS_GAP_Y)-CONTROLS_GAP_Y;
   int x2=x1+13*BUTTON_WIDTH;
   int y2=y1+LIST_HEIGHT;
//--- create
   ushort arr_columns_size[8]={BUTTON_WIDTH,3*BUTTON_WIDTH,2*BUTTON_WIDTH,BUTTON_WIDTH,BUTTON_WIDTH,BUTTON_WIDTH,2*BUTTON_WIDTH,2*BUTTON_WIDTH};
   if(!m_table_list_view1.Create(m_chart_id,m_name+"ListView1",m_subwin,x1,y1,x2,y2,8,arr_columns_size))
      return(false);
   if(!m_table_list_view1.TextAlign(0,ALIGN_RIGHT))
      return(false);
   if(!m_table_list_view1.TextAlign(2,ALIGN_RIGHT))
      return(false);
   if(!m_table_list_view1.TextAlign(4,ALIGN_RIGHT))
      return(false);
   if(!m_table_list_view1.TextAlign(5,ALIGN_RIGHT))
      return(false);
   if(!m_table_list_view1.TextAlign(6,ALIGN_RIGHT))
      return(false);
   if(!m_table_list_view1.TextAlign(7,ALIGN_RIGHT))
      return(false);
   if(!Add(m_table_list_view1))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Filling the ListView                                             |
//+------------------------------------------------------------------+
bool CoSDialog::FillListsView(void)
  {
//---
   for(int i=0; i<m_table.Total(); i++)
     {
      CLineTable *line=m_table.At(i);
        {
         //--- get total amount of signals in the terminal 
         int total=SignalBaseTotal();
         //ArrayResize(m_arr_signals,total);
         //--- process all signals 
         for(int j=0;j<total;j++)
           {
            //--- select the signal by index 
            if(SignalBaseSelect(j))
              {
               string name=SignalBaseGetString(SIGNAL_BASE_NAME);             // имя сигнала 
               SigInfo.balance=SignalBaseGetDouble(SIGNAL_BASE_BALANCE);      // Signal balance
               SigInfo.leverage=SignalBaseGetInteger(SIGNAL_BASE_LEVERAGE);   // Signal leverage
               SigInfo.currency=SignalBaseGetString(SIGNAL_BASE_CURRENCY);    // Signal currency
               SigInfo.gain=SignalBaseGetDouble(SIGNAL_BASE_GAIN);            // Signal gain
               SigInfo.price=SignalBaseGetDouble(SIGNAL_BASE_PRICE);          // Signal subscription price
               if(line.Text()==name)
                 {
                  string item[8]={"col0","col1","col2","col3","col4","col5","col6","col7"};
                  item[0]=DoubleToString(SigInfo.gain,2);
                  item[1]=name;
                  item[2]=DoubleToString(SigInfo.balance,0);
                  item[3]=SigInfo.currency;
                  item[4]="1:"+IntegerToString(SigInfo.leverage);
                  item[5]=DoubleToString(SigInfo.price,0);
                  string item_6=(line.Number()==-1.0)?("n/d"):(DoubleToString(line.Number(),2)+"%");
                  item[6]=item_6;
                  item[7]=DoubleToString(line.Number1(),2);
                  long value[]={0,1,2,3,4,5,6,7};
                  if(!m_table_list_view1.ItemAdd(item,value)) ///
                     return(false);
                  break;
                 }
              }
            else PrintFormat("Error in call of SignalBaseSelect. Error code=%d",GetLastError());
           }
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Canvas1"                                             |
//+------------------------------------------------------------------+
bool CoSDialog::CreateBmpButton1(void)
  {
//--- coordinates
   int x1=1;
   int y1=INDENT_TOP+3*(COMBOBOX_HEIGHT+CONTROLS_GAP_Y)-CONTROLS_GAP_Y+LIST_HEIGHT;
   int x2=ClientAreaWidth()-x1-1;
   int y2=ClientAreaHeight()-y1-1;
//--- create canvas
   if(!m_canvas1.Create("Canvas1",x2,y2,COLOR_FORMAT_XRGB_NOALPHA))
     {
      Print("Error creating canvas: ",GetLastError());
      return(false);
     }
   m_canvas1.FontSet("Trebuchet MS",-100,FW_THIN);
   m_canvas1.Erase(ColorToARGB(C'0xF7,0xF7,0xF7',255));
   m_canvas1.Update(true);

//--- create
   if(!m_bmp_button1.Create(m_chart_id,m_name+"BmpButton1",m_subwin,x1,y1,x1+10,y1+10))
      return(false);
//--- sets the name of bmp files of the control CBmpButton
   if(!m_bmp_button1.BmpOnName(m_canvas1.ResourceName()))
      return(false);
   if(!Add(m_bmp_button1))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Refresh list of signals                                          |
//+------------------------------------------------------------------+
void CoSDialog::Refresh(void)
  {
   int sig_total=SignalBaseTotal();
   static int prev_signal_total=0;
   static double prev_account_balance=1000;
   static long prev_deposit_percent=5;
   static long prev_account_leverage=100;
   static string prev_account_currency="USD";
   if(prev_signal_total!=sig_total || prev_account_balance!=AccInfo.balance || 
      prev_deposit_percent!=AccInfo.dep_perc || prev_account_leverage!=AccInfo.leverage || 
      prev_account_currency!=AccInfo.currency)
     {
      m_canvas1.Erase(ColorToARGB(C'0xF7,0xF7,0xF7',255));
      m_canvas1.Update(true);
      //---
      m_table_list_view1.ItemsClear();
      InitStructurs();
      //---
      FillListsView();
      prev_signal_total=sig_total;
      prev_account_balance=AccInfo.balance;
      prev_deposit_percent=AccInfo.dep_perc;
      prev_account_leverage=AccInfo.leverage;
      prev_account_currency=AccInfo.currency;
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CoSDialog::OnChangeEdit1(void)
  {
//--- allowed to use 0 to 9 digits only
   string   text     =m_edit1.Text();
   int      text_len =StringLen(text);
   string   sample   ="0123456789";
   for(int i=0;i<text_len;i++)
     {
      string substr=StringSubstr(text,i,1);
      if(StringFind(sample,substr,0)==-1)
        {
         m_edit1.Text(DoubleToString(AccInfo.balance,0));
         m_error=true;
         Print("middle ",__FUNCTION__,", ",m_error,", AccInfo.balance=",AccInfo.balance);
         return;
        }
     }
   m_error=false;
   AccInfo.balance=StringToDouble(m_edit1.Text());
   Refresh();
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CoSDialog::OnChangeComboBox1(void)
  {
   AccInfo.currency=m_combo_box1.Select();
   Refresh();
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CoSDialog::OnChangeComboBox2(void)
  {
   AccInfo.leverage=m_combo_box2.Value();
   Refresh();
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CoSDialog::OnChangeComboBox3(void)
  {
   AccInfo.dep_perc=m_combo_box3.Value();
   Refresh();
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CoSDialog::OnClickTableListView1(void)
  {
   int row=-1;
   int col=-1;
   m_table_list_view1.Current(row,col);
   string name_signal=m_table_list_view1.GetText(row,1);

//--- get total amount of signals in the terminal 
   int total=SignalBaseTotal();
//ArrayResize(m_arr_signals,total);
//--- process all signals 
   for(int j=0;j<total;j++)
     {
      //--- select the signal by index 
      if(SignalBaseSelect(j))
        {
         string name=SignalBaseGetString(SIGNAL_BASE_NAME);             // имя сигнала 
         SigInfo.balance=SignalBaseGetDouble(SIGNAL_BASE_BALANCE);      // Signal balance
         SigInfo.leverage=SignalBaseGetInteger(SIGNAL_BASE_LEVERAGE);   // Signal leverage
         SigInfo.currency=SignalBaseGetString(SIGNAL_BASE_CURRENCY);    // Signal currency
         SigInfo.gain=SignalBaseGetDouble(SIGNAL_BASE_GAIN);            // Signal gain
         SigInfo.price=SignalBaseGetDouble(SIGNAL_BASE_PRICE);          // Signal subscription price
         if(name_signal==name)
           {
            ExchangeRate(AccInfo,SigInfo,true);
            break;
           }
        }
      else PrintFormat("Error in call of SignalBaseSelect. Error code=%d",GetLastError());
     }
  }
//+------------------------------------------------------------------+
