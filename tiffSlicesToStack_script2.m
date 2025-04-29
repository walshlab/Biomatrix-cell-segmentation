%%%%%%%%%%%%%%%%%%%%
%%%This script takes a folder of 2D .tiff images, and saves them as a single 3D .tiff stack
%%%for additional analysis in ImageJ and Imaris
%This script requires 3 inputs: 
%(1) inputFolder (folder with 2D .tiff images)
%(2) outputFolder (folder location to save 3D .tiff stack file)
%(3) outputFileName (name of 3D .tiff stack file to save)

%%%%USER INPUTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prompt user to select the original folder
inputFolder = uigetdir('Select the folder containing original TIFF files');

% Check if the user canceled folder selection
if inputFolder == 0
    error('Folder selection canceled by user.');
end

% Get the parent directory of the originalFolder and use as the
% outputFolder
outputFolder = fileparts(inputFolder);

% Create the output folder if it does not exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Define output file name with full path
outputFileName = fullfile(outputFolder, 'sample_A1_.tif');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get a list of all TIFF files in the input folder
tifFiles = dir(fullfile(inputFolder, '*.tif'));

% Extract file names and convert to numeric
fileNames = {tifFiles.name};
fileNumbers = cellfun(@(x) str2double(regexprep(x, '\D', '')), fileNames);

% Sort file numbers
[sortedFileNumbers, sortedIndices] = sort(fileNumbers);

% Sort file names based on sorted file numbers
sortedFileNames = fileNames(sortedIndices);

% Open the first TIFF file to get the initial settings
firstTiff = Tiff(fullfile(inputFolder, sortedFileNames{1}), 'r');
firstImage = firstTiff.read();
tagstruct.ImageLength = size(firstImage, 1);
tagstruct.ImageWidth = size(firstImage, 2);
tagstruct.Photometric = firstTiff.getTag('Photometric');
tagstruct.BitsPerSample = firstTiff.getTag('BitsPerSample');
tagstruct.SamplesPerPixel = firstTiff.getTag('SamplesPerPixel');
tagstruct.RowsPerStrip = firstTiff.getTag('RowsPerStrip');
tagstruct.PlanarConfiguration = firstTiff.getTag('PlanarConfiguration');
try
    tagstruct.Software = firstTiff.getTag('Software');
catch
    tagstruct.Software = 'MATLAB';
end
firstTiff.close();

% Create a Tiff object for writing the stack with 'bigtiff' option
t = Tiff(outputFileName, 'w8'); % 'w8' is the mode for bigTIFF

% Loop through each TIFF file and write each slice to the stack
h = waitbar(0, 'Writing TIFF stack...');
for i = 1:numel(sortedFileNames)
    currentTiff = Tiff(fullfile(inputFolder, sortedFileNames{i}), 'r');
    currentImage = currentTiff.read();
    
    % Write the current slice to the stack
    if i == 1
        % For the first slice, set the tag properties
        t.setTag(tagstruct);
        t.write(currentImage);
    else
        % For subsequent slices, write a new directory and then write the image
        t.writeDirectory();
        t.setTag(tagstruct);
        t.write(currentImage);
    end
    
    currentTiff.close();
    
    waitbar(i/numel(sortedFileNames), h, sprintf('Writing slice %d of %d', i, numel(sortedFileNames)));
end

% Close the Tiff object and the progress bar
t.close();
close(h);
disp('TIFF stack saved successfully.');

