###############################################
# PERSIANN-Unet (PUnet) model for global satellite precipitation estimation using infrared images
# by Phu Nguyen & Vu Dao at Center for Hydrometeorology & Remote Sensing at UC Irvine
# Feb 2025
###############################################
# Input is IR bin.gz file 3000x9000 processed by UCI CHRS

# Import necessary libraries
import cv2
import os
import re
import numpy as np
import gzip
import glob

# Set the system run on CPUs, and filter out info and warning messages
os.environ['CUDA_VISIBLE_DEVICES'] = '-1'
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

import tensorflow as tf
from tensorflow.keras.layers import Conv2D, BatchNormalization, MaxPooling2D, UpSampling2D, concatenate, Input, Dropout
from tensorflow.keras.models import Model
from scipy.ndimage import uniform_filter, distance_transform_edt, convolve, gaussian_filter
from cv2.ximgproc import guidedFilter
import concurrent.futures
from tqdm import tqdm
import imresize
import tempfile

###############################################

# Define paths for parameters and input/output data
PARAMETER_DIR   = "/home/ndphu/PUnet_CPC/Parameters/"
MODEL_WEIGHT_DIR= "/home/ndphu/PUnet_CPC/Model weight/"
IR_DATA_DIR     = "/nfs/chrs-data3/goesdata/chrs-data/merged/delay_2d/globir_04/"
OUTPUT_DIR      = "/zfs_data2/ndphu/PUnet/PUnet_CPC/30mins/"
PARAMETER_FILE  = "Rain1hmax04.npy"

NR = 3000
NC = 9000
INR = 512
INC = 1536
MISSING = np.int16(-9999)   # int16-safe sentinel
PREFIX_OUT = "PUnet"

# Define start and end day (format: yyyymmddhh)
startdate = 2025100100
enddate   = 2025100123

# Number of CPUs to use for parallel processing
NUM_CPUS = 16

# Ensure base output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

###############################################
# Functions

# --------- Model cache (per worker process) ----------
_model_cache = {}

def _build_unet():
    input_data = Input(shape=(512, 1536, 2), name='input_data')

    # Encoder
    conv1 = Conv2D(64, (3, 3), padding='same')(input_data)
    conv1 = BatchNormalization()(conv1)
    conv1 = tf.keras.layers.ReLU()(conv1)
    conv1 = Conv2D(64, (3, 3), activation='relu', padding='same')(conv1)
    pool1 = MaxPooling2D(pool_size=(2, 2))(conv1)

    conv2 = Conv2D(128, (3, 3), padding='same')(pool1)
    conv2 = BatchNormalization()(conv2)
    conv2 = tf.keras.layers.ReLU()(conv2)
    conv2 = Conv2D(128, (3, 3), activation='relu', padding='same')(conv2)
    pool2 = MaxPooling2D(pool_size=(2, 2))(conv2)

    conv3 = Conv2D(256, (3, 3), activation='relu', padding='same')(pool2)
    conv3 = Conv2D(256, (3, 3), activation='relu', padding='same')(conv3)
    conv3 = Dropout(0.3)(conv3)
    pool3 = MaxPooling2D(pool_size=(2, 2))(conv3)

    # Bottleneck
    conv4 = Conv2D(512, (3, 3), padding='same')(pool3)
    conv4 = BatchNormalization()(conv4)
    conv4 = tf.keras.layers.ReLU()(conv4)
    conv4 = Dropout(0.4)(conv4)
    conv4 = Conv2D(512, (3, 3), activation='relu', padding='same')(conv4)

    # Decoder
    up3 = UpSampling2D(size=(2, 2))(conv4)
    up3 = concatenate([conv3, up3], axis=-1)
    conv5 = Conv2D(256, (3, 3), activation='relu', padding='same')(up3)
    conv5 = Conv2D(256, (3, 3), activation='relu', padding='same')(conv5)

    up2 = UpSampling2D(size=(2, 2))(conv5)
    up2 = concatenate([conv2, up2], axis=-1)
    conv6 = Conv2D(128, (3, 3), padding='same')(up2)
    conv6 = BatchNormalization()(conv6)
    conv6 = tf.keras.layers.ReLU()(conv6)
    conv6 = Conv2D(128, (3, 3), activation='relu', padding='same')(conv6)

    up1 = UpSampling2D(size=(2, 2))(conv6)
    up1 = concatenate([conv1, up1], axis=-1)
    conv7 = Conv2D(64, (3, 3), activation='relu', padding='same')(up1)
    conv7 = Conv2D(64, (3, 3), activation='relu', padding='same')(conv7)

    # Output Layer
    output_data = Conv2D(1, (1, 1), activation='relu')(conv7)
    return Model(inputs=input_data, outputs=output_data)

