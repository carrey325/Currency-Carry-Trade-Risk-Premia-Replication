import os
import pandas as pd
import matplotlib.pyplot as plt

# Hard-coded path
newpath = r"C:\Users\Carrey Chen\iCloudDrive\Documents\BU MSMFT\25 Fall Course\MF702 Fundamentals of Finance\Final Project\python replication" + os.sep

sample = 3
horizon = 1
date_begin = 1975
date_end = 2015

file_name = f"cum_excess_returns_GFD_sample_{sample}_horizon_{horizon}_date_begin_{date_begin}_date_end_{date_end}_2016.xls"
file_path = os.path.join(newpath, file_name)

# Read Excel
XRetMat_1 = pd.read_excel(file_path, sheet_name=0, header=None)
XRetMat_4 = pd.read_excel(file_path, sheet_name=3, header=None)

n_obs = len(XRetMat_1)

# Construct time index
dates_sample = pd.date_range(start=f"{date_begin}-01-01", periods=n_obs, freq="M")

# Begin plotting
plt.figure(figsize=(10, 7))

# Panel A
plt.subplot(2, 2, 1)
plt.plot(dates_sample, XRetMat_1.iloc[:, 1], 'r--', linewidth=1, label='FX Premium')
plt.plot(dates_sample, XRetMat_1.iloc[:, 2], 'b', linewidth=1, label='Local Currency Bond Premium')
plt.grid(True)
plt.title('Sorting on Interest Rate Levels', fontsize=8)
plt.ylabel('Cumulative log returns')
plt.ylim([-2.5, 2])
plt.xlim(dates_sample.min(), dates_sample.max())
plt.legend(loc='lower left', fontsize=6)

# Panel B
plt.subplot(2, 2, 2)
plt.plot(dates_sample, XRetMat_4.iloc[:, 1], 'r--', linewidth=1)
plt.plot(dates_sample, XRetMat_4.iloc[:, 2], 'b', linewidth=1)
plt.grid(True)
plt.title('Sorting on Interest Rate Deviations', fontsize=8)
plt.ylabel('Cumulative log returns')
plt.ylim([-2.5, 2])
plt.xlim(dates_sample.min(), dates_sample.max())

# Panel C
plt.subplot(2, 2, 3)
plt.plot(dates_sample, XRetMat_1.iloc[:, 3], 'r--', linewidth=1)
plt.plot(dates_sample, XRetMat_1.iloc[:, 4], 'b', linewidth=1)
plt.grid(True)
plt.title('Sorting on Yield Curve Slope Levels', fontsize=8)
plt.ylabel('Cumulative log returns')
plt.ylim([-2.5, 2])
plt.xlim(dates_sample.min(), dates_sample.max())

# Panel D
plt.subplot(2, 2, 4)
plt.plot(dates_sample, XRetMat_4.iloc[:, 3], 'r--', linewidth=1)
plt.plot(dates_sample, XRetMat_4.iloc[:, 4], 'b', linewidth=1)
plt.grid(True)
plt.title('Sorting on Yield Curve Slope Deviations', fontsize=8)
plt.ylabel('Cumulative log returns')
plt.ylim([-2.5, 2])
plt.xlim(dates_sample.min(), dates_sample.max())

plt.tight_layout()

save_name = f"Cum_Excess_Returns_GFD_Sample_{sample}_Start_{date_begin}_End_{date_end}.png"
plt.savefig(os.path.join(newpath, save_name), dpi=300)

plt.show()
