//--- Include/EntryManager.mqh --------------------------------------
#ifndef __ENTRY_MANAGER_MQH__
#define __ENTRY_MANAGER_MQH__
#include <Trade\Trade.mqh>
#include "QMDetector.mqh"
#include "CompressionDetector.mqh"

class EntryManager {
private:
   CTrade _trade;
   double CalculateLotSize(double price, double sl, double risk) {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmt = balance * risk/100;
      double pips    = (sl>0 ? MathAbs(price - sl) : 1) / _Point;
      double tickVal = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      if(pips <= 0 || tickVal <= 0) return 0.01;
      return NormalizeDouble(riskAmt/(pips*tickVal), 2);
   }
   void ExecuteClusterBombs(ENUM_ORDER_TYPE type, double sl) {
      double anchor = (type==ORDER_TYPE_SELL)
                      ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                      : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      _trade.PositionOpen(_Symbol, type, 0.1, anchor, sl, 0, "CB Anchor");
      for(int i=1; i<=5; i++) {
         double offset = i * 7 * _Point * (type==ORDER_TYPE_SELL ? -1 : 1);
         double pr     = anchor + offset;
         _trade.PositionOpen(_Symbol, type, 0.02, pr, sl, 0, StringFormat("CB%d", i));
      }
   }
public:
   bool OpenPosition(const SQuasimodo &q, const SCompression &c, double risk) {
      if(q.Confirmed)
         return OpenQMEntry(q, c, risk);
      return false;
   }
   bool OpenQMEntry(const SQuasimodo &q, const SCompression &c, double risk) {
      ENUM_ORDER_TYPE type = (q.Type==SIGNAL_QM_SELL? ORDER_TYPE_SELL : ORDER_TYPE_BUY);
      if(c.Confirmed) {
         double sl = (type==ORDER_TYPE_SELL)? c.High+5*_Point : c.Low-5*_Point;
         ExecuteClusterBombs(type, sl);
         return true;
      }
      double price = (type==ORDER_TYPE_SELL)
                     ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
                     : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double sl    = (type==ORDER_TYPE_SELL)? q.Head+10*_Point : q.MPL-10*_Point;
      double tp    = (type==ORDER_TYPE_SELL)? q.MPL-100*_Point: q.Head+100*_Point;
      double lots  = CalculateLotSize(price, sl, risk);
      return _trade.PositionOpen(_Symbol, type, lots, price, sl, tp, "QM Entry");
   }
   bool OpenFakeoutEntry(const SCompression &c, double risk) {
      if(!c.Confirmed) return false;
      double sl = c.High + 5*_Point;
      ExecuteClusterBombs(ORDER_TYPE_SELL, sl);
      return true;
   }
};
#endif