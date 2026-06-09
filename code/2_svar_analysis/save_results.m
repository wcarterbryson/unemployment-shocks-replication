function save_results(dt, Yt, BB, par, pth)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SAVE_RESULTS Export results for plotting
% - Inputs: 
%   + dt : T x 1 vector of dates
%   + Yt : T x N vector of endogenous variables
%   + BB  : struct array containing estimation output 
%   + par : struct array containing parameters
%   + pth : struct array containing directory paths
% - Outputs: none
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Unpack parameters
p = par.p;                  % Number of lags
K = par.opt.K;              % Number of draws
s1 = par.opt.conf_sig;      % Inner confidence interval
s2 = par.opt.conf_sig_2;    % Outer confidence interval
mdl = BB.est.mdl;           % Name of model
N = BB.est.N;               % Number of endogenous variables

% Set the full output path
if isfield(par, 'robust')
    out_path = fullfile(pth.ores_dir, 'robustness', par.robust);
else
    out_path = fullfile(pth.ores_dir, mdl);
end

% Create output directory if it doesn't exist
if ~exist(out_path, 'dir')
    mkdir(out_path);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IRFs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the IRF draws to use based on the model
ird = BB.est.ir_draws; % Basline
if strcmp(mdl, 'zerosign')
    ird = BB.est.irzerosign_draws; % Zero/sign restrictions
end

% Sort indeces
sort_idx1 = round((0.5 + [-s1, s1, 0]/2) * K);
sort_idx2 = round((0.5 + [-s2, s2, 0]/2) * K);

% Export each (shock, variable) combination
for ee = 1:N
    for vv = 1:N

        % Extract 
        ir = squeeze(ird(vv,:,ee,:));
        ir = sort(ir, 2);

        % Get median and quantiles
        med0 = ir(:,sort_idx1(3));
        low1 = ir(:,sort_idx1(1));
        upp1 = ir(:,sort_idx1(2));
        low2 = ir(:,sort_idx2(1));
        upp2 = ir(:,sort_idx2(2));

        % Pack and write to csv
        fname = sprintf('%s_ir_v%d_e%d.csv', mdl, vv, ee);
        writematrix([med0 low1 upp1 low2 upp2], ...
            fullfile(out_path, fname), 'Delimiter',',');

    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FEVD and HD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FEVD
if ~isfield(par, 'robust')
for vv = 1:N
    fd = squeeze(BB.FEVD(vv,:,:));
    fname = sprintf('%s_fevd_v%d.csv', mdl, vv);
    writematrix(fd, fullfile(out_path, fname), 'Delimiter',',');
end
end

% HD
if ~isfield(par, 'robust')
yyyy = year(dt((p+1):end));
qq = quarter(dt((p+1):end));
for vv = 1:N
    hd = [yyyy qq Yt((p+1):end,vv) squeeze(BB.HD(:,vv,:))];
    fname = sprintf('%s_hd_v%d.csv', mdl, vv);
    writematrix(hd, fullfile(out_path, fname), 'Delimiter',',');
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Export each (shock, variable) combination
if ~isfield(par, 'robust')
Nx = size(BB.LP.b, 1); % Number of exogenous (LP) variables
for ee = 1:N
    for xx = 1:Nx

        % Extract LP coefficients
        lp = squeeze(BB.LP.b(xx,ee,:));
        lp_low = squeeze(BB.LP.b_low(xx,ee,:));
        lp_upp = squeeze(BB.LP.b_upp(xx,ee,:));

        % Write
        fname = sprintf('%s_lp_x%d_e%d.csv', mdl, xx, ee);
        writematrix([lp lp_low lp_upp], ...
            fullfile(out_path, fname), 'Delimiter',',');

    end

end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variance decomposition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save results
writetable(BB.VD, ...
    fullfile(out_path, strcat(mdl, '_var_decomp.csv')), ...
    'Delimiter', ',', 'WriteRowNames', true)
if ~isfield(par, 'robust')
writetable(BB.VD_noint, ...
    fullfile(out_path, strcat(mdl, '_var_decomp_noint.csv')), ...
    'Delimiter', ',', 'WriteRowNames', true)
end

% Display
disp('---------------------------------------------------------------')
disp(['----- RESULTS SAVED: ' mdl ' ---------------------------------'])
disp('---------------------------------------------------------------')

end
