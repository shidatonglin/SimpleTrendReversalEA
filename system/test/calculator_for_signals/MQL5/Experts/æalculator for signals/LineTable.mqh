//+------------------------------------------------------------------+
//|                                                LineTable.mqh.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#property version   "1.012"
#property description "Virtual (no visual design) table class"
#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#define EQUAL 0
#define LESS -1
#define MORE 1
//+------------------------------------------------------------------+
//| Sort type                                                        |
//+------------------------------------------------------------------+
enum ENUM_SORT_TYPE
  {
   SORT_BY_TEXT,
   SORT_BY_NUMBER
  };
//+------------------------------------------------------------------+
//| Class CLineTable                                                 |
//| Usage: sort list                                                 |
//+------------------------------------------------------------------+
class CLineTable : public CObject
  {
private:
   string            m_text;
   double            m_number;
   double            m_number1;
public:
                     CLineTable();
                     CLineTable(string text,double number,double number1)
     {
      m_text=text;
      m_number=number;
      m_number1=number1;
     }
   string Text()const         { return m_text;        }
   double Number()const       { return m_number;      }
   double Number1()const      { return m_number1;     }
   virtual int Compare(const CObject *node,const int mode=0) const
     {
      const CLineTable *line=node;
      switch(mode)
        {
         case SORT_BY_TEXT:
            if(line.Text()==this.Text())
            return EQUAL;
            else if(line.Text()<this.Text())
               return MORE;
            else
               return LESS;
         case SORT_BY_NUMBER:
            if(line.Number()==this.Number())
            return EQUAL;
            else if(line.Number()<this.Number())
               return LESS;
            else
               return MORE;
        }
      return EQUAL;
     }
  };
//+------------------------------------------------------------------+
