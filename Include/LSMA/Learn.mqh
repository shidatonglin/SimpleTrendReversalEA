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