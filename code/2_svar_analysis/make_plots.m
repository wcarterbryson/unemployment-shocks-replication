function make_plots(dt, Yt, BB, par)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MAKE_PLOTS Make plots in Matlab to preview results
% - Inputs: 
%   + dt : T x 1 vector of dates
%   + Yt : T x N vector of endogenous variables
%   + BB  : struct array containing estimation output 
%   + par : struct array containing parameters
% - Outputs: none
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set some parameters
N = BB.est.N;       % Number of variables (same as number of shocks)
p = par.p;          % Number of lags
h = par.opt.hor;    % Horizons for IRFs
colors = [
    0.8500 0.3250 0.0980;
    0.0000 0.4470 0.7410;
    0.4660 0.6740 0.1880;
    1.0000 0.0000 1.0000];

% Plot data
figure
plot(dt, Yt)
legend(par.opt.varnames)

% Plot all IRFs
ird = BB.est.ir_draws; % Basline
if strcmp(BB.est.mdl, 'zerosign')
    ird = BB.est.irzerosign_draws; % Zero/sign restrictions
end
plot_all_irfs_(ird, par.opt)

% Plot LP: response to EU shock
figure
for iiv = 1:size(BB.LP.b,1)
    xx = 1:h;
    y1 = squeeze(BB.LP.b_low(iiv,1,:))';
    y2 = squeeze(BB.LP.b_upp(iiv,1,:))';
    subplot(1,3,iiv)
    fill([xx fliplr(xx)], [y1 fliplr(y2)], ...
        [0.5 0.5 0.5], 'EdgeColor','none')
    hold on
    plot(1:h, squeeze(BB.LP.b(iiv,1,:)), 'k', 'LineWidth', 2)
    plot([-1 h + 1],[0 0],'k:', 'LineWidth', 1)
    xlim([1 h])
    title('Response to Inflow Shock')
    if iiv == 1
        ylabel('Percent')
    end
end

% Plot LP: response to UE shock
figure
for iiv = 1:size(BB.LP.b,1)
    xx = 1:h;
    y1 = squeeze(BB.LP.b_low(iiv,2,:))';
    y2 = squeeze(BB.LP.b_upp(iiv,2,:))';
    subplot(1,3,iiv)
    fill([xx fliplr(xx)], [y1 fliplr(y2)], ...
        [0.5 0.5 0.5], 'EdgeColor','none')
    hold on
    plot(1:h, squeeze(BB.LP.b(iiv,2,:)), 'k', 'LineWidth', 2)
    plot([-1 h + 1],[0 0],'k:', 'LineWidth', 1)
    xlim([1 h])
    title('Response to Outflow Shock')
    if iiv == 1
        ylabel('Percent')
    end
end

% Plot FEVD area plots
figure
for ii = 1:N
    subplot(2, 2, ii)
    aa = 100.*fliplr(squeeze(BB.FEVD(ii,:,:)));
    fa = area(1:h, aa);
    for jj = size(aa,2):-1:1
        fa(jj).FaceColor = colors((1 + size(aa,2)) - jj, :);
    end
    title(par.opt.varnames{ii})
    xlim([1 h])
    ylim([0 100])
    xlabel('Quarters')
    ylabel('Share of variance')
    if ii == 1
        legend(fliplr(par.opt.shocksnames), 'Location', 'best')
    end
end

% HD labels
hd_labels = par.opt.shocksnames;
hd_labels{end+1} = 'Initial Conditions';
hd_labels{end+1} = 'Variable';

% Plot HD (2001)
figure
for ii = 1:3
subplot(1,3,ii)
bb = bar(dt((p+1):end), squeeze(BB.HD(:,ii,:)), 'stacked');
for jj = 1:numel(bb)
    bb(jj).FaceColor = colors(jj, :);
end
hold on 
plot(dt, Yt(:,ii), 'k', 'LineWidth', 2)
xlim([datetime(2000,1,1) datetime(2003,12,31)])
title(par.opt.varnames{ii})
if ii == 1
    legend(hd_labels{[1 2 3 4 6]},'Location','best')
end
end

% Plot HD (2008)
figure
for ii = 1:3
subplot(1,3,ii)
bb = bar(dt((p+1):end), squeeze(BB.HD(:,ii,:)), 'stacked');
for jj = 1:numel(bb)
    bb(jj).FaceColor = colors(jj, :);
end
hold on 
plot(dt, Yt(:,ii), 'k', 'LineWidth', 2)
xlim([datetime(2007,1,1) datetime(2010,12,31)])
title(par.opt.varnames{ii})
if ii == 1
    legend(hd_labels{[1 2 3 4 6]},'Location','best')
end
end

% Variance decomposition
disp('---------------------------------------------------------------')
disp('----- Contribution of each shock ------------------------------')
disp('---------------------------------------------------------------')
disp(' ')
disp(BB.VD)

% Variance decomposition, no interaction
disp('---------------------------------------------------------------')
disp('----- Contribution of each shock: no interaction --------------')
disp('---------------------------------------------------------------')
disp(' ')
disp(BB.VD_noint)

end