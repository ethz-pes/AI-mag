function init_toolbox()

% add path
addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))

% close figures
close('all')

% print copyright
author = 'T. Guillod';
year = '2019-2020';
copyright = 'ETHZ PES';
license = 'xxx License';
fprintf('%s / (c) %s %s / %s\n', author, year, copyright, license)

end