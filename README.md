# soil-water-content-forecast

[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)


## Idea

### Data analysis
- Check time series is stationary or non-stationary
- Granger causality test
- Visualize data to reveal potential problems

### Machine learning
- Feature engineering and data transformation
- Regardless of which library is used for machine learning, we can check out the [Common Pitfalls](https://scikit-learn.org/stable/common_pitfalls.html) chapter of the scikit-learn user guide to avoid these when you are doing machine learning
- Diagnose models by residual analysis or other methods
- Plot time series of $y$ and $\hat{y}$ and perform a cross-correlation function (CCF) to check if there is a time offset between two time series

### Software engineering
- Add compatibility to the project's Project.toml (We can use [PackageCompatUI.jl](https://github.com/GunnarFarneback/PackageCompatUI.jl) to help manage compatibility)
- Check if we need to pass the number of threads to julia REPL, IJulia and Pluto
- Organize the main functions of the package to reduce the time for developers to explore

### Documentation
- The content in README.md may be mainly about how to use (such as training models, making predictions, etc.)


## Development
See [DEVELOPMENT.md](./DEVELOPMENT.md).
