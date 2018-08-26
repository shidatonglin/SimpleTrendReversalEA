
class ExpertUtility{
private:
public:
    ExpertUtility();
    ~ExpertUtility();
    CompareDoubles(double, double);
}

bool CompareDoubles(double number1,double number2)
{
    if(NormalizeDouble(number1-number2,8)==0)
        return(true);
    else
        return(false);
}