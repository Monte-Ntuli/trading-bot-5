//--- Include/FakeoutDetector.mqh ----------------------------------
#ifndef __FAKEOUT_DETECTOR_MQH__
#define __FAKEOUT_DETECTOR_MQH__
#include "QMDetector.mqh"

class FakeoutDetector {
private:
   int _lk;
public:
   FakeoutDetector(int lookback): _lk(lookback) {}
   bool Detect(const MqlRates &r[]) {
    Print("[FakeoutDetector] Detect(): entry");

    int bars = ArraySize(r);
    if (bars < 3) {
        Print("[FakeoutDetector] Detect(): not enough bars");
        return false;
    }

    int fakeouts = 0;

    // Example logic: check last 3 bars if wicks are larger than bodies (simplified fakeout detection)
    for (int i = 0; i < 3; i++) {
        double body = MathAbs(r[i].open - r[i].close);
        double wick = (r[i].high - r[i].low) - body;

        if (wick > body * 1.5) {  // Wick much larger than body = possible fakeout
            fakeouts++;
        }
    }

    // 🔍 After counting, log
    PrintFormat("[FakeoutDetector] Fakeouts detected in last 3 bars: %d", fakeouts);

    Print("[FakeoutDetector] Detect(): exit");

    return (fakeouts >= 2);  // Example: 2 or more fakeouts = true
}
};
#endif