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
    Print("[CompressionDetector] Analyze(): entry");

    // Build out your SCompression as before
    SCompression c = {0,0,0,false};
    int n = ArraySize(r);
    if(n < _periods) {
        PrintFormat("[CompressionDetector] not enough bars: %d/%d", n, _periods);
        return c;
    }

    // 1) Pull ATR
    double atrArr[1];
    CopyBuffer(_atrHandle, 0, 0, 1, atrArr);
    double atr = atrArr[0];

    // 2) Compute high/low range
    double high = r[0].high, low = r[0].low;
    for(int i = 1; i < MathMin(n, _periods); i++) {
        high = MathMax(high, r[i].high);
        low  = MathMin(low,  r[i].low);
    }
    double range = high - low;

    // 3) Fill structure
    c.High      = r[0].high;
    c.Low       = r[0].low;
    c.Start     = r[MathMin(n,_periods)-1].time;
    c.Confirmed = (atr <= _threshold) && (range <= 2*atr);

    // 4) Log outcome
    PrintFormat("[CompressionDetector] ATR=%.5f, Range=%.5f, Confirmed=%s",
                atr, range, c.Confirmed ? "Yes" : "No");
    Print("[CompressionDetector] Analyze(): exit");

    return c;
}
};
#endif