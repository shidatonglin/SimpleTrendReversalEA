//+------------------------------------------------------------------+
//|                                              MoneyManagement.mqh |
//|                                                     Andrew Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+

#property copyright "Andrew Young"
#property link      "http://www.expertadvisorbook.com"

/*
 Creative Commons Attribution-NonCommercial 3.0 Unported
 http://creativecommons.org/licenses/by-nc/3.0/

 You may use this file in your own personal projects. You
 may modify it if necessary. You may even share it, provided
 the copyright above is present. No commercial use permitted. 
*/


#define MAX_PERCENT 10		// Maximum balance % used in money management

class MoneyManagement{

private:

    double m_percentage;

public:

    MoneyManagement() : m_percentage(0){

    }

    MoneyManagement(double pPercentage) : m_percentage(pPercentage){
        if(m_percentage < 0) m_percentage = 0;
        if(m_percentage > MAX_PERCENT) m_percentage = MAX_PERCENT;
    }

    ~MoneyManagement() {

    }

    // Risk-based money management using stop loss in points
    double getOrderLots(string pSymbol, int pStopPoints)
    {
        double tradeSize;

        if(m_percentage > 0 && pStopPoints > 0)
        {
            if(m_percentage > MAX_PERCENT) pPercent = MAX_PERCENT;

            double margin = AccountInfoDouble(ACCOUNT_BALANCE) * (m_percentage / 100);
            double tickSize = SymbolInfoDouble(pSymbol,SYMBOL_TRADE_TICK_VALUE);

            tradeSize = (margin / pStopPoints) / tickSize;
            tradeSize = VerifyVolume(pSymbol,tradeSize);

            return(tradeSize);
        }
        else
        {
            //tradeSize = pFixedVol;
            //tradeSize = VerifyVolume(pSymbol,tradeSize);

            return(0);
        }
    }


    // Verify and adjust trade volume
    double VerifyVolume(string pSymbol,double pVolume)
    {
        double minVolume = SymbolInfoDouble(pSymbol,SYMBOL_VOLUME_MIN);
        double maxVolume = SymbolInfoDouble(pSymbol,SYMBOL_VOLUME_MAX);
        double stepVolume = SymbolInfoDouble(pSymbol,SYMBOL_VOLUME_STEP);

        double tradeSize;
        if(pVolume < minVolume) tradeSize = minVolume;
        else if(pVolume > maxVolume) tradeSize = maxVolume;
        else tradeSize = MathRound(pVolume / stepVolume) * stepVolume;

        //if(stepVolume >= 0.1) tradeSize = NormalizeDouble(tradeSize,1);
        //else tradeSize = NormalizeDouble(tradeSize,2);
        tradeSize = NormalizeDouble(tradeSize,2);

        return(tradeSize);
    }

    // Calculate distance between order price and stop loss in points
    double StopPriceToPoints(string pSymbol,double pStopPrice, double pOrderPrice)
    {
        double stopDiff = MathAbs(pStopPrice - pOrderPrice);
        double getPoint = SymbolInfoDouble(pSymbol,SYMBOL_POINT);
        double priceToPoint = stopDiff / getPoint;
        return(priceToPoint);
    }
};
