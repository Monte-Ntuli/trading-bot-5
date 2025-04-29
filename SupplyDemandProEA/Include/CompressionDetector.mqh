//--- Include/CompressionDetector.mqh -------------------------------
#ifndef __COMPRESSION_DETECTOR_MQH__
#define __COMPRESSION_DETECTOR_MQH__
#include <Indicators\Indicators.mqh>
struct SCompression { double High, Low; datetime Start; bool Confirmed; };

class CompressionDetector {
private:
   int    _periods;
   double _threshold;
   int    _minBars;
   int    _atrHandle;
public:
   CompressionDetector(int pr, double thr, int mb): _periods(pr), _threshold(thr), _minBars(mb) {
      _atrHandle = iATR(_Symbol, PERIOD_H1, 14);
   }
   ~CompressionDetector() {
      if(_atrHandle != INVALID_HANDLE) IndicatorRelease(_atrHandle);
   }
   SCompression Analyze(const MqlRates &r[]) {
      SCompression c = {0,0,0,false};
      int n = ArraySize(r);
      if(n < 1) return c;
      double atrArr[1];
      if(_atrHandle == INVALID_HANDLE || CopyBuffer(_atrHandle, 0, 0, 1, atrArr) < 1) return c;
      double atr = atrArr[0];
      int bars = MathMin(_periods, n);
      double high = r[0].high, low = r[0].low;
      for(int i = 1; i < bars; i++) {
         high = MathMax(high, r[i].high);
         low  = MathMin(low,  r[i].low);
      }
      c.High      = r[0].high;
      c.Low       = r[0].low;
      c.Start     = r[bars-1].time;
      c.Confirmed = (atr <= _threshold) && (high - low <= 2*atr);
      return c;
   }
};
#endif