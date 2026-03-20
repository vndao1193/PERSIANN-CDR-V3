# PERSIANN-CDR V3

![PERSIANN-CDR Framework](Figures/Framework.png) <!-- Update or remove logo path as needed -->

## Abstract
Reliable long-term precipitation records are essential for hydrologic forecasting, climate analysis, and water resource management. However, existing satellite-based products often trade off between spatial resolution, latency, and temporal coverage. High-resolution datasets (e.g., IMERG, CMORPH, and PERSIANN) are limited to recent decades, while climate-scale records (e.g., GPCP, PERSIANN-CDR, and CMAP) provide long-term coverage at coarse resolution, limiting their ability to capture extremes and sub-daily variability. 

To address this gap, we introduce PERSIANN-Climate Data Record V3 (PERSIANN-CDR V3), a global deep learning–based framework that reconstructs high-resolution precipitation from 1980 to 2025. Built on a U-Net architecture, the model integrates geostationary infrared satellite data, monthly climatology, and MERRA-2 to produce 3-hourly estimates at 0.04° resolution. It integrates GridSat-B1 (1980–2000; 3-hourly) and CPC-4km (2000–present; 30-minute), with MERRA-2 filling data gaps to ensure a continuous record. Inputs are standardized to a common grid, and a monthly bias correction using GPCP (2.5°) preserves temporal consistency.

Unlike regionally trained approaches, PERSIANN-CDR V3 employs a globally unified model, reducing boundary artifacts and enabling seamless integration of historical and near-real-time precipitation, supporting both research and operational applications.

---

## Key Features

- **Coverage:** Global (60°N–60°S)
- **Spatial Resolution:** 0.04° (~4 km)
- **Temporal Resolution:** 3-hourly, daily, monthly, yearly
- **Data Period:** 1980–Present
- **Format:** bin.gz, tiff, netcdf

---

## Highlights

- Improved calibration and bias correction for enhanced climate analysis
- Compatible with hydrological and climate models
- Consistent between different eras of IR inputs

---

## Access the Data

- [Primary Data Portal](https://chrsdata.eng.uci.edu/)
- [HTTP Download ](https://persiann.eng.uci.edu/CHRSdata/PUnetCDR/)

---

## Quick Start


## Documentation

- [User Guide](docs/USER_GUIDE.md) <!-- Adjust path as needed -->
- [Citing PERSIANN-CDR V3](#citation)
- [FAQ & Support](docs/FAQ.md)

---

## Citation

If you use PERSIANN-CDR V3 in your research, please cite:

> Nguyen, P., Dao, V., Ung, T., Jimenez Arellano, C., Hsu, K., Sorooshian, S., AghaKouchak, A., Huffman, G. J., & Ralph, F. M. PERSIANN-Unet: The first global satellite precipitation algorithm utilizing deep learning with infrared data. Accepted for publication in the Journal of Hydrometeorology.

(The full V3 citation will be available upon publication.)

---

## Contact & Support

For questions, dataset requests, or to report issues, please [open an issue](https://github.com/[your-org]/persiann-cdr-v3/issues) or email vudao1193@gmail.com.

---

## License

This dataset and accompanying code are licensed under the [CC BY 4.0 License](LICENSE).

---

**PERSIANN-CDR V3** is developed by the Center for Hydrometeorology and Remote Sensing (CHRS), University of California, Irvine.
