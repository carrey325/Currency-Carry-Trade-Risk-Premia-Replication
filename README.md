# Replication of “The Term Structure of Currency Carry Trade Risk Premia” (AER 2019)

**TL;DR:** This repository replicates Lustig, Stathopoulos, and Verdelhan’s 2019 AER paper, *The Term Structure of Currency Carry Trade Risk Premia*, and confirms its core result that short-rate-driven FX carry premia are offset by local bond term premia as bond maturity rises; the paper’s data come mainly from G10 monthly Global Financial Data bond/T-bill/CPI series, Wright (2011) zero-coupon yield curves supplemented with Bloomberg sovereign curve data, and S&P sovereign ratings.

This repository contains a full replication of **Lustig, Stathopoulos, and Verdelhan (2019)**, *American Economic Review*, focusing on the term structure of currency carry trade risk premia.  
The project rebuilds every empirical component of the paper using reconstructed G10 interest rate, yield curve, bond return, and FX datasets (1975–2015), and validates the central empirical claims of the original study.

---

## 📌 Research Question

**Why are currency carry trades highly profitable at short horizons, yet yield weak or insignificant returns when implemented with long-maturity bonds?**

The original paper proposes a **risk segregation mechanism**:

- **FX excess returns** are driven by **short-rate differentials**.  
- **Local bond term premia** are driven by **yield curve slopes**.  
- These two components **offset each other** when combined into long-maturity foreign bond positions.

Our replication investigates and confirms this structure across G10 economies.

---

## 📂 Contents of This Repository

### **1. Replication of Table 1 – Time-Series Predictability Regressions**

We reproduce interest-rate–based and slope-based predictive regressions:

- Short rates **predict currency excess returns (rxᴲˣ)**.  
- Yield slopes **predict local bond excess returns (rxˡᵒᶜ)**.  
- Combined dollar excess returns become **unpredictable**, confirming the offset mechanism.

---

### **2. Replication of Table 2 – Portfolio Sorts & Sharpe Ratios**

Using G10 portfolios sorted on:

- Short-term interest rates  
- Yield curve slopes  

We confirm that:

- FX and local bond risks individually earn **meaningful Sharpe ratios**,  
- But total USD long-bond returns show **low and insignificant** Sharpe ratios.

---

### **3. Replication of Figure 1 – Sorting-Based Long–Short Strategies**

Cumulative returns for four sorting signals:

- Short-rate levels  
- Short-rate deviations  
- Slope levels  
- Slope deviations  

FX returns (red) and bond returns (blue) consistently move in **opposite directions**, reinforcing the risk segregation hypothesis.

---

### **4. Replication of Figure 2 – Carry Trade Performance**

We rebuild a daily carry trade using forward points:

- The strategy earns **steady returns** in calm markets  
- **Drawdowns** occur during global risk spikes  

---

### **5. Extension – Market Volatility & Carry Trade Risk**

Using **VIX** and **VXY**, we show:

- Carry trade returns **collapse** when global volatility surges  
- High-volatility regimes produce **sharp negative jumps**, consistent with the strategy earning **risk premia**, not arbitrage returns

---

## 🎯 Key Conclusions

### **1. Risk Offset Mechanism**
Short-rate–driven FX premia are **offset** by slope-driven bond premia when trading long-maturity bonds.  
This explains why **UIP fails at the short end but appears to hold at the long end**.

### **2. Segregation of Predictors**
- **Interest-rate levels → FX risk premia**  
- **Yield slope → Bond term premia**  

The two factors act in **opposite directions**, neutralizing total USD returns.

### **3. Carry Trade = Risk Premia**
Volatility analysis shows:

- **Steady gains** in low-vol environments  
- **Sharp losses** when VIX spikes  

Carry trade profits reflect **compensation for bearing global macro and volatility risk**, not mispricing.

---
