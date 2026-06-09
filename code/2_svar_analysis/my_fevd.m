function fevd_vhs = my_fevd(BB)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MY_FEVD Compute forecast error variable decomposition
% - Inputs: 
%   + BB : struct array containing estimation output 
% - Outputs:
%   + fevd_vhs : FEVD for (variable, horizon, shock)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the IRF draws to use based on the model
ird = BB.ir_draws; % Basline
if strcmp(BB.mdl, 'zerosign')
    ird = BB.irzerosign_draws; % Zero/sign restrictions
end

% Compute the FEVD across (variable, horizon, shock)
ir_vhs = median(ird, 4); % Take the median impulse response
fevd_vhs = cumsum(ir_vhs.^2,2) ./ sum(cumsum(ir_vhs.^2,2),3);

end