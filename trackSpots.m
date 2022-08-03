%This script identifies and tracks spots in an image. Spot detection is
%carried out using a difference of Gaussians filter. Tracking uses the
%linear assignment framework.

clearvars
clc

%Parameters
% imageFile = 'D:\Work\CZI Dynamic Imaging RFA\data\A473_res_middle_5min_power2_post.oir';
imageFile = 'D:\Work\CZI Dynamic Imaging RFA\data\A482_res_middle_5min_power2.oir';
outputDir = 'D:\Work\CZI Dynamic Imaging RFA\processed\';

%% Start code

%Create a BioformatsImage object to read the OIR file
bfr = BioformatsImage(imageFile);

%Create a LAPLinker object to create tracks
LAP = LAPLinker;
LAP.LinkScoreRange = [0 15];

%Create a video file
if ~exist(outputDir, 'dir')
    mkdir(outputDir)
end
[~, outputFN] = fileparts(imageFile);

vid = VideoWriter(fullfile(outputDir, [outputFN, '.avi']));
vid.FrameRate = 10;
open(vid)

for iT = 1:bfr.sizeT
    
    %Read in current frame
    I = getPlane(bfr, 1, 1, iT);
       
    %Find spots using the difference of Gaussians filter
    spotMask = detectSpots(I, 3, 2);
    spotMask = bwareaopen(spotMask, 10);
    
    %Get spot data
    spotData = regionprops(spotMask, I, 'MeanIntensity', 'Centroid');
    
    %Track individual spots
    LAP = assignToTrack(LAP, iT, spotData);
    
    %Create an output image for the video file
    Iout = showoverlay(I, spotMask, 'opacity', 40);
    Idbl = double(Iout);
    Idbl = (Idbl - min(Idbl(:)))/(max(Idbl(:)) - min(Idbl(:)));
    for iAT = 1:numel(LAP.activeTrackIDs)
        
        currData = getTrack(LAP, LAP.activeTrackIDs(iAT));
        
        if currData.Frames(end) == iT
            
            Idbl = insertText(Idbl, currData.Centroid(end, :), currData.ID, ...
                'BoxOpacity', 0, 'TextColor', 'yellow');
            
        end
        
    end
    writeVideo(vid, Idbl);

    
end
close(vid)

%Save the tracked data as a MAT-file
save(fullfile(outputDir, [outputFN, '.mat']), 'LAP')

%% Example analysis

%Get object #2 (see video for labels)
objData = getTrack(LAP, 2);

%Plot the mean intensity of the spot
plot(objData.Frames, objData.MeanIntensity)

return
%% Export images for figures
topLeft = [190 35];
imgSize = 200;

[spotMask, dogImg] = detectSpots(I, 3, 2);
spotMask = bwareaopen(spotMask, 10);

cropI = I(topLeft(1):(topLeft(1) + imgSize), topLeft(2):(topLeft(2) + imgSize));

cropI = double(cropI);
cropI = cropI ./ max(cropI(:));
cropI = cat(3, zeros(size(cropI)), cropI, zeros(size(cropI)));
cropI = imresize(cropI, 2, 'nearest');
imwrite(cropI, 'D:\Work\CZI Dynamic Imaging RFA\proposal\Figures\spots.png')

cropDoG = dogImg(topLeft(1):(topLeft(1) + imgSize), topLeft(2):(topLeft(2) + imgSize));

cropDoG = double(cropDoG);
cropDoG = cropDoG ./ max(cropDoG(:));
cropDoG = imresize(cropDoG, 2, 'nearest');
imwrite(cropDoG, 'D:\Work\CZI Dynamic Imaging RFA\proposal\Figures\dog.png')

cropMask = spotMask(topLeft(1):(topLeft(1) + imgSize), topLeft(2):(topLeft(2) + imgSize));

cropMask = double(cropMask);
cropMask = cropMask ./ max(cropMask(:));
cropMask = imresize(cropMask, 2, 'nearest');

imwrite(cropMask, 'D:\Work\CZI Dynamic Imaging RFA\proposal\Figures\mask.png')

%%
figure;

%Convert to time
dt = (1/3)/60; %3 frame/sec

for iTrack = [1 2]
    
    currTrack = getTrack(LAP, iTrack);
    
    tt = currTrack.Frames * dt;
    
    plot(tt, currTrack.MeanIntensity);%, tt, smooth(currTrack.MeanIntensity, 5), '--')
    hold on
    
end
plot([90/60 90/60], ylim, 'k--', [180/60 180/60], ylim, 'k--')

hold off
xlabel('Time (min)')
ylabel('Intensity (arb. units)')
xlim([0 5])

