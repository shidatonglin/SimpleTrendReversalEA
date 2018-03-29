#property strict
// https://www.mql5.com/en/forum/7383
// https://www.mql5.com/en/forum/96031
//#include <Object.mqh>

class TestCL {
protected:
   int m_id;
   double m_a[];
   
public:
   TestCL(int id, int sz);
};

TestCL::TestCL(int id, int sz) : m_id(id)
{
   ArrayResize(m_a, sz);
};


class TestDerv1 : public TestCL {
private:
   string  m_name;
   double  m_coeff1;
   double  m_coeff2;
   int     m_int0;
   
public:
   TestDerv1(int id, int sz) : TestCL(id,sz) {};
   TestDerv1(int id, int sz, string name, double c1, double c2, int i0);
              
   void setParas2(string name, double c1, double c2, int i0);
};

// construction and setup in one step
TestDerv1::TestDerv1(int id, int sz, string name, double c1, double c2, int i0) :
   TestCL(id, fmax(sz, i0)),
   m_name(name),
   m_coeff1(c1),
   m_coeff2(c2),
   m_int0(i0)
{
}

// construction an setup in 2 steps
void TestDerv1::setParas2(string name, double c1, double c2, int i0)
{
   if (ArraySize(m_a) > i0)
   {
      ArrayResize(m_a, i0);
   }
   m_name = name;
   m_coeff1 = c1;
   m_coeff2 = c2;
   m_int0 = i0;
}

// Script
void OnStart() {
   TestCL*    cl1 = new TestDerv1(1, 12, "Test 1", 3.1416, 2.718281828459, 99);
   TestDerv1* cl2 = new TestDerv1(2, 12);
   
   cl2.setParas2("Test 2", 3.1416, 2.718281828459, 99);
}


