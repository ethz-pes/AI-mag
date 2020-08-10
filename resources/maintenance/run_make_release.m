function run_make_release()
% Create a release of the data of the tool.
%
%    Create an archive (zip and tar.gz).
%    Put the data, a readme, and the license.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% names of the folders to pack
name = {'dataset', 'design'};

% path of the root of the project
folder = '../..';

% folder with the readme and license files
folder_readme_license = 'release_readme_license';

% folder to put the archive
folder_archive = 'release_archive';

% create the archive
get_archive(name, folder, folder_readme_license, folder_archive)

end

function get_archive(name, folder, folder_readme_license, folder_archive)
% Create archives (zip and tar.gz) of a folder, add readme, add license.
%
%    Parameters:
%        name (cell): cell with the names of the folders to archive
%        folder (str): path to the root of the project
%        folder_readme_license (str): path of the folder containing the readme and license
%        folder_archive (str): path of the folder where the archives will be written

% create the temporary directory
fprintf('init\n')
folder_work = pwd();
folder_data_tmp = tempname();
folder_archive_tmp = tempname();
[s, m] = mkdir(folder_archive);
[s, m] = mkdir(folder_data_tmp);
[s, m] = mkdir(folder_archive_tmp);

% copy the data
fprintf('copy data\n')
for i=1:length(name)
    copyfile([folder filesep() name{i}],[folder_data_tmp filesep() name{i}])
end
copyfile(folder_readme_license, folder_data_tmp)

% create the zip and tar archives
cd(folder_data_tmp)
fprintf('zip data\n')
zip([folder_archive_tmp filesep() 'data.zip'],'.');
fprintf('tar data\n')
tar([folder_archive_tmp filesep() 'data.tar'],  '.');
cd(folder_work)

% gzip the tar archive
fprintf('gzip data\n')
gzip([folder_archive_tmp filesep() 'data.tar'], folder_archive_tmp);

% copy data
fprintf('copy archive\n')
copyfile([folder_archive_tmp filesep() 'data.zip'], folder_archive);
copyfile([folder_archive_tmp filesep() 'data.tar.gz'], folder_archive);

% clean temporary
fprintf('clean\n')
[s, m] = rmdir(folder_data_tmp, 's');
[s, m] = rmdir(folder_archive_tmp, 's');

end
