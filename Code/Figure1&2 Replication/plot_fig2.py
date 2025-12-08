import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# 固定路径
base_path = r"C:\Users\Carrey Chen\iCloudDrive\Documents\BU MSMFT\25 Fall Course\MF702 Fundamentals of Finance\Final Project\python replication" + os.sep

horizon = 1
source = 1
frequency = 1

# 与 source=1 对应，Nport = 3 (三组 + long-short)
Nport = 3
n_cols_keep = Nport + 1   # 4 列：P1, P2, P3, Long–Short

maturity_grid = np.array([1, 4, 8, 12, 16, 20, 40, 60])

slope_dollar_rows = []
slope_dollar_se_rows = []

for maturity in maturity_grid:
    file_name = f"portfolio_composition_BB_sample_{source}_horizon_{horizon}_maturity_{maturity}_2016.xls"
    file_path = os.path.join(base_path, file_name)

    df_slope = pd.read_excel(file_path, sheet_name="Slope Table", header=None)

    # 关键：根据你截图，
    # 第 13 行（索引 12）是 Dollar slope 的 Mean
    # 第 14 行（索引 13）是 Dollar slope 的 s.e.
    # 数值在 C 列开始，也就是索引 2
    row_mean = pd.to_numeric(df_slope.iloc[12, 2:2 + n_cols_keep], errors="coerce").values
    row_se   = pd.to_numeric(df_slope.iloc[13, 2:2 + n_cols_keep], errors="coerce").values

    slope_dollar_rows.append(row_mean)
    slope_dollar_se_rows.append(row_se)

slope_dollar = np.vstack(slope_dollar_rows)
slope_dollar_se = np.vstack(slope_dollar_se_rows)

# long–short 在第 4 列 → 索引 3
col_long_short = Nport

y1 = -slope_dollar[:, col_long_short]
y2 = -slope_dollar[:, col_long_short] + 1.96 * slope_dollar_se[:, col_long_short]
y3 = -slope_dollar[:, col_long_short] - 1.96 * slope_dollar_se[:, col_long_short]
y4 = -slope_dollar[:, col_long_short] + 1.645 * slope_dollar_se[:, col_long_short]
y5 = -slope_dollar[:, col_long_short] - 1.645 * slope_dollar_se[:, col_long_short]
y6 = -slope_dollar[:, col_long_short] + slope_dollar_se[:, col_long_short]
y7 = -slope_dollar[:, col_long_short] - slope_dollar_se[:, col_long_short]

plt.figure(figsize=(8, 6))

# 95% CI
plt.fill_between(maturity_grid, y3, y2, color=(0.7, 0.7, 0.7))
# 90% CI
plt.fill_between(maturity_grid, y5, y4, color=(0.5, 0.5, 0.5))
# 1 s.e.
plt.fill_between(maturity_grid, y7, y6, color=(0.4, 0.4, 0.4))

for low, high in [(y3, y2), (y5, y4), (y7, y6)]:
    plt.plot(maturity_grid, low, color=(0.9, 0.9, 0.9), linewidth=1)
    plt.plot(maturity_grid, high, color=(0.9, 0.9, 0.9), linewidth=1)

plt.plot(maturity_grid, y1, color="blue", linewidth=3)

plt.grid(True, zorder=10)
plt.gca().set_axisbelow(False)

plt.xlabel("Maturity (in quarters)")
plt.ylabel("Dollar Excess Returns")
plt.xlim([maturity_grid.min(), maturity_grid.max()])
plt.ylim([-6.75, 6])

save_name = f"Term_se_BB_AllMaturities_Slope_{frequency}_Horizon_{horizon}_Source_{source}_TermStructureOnly_python.png"
plt.tight_layout()
plt.savefig(os.path.join(base_path, save_name), dpi=300)

plt.show()
