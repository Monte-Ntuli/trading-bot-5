## Overview

SupplyDemandProEA is an Expert Advisor (EA) written in MQL5 for the MetaTrader 5 platform. It integrates supply/demand zone detection, Quasimodo pattern recognition, compression identification, and fakeout signal filtering to automate trade entries. The core logic resides in the `SupplyDemandProEA.mq5` file, which orchestrates initialization and tick-by-tick processing ([github.com](https://github.com/Monte-Ntuli/trading-bot-5/blob/main/SupplyDemandProEA/SupplyDemandProEA.mq5)). Supporting modules are organized under the `Include` directory, including:

- **ZoneManager**: Detects and manages supply/demand zones (Include/ZoneManager.mqh) ([github.com](https://github.com/Monte-Ntuli/trading-bot-5/blob/main/SupplyDemandProEA/Include/ZoneManager.mqh))
- **QMDetector**: Identifies Quasimodo patterns (Include/QMDetector.mqh) ([github.com](https://github.com/Monte-Ntuli/trading-bot-5/blob/main/SupplyDemandProEA/Include/QMDetector.mqh))
- **CompressionDetector**: Analyzes ATR-based compression (Include/CompressionDetector.mqh) ([github.com](https://github.com/Monte-Ntuli/trading-bot-5/blob/main/SupplyDemandProEA/Include/CompressionDetector.mqh))
- **FakeoutDetector**: Filters false breakout signals (Include/FakeoutDetector.mqh) ([github.com](https://github.com/Monte-Ntuli/trading-bot-5/blob/main/SupplyDemandProEA/Include/FakeoutDetector.mqh))
- **EntryManager**: Executes cluster-bomb and standard entries with dynamic lot calculation (Include/EntryManager.mqh) ([github.com](https://github.com/Monte-Ntuli/trading-bot-5/blob/main/SupplyDemandProEA/Include/EntryManager.mqh))
- **NewsFilter**: Placeholder for news-based filtering (Include/NewsFilter.mqh) ([github.com](https://github.com/Monte-Ntuli/trading-bot-5/blob/main/SupplyDemandProEA/Include/NewsFilter.mqh))

## Features

- **Supply/Demand Zone Detection**: Automatically detects price zones of interest.
- **Quasimodo Pattern Detection**: Identifies reversal setups and validates via marubozu candles.
- **Compression Analysis**: Uses ATR threshold to detect low volatility compressions.
- **Fakeout Filtering**: Recognizes and capitalizes on false breakouts.
- **Cluster Bomb Entries**: Executes multiple staggered orders around an anchor price.
- **Dynamic Risk Management**: Calculates lot sizes based on account balance and configurable risk percent.

## Prerequisites

- MetaTrader 5 platform with MQL5 support
- Basic familiarity with installing EAs in MT5

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Monte-Ntuli/trading-bot-5.git
   ```
2. **Copy files**:
   - Place `SupplyDemandProEA.mq5` into your `MQL5/Experts` directory
   - Copy the entire `Include` folder into `MQL5/Experts/Include`
3. **Compile**:
   - Launch MetaEditor, open `SupplyDemandProEA.mq5`, and compile.

## Configuration

1. In MetaTrader 5, go to **Tools → Options → Expert Advisors** and enable **Allow WebRequest for listed URL** if external requests are used.
2. Attach the EA to an H1 chart of your preferred symbol.
3. Adjust input parameters in the EA’s **Inputs** tab:
   - `RiskPercent`: Percentage of balance risked per trade
   - `MinZoneWidthPips` / `MaxZoneWidthPips`: Zone size constraints
   - `QMLookback`, `CompressPeriods`, `FakeoutLookback`, `ATRThreshold`: Pattern detector settings

## Usage

- After compiling and attaching, the EA will:
  1. Initialize historical rates (`OnInit`).
  2. On each new H1 bar (`OnTick`), update indicators and detect patterns.
  3. Execute entries via the `EntryManager` when conditions are met.
- Monitor trade activity in the **Experts** log and **Journal**.

## Error Handling

- The EA verifies rate array sizes before analysis.
- `CalculateLotSize` safeguards against invalid pip values or tick values.
- Unsupported order requests return `false` and log errors.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature-name`)
3. Commit your changes (`git commit -m 'Add feature'`)
4. Push to the branch (`git push origin feature-name`)
5. Open a pull request

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.

## Contact

Maintained by Monte Ntuli. Feel free to open issues or submit pull requests on GitHub.

