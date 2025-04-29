//--- Include/ZoneManager.mqh ---------------------------------------
#ifndef __ZONE_MANAGER_MQH__
#define __ZONE_MANAGER_MQH__
#define MAX_ZONES 100
#include <Arrays\ArrayObj.mqh>

enum ENUM_ZONE_TYPE { ZONE_SUPPLY, ZONE_DEMAND };

// Fixed-size pool to limit memory churn
class CZone {
public:
   ENUM_ZONE_TYPE Type;
   double         Top, Base;
   datetime       Created;
   ENUM_TIMEFRAMES TF;
};

class ZoneManager {
private:
   CZone _pool[MAX_ZONES];
   int   _count;
   int   _minWidthPips, _maxWidthPips;
   static bool IsBaseFormation(const MqlRates &r[], int i) {
      if(i+1 >= ArraySize(r)) return false;
      return MathAbs(r[i].high - r[i+1].high) < 5*_Point && MathAbs(r[i].low - r[i+1].low) < 5*_Point;
   }
public:
   ZoneManager(int minPips, int maxPips): _count(0), _minWidthPips(minPips), _maxWidthPips(maxPips) {}

   // Reuse fixed pool, avoid new/delete each tick
   void AddZones(const MqlRates &r[], int total) {
      _count = 0;
      if(total < 3) return;
      for(int i = 0; i < total-2 && _count < MAX_ZONES; i++) {
         if(!IsBaseFormation(r, i)) continue;
         CZone z;
         if(r[i+2].close > r[i+2].open) {
            z.Type = ZONE_DEMAND;
            z.Top  = MathMax(r[i+1].high, r[i].high);
            z.Base = MathMin(r[i+1].low,  r[i].low);
         } else {
            z.Type = ZONE_SUPPLY;
            z.Top  = MathMax(r[i+1].high, r[i].high);
            z.Base = MathMin(r[i+1].low,  r[i].low);
         }
         double widthPips = (z.Top - z.Base) / _Point;
         if(widthPips < _minWidthPips || widthPips > _maxWidthPips) { _count--; continue; }
         z.Created = r[i].time;
         z.TF      = PERIOD_H1;
         _pool[_count++] = z;
      }
   }

   void CheckFlips(const MqlRates &r[]) {
      for(int i = _count - 1; i >= 0; i--) {
         // Demand broken up => becomes Supply
         if(r[0].low < _pool[i].Base && r[0].close > _pool[i].Top && _pool[i].Type == ZONE_DEMAND)
            _pool[i].Type = ZONE_SUPPLY;
         // Supply broken down => becomes Demand
         else if(r[0].high > _pool[i].Top && r[0].close < _pool[i].Base && _pool[i].Type == ZONE_SUPPLY)
            _pool[i].Type = ZONE_DEMAND;
      }
   }

   // Return pointer to array and count
   const CZone* GetZones(int &count) {
      count = _count;
      return _pool;
   }
   
   // Check if a zone still meets validity criteria (freshness, width, etc.)
   bool IsZoneValid(const CZone &z, const MqlRates &r[]) const {
      // Freshness: created within last 3 bars
      if((r[0].time - z.Created) > 3 * PeriodSeconds(PERIOD_H1))
         return false;
      // Width already checked on creation, but you can re-check here if needed
      return true;
   }

   // Find the closest valid zone to given price and type; returns NULL if none found
   CZone* FindClosestZone(double price, ENUM_ZONE_TYPE type, const MqlRates &r[]) {
      CZone *best = NULL;
      double bestDist = DBL_MAX;
      for(int i = 0; i < _count; i++) {
         CZone &z = _pool[i];
         if(z.Type != type) continue;
         if(!IsZoneValid(z, r)) continue;
         double mid = (z.Top + z.Base) / 2.0;
         double dist = MathAbs(price - mid);
         if(dist < bestDist) {
            bestDist = dist;
            best = &z;
         }
      }
      return best; // NULL if no valid zone
   }
};
#endif