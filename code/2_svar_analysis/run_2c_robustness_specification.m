% File description: run robustness - including vacancies and GDP in the VAR

% Clear workspace
clear; close all; clc;

% Set paths and parameters
pths = set_paths();
para = set_paras();
para.robust = 'specification';
para.opt.varnames{5} = 'Vacancy level';
para.opt.varnames{6} = 'Output level';
para.opt.shocksnames{5} = 'V';
para.opt.shocksnames{6} = 'GDP';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import and clean data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in svar data
svar_data = readtable(fullfile(pths.dcln_dir, 'svar_data.csv'));
quarter = datetime(svar_data.quarter); % Unpack date variable

% Ensure sample = 1948:1 to 2019:4
in_samp = quarter >= datetime(1948,1,1) & quarter <= datetime(2019,12,31);
svar_data = svar_data(in_samp,:);
quarter = quarter(in_samp);

% Create dct from raw data names to abbreviations
name_dct = containers.Map({'eu_2state', 'ue_2state', 'ur', 'mu', ...
    'pi_eu_3state', 'pi_ue_3state', 'v', 'gdpc1'}, ...
    {'peu', 'pue', 'unr', 'aud', 'eu3', 'ue3', 'vac', 'gdp'});

% Unpack data series and apply Hamilton filter
D = struct(); % Initialize output struct
for key = keys(name_dct)
    k = key{1}; % Get each key (raw data series name)
    D.raw.(name_dct(k)) = svar_data.(k);
    D.trd.(name_dct(k)) = ham_filter(D.raw.(name_dct(k)), 8, 4);
    D.cyc.(name_dct(k)) = log(D.raw.(name_dct(k))./D.trd.(name_dct(k)));
end

% Specify VAR and variable order: {P(EU), P(UE), UR, Avg. Unemp. Dur.}
Yt = 100.*[D.cyc.peu D.cyc.pue D.cyc.unr D.cyc.aud D.cyc.vac D.cyc.gdp];
qt = quarter(~any(isnan(Yt),2));    % Trim NaN
Yt = Yt(~any(isnan(Yt),2),:);       % Trim NaN

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run estimation and decompositions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Zero-sign restrictions
Zsgn.est = estimate_svar(Yt, para, 'zerosign'); % Estimate SVAR
Zsgn.VD = var_decomp(Zsgn.est, para);   % Variance decomposition
if para.save_flag
    save_results(qt, Yt, Zsgn, para, pths);
end

