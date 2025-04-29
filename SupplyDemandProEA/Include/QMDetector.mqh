//--- Include/QMDetector.mqh ----------------------------------------
#ifndef __QM_DETECTOR_MQH__
#define __QM_DETECTOR_MQH__
enum ENUM_TRADE_SIGNAL { SIGNAL_NONE, SIGNAL_QM_SELL, SIGNAL_QM_BUY, SIGNAL_FAKEOUT_KING };
struct SQuasimodo { double LeftShoulder, Head, RightShoulder, MPL; bool Confirmed; ENUM_TRADE_SIGNAL Type; };

class QMDetector {
private:
   int _lk;
   static bool IsMarubozu(const MqlRates &r[], int b, ENUM_TRADE_SIGNAL t) {
      if(b >= ArraySize(r)) return false;
      double body  = MathAbs(r[b].close - r[b].open);
      double range = r[b].high - r[b].low;
      if(range <= 0) return false;
      bool strong = body/range > 0.85;
      return (t == SIGNAL_QM_SELL ? strong && r[b].close < r[b].open
                                  : strong && r[b].close > r[b].open);
   }
   bool ValidateMPL(SQuasimodo &q, const MqlRates &r[]) {
      for(int i = 0; i < _lk && i < ArraySize(r); i++) {
         if(q.Type == SIGNAL_QM_SELL && r[i].low <= q.MPL && IsMarubozu(r, i, q.Type)) return true;
         if(q.Type == SIGNAL_QM_BUY  && r[i].high >= q.MPL && IsMarubozu(r, i, q.Type)) return true;
      }
      return false;
   }
public:
   QMDetector(int lk=5): _lk(lk) {}
   SQuasimodo Detect(const MqlRates &r[]) {
   
    Print("[QMDetector] Detect(): entry");
    
      SQuasimodo q = {0,0,0,0,false,SIGNAL_NONE};
      int n = ArraySize(r);
      if(n < 4) {
      PrintFormat("[QMDetector] Detect(): insufficient bars (%d), abort", n);
      return q;
      }
      
      if(r[3].high>r[2].high && r[2].high>r[1].high && r[3].low<r[2].low && r[2].low<r[1].low) {
         q.LeftShoulder = r[3].high; q.Head = r[2].high; q.RightShoulder = r[1].high;
         q.MPL = (q.LeftShoulder + q.Head)/2;
         q.Type = SIGNAL_QM_SELL;
         q.Confirmed = ValidateMPL(q, r);
         
         PrintFormat("[QMDetector] Sell QM detected: Head=%.5f, MPL=%.5f, Confirmed=%s",
                     q.Head, q.MPL, q.Confirmed ? "Yes" : "No");
                     
         return q;
      }
      if(r[3].low<r[2].low && r[2].low<r[1].low && r[3].high>r[2].high && r[2].high>r[1].high) {
         q.LeftShoulder = r[3].low; q.Head = r[2].low; q.RightShoulder = r[1].low;
         q.MPL = (q.LeftShoulder + q.Head)/2;
         q.Type = SIGNAL_QM_BUY;
         q.Confirmed = ValidateMPL(q, r);
         
          PrintFormat("[QMDetector] Buy QM detected: Head=%.5f, MPL=%.5f, Confirmed=%s",
                     q.Head, q.MPL, q.Confirmed ? "Yes" : "No");
                     
         return q;
      }
      Print("[QMDetector] Detect(): no QM pattern found");
      return q;
   }
};
#endif