%%%%%%%%%%%%%%%%%%%%
%%%This script takes a folder of 2D .tiff images of the raw biomatrix LSFM
%%%data an quantifies biomatrix 3D porosity. 
%%%First, data is pre-processed. Then, the biomatrix scaffold is segmented and saved as 2D .tiffs.
%%%Then, the biomatrix envelope is segmented and saved as folder of 2D .tiffs.
%%%Finally, 3D porosity is quantified. 
%%%This script requires 3 inputs: 
%(1) originalFolder (folder with raw 2D .tiff images)
%(2) outputFolder_scaffold (folder location to save 2D .tiff scaffold images)
%(3) outputFolder_envelope (folder location to save 2D .tiff envelope images)

%%%%USER INPUTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define paths
originalFolder = 'E:\';
outputFolder_scaffold = 'E:\scaffold binarized';
outputFolder_envelope = 'E:\envelope binarized';

% Create output folders if they don't exist
if ~exist(outputFolder_scaffold, 'dir')
    mkdir(outputFolder_scaffold);
end
if ~exist(outputFolder_envelope, 'dir')
    mkdir(outputFolder_envelope);
end

% Get list of TIFF files
fileList = dir(fullfile(originalFolder, '*.tif*'));
numImages = length(fileList);

% Create the disk structuring element
radius1 = 1;
decomposition1 = 0;
se1 = strel('disk', radius1, decomposition1);

radius2 = 9;
decomposition2 = 0;
se2 = strel('disk', radius2, decomposition2);

% Initialize variables to store pixel counts
imm_clean_pixel_count = zeros(1, numImages);
BWfh_pixel_count = zeros(1, numImages);

% Process images one at a time
h = waitbar(0, 'Processing Images...');
for image = 1:numImages
    waitbar(image/numImages, h, sprintf('Processing Image %d/%d', image, numImages));
    
    % Read the image
    imfile = fullfile(originalFolder, fileList(image).name);
    tmp = imread(imfile);
    
    % Local background subtraction
    background = imopen(tmp, strel('disk', 50));
    imm = imsubtract(tmp, background);
    
    % Histogram equalization
    imm_imadjust = imadjust(imm);
    
    % Frangi vessel filter
    imm_frangil = fibermetric(imm_imadjust, 10);
    imm_frangilbin = imbinarize(imm_frangil, 0.1);
    imm_frangilbin_closed = imclose(imm_frangilbin, se1);
    imm_clean = bwareaopen(imm_frangilbin_closed, 20, 4);
    
    % Save segmented scaffold image
    binaryMaskOut = fullfile(outputFolder_scaffold, ['scaffold_binarized', num2str(image), '.tif']);
    imwrite(imm_clean, binaryMaskOut);
    
    % Count pixels equal to 1 in imm_clean and store the count
    imm_clean_pixel_count(image) = sum(imm_clean(:));
    
    % Segmenting scaffold envelope
    BW = imdilate(imm_frangilbin, se2);
    BWe = imerode(BW, se2);
    BWfh = imfill(BWe, 'holes');
    
    % Save segmented envelope image
    binaryopenMaskOut = fullfile(outputFolder_envelope, ['envelope_binarized', num2str(image), '.tif']);
    imwrite(BWfh, binaryopenMaskOut);
    
    % Count pixels equal to 1 in BWfh and store the count
    BWfh_pixel_count(image) = sum(BWfh(:));
end
close(h);

% Calculate total pixels equal to 1 across all images
imm_clean_total_pixels = sum(imm_clean_pixel_count(1:end));
BWfh_total_pixels = sum(BWfh_pixel_count(1:end));
disp('3D biomatrix porosity is');
porosity = (1 - (imm_clean_total_pixels / BWfh_total_pixels)) * 100
