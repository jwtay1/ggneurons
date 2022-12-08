clearvars
clc

dataDir = 'D:\CU-Projects\rootlab\data';

reader = BioformatsImage(fullfile(dataDir, 'q240.nd2'));

%%
spotMaskGreen = zeros(reader.height, reader.width, reader.sizeZ, 'logical');
spotMaskRed = zeros(reader.height, reader.width, reader.sizeZ, 'logical');
Iegfp = zeros(reader.height, reader.width, reader.sizeZ, 'uint16');
Ired = zeros(reader.height, reader.width, reader.sizeZ, 'uint16');

for iZ = 1:reader.sizeZ

    Iegfp(:, :, iZ) = getPlane(reader, iZ, 2, 1);
    spotMaskGreen(:, :, iZ) = maskSpots(Iegfp(:, :, iZ), 2, 5, 100);
    
    Ired(:, :, iZ) = getPlane(reader, iZ, 3, 1);
    spotMaskRed(:, :, iZ) = maskSpots(Ired(:, :, iZ), 2, 5, 120);

    if iZ == 1
        
        imwrite(spotMaskGreen(:, :, iZ), 'greenMask.tif', 'Compression', 'none')
        imwrite(spotMaskRed(:, :, iZ), 'redMask.tif', 'Compression', 'none')
        imwrite(Iegfp(:, :, iZ), 'gfp.tif', 'Compression', 'none')
        imwrite(Ired(:, :, iZ), 'red.tif', 'Compression', 'none')
        
    else
        
        imwrite(spotMaskGreen(:, :, iZ), 'greenMask.tif', 'Compression', 'none', 'writeMode', 'append')
        imwrite(spotMaskRed(:, :, iZ), 'redMask.tif', 'Compression', 'none', 'writeMode', 'append')
        imwrite(Iegfp(:, :, iZ), 'gfp.tif', 'Compression', 'none', 'writeMode', 'append')
        imwrite(Ired(:, :, iZ), 'red.tif', 'Compression', 'none', 'writeMode', 'append')
        
    end
    
end

%% Remove spots that are too small

spotMaskGreen = bwareaopen(spotMaskGreen, 15, 26);
spotMaskRed = bwareaopen(spotMaskRed, 15, 26);

spotMaskMatch = zeros(reader.height, reader.width, reader.sizeZ, 'logical');
for iZ = 1:size(spotMaskGreen, 3)
    
    spotMaskMatch(:, :, iZ) = spotMaskGreen(:, :, iZ) & spotMaskRed(:, :, iZ);
    
    if iZ == 1
        
        imwrite(spotMaskMatch(:, :, iZ), 'spotMask.tif', 'Compression', 'none')

    else
        
        imwrite(spotMaskMatch(:, :, iZ), 'spotMask.tif', 'Compression', 'none', 'writeMode', 'append')
        
    end
    
end

%%
%To detect intersecting volumes, could do a count using ismember for each
%object in the z-plane for each object in each z plane
dataGreen = regionprops3(spotMaskGreen, 'VoxelIdxList', 'Volume');
dataRed = regionprops3(spotMaskRed, 'VoxelIdxList', 'Volume');

dataMatch = bwconncomp(spotMaskMatch);
numMatches = dataMatch.NumObjects;

%% Make a 3D label

%1 - green mask
%2 - red mask
%3 - match mask

labels = zeros(size(Iegfp), 'uint8');
for iZ = 1:size(spotMaskRed, 3)
    
    currGreenPerim = bwperim(spotMaskGreen(:, :, iZ));
    currRedPerim = bwperim(spotMaskRed(:, :, iZ));
    currMatchPerim = bwperim(spotMaskMatch(:, :, iZ));
    
    currLabel = zeros(size(spotMaskMatch, 1), size(spotMaskMatch, 2), 'uint8');
    currLabel(currGreenPerim) = 1;
    currLabel(currRedPerim) = 2;
    currLabel(currMatchPerim) = 3;    
    
    labels(:, :, iZ) = currLabel;
end

volumeViewer(Iegfp, labels)
%% Make a blended 3D image
% 
% Iout = zeros(size(Iegfp), 'uint16');
% 
% IredMax = double(max(Ired(:)));
% IredMin = double(min(Ired(:)));
% 
% IgreenMax = double(max(Iegfp(:)));
% IgreenMin = double(min(Iegfp(:)));
% 
% for iZ = 1:size(spotMaskRed, 3)
% 
%     %Rescale
%     currRed = double(Ired(:, :, iZ));
%     currRed = (currRed - IredMin)/(IredMax - IredMin);
%     currRed = uint8(currRed * 255);
%     
%     currGreen = double(Iegfp(:, :, iZ));
%     currGreen = (currGreen - IgreenMin)/(IgreenMax - IgreenMin);
%     currGreen = uint8(currGreen * 255);
%     
%     currBlue = zeros(size(currGreen), 'uint16');
%     
%     currMatchPerim = bwperim(spotMaskMatch(:, :, iZ));
%     
%     currBlue(currMatchPerim) = 255;
%     currGreen(currMatchPerim) = 255;
%     
%     Iout(:, :, iZ) = cat(3, currRed, currGreen, currBlue);
%     
%     %Iout = showoverlay(spotMaskRed(:, :, iZ), spotMaskGreen(:, :, iZ), 'Color', [0 1 0]);
%     %showoverlay(Iout, spotMaskMatch(:, :, iZ), 'Color', [1 0 0], 'Opacity', 70);
% 
% end
%% Data analysis

%%ACtually could be faster if we just use an and operator

% 
% matches_redvgreen = zeros(1, size(dataRed, 1));
% 
% for iRedSpots = 1:size(dataRed, 1)
%     
%     %For each red spot, test to see if it intersects with a green spot
%     numHits = zeros(1, size(dataGreen, 1));
%     for iGreenSpots = 1:size(dataGreen, 1)        
%         numHits(iGreenSpots) = nnz(ismember(dataRed.VoxelIdxList{iRedSpots}, dataGreen.VoxelIdxList{iGreenSpots}));        
%     end
%     
%     [maxVal, maxIdx] = max(numHits);
%     
%     if (maxVal / dataRed.Volume(iRedSpots)) > 0.5
%         matches_redvgreen(iRedSpots) = maxIdx;
%         keyboard
%     end
%    
% end
% 

