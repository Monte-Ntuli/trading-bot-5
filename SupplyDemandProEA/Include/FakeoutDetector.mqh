//--- Include/FakeoutDetector.mqh ----------------------------------
#ifndef __FAKEOUT_DETECTOR_MQH__
#define __FAKEOUT_DETECTOR_MQH__
#include "QMDetector.mqh"

class FakeoutDetector {
private:
   int _lk;
public:
   FakeoutDetector(int lookback): _lk(lookback) {}
   ENUM_TRADE_SIGNAL Detect(const MqlRates &r[]) {
      int n = ArraySize(r);
      if(n < _lk+2) return SIGNAL_NONE;
      int count = 0;
      for(int i = 1; i <= _lk; i++) {
         if(r[i].high > r[i+1].high && r[i].close < r[i].open)
            count++;
      }
      return (count >= 3 ? SIGNAL_FAKEOUT_KING : SIGNAL_NONE);
   }
};
#endif