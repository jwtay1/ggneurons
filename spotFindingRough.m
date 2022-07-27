clearvars
clc

bfr = BioformatsImage('D:\Work\CZI Dynamic Imaging RFA\data\A473_res_middle_5min_power2_post.oir');

LAP = LAPLinker;

vid = VideoWriter('D:\Work\CZI Dynamic Imaging RFA\processed\A473_res_middle_5min_power2.avi');
vid.FrameRate = 10;
open(vid)

for iT = 1:bfr.sizeT
    
    I = getPlane(bfr, 1, 1, iT);
       
    %Find spots
    spotMask = detectSpots(I, 3, 2);
    
    spotMask = bwareaopen(spotMask, 10);
    
    spotData = regionprops(spotMask, I, 'MeanIntensity', 'Centroid');
    LAP = assignToTrack(LAP, iT, spotData);
    
%     imshow(spotMask)

    Idbl = double(I);
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
%%

track1 = getTrack(LAP, 2);
plot(track1.Frames, track1.MeanIntensity)

%%
save('D:\Work\CZI Dynamic Imaging RFA\processed\A473_res_middle_5min_power2.mat', 'LAP')