class myClass1
  {
private:
   string            mystring1;
public:
                     myClass1(string);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
myClass1::myClass1(string s)
  {
   mystring1=s;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class myClass2 : myClass1
  {
private:
   string            mystring2;
public:
                     myClass2(string);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void myClass2::myClass2(string s):myClass1(s) // Compiler complains at this line making a wrong reference to myClass1.
  {
   mystring2=s;
  }
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class myClass11
  {
private:
   string            mystring1;
public:
                     myClass11(string s):mystring1(s) { }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class myClass21 : myClass11
  {
private:
   string            mystring2;
public:
                     myClass21(string s):myClass11(s),mystring2(s) { }
  };
//+------------------------------------------------------------------+


class Person{
protected:
   string _name;
   int    _age;
public:
   Person(string name, int age):_name(name),_age(age){}
   ~Person(){}
};

class Student : public Person{
protected:
   string _className;
   int    _no;
public:
   Student(string name,int age, string className, int no):
               Person(name,age),
               _className(className),
               _no(no){}
   Student(string name,int age, string className): Person(name,age){
      _className = className;
   }
   ~Student(){}
};



class Candle : public CObject
{
   MqlRates          m_rate;
public:
            Candle(){}
            Candle(const MqlRates &rate) { Init(rate); }
   double   High()  { return m_rate.high; }
   double   Open()  { return m_rate.open; }
   double   Close() { return m_rate.close; }
   double   Low()   { return m_rate.low; }
   datetime Time()  { return m_rate.time; }
   
   void     Init(const MqlRates &rate) { this.m_rate = rate; }
};

class DailyHighCandle : public Candle
{
public:
   DailyHighCandle()
   {
      MqlRates r[];
      ArraySetAsSeries(r,true);
      MqlDateTime stop;
      TimeCurrent(stop);
      stop.hour=0;
      stop.min=0;
      stop.sec=0;
      int total = CopyRates(_Symbol,PERIOD_M1,TimeCurrent(),StructToTime(stop),r);
      int index=-1;
      double highest = DBL_MIN;
      for(int i=0;i<total;i++)
      {
         if(r[i].high > highest)
         {
            highest = r[i].high;
            index = i;
         }
      }
      Init(r[index]); 
   }     
};

void OnStart()
{
   DailyHighCandle high_candle;
   Print(high_candle.Time());
}


#include <Arrays\ArrayObj.mqh>

class Candle : public CObject
{
protected:
   MqlRates          m_rate;
public:
            Candle(){}
            Candle(const Candle &other)   { this.m_rate = other.m_rate;}
            Candle(const MqlRates &rate)  { this.m_rate = rate;   }
            
    
   double   High()  const { return m_rate.high; }
   double   Open()  const { return m_rate.open; }
   double   Close() const { return m_rate.close; }
   double   Low()   const { return m_rate.low; }
   datetime Time()  const { return m_rate.time; }
   void     CopyIn(Candle &other)   { this.m_rate = other.m_rate; }
   void     CopyOut(Candle &other) const  { other.m_rate = this.m_rate; }
   void     Init(const MqlRates &rate){ this.m_rate = rate; }
protected:
   int      CopyDailyRates(MqlRates &rates[])
   {
      MqlDateTime stop;
      TimeCurrent(stop);
      stop.hour=0;
      stop.min=0;
      stop.sec=0;
      return CopyRates(_Symbol,PERIOD_M1,TimeCurrent(),StructToTime(stop),rates);
   }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class DailyMaxCandle : public Candle
{
public:
   DailyMaxCandle()
   {
      MqlRates rates[];
      int total = CopyDailyRates(rates);
      if(total <=0)
         return;
      double highest = DBL_MIN;
      int index=0;
      for(int i=0;i<total;i++)
      {
         if(rates[i].high > highest)
         {
            highest = rates[i].high;
            index = i;
         }
      }
      Init(rates[index]); 
   }     
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class DailyMinCandle : public Candle
{
public:
   DailyMinCandle()
   {  
      MqlRates rates[];
      int total = CopyDailyRates(rates);
      if(total <=0)
         return;
      double lowest = DBL_MAX;
      int index=0;
      for(int i=0;i<total;i++)
      {
         if(rates[i].low < lowest)
         {
            lowest = rates[i].low;
            index = i;
         }
      }
      Init(rates[index]); 
   }     
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CandleVector : public CArrayObj
{
protected:
public:
   Candle* operator[](const int i)const{ return At(i);}
   void Refresh()
   {
      Clear();
      MqlRates r[];
      ArraySetAsSeries(r,true);
      int total = CopyRates(_Symbol,_Period,0,Bars,r);
      int count = 0;
      for(int i=0;i<total;i++)
         Add(new Candle(r[i]));
   }
   Candle* Min()
   {
      Candle *min=NULL;
      double lowest = DBL_MAX;
      for(int i=0;i<Total();i++)
      {
         if(this[i].Low() < lowest)
         {
            min = this[i];
            lowest = min.Low();
         }
      }  
      return min;
   }
   Candle* Max()
   {
      Candle *max=NULL;
      double highest = DBL_MIN;
      for(int i=0;i<Total();i++)
      {
         if(this[i].High() > highest)
         {
            max = this[i];
            highest = max.High();
         }
      }  
      return max;
   }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnStart()
{
   const DailyMaxCandle high_candle;
   const DailyMinCandle low_candle;
   Print(high_candle.Time());
   
   Candle candle2 = high_candle; //using copy constructor;
   Candle candle3;
   candle2.CopyOut(candle3);
   
   CandleVector vect;
   vect.Refresh();
   
   Candle *oldest = vect[vect.Total()-1];
   Candle *newest = vect[0];
   Candle *highest= vect.Max();
   Candle *lowest = vect.Min();
   Print("Oldest bar = ",oldest.Time()," | Recent bar = ",newest.Time());
// or get the same results -->
   Print("Oldest bar = ",vect[vect.Total()-1].Time()," | Recent bar = ",vect[0].Time());
   
}

https://www.mql5.com/en/forum/223832

https://www.mql5.com/en/articles/53