%This script attempts to identify cells from z-stack recordings of the
%glutamate reporter. The script works by creating a 3D binary mask of the
%fluoresence channel through simple intensity thresholding. The binary mask
%is then labeled and can be displayed using MATLAB's built-in volume viewer
%tool.

clearvars
clc

%Parameters
imageFile = 'D:\Work\CZI Dynamic Imaging RFA\data\a773_zstack_nozoom_smallclusters.oir';
thresholdLvl = 4085;

%% Begin code

%Create a BioformatsImage object to read in OIR file
bfr = BioformatsImage(imageFile);

%Initialize empty matrices to hold image and mask information
spotMask = false(bfr.height, bfr.width, bfr.sizeZ);
vol = zeros(bfr.height, bfr.width, bfr.sizeZ, 'uint16');

%Create a mask for each z-plane
for iZ = 1:bfr.sizeZ
    
    %Read in plane image
    I = getPlane(bfr, iZ, 1, 1);
    
    %Save the current z-plane into a 3D matrix for later viewing
    vol(:, :, iZ) = I;
        
    %Create the mask by thresholding
    spotMask(:, :, iZ) = I > 4085;
    
    %Remove small spots < 10 pixels in area
    spotMask(:, :, iZ) = bwareaopen(spotMask(:, :, iZ), 10);
    
end

%% Analysis

%Clean up the final mask by removing anything less than 200 pixels in
%volume
spotMask = bwareaopen(spotMask, 200, 26);

%Create a labeled image
labeledVol = bwlabeln(spotMask);

%Measure volume properties
celldata = regionprops3(spotMask);

%% Visualization

volumeViewer(vol, labeledVol);

%Note: I think it looks better to set the background color to black in the
%resulting GUI