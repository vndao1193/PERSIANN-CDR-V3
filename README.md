# PERSIANN-CDR V3

![PERSIANN-CDR Logo](https://chrsdata.eng.uci.edu/img/logo.png) <!-- Update or remove logo path as needed -->

**PERSIANN-CDR V3** is the latest version of the global Precipitation Estimation from Remotely Sensed Information using Artificial Neural Networks–Climate Data Record. It provides long-term, high-resolution satellite-based precipitation estimates, enabling climate research, hydrological modeling, and applications in weather and disaster monitoring.

---

## Key Features

- **Coverage:** Global (60°N–60°S)
- **Spatial Resolution:** 0.04° (~4 km)
- **Temporal Resolution:** 3-hourly, daily, monthly
- **Data Period:** [Start Year]–Present
- **Format:** NetCDF, GeoTIFF

---

## Highlights

- Improved calibration and bias correction for enhanced climate analysis
- Compatible with hydrological and climate models
- Open-source tools and example scripts available

---

## Access the Data

- [Primary Data Portal](https://chrsdata.eng.uci.edu/)
- [Direct Download (THREDDS)](https://thredds.chrsdata.eng.uci.edu/)

---

## Quick Start

```python
# Example: Download and visualize PERSIANN-CDR V3 using Python (xarray, matplotlib)
import xarray as xr
import matplotlib.pyplot as plt

ds = xr.open_dataset("https://thredds.chrsdata.eng.uci.edu/thredds/dodsC/PERSIANN-CDR-V3/sample.nc")
data = ds['precipitation'].isel(time=0)
data.plot()
plt.title('Sample Precipitation - PERSIANN-CDR V3')
plt.show()
```

---

## Documentation

- [User Guide](docs/USER_GUIDE.md) <!-- Adjust path as needed -->
- [Citing PERSIANN-CDR V3](#citation)
- [FAQ & Support](docs/FAQ.md)

---

## Citation

If you use PERSIANN-CDR V3 in your research, please cite:

> Bolboli Zadeh, M., Nguyen, P., Hsu, K. L., AghaKouchak, A., Thanh Ung, T., & Sorooshian, S. (2026). A Global High-Resolution Precipitation Climate Record: PERSIANN-CCS-CDR Version 2.0. Scientific Data.

(The full V3 citation will be available upon publication.)

---

## Contact & Support

For questions, dataset requests, or to report issues, please [open an issue](https://github.com/[your-org]/persiann-cdr-v3/issues) or email chrs@uci.edu.

---

## License

This dataset and accompanying code are licensed under the [CC BY 4.0 License](LICENSE).

---

**PERSIANN-CDR V3** is developed by the Center for Hydrometeorology and Remote Sensing (CHRS), University of California, Irvine.
