//--- SupplyDemandProEA.mq5 -----------------------------------------
#include <Trade\Trade.mqh>
#include "Include\ZoneManager.mqh"
#include "Include\QMDetector.mqh"
#include "Include\CompressionDetector.mqh"
#include "Include\FakeoutDetector.mqh"
#include "Include\EntryManager.mqh"

input double RiskPercent        = 1.0;
input int    MinZoneWidthPips   = 5;
input int    MaxZoneWidthPips   = 25;
input int    QMLookback         = 5;
input int    CompressPeriods    = 20;
input int    FakeoutLookback    = 3;
input double ATRThreshold       = 0.002;

MqlRates             Rates[];
ZoneManager          g_zones(MinZoneWidthPips, MaxZoneWidthPips);
QMDetector           g_qm(QMLookback);
CompressionDetector  g_comp(CompressPeriods, ATRThreshold, 15);
FakeoutDetector      g_fake(FakeoutLookback);
EntryManager         g_entry;

bool NewBarH1() {
   static datetime last=0;
   datetime t=iTime(_Symbol,PERIOD_H1,0);
   if(t!=last){last=t;return true;} return false;
}

int OnInit() {
   ArraySetAsSeries(Rates,true);
   CopyRates(_Symbol,PERIOD_H1,0,500,Rates);
   return(INIT_SUCCEEDED);
}

void OnTick() {
   static bool busy=false;
   if(busy||!NewBarH1()) return;
   busy=true;

   // Update rates
   CopyRates(_Symbol,PERIOD_H1,0,CompressPeriods>QMLookback?CompressPeriods:QMLookback+3,Rates);
   int rc=ArraySize(Rates);
   if(rc < 4) { busy=false; return; }

   // Zones
   g_zones.AddZones(Rates, rc);
   g_zones.CheckFlips(Rates);

   // Detect
   SQuasimodo   qm   = g_qm.Detect(Rates);
   SCompression comp = g_comp.Analyze(Rates);
   ENUM_TRADE_SIGNAL fake = g_fake.Detect(Rates);

   // Entries
   if(qm.Confirmed)
      g_entry.OpenPosition(qm, comp, RiskPercent);
   else if(fake==SIGNAL_FAKEOUT_KING)
      g_entry.OpenFakeoutEntry(comp, RiskPercent);

   busy=false;
}
