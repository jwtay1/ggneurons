clearvars
clc

bfr = BioformatsImage('D:\Work\CZI Dynamic Imaging RFA\data\a773_zstack_nozoom_smallclusters.oir');

%%
spotMask = zeros(bfr.height, bfr.width, bfr.sizeZ);

for iZ = 1:bfr.sizeZ
I = getPlane(bfr, iZ, 1, 1);

spotMask(:, :, iZ) = I > 4085;
%spotMask = imopen(spotMask, strel('disk', 2));
%showoverlay(I, spotMask, 'opacity', 40);

if iZ == 1
    imwrite(spotMask(:, :, iZ), 'spotmask.tif');
else
    imwrite(spotMask(:, :, iZ), 'spotmask.tif', 'writeMode', 'append')
end


end

return
%% Analysis

%Identify individual cells using the maximum intensity projection
%Get a MIP
mipMask = max(spotMask, [], 3);

mipMask = imclose(mipMask, strel('disk', 2));
mipMask = bwareaopen(mipMask, 200);

cellsBB = regionprops(mipMask, 'BoundingBox');

imshow(mipMask, [])

%For a single plane, run a spot finding algorithm and count spots, quantify
%intensity?



