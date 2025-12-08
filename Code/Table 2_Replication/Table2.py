import pandas as pd
import numpy as np
import scipy.io
import os
from datetime import datetime, timedelta

DATA_PATH = '.'
START_DATE = '1975-01-01'
END_DATE = '2015-12-01'
BOOTSTRAP_ITER = 1000

G10_MAP = {
    193: 'Australia', 156: 'Canada', 134: 'Germany', 158: 'Japan',
    196: 'New Zealand', 142: 'Norway', 144: 'Sweden', 146: 'Switzerland',
    112: 'United Kingdom', 111: 'United States'
}

def matlab_to_python_date(serial):
    if np.isnan(serial): return pd.NaT
    try:
        return datetime.fromordinal(int(serial)) + timedelta(days=serial % 1) - timedelta(days=366)
    except:
        return pd.NaT

def load_data_with_dates(filename):
    path = os.path.join(DATA_PATH, filename)
    if not os.path.exists(path): raise FileNotFoundError(f"Missing {filename}")
    mat = scipy.io.loadmat(path)
    
    data = None
    for k, v in mat.items():
        if not k.startswith('__') and isinstance(v, np.ndarray) and v.shape[0] > 100:
            data = v
            break
    if data is None: raise ValueError(f"No data in {filename}")

    header_codes = data[0, :]
    
    raw_dates = data[1:, 0]
    
    date_index = [matlab_to_python_date(d) for d in raw_dates]
    
    df_dict = {}
    for code, name in G10_MAP.items():
        matches = np.where(header_codes == code)[0]
        if len(matches) > 0:
            col_idx = matches[0]
            df_dict[name] = data[1:, col_idx]
        else:
            df_dict[name] = np.full(len(date_index), np.nan)
            
    df = pd.DataFrame(df_dict, index=date_index)
    

    df.index = pd.to_datetime(df.index) + pd.offsets.MonthBegin(-1)
    
    return df

print("--- Loading Data with Correct 1900-2016 Timeline ---")
try:
    df_bonds_usd = load_data_with_dates('Bonds_dollar_M.mat')
    df_bonds_loc = load_data_with_dates('Bonds_local_M.mat')
    df_tb        = load_data_with_dates('TB_M.mat')
    df_yields    = load_data_with_dates('Yields_M.mat')
    
    print(f"Data Range: {df_bonds_usd.index[0].date()} to {df_bonds_usd.index[-1].date()}")
    
except Exception as e:
    print(f"Error: {e}")
    exit()


log_ret_bonds_usd = np.log(df_bonds_usd).diff()
log_ret_bonds_loc = np.log(df_bonds_loc).diff()
log_ret_tb        = np.log(df_tb).diff()

rf_us = log_ret_tb['United States']
rf_local = log_ret_tb

rx_bond_usd = log_ret_bonds_usd.subtract(rf_us, axis=0)
rx_bond_loc = log_ret_bonds_loc - rf_local
rx_fx = rx_bond_usd - rx_bond_loc

sig_rate_diff = rf_local.subtract(rf_us, axis=0)

short_rate_ann_pct = log_ret_tb * 1200
yields_lagged = df_yields.shift(1) # Yield_{t-1}

slope = yields_lagged - short_rate_ann_pct
sig_slope_diff = slope.subtract(slope['United States'], axis=0)


sl = slice(START_DATE, END_DATE)

rx_bond_usd = rx_bond_usd.loc[sl]
rx_bond_loc = rx_bond_loc.loc[sl]
rx_fx       = rx_fx.loc[sl]

sig_rate_diff = sig_rate_diff.loc[sl]
sig_slope_diff = sig_slope_diff.loc[sl]

print(f"Sliced Sample: {len(rx_bond_usd)} months (Expected: ~492)")