def _get_model(weight_dict):
    # One cached model per weight dict object (per worker process)
    key = id(weight_dict)
    if key not in _model_cache:
        model = _build_unet()
        model.set_weights([weight_dict[f"weight_{i}"] for i in range(len(weight_dict))])
        _model_cache[key] = model
    return _model_cache[key]

def load_model_pred(inp, weight_dict):
    model = _get_model(weight_dict)
    pred = model(inp, training=False).numpy()[0, ..., 0]
    return pred

# Function to clean bad (NaN) pattern in IR images
def removebad(ir0):
    ir0f = np.asarray(ir0, dtype=np.float32)

    # Build the indicator without touching ir0
    x = np.where(np.isnan(ir0f) | (ir0f < 0), -2.0, 0.0).astype(np.float32)
    x1 = uniform_filter(x, size=(25, 250), mode='reflect')

    ir = ir0f.copy()
    ir[x1 < -0.5] = np.nan
    return ir

# Function to fill missing (NaN) in IR images locally
def fill_missing(ir_nan, window_size=10, mode='reflect'):
    nan_mask = np.isnan(ir_nan).astype(np.float32)
    ir_filled_temp = np.where(nan_mask, 0, ir_nan)

    smoothed = uniform_filter(ir_filled_temp, size=window_size, mode=mode)
    normalization = uniform_filter(1 - nan_mask, size=window_size, mode=mode)
    normalization[normalization == 0] = np.nan

    filled_values = smoothed / normalization
    ir_filled = np.where(nan_mask == 1, filled_values, ir_nan)
    return ir_filled

# Fast fill: fill ALL NaNs with nearest-neighbor using distance transform
def fill_missing_all_fast(a):
    a = np.asarray(a, dtype=np.float32)
    mask = np.isnan(a)
    if not np.any(mask):
        return a
    idx = distance_transform_edt(mask, return_indices=True)[1]
    return a[tuple(idx)]

def apply_mapping_function(future_satellite_estimate, satellite_quantiles, observed_quantiles):
    """NaN-safe, with protection for flat sat quantiles."""
    non_zero_mask = future_satellite_estimate > 0.001
    corrected_estimate = np.copy(future_satellite_estimate)

    lat_indices, lon_indices = np.where(non_zero_mask)
    batch_size = 1000  # Process 1000 points at a time

    for i in range(0, len(lat_indices), batch_size):
        batch_lat = lat_indices[i:i+batch_size]
        batch_lon = lon_indices[i:i+batch_size]

        for j in range(len(batch_lat)):
            lat, lon = batch_lat[j], batch_lon[j]
            sat_quantiles = np.asarray(satellite_quantiles[:, lat, lon], dtype=np.float32)
            obs_quantiles = np.asarray(observed_quantiles[:, lat, lon], dtype=np.float32)
            # enforce non-decreasing for interp stability
            sat_quantiles = np.maximum.accumulate(sat_quantiles)

            value = future_satellite_estimate[lat, lon]
            if value > sat_quantiles[-1]:
                denom = (sat_quantiles[-1] - sat_quantiles[-2] + 1e-6)
                slope = max((obs_quantiles[-1] - obs_quantiles[-2]) / denom, 1.0)
                corrected_estimate[lat, lon] = obs_quantiles[-1] + slope * (value - sat_quantiles[-1])
            else:
                corrected_estimate[lat, lon] = np.interp(value, sat_quantiles, obs_quantiles)

    return corrected_estimate

