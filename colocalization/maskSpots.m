function [mask, Idiff] = maskSpots(imgIn, sigma1, sigma2, th)

Ig1 = imgaussfilt(imgIn, sigma1);
Ig2 = imgaussfilt(imgIn, sigma2);

Idiff = Ig1 - Ig2;

%imshow(Idiff, [])

mask = Idiff > th;