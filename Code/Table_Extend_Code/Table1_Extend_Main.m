function Run_Table1_PanelA_B_Final_True_Match()
% ============================================= %
% Replicates Table 1 Panel A & Panel B
% FIXED: Slope Logic (Log-Yield), Sample Start (Dec 74), Scaling
% ============================================= %

    clc;
    close all;

    % --- 1. Options ---
    date_begin  = datenum('6/30/1998');
    date_end    = datenum('12/31/2015'); 
    sample      = 3; 
    writing     = 1; 
    
    switch writing 
        case 1, writing_results = 1;
        case 2, writing_results = 2;
    end

    horizon     = 1; 
    ScalingFactor = 12/horizon; % 12
    ScalingFactor_Real = 1200;  % 1200

    NW_lag_choice = 5; 
    block_length  = 12; 
    nboot         = 1000; 

    % --- 2. Import Data ---
    newpath = strcat(pwd, filesep);
    disp('Loading data...');
    load(strcat(newpath,'Bonds_local_M.mat'),'GFD_Bonds_local_M');
    load(strcat(newpath,'Bonds_dollar_M.mat'),'GFD_Bonds_dollar_M');
    load(strcat(newpath,'TB_M.mat'),'GFD_TB_M');
    load(strcat(newpath,'Yields_M.mat'),'GFD_Yields_M');
    load(strcat(newpath,'CPI_M.mat'),'CPI_M_GFD');
    
    try
        load(strcat(newpath,'Ratings_Backfilled_M.mat'),'Ratings_Backfilled_M');
        load(strcat(newpath,'Ratings_wOutlook_Backfilled_M.mat'),'Ratings_wOutlook_Backfilled_M'); 
        Ratings_M = Ratings_Backfilled_M;
        if exist('GFD_Ratings_wOutlook_Backfilled_M', 'var')
            Ratings_wOutlook_M = GFD_Ratings_wOutlook_Backfilled_M;
        elseif exist('Ratings_wOutlook_Backfilled_M', 'var')
            Ratings_wOutlook_M = Ratings_wOutlook_Backfilled_M;
        else 
            Ratings_wOutlook_M = [];
        end
    catch
        Ratings_M = []; Ratings_wOutlook_M = [];
    end

    Yields_M_GFD = GFD_Yields_M(:,[1:45,47:54,56:end]);
    TBILL_M_GFD  = GFD_TB_M(:,[1:13,15:52,54:56,58:end]);
    Bonds_M_GFD_local = GFD_Bonds_local_M(:,[1:7,9:end]);       
    Bonds_M_GFD_dollar = GFD_Bonds_dollar_M(:,[1:7,9:end]);

    CPI_M_GFD = [CPI_M_GFD(1,:); NaN(600,size(CPI_M_GFD,2)); CPI_M_GFD(2:end,:)];
    CPI_M_GFD(2:601,1) = GFD_Bonds_local_M(2:601,1);
    
    if ~isempty(Ratings_M)
        Ratings_M(1,105) = 528;  
        Ratings_M = [Ratings_M(1,:); NaN(900,size(Ratings_M,2)); Ratings_M(2:end,:)]; 
        Ratings_M(2:901,1) = GFD_Bonds_local_M(2:901,1);
    end
    if ~isempty(Ratings_wOutlook_M)
        Ratings_wOutlook_M(1,105) = 528;
        Ratings_wOutlook_M = [Ratings_wOutlook_M(1,:); NaN(900,size(Ratings_wOutlook_M,2)); Ratings_wOutlook_M(2:end,:)]; 
        Ratings_wOutlook_M(2:901,1) = GFD_Bonds_local_M(2:901,1);
    end

    % --- 3. Sample Selection ---
        Countries_Sample = { ...
        'Australia'; ...
        'Austria'; ...
        'Belgium'; ...
        'Canada'; ...
        'Denmark'; ...
        'Finland'; ...
        'France'; ...
        'Germany'; ...
        'Ireland'; ...
        'Italy'; ...
        'Japan'; ...
        'Lithuania'; ...
        'Malaysia'; ...
        'Netherlands'; ...
        'New Zealand'; ...
        'Norway'; ...
        'Russia'; ...
        'Singapore'; ...
        'Slovakia'; ...
        'Spain'; ...
        'Sweden'; ...
        'Switzerland'; ...
        'Taiwan'; ...
        'United Kingdom'; ...
        'United States'};  

    [IMF_codes, IMF_names] = xlsread('IMF_codes.xls');
    ListIMFCodes = NaN*zeros(size(Countries_Sample,1),1);
    for i=1:size(Countries_Sample,1)
        for j=1:size(IMF_names,1)
            if strcmpi(Countries_Sample(i,1),IMF_names(j,1))
                ListIMFCodes(i,1)=IMF_codes(j,1);
            end
        end
    end

    TBILL_M_GFD_Subsample = NaN*zeros(size(TBILL_M_GFD,1),1+size(Countries_Sample,1));
    Yields_M_GFD_Subsample = NaN*zeros(size(Yields_M_GFD,1),1+size(Countries_Sample,1));
    Bonds_M_GFD_dollar_Subsample = NaN*zeros(size(Bonds_M_GFD_dollar,1),1+size(Countries_Sample,1));
    Bonds_M_GFD_local_Subsample = NaN*zeros(size(Bonds_M_GFD_local,1),1+size(Countries_Sample,1));
    CPI_M_GFD_Subsample = NaN*zeros(size(CPI_M_GFD,1),1+size(Countries_Sample,1));
    
    TBILL_M_GFD_Subsample(:,1) = TBILL_M_GFD(:,1);
    Yields_M_GFD_Subsample(:,1) = Yields_M_GFD(:,1);
    Bonds_M_GFD_dollar_Subsample(:,1) = Bonds_M_GFD_dollar(:,1);
    Bonds_M_GFD_local_Subsample(:,1) = Bonds_M_GFD_local(:,1);
    CPI_M_GFD_Subsample(:,1) = CPI_M_GFD(:,1);

    for i=1:size(ListIMFCodes,1)
       col_TB=find(TBILL_M_GFD(1,:)==ListIMFCodes(i,1));
       if ~isempty(col_TB), TBILL_M_GFD_Subsample(:,1+i) = TBILL_M_GFD(:,col_TB); end
       col_Ylds=find(Yields_M_GFD(1,:)==ListIMFCodes(i,1));
       if ~isempty(col_Ylds), Yields_M_GFD_Subsample(:,1+i) = Yields_M_GFD(:,col_Ylds); end
       col_Bonds_dollar=find(Bonds_M_GFD_dollar(1,:)==ListIMFCodes(i,1));
       if ~isempty(col_Bonds_dollar), Bonds_M_GFD_dollar_Subsample(:,1+i) = Bonds_M_GFD_dollar(:,col_Bonds_dollar); end
       col_Bonds =find(Bonds_M_GFD_local(1,:)==ListIMFCodes(i,1));
       if ~isempty(col_Bonds), Bonds_M_GFD_local_Subsample(:,1+i) = Bonds_M_GFD_local(:,col_Bonds); end
       col_CPI =find(CPI_M_GFD(1,:)==ListIMFCodes(i,1));
       if ~isempty(col_CPI), CPI_M_GFD_Subsample(:,1+i) = CPI_M_GFD(:,col_CPI(1)); end
    end

    TBILL_M_GFD = TBILL_M_GFD_Subsample;
    Yields_M_GFD = Yields_M_GFD_Subsample;
    Bonds_M_GFD_dollar = Bonds_M_GFD_dollar_Subsample;
    Bonds_M_GFD_local = Bonds_M_GFD_local_Subsample;

    % --- 4. Returns Calculation (Start Dec 1974 for 492 Obs) ---
    idx_start = find(Bonds_M_GFD_local(:,1)>=date_begin,1,'first');
    idx_end   = find(Bonds_M_GFD_local(:,1)<=date_end,1,'last');
    
    line_begin = idx_start - 1; 
    line_end   = idx_end;

    B_local  = Bonds_M_GFD_local(line_begin:line_end,2:end); 
    B_dollar = Bonds_M_GFD_dollar(line_begin:line_end,2:end);
    TB       = TBILL_M_GFD(line_begin:line_end,2:end);
    Yield    = Yields_M_GFD(line_begin:line_end, 2:end); 

    Nc = size(Countries_Sample,1);
    col_base = Nc; 

    TB_month = TB(2:end,:) ./ TB(1:end-1,:) - 1;
    BondsHPR = B_local(2:end,:) ./ B_local(1:end-1,:) - 1;
    BondsHPRDollar = B_dollar(2:end,:) ./ B_dollar(1:end-1,:) - 1;

    % --- FIX: Slope Calculation (Strict Log Logic) ---
    % Yields_M_GFD is Annual Percent (e.g. 5.00).
    % We convert to Annual Log Yield: log(1 + 5.00/100).
    % Then divide by 12 to get Monthly Log Yield.
    
    % Step 1: Align Yield (at t-1)
    Yield_t_minus_1 = Yield(1:end-1, :);
    
    % Step 2: Convert to Monthly Log Yield
    Yield_Monthly_Log = log(1 + Yield_t_minus_1 / 100) / 12;
    
    % Step 3: TB_month is Simple Monthly Return. Convert to Log Return.
    TB_month_Log = log(1 + TB_month);
    
    % Step 4: Slope = Difference
    Slope = Yield_Monthly_Log - TB_month_Log;

    BondsHPERDollar = NaN*zeros(size(BondsHPRDollar));
    BondsHPER = NaN*zeros(size(BondsHPR));

    for i=1:size(BondsHPRDollar,2)
        BondsHPERDollar(:,i) = log((1+BondsHPRDollar(:,i))./(1+TB_month(:,col_base))); 
    end
    for i=1:size(BondsHPR,2)
        BondsHPER(:,i) = log((1+BondsHPR(:,i))./(1+TB_month(:,i))); 
    end

    FXEXR = BondsHPERDollar - BondsHPER; 
    BondsHPRDiff = BondsHPER - repmat(BondsHPER(:,col_base),1,Nc); 

    BondsHPERDollar_h = BondsHPERDollar(horizon:end,:);
    BondsHPER_h       = BondsHPER(horizon:end,:);
    FXEXR_h           = FXEXR(horizon:end,:);
    BondsHPRDiff_h    = BondsHPRDiff(horizon:end,:);
    TB_month_h        = TB_month(horizon:end,:);
    Slope_h           = Slope(horizon:end,:); 

    if NW_lag_choice == 5 
        lags = ceil(1.3*(size(BondsHPER,1))^(1/2))-1;
    end
    weight = 1;

    % ============================================= %
    % 5. Panel A: Interest Rate Differentials
    % ============================================= %
    disp('Running Regressions for Table 1 Panel A...');

    TSPred_BetasIRDiff_con = NaN*zeros(Nc,1); TSPred_BetasIRDiff_con_se = NaN*zeros(Nc,1);
    TSPred_BetasIRDiff_R2adj = NaN*zeros(Nc,1); TSPred_BetasIRDiff_con_pval = NaN*zeros(Nc,1);
    TSPred_BetasIRDiff_Nobs = NaN*zeros(Nc,1); TSPred_BetasIRDiff = NaN*zeros(Nc,1); TSPred_BetasIRDiff_se = NaN*zeros(Nc,1);
    TSPred_BetasFXIRDiff_con = NaN*zeros(Nc,1); TSPred_BetasFXIRDiff_con_se = NaN*zeros(Nc,1);
    TSPred_BetasFXIRDiff_R2adj = NaN*zeros(Nc,1); TSPred_BetasFXIRDiff_con_pval = NaN*zeros(Nc,1);
    TSPred_BetasFXIRDiff_Nobs = NaN*zeros(Nc,1); TSPred_BetasFXIRDiff = NaN*zeros(Nc,1); TSPred_BetasFXIRDiff_se = NaN*zeros(Nc,1);
    TSPred_BetasIRDiffLocal_con = NaN*zeros(Nc,1); TSPred_BetasIRDiffLocal_con_se = NaN*zeros(Nc,1);
    TSPred_BetasIRDiffLocal_R2adj = NaN*zeros(Nc,1); TSPred_BetasIRDiffLocal_con_pval = NaN*zeros(Nc,1);
    TSPred_BetasIRDiffLocal_Nobs = NaN*zeros(Nc,1); TSPred_BetasIRDiffLocal = NaN*zeros(Nc,1); TSPred_BetasIRDiffLocal_se = NaN*zeros(Nc,1);
    lhv_IRDiff_all = []; rhv_IRDiff_all = []; lhv_FXIRDiff_all = []; rhv_FXIRDiff_all = []; lhv_IRDiffLocal_all = []; rhv_IRDiffLocal_all = [];

    for n=1:Nc-1
        % Panel A uses Percent Scaling (1200)
        rhv = [ones(size(BondsHPERDollar_h(:,n),1),1) (TB_month_h(:,n)-TB_month_h(:,end))*ScalingFactor_Real];
        lhv = (BondsHPERDollar_h(:,n) - BondsHPERDollar_h(:,end))*ScalingFactor_Real;
        mask = ~isnan(lhv) & ~any(isnan(rhv), 2); lhv_s = lhv(mask); rhv_s = rhv(mask, :);
        [bv, sebv, ~, R2vadj] = olsgmm(lhv_s, rhv_s, lags, weight);
        TSPred_BetasIRDiff_con(n,1) = bv(1); TSPred_BetasIRDiff_con_se(n,1) = sebv(1);
        TSPred_BetasIRDiff(n,1) = bv(2); TSPred_BetasIRDiff_se(n,1) = sebv(2);
        TSPred_BetasIRDiff_R2adj(n,1) = R2vadj; TSPred_BetasIRDiff_Nobs(n,1) = size(lhv_s,1);
        lhv_IRDiff_all = [lhv_IRDiff_all; lhv_s]; rhv_IRDiff_all = [rhv_IRDiff_all; rhv_s];

        lhv = FXEXR_h(:,n)*ScalingFactor_Real;
        mask = ~isnan(lhv) & ~any(isnan(rhv), 2); lhv_s = lhv(mask); rhv_s = rhv(mask, :);
        [bv, sebv, ~, R2vadj] = olsgmm(lhv_s, rhv_s, lags, weight);
        TSPred_BetasFXIRDiff_con(n,1)=bv(1); TSPred_BetasFXIRDiff_con_se(n,1)=sebv(1);
        TSPred_BetasFXIRDiff(n,1)=bv(2); TSPred_BetasFXIRDiff_se(n,1)=sebv(2);
        TSPred_BetasFXIRDiff_R2adj(n,1)=R2vadj; TSPred_BetasFXIRDiff_Nobs(n,1)=size(lhv_s,1);
        lhv_FXIRDiff_all = [lhv_FXIRDiff_all; lhv_s]; rhv_FXIRDiff_all = [rhv_FXIRDiff_all; rhv_s];

        lhv = BondsHPRDiff_h(:,n)*ScalingFactor_Real;
        mask = ~isnan(lhv) & ~any(isnan(rhv), 2); lhv_s = lhv(mask); rhv_s = rhv(mask, :);
        [bv, sebv, ~, R2vadj] = olsgmm(lhv_s, rhv_s, lags, weight);
        TSPred_BetasIRDiffLocal_con(n,1)=bv(1); TSPred_BetasIRDiffLocal_con_se(n,1)=sebv(1);
        TSPred_BetasIRDiffLocal(n,1)=bv(2); TSPred_BetasIRDiffLocal_se(n,1)=sebv(2);
        TSPred_BetasIRDiffLocal_R2adj(n,1)=R2vadj; TSPred_BetasIRDiffLocal_Nobs(n,1)=size(lhv_s,1);
        lhv_IRDiffLocal_all = [lhv_IRDiffLocal_all; lhv_s]; rhv_IRDiffLocal_all = [rhv_IRDiffLocal_all; rhv_s];
    end
    
    Wp_IRDiff_TermStr = NaN*zeros(Nc+2,1); 
    [bv, sebv, ~, ~] = olsgmm(lhv_IRDiff_all, rhv_IRDiff_all, lags, weight); Wp_IRDiff_con = 2*(1-tcdf(abs(bv(1)/sebv(1)), size(lhv_IRDiff_all,1)-2)); Wp_IRDiff_slope = 2*(1-tcdf(abs(bv(2)/sebv(2)), size(lhv_IRDiff_all,1)-2)); Wp_IRDiff_TermStr(Nc+2,1) = Wp_IRDiff_slope;
    [bv, sebv, ~, ~] = olsgmm(lhv_FXIRDiff_all, rhv_FXIRDiff_all, lags, weight); Wp_FXIRDiff_con = 2*(1-tcdf(abs(bv(1)/sebv(1)), size(lhv_FXIRDiff_all,1)-2)); Wp_FXIRDiff_slope = 2*(1-tcdf(abs(bv(2)/sebv(2)), size(lhv_FXIRDiff_all,1)-2)); 
    [bv, sebv, ~, ~] = olsgmm(lhv_IRDiffLocal_all, rhv_IRDiffLocal_all, lags, weight); Wp_IRDiffLocal_con = 2*(1-tcdf(abs(bv(1)/sebv(1)), size(lhv_IRDiffLocal_all,1)-2)); Wp_IRDiffLocal_slope = 2*(1-tcdf(abs(bv(2)/sebv(2)), size(lhv_IRDiffLocal_all,1)-2));

    % ============================================= %
    % 6. Panel B: Slope Differentials
    % ============================================= %
    disp('Running Regressions for Table 1 Panel B...');

    TSPred_BetasSlopeDiff_con = NaN*zeros(Nc,1); TSPred_BetasSlopeDiff_con_se = NaN*zeros(Nc,1);
    TSPred_BetasSlopeDiff_R2adj = NaN*zeros(Nc,1); TSPred_BetasSlopeDiff_Nobs = NaN*zeros(Nc,1); TSPred_BetasSlopeDiff = NaN*zeros(Nc,1); TSPred_BetasSlopeDiff_se = NaN*zeros(Nc,1);
    TSPred_BetasFXSlopeDiff_con = NaN*zeros(Nc,1); TSPred_BetasFXSlopeDiff_con_se = NaN*zeros(Nc,1);
    TSPred_BetasFXSlopeDiff_R2adj = NaN*zeros(Nc,1); TSPred_BetasFXSlopeDiff_Nobs = NaN*zeros(Nc,1); TSPred_BetasFXSlopeDiff = NaN*zeros(Nc,1); TSPred_BetasFXSlopeDiff_se = NaN*zeros(Nc,1);
    TSPred_BetasSlopeDiffLocal_con = NaN*zeros(Nc,1); TSPred_BetasSlopeDiffLocal_con_se = NaN*zeros(Nc,1);
    TSPred_BetasSlopeDiffLocal_R2adj = NaN*zeros(Nc,1); TSPred_BetasSlopeDiffLocal_Nobs = NaN*zeros(Nc,1); TSPred_BetasSlopeDiffLocal = NaN*zeros(Nc,1); TSPred_BetasSlopeDiffLocal_se = NaN*zeros(Nc,1);
    lhv_SlopeDiff_all = []; rhv_SlopeDiff_all = []; lhv_FXSlopeDiff_all = []; rhv_FXSlopeDiff_all = []; lhv_SlopeDiffLocal_all = []; rhv_SlopeDiffLocal_all = [];

    for n=1:Nc-1
        % Panel B: Uses Decimal Scaling (12).
        % Slope_h is already monthly log diff (decimal).
        % 12 * Slope_h -> Annualized Log Slope Diff.
        rhv = [ones(size(BondsHPERDollar_h(:,n),1),1) (12*Slope_h(:,n)-12*Slope_h(:,end))];
        
        lhv = (BondsHPERDollar_h(:,n) - BondsHPERDollar_h(:,end))*ScalingFactor;
        mask = ~isnan(lhv) & ~any(isnan(rhv), 2); lhv_s = lhv(mask); rhv_s = rhv(mask, :);
        [bv, sebv, ~, R2vadj] = olsgmm(lhv_s, rhv_s, lags, weight);
        TSPred_BetasSlopeDiff_con(n,1)=bv(1); TSPred_BetasSlopeDiff_con_se(n,1)=sebv(1);
        TSPred_BetasSlopeDiff(n,1)=bv(2); TSPred_BetasSlopeDiff_se(n,1)=sebv(2);
        TSPred_BetasSlopeDiff_R2adj(n,1)=R2vadj; TSPred_BetasSlopeDiff_Nobs(n,1)=size(lhv_s,1);
        lhv_SlopeDiff_all = [lhv_SlopeDiff_all; lhv_s]; rhv_SlopeDiff_all = [rhv_SlopeDiff_all; rhv_s];

        lhv = FXEXR_h(:,n)*ScalingFactor;
        mask = ~isnan(lhv) & ~any(isnan(rhv), 2); lhv_s = lhv(mask); rhv_s = rhv(mask, :);
        [bv, sebv, ~, R2vadj] = olsgmm(lhv_s, rhv_s, lags, weight);
        TSPred_BetasFXSlopeDiff_con(n,1)=bv(1); TSPred_BetasFXSlopeDiff_con_se(n,1)=sebv(1);
        TSPred_BetasFXSlopeDiff(n,1)=bv(2); TSPred_BetasFXSlopeDiff_se(n,1)=sebv(2);
        TSPred_BetasFXSlopeDiff_R2adj(n,1)=R2vadj; TSPred_BetasFXSlopeDiff_Nobs(n,1)=size(lhv_s,1);
        lhv_FXSlopeDiff_all = [lhv_FXSlopeDiff_all; lhv_s]; rhv_FXSlopeDiff_all = [rhv_FXSlopeDiff_all; rhv_s];

        lhv = BondsHPRDiff_h(:,n)*ScalingFactor;
        mask = ~isnan(lhv) & ~any(isnan(rhv), 2); lhv_s = lhv(mask); rhv_s = rhv(mask, :);
        [bv, sebv, ~, R2vadj] = olsgmm(lhv_s, rhv_s, lags, weight);
        TSPred_BetasSlopeDiffLocal_con(n,1)=bv(1); TSPred_BetasSlopeDiffLocal_con_se(n,1)=sebv(1);
        TSPred_BetasSlopeDiffLocal(n,1)=bv(2); TSPred_BetasSlopeDiffLocal_se(n,1)=sebv(2);
        TSPred_BetasSlopeDiffLocal_R2adj(n,1)=R2vadj; TSPred_BetasSlopeDiffLocal_Nobs(n,1)=size(lhv_s,1);
        lhv_SlopeDiffLocal_all = [lhv_SlopeDiffLocal_all; lhv_s]; rhv_SlopeDiffLocal_all = [rhv_SlopeDiffLocal_all; rhv_s];
    end

    Wp_SlopeDiff_TermStr = NaN*zeros(Nc+2,1); 
    [bv, sebv, ~, ~] = olsgmm(lhv_SlopeDiff_all, rhv_SlopeDiff_all, lags, weight); Wp_SlopeDiff_con = 2*(1-tcdf(abs(bv(1)/sebv(1)), size(lhv_SlopeDiff_all,1)-2)); Wp_SlopeDiff_slope = 2*(1-tcdf(abs(bv(2)/sebv(2)), size(lhv_SlopeDiff_all,1)-2)); Wp_SlopeDiff_TermStr(Nc+2,1) = Wp_SlopeDiff_slope;
    [bv, sebv, ~, ~] = olsgmm(lhv_FXSlopeDiff_all, rhv_FXSlopeDiff_all, lags, weight); Wp_FXSlopeDiff_con = 2*(1-tcdf(abs(bv(1)/sebv(1)), size(lhv_FXSlopeDiff_all,1)-2)); Wp_FXSlopeDiff_slope = 2*(1-tcdf(abs(bv(2)/sebv(2)), size(lhv_FXSlopeDiff_all,1)-2)); 
    [bv, sebv, ~, ~] = olsgmm(lhv_SlopeDiffLocal_all, rhv_SlopeDiffLocal_all, lags, weight); Wp_SlopeDiffLocal_con = 2*(1-tcdf(abs(bv(1)/sebv(1)), size(lhv_SlopeDiffLocal_all,1)-2)); Wp_SlopeDiffLocal_slope = 2*(1-tcdf(abs(bv(2)/sebv(2)), size(lhv_SlopeDiffLocal_all,1)-2));

    % ============================================= %
    % 7. Compile & Print
    % ============================================= %
    rows = Countries_Sample';
    Wp_Column_A = NaN*zeros(Nc-1, 1); Wp_Column_B = NaN*zeros(Nc-1, 1); 

    Table_A = [TSPred_BetasIRDiff_con(1:Nc-1,1) TSPred_BetasIRDiff_con_se(1:Nc-1,1) TSPred_BetasIRDiff(1:Nc-1,1) TSPred_BetasIRDiff_se(1:Nc-1,1) 100*TSPred_BetasIRDiff_R2adj(1:Nc-1,1) TSPred_BetasFXIRDiff_con(1:Nc-1,1) TSPred_BetasFXIRDiff_con_se(1:Nc-1,1) TSPred_BetasFXIRDiff(1:Nc-1,1) TSPred_BetasFXIRDiff_se(1:Nc-1,1) 100*TSPred_BetasFXIRDiff_R2adj(1:Nc-1,1) TSPred_BetasIRDiffLocal_con(1:Nc-1,1) TSPred_BetasIRDiffLocal_con_se(1:Nc-1,1) TSPred_BetasIRDiffLocal(1:Nc-1,1) TSPred_BetasIRDiffLocal_se(1:Nc-1,1) 100*TSPred_BetasIRDiffLocal_R2adj(1:Nc-1,1) Wp_Column_A TSPred_BetasIRDiff_Nobs(1:Nc-1,1)];
    Panel_Row_A = [Wp_IRDiff_con NaN Wp_IRDiff_slope NaN NaN Wp_FXIRDiff_con NaN Wp_FXIRDiff_slope NaN NaN Wp_IRDiffLocal_con NaN Wp_IRDiffLocal_slope NaN NaN Wp_IRDiff_TermStr(Nc+2,1) NaN];
    Table_A = [Table_A; Panel_Row_A];

    Table_B = [TSPred_BetasSlopeDiff_con(1:Nc-1,1) TSPred_BetasSlopeDiff_con_se(1:Nc-1,1) TSPred_BetasSlopeDiff(1:Nc-1,1) TSPred_BetasSlopeDiff_se(1:Nc-1,1) 100*TSPred_BetasSlopeDiff_R2adj(1:Nc-1,1) TSPred_BetasFXSlopeDiff_con(1:Nc-1,1) TSPred_BetasFXSlopeDiff_con_se(1:Nc-1,1) TSPred_BetasFXSlopeDiff(1:Nc-1,1) TSPred_BetasFXSlopeDiff_se(1:Nc-1,1) 100*TSPred_BetasFXSlopeDiff_R2adj(1:Nc-1,1) TSPred_BetasSlopeDiffLocal_con(1:Nc-1,1) TSPred_BetasSlopeDiffLocal_con_se(1:Nc-1,1) TSPred_BetasSlopeDiffLocal(1:Nc-1,1) TSPred_BetasSlopeDiffLocal_se(1:Nc-1,1) 100*TSPred_BetasSlopeDiffLocal_R2adj(1:Nc-1,1) Wp_Column_B TSPred_BetasSlopeDiff_Nobs(1:Nc-1,1)];
    Panel_Row_B = [Wp_SlopeDiff_con NaN Wp_SlopeDiff_slope NaN NaN Wp_FXSlopeDiff_con NaN Wp_FXSlopeDiff_slope NaN NaN Wp_SlopeDiffLocal_con NaN Wp_SlopeDiffLocal_slope NaN NaN Wp_SlopeDiff_TermStr(Nc+2,1) NaN];
    Table_B = [Table_B; Panel_Row_B];

    disp(' ');
    disp('=======================================================================================================================================');
    disp('                                        Table 1 Panel A: Interest Rate Differentials                                                   ');
    disp('=======================================================================================================================================');
    fprintf('%-15s | %-6s %-6s %-6s %-6s %-6s | %-6s %-6s %-6s %-6s %-6s | %-6s %-6s %-6s %-6s %-6s \n', 'Country', 'Const', 'SE', 'Beta', 'SE', 'R2(%)', 'Const', 'SE', 'Beta', 'SE', 'R2(%)', 'Const', 'SE', 'Beta', 'SE', 'R2(%)');
    disp('---------------------------------------------------------------------------------------------------------------------------------------');
    for i = 1:Nc-1, fprintf('%-15s | %6.2f %6.2f %6.2f %6.2f %6.2f | %6.2f %6.2f %6.2f %6.2f %6.2f | %6.2f %6.2f %6.2f %6.2f %6.2f \n', rows{i}, Table_A(i, 1:5), Table_A(i, 6:10), Table_A(i, 11:15)); end
    fprintf('%-15s | %6.2f %6s %6.2f %6s %6s | %6.2f %6s %6.2f %6s %6s | %6.2f %6s %6.2f %6s %6s \n', 'Panel (P-val)', Table_A(Nc, 1), '', Table_A(Nc, 3), '', Table_A(Nc, 6), '', Table_A(Nc, 8), '', Table_A(Nc, 11), '', Table_A(Nc, 13), '');
    
    disp(' ');
    disp('=======================================================================================================================================');
    disp('                                        Table 1 Panel B: Slope Differentials                                                           ');
    disp('=======================================================================================================================================');
    fprintf('%-15s | %-6s %-6s %-6s %-6s %-6s | %-6s %-6s %-6s %-6s %-6s | %-6s %-6s %-6s %-6s %-6s | %-6s %-10s \n', 'Country', 'Const', 'SE', 'Beta', 'SE', 'R2(%)', 'Const', 'SE', 'Beta', 'SE', 'R2(%)', 'Const', 'SE', 'Beta', 'SE', 'R2(%)', 'Obs.');
    disp('---------------------------------------------------------------------------------------------------------------------------------------');
    for i = 1:Nc-1, fprintf('%-15s | %6.2f %6.2f %6.2f %6.2f %6.2f | %6.2f %6.2f %6.2f %6.2f %6.2f | %6.2f %6.2f %6.2f %6.2f %6.2f | %6.0f \n', rows{i}, Table_B(i, 1:5), Table_B(i, 6:10), Table_B(i, 11:15), Table_B(i, 17)); end
    fprintf('%-15s | %6.2f %6s %6.2f %6s %6s | %6.2f %6s %6.2f %6s %6s | %6.2f %6s %6.2f %6s %6s \n', 'Panel (P-val)', Table_B(Nc, 1), '', Table_B(Nc, 3), '', Table_B(Nc, 6), '', Table_B(Nc, 8), '', Table_B(Nc, 11), '', Table_B(Nc, 13), '', '');
    disp('=======================================================================================================================================');
    
    if writing_results == 1
        xlswrite('Results_TS_Simple.xls',Table_A,'Sheet1','A3');
        xlswrite('Results_TS_Simple.xls',Table_B,'Sheet1','A20');
    end
    disp('Done.');
