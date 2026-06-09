function pths = set_paths()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SET_PATHS Sets the paths for the project directory
% File description: Set all paths globally in this file so that you don't
% have to set them in each sub-program.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SET path to Empirical Macro Toolbox (Ferroni and Canova, 2025)
% *** Edit this line to point to your local copy of the toolbox ***
util_dir = '/path/to/toolbox/';

% Project root is derived automatically from this file's location
this_dir     = fileparts(mfilename('fullpath'));
pths.root_dir = fullfile(this_dir, '..', '..');

% SET sub-directories
pths.dcln_dir = fullfile(pths.root_dir, 'data', 'clean');
pths.ores_dir = fullfile(pths.root_dir, 'output', 'results');

% Add path to Empirical macro toolbox (Ferroni and Canova, 2025)
addpath(fullfile(util_dir, 'BVAR_', 'bvartools'))

end