# Function to apply multi-scale guided filtering for noise reduction and quality enhancement
def multi_scale_guided_filter(guide, target, base_radius, base_epsilon, scales):
    filtered = target.copy()
    for scale in scales:
        scaled_radius = int(base_radius * scale)
        scaled_epsilon = float(base_epsilon * (scale ** 2))
        filtered = guidedFilter(guide, filtered, scaled_radius, scaled_epsilon)
    return filtered

# Function to smooth the left/right wrap seam in a 2D array
def kernel_smooth_seam(data, overlap_width=50, kernel_size=25, sigma=5.0, final_blur_sigma=1.0):

    w = overlap_width
    # --- work on a copy to avoid modifying the caller's array
    seamless_data = data.copy()

    # --- build Gaussian kernel inline (normalized to sum=1)
    ax = np.arange(-kernel_size // 2 + 1, kernel_size // 2 + 1)
    xx, yy = np.meshgrid(ax, ax)
    kernel = np.exp(-(xx**2 + yy**2) / (2.0 * sigma**2))
    kernel /= kernel.sum()

    # --- extract left/right context and seam pieces
    left_ctx = seamless_data[:, -w - kernel_size:-w]        # (nrows, kernel_size)
    left_seam = seamless_data[:, -w:]                       # (nrows, w)
    right_seam = seamless_data[:, :w]                       # (nrows, w)
    right_ctx = seamless_data[:, w:w + kernel_size]         # (nrows, kernel_size)

    # Concatenate into a single block: [left_ctx | left_seam | right_seam | right_ctx]
    block = np.concatenate((left_ctx, left_seam, right_seam, right_ctx), axis=1)
    n_block_cols = block.shape[1]
    k = kernel_size

    # --- smooth the block with convolution (reflect mode reduces border artifacts)
    smoothed = convolve(block, kernel, mode='reflect')

    # --- GAUSSIAN ALPHA blending 
    # choose alpha_sigma if not provided
    alpha_sigma = max(w / 5.0, 1.0)

    # column coords in block
    cols = np.arange(n_block_cols)
    join_center = k + w - 0.5
    dist_to_join = np.abs(cols - join_center)

    # gaussian centered at join_center (peak at center)
    gauss = np.exp(-(dist_to_join ** 2) / (2.0 * (alpha_sigma ** 2 + 1e-12)))
    # invert gaussian so alpha = 0 at center (use smoothed) and ->1 at edges (keep original)
    gauss = gauss / gauss.max()            # normalize to 0..1 (peak 1)
    alpha = 1.0 - gauss                    # alpha: 0 at center, 1 at far edges

    # only apply alpha blending inside seam columns; keep 1 outside
    seam_mask = (cols >= k) & (cols < k + 2 * w)
    alpha_full = np.ones_like(alpha)
    if np.any(seam_mask):
        alpha_full[seam_mask] = alpha[seam_mask]

    alpha_2d = alpha_full[np.newaxis, :]   # shape (1, n_block_cols) for broadcasting
    combined = alpha_2d * block + (1.0 - alpha_2d) * smoothed

    # --- optional final blur to further soften transitions
    if final_blur_sigma and final_blur_sigma > 0:
        combined = gaussian_filter(combined, sigma=(final_blur_sigma, final_blur_sigma), mode='reflect')

    # --- put blended seam back into the copy of the original array
    seamless_data[:, -w:] = combined[:, k:k + w]         # left_seam region -> rightmost columns
    seamless_data[:, :w] = combined[:, k + w:k + 2 * w]  # right_seam region -> leftmost columns

    return seamless_data

# Main file processor
def process_file(args):
    """Process a single file with optimizations"""
    file_ir, params = args
    try:
        weight, xtrain2, satellite_quantiles, observed_quantiles, Rain1hmax, year_output_dir = params

        # Load IR bin.gz file
        with gzip.open(file_ir, "rb") as f_in:
            om = np.frombuffer(f_in.read(), dtype=np.dtype(">i2")).reshape([NR, NC])
        ir0 = om.astype(np.float32) / 100.0
        ir = ir0.copy()
        # Processing IR
        ir[ir < 173.0] = np.nan  # Apply temperature threshold
        
        # Apply longitude shift (concatenate)
        ir = np.roll(ir, shift=-4500, axis=1)
        ir = fill_missing(ir)
        
        # Store mask for final NaN locations
        ir1 = removebad(ir)
        mask = np.isnan(ir1)

        # Resize and normalize for U-Net
        ir2 = imresize.imresize(ir1, output_shape=[INR, INC], method="bilinear")
        ir2 = fill_missing_all_fast(ir2)
        ir2 = np.clip(ir2, 173.0, 300.0)
        ir2 = (300.0 - ir2) / (300.0 - 173.0)
        ir2 = np.nan_to_num(ir2, nan=0.0).astype(np.float32)

        # Prepare model input
        ir_input = ir2[np.newaxis, ...].astype(np.float32)
        rain = np.asarray(xtrain2, dtype=np.float32)
        if rain.ndim == 2:
            rain = rain[np.newaxis, ...]
        inp = np.stack([ir_input, rain], axis=-1)

        # Predict
        pred = load_model_pred(inp, weight)

        # Quantile mapping
        pred = apply_mapping_function(pred, satellite_quantiles, observed_quantiles)
        pred[pred < 0] = 0

        # Apply multi-scale guided filtering with optimized parameters
        radius = 15
        epsilon = 0.0001
        scale_factors = [1, 2, 4]
        rainfall_emphasis_factor = 1.175
        rain_threshold = 0.025

        # Resize back to full resolution
        interpolated_precip_data = cv2.resize(pred.astype(np.float32), (NC, NR), interpolation=cv2.INTER_LINEAR)
        norain_indices = np.where(interpolated_precip_data < rain_threshold)

        # Prepare for guided filtering
        nan_indices = np.isnan(interpolated_precip_data)
        interpolated_precip_data[nan_indices] = 1e-3

        # Create guide image for filtering
        guide_image = np.clip(ir1, 173.0, 300.0)
        guide_image = (300.0 - guide_image) / (300.0 - 173.0)
        guide_image = np.nan_to_num(guide_image, nan=0.0).astype(np.float32)
        guide_image = cv2.normalize(guide_image, None, 0, 1, cv2.NORM_MINMAX)
        
        weighted_guide_image = interpolated_precip_data * guide_image
        weighted_guide_image[nan_indices] = 1e-3

        # Apply guided filtering
        filtered_result = multi_scale_guided_filter(
            weighted_guide_image, interpolated_precip_data, radius, epsilon, scale_factors
        )
        
        # Apply final mask
        filtered_result[mask] = np.nan

        # Normalize to preserve total rainfall
        filtered_result = np.maximum(filtered_result, 1e-6)
        filtered_result = np.power(filtered_result, rainfall_emphasis_factor)
        filtered_result[norain_indices] = 0

        # Apply rainfall max threshold
        filtered_result = np.minimum(filtered_result, Rain1hmax)

        # Apply seam smoothing
        filtered_result = kernel_smooth_seam(filtered_result)

        # -------- Save to output file in per-year subfolder --------
        os.makedirs(year_output_dir, exist_ok=True)
        file_path = os.path.join(year_output_dir, PREFIX_OUT + os.path.basename(file_ir)[-17:])

        # Convert to int16 and save
        pred_save = np.round(filtered_result * 100).astype(np.int16)
        pred_save[mask] = MISSING

        # Save efficiently using temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".bin", mode="wb") as temp_file:
            pred_save.tofile(temp_file, sep="", format="%<h")

        with open(temp_file.name, "rb") as temp_bin_file, gzip.open(file_path, "wb", compresslevel=5) as f:
            f.write(temp_bin_file.read())

        os.remove(temp_file.name)
        return file_ir[-17:]
    
    except Exception as e:
        print(f"Error processing {file_ir}: {str(e)}")
        return None

def main(startdate, enddate):
    """Main function with optimized file processing"""

    start_year  = int(str(startdate)[:4])
    end_year    = int(str(enddate)[:4])
    start_month = int(str(startdate)[4:6])
    end_month   = int(str(enddate)[4:6])

    # Generate unique (year, month) pairs to process
    year_months = []
    for year in range(start_year, end_year + 1):
        for month in range(1, 13):
            if (year == start_year and month < start_month) or (year == end_year and month > end_month):
                continue
            year_months.append((year, f"{month:02d}"))

    # Load parameters only once
    print("Loading model parameters...")
    observed_quantiles_all = np.load(os.path.join(PARAMETER_DIR, "Obs_quantiles.npy"), allow_pickle=True).item()
    satellite_quantiles_all= np.load(os.path.join(PARAMETER_DIR, "Satellite_quantiles.npy"), allow_pickle=True).item()
    Rain1hmax_all          = np.load(os.path.join(PARAMETER_DIR, PARAMETER_FILE), allow_pickle=True).item()
    RAIN                   = np.load(os.path.join(PARAMETER_DIR, "RAIN.npy"), allow_pickle=True).item()

    # Regex to pull YYMMDDHH anywhere in the filename
    time_re = re.compile(r'.*?(\d{8})')

    # Process files by month
    for year, month in year_months:
        print(f"Processing {year}-{month}")

        # Per-year output directory
        year_output_dir = os.path.join(OUTPUT_DIR, str(year))
        os.makedirs(year_output_dir, exist_ok=True)

        # Load month-specific parameters
        weight = np.load(os.path.join(MODEL_WEIGHT_DIR, f"model_weight{month}.npy"), allow_pickle=True).item()
        xtrain2 = RAIN.get(month)                       # shape (512,1536) or (1,512,1536)
        observed_quantiles = observed_quantiles_all.get(month)
        satellite_quantiles= satellite_quantiles_all.get(month)
        Rain1hmax = Rain1hmax_all.get(month)

        # Package parameters for workers
        params = (weight, xtrain2, satellite_quantiles, observed_quantiles, Rain1hmax, year_output_dir)

        # Find IR files within date range; be generous in the glob then filter
        glob_pattern = os.path.join(IR_DATA_DIR, str(year), f"bglob{str(year)[2:]}{month}*.bin.gz")
        all_files = sorted(glob.glob(glob_pattern))

        # Filter files based on startdate and enddate (parse YYMMDDHH)
        filenames = []
        for file in all_files:
            m = time_re.search(os.path.basename(file))
            if not m:
                continue
            # Build YYYYMMDDHH
            ts = int('20' + m.group(1))
            if startdate <= ts <= enddate:
                filenames.append((file, params))

        print(f"Found {len(filenames)} files for {year}-{month}")

        if filenames:
            with concurrent.futures.ProcessPoolExecutor(max_workers=NUM_CPUS) as executor:
                total_files = len(filenames)
                progress_bar = tqdm(total=total_files, desc=f"Processing {year}-{month}", position=0, leave=True)

                futures = [executor.submit(process_file, args) for args in filenames]
                for future in concurrent.futures.as_completed(futures):
                    try:
                        result = future.result()
                        if result:
                            progress_bar.update(1)
                    except Exception as e:
                        print(f"Exception: {str(e)}")

                progress_bar.close()

    print(f"Processing complete for files from {startdate} to {enddate}.")

if __name__ == "__main__":
    main(startdate, enddate)
###############################################