end

function [b, seb, R2, R2adj] = olsgmm(y, x, lags, weight)
    [n, k] = size(x); b = (x' * x) \ (x' * y); u = y - x * b;
    y_dm = y - mean(y); sst = y_dm' * y_dm; ssr = u' * u; R2 = 1 - ssr / sst; R2adj = 1 - (1 - R2) * (n - 1) / (n - k);
    S = (x .* u)' * (x .* u);
    for l = 1:lags, w = 1 - l / (lags + 1); G = (x(l+1:end, :) .* u(l+1:end))' * (x(1:end-l, :) .* u(1:end-l)); S = S + w * (G + G'); end
    V = inv(x' * x) * S * inv(x' * x); seb = sqrt(diag(V));
end

function bootstrap_stats = regression_bootstrap_short(X, block_length, nboot)
    X = X(~any(isnan(X),2),:); N = size(X,1); Z = size(X,2); num_blocks = ceil(N/block_length); missing_obs = num_blocks*block_length - N;
    data_add = floor(rand(missing_obs,nboot)*N)+1; Indices = reshape(1:num_blocks*block_length,block_length,num_blocks);
    slope = zeros(Z-1, nboot);
    R_sq = zeros(1, nboot);
    for i = 1:nboot, randblock = unidrnd(num_blocks,1,num_blocks); Ind_sim = Indices(:,randblock); Ind_sim = Ind_sim(:); X_sim = [X; X(data_add(:,i),:)]; X_sim = X_sim(Ind_sim,:);
    [b,~,~,~,stats] = regress(X_sim(:,1), X_sim(:,2:end)); slope(:,i) = b; end
    bootstrap_stats = zeros(Z-1, 4);
    for k = 1:Z-1, bootstrap_stats(k,:) = [mean(slope(k,:)), std(slope(k,:)), prctile(slope(k,:), 5), prctile(slope(k,:), 95)]; end
end