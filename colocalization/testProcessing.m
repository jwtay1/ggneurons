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

end

%% Remove spots that are too small

spotMaskGreen = bwareaopen(spotMaskGreen, 15, 26);
spotMaskRed = bwareaopen(spotMaskRed, 15, 26);

spotMaskMatch = zeros(reader.height, reader.width, reader.sizeZ, 'logical');
for iZ = 1:size(spotMaskGreen, 3)
    
    spotMaskMatch(:, :, iZ) = spotMaskGreen(:, :, iZ) & spotMaskRed(:, :, iZ);
    
end

%%
%To detect intersecting volumes, could do a count using ismember for each
%object in the z-plane for each object in each z plane
dataGreen = regionprops3(spotMaskGreen, 'VoxelIdxList', 'Volume');
dataRed = regionprops3(spotMaskRed, 'VoxelIdxList', 'Volume');

dataMatch = bwconncomp(spotMaskMatch);
numMatches = dataMatch.NumObjects

%%



iZ = 10;
Iout = showoverlay(spotMaskRed(:, :, iZ), spotMaskGreen(:, :, iZ), 'Color', [0 1 0]);
showoverlay(Iout, spotMaskMatch(:, :, iZ), 'Color', [1 0 0], 'Opacity', 70);


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