def get_stats(series, n_iter=1000):
    clean = series.dropna()
    if len(clean) == 0: return np.nan, np.nan, np.nan, np.nan
    
    vals = clean.values

    mu = np.mean(vals) * 1200
    std = np.std(vals, ddof=1)
    if std == 0: return mu, 0, 0, 0
    sr = (np.mean(vals) / std) * np.sqrt(12)

    rng = np.random.default_rng(42)
    indices = rng.integers(0, len(vals), (n_iter, len(vals)))
    samples = vals[indices]
    
    means = np.mean(samples, axis=1) * 1200
    stds = np.std(samples, axis=1, ddof=1)
    srs = (np.mean(samples, axis=1) / stds) * np.sqrt(12)
    
    return mu, np.std(means), sr, np.std(srs)


target_countries = [c for c in G10_MAP.values() if c != 'United States']

print("\n" + "="*100)
print(f"{'TABLE 2: DYNAMIC PORTFOLIOS (1975-2015)':^100}")
print("="*100)

print(f"{'Country':<15} | {'Bond Dollar (rx_S)':^24} | {'Currency (rx_FX)':^24} | {'Bond Local (rx_*)':^24}")

print(f"{'':<15} | {'Mean     SR     SE(SE)':^24} | {'Mean     SR     SE(SE)':^24} | {'Mean     SR     SE(SE)':^24}")
print("-" * 100)

strategies = {'Panel A. Interest Rates': 'Levels', 'Panel B. Slopes': 'Slopes'}

for panel_name, strat_type in strategies.items():
    print(f"--- {panel_name} ---")
    
    pf_usd, pf_fx, pf_loc = [], [], []
    
    for country in target_countries:
        if strat_type == 'Levels':

            sig = np.sign(sig_rate_diff[country])
        else:
            sig = np.where(sig_slope_diff[country] < 0, 1, -1)
            sig = pd.Series(sig, index=sig_slope_diff.index)
            
        s_usd = sig * (rx_bond_usd[country] - rx_bond_usd['United States'])
        s_fx  = sig * rx_fx[country]
        s_loc = sig * (rx_bond_loc[country] - rx_bond_loc['United States'])
        
        pf_usd.append(s_usd)
        pf_fx.append(s_fx)
        pf_loc.append(s_loc)
        
        m_u, se_m_u, sr_u, se_sr_u = get_stats(s_usd, BOOTSTRAP_ITER)
        m_f, se_m_f, sr_f, se_sr_f = get_stats(s_fx, BOOTSTRAP_ITER)
        m_l, se_m_l, sr_l, se_sr_l = get_stats(s_loc, BOOTSTRAP_ITER)

        print(f"{country:<15} | {m_u:6.2f} {sr_u:6.2f}               | {m_f:6.2f} {sr_f:6.2f}               | {m_l:6.2f} {sr_l:6.2f}               ")

        print(f"{'':<15} | ({se_m_u:4.2f}) ({se_sr_u:4.2f})             | ({se_m_f:4.2f}) ({se_sr_f:4.2f})             | ({se_m_l:4.2f}) ({se_sr_l:4.2f})             ")
        print("-" * 100)

    # Equal Weight
    ew_usd = pd.concat(pf_usd, axis=1).mean(axis=1)
    ew_fx  = pd.concat(pf_fx, axis=1).mean(axis=1)
    ew_loc = pd.concat(pf_loc, axis=1).mean(axis=1)
    
    mu_u, sem_u, sru, sesr_u = get_stats(ew_usd, BOOTSTRAP_ITER)
    mu_f, sem_f, srf, sesr_f = get_stats(ew_fx, BOOTSTRAP_ITER)
    mu_l, sem_l, srl, sesr_l = get_stats(ew_loc, BOOTSTRAP_ITER)

    print(f"{'Equally Wgt':<15} | {mu_u:6.2f} {sru:6.2f}               | {mu_f:6.2f} {srf:6.2f}               | {mu_l:6.2f} {srl:6.2f}               ")

    print(f"{'':<15} | ({sem_u:4.2f}) ({sesr_u:4.2f})             | ({sem_f:4.2f}) ({sesr_f:4.2f})             | ({sem_l:4.2f}) ({sesr_l:4.2f})             ")
    print("=" * 100)