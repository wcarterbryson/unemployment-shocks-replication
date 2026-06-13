% Run all

% Change to this file's directory so sub-scripts resolve correctly
cd(fileparts(mfilename('fullpath')));

tic;
run_2_main
run_2a_robustness_lags
run_2b_robustness_sample
run_2c_robustness_specification
toc;
