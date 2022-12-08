

% Iegfp = getPlane(reader, 1, 2, 1);
% [spotMaskGreen, Idiff] = maskSpots(Iegfp, 2, 5, 100);
% 
% figure(1)
% imshow(Idiff, [])
% figure(2)
% imshowpair(Iegfp, spotMaskGreen)


Ired = getPlane(reader, 1, 3, 1);
[spotMaskRed, Idiff] = maskSpots(Ired, 2, 5, 120);

figure(1)
imshow(Idiff, [])
figure(2)
imshowpair(Ired, spotMaskRed)
%Iref = getPlane(reader, 1, 3, 1);
%spotMaskRed = maskSpots(Iegfp, 4, 12);

