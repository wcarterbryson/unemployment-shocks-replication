function pths = set_paths()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SET_PATHS Sets the paths for the project directory
% File description: Set all paths globally in this file so that you don't
% have to set them in each sub-program.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SET: full path to the BVAR_ toolbox directory (Ferroni and Canova, 2025)
util_dir = '/path/to/BVAR_/';
addpath(fullfile(util_dir, 'bvartools'))

% Project root is derived automatically from this file's location
this_dir      = fileparts(mfilename('fullpath'));
pths.root_dir = fullfile(this_dir, '..', '..');

% Sub-directories
pths.dcln_dir = fullfile(pths.root_dir, 'data', 'clean');
pths.ores_dir = fullfile(pths.root_dir, 'output', 'results');

end
