% Raymond Xu, 11/24/2016
% this example script shows how to estimate the motion kernel of a blurred
% image
I = im2double(imread('cameraman.tif'));
LEN = 41;
THETA = 51;
PSF = fspecial('motion', LEN, THETA);
figure
imagesc(PSF)
title('PSF')
blurred = imfilter(I, PSF, 'conv', 'circular');
figure
imshow(blurred)
title('blurred')
fftblurred = fft2(blurred);
figure
fftedit = log(abs(fftshift(fftblurred)));
imagesc(fftedit);
title('fft of blurred')
% This is how to do it with the radon transform
% [ysum,x]=radon(log(abs(fftshift(fftblurred))),[0:90]);
% figure
% plot(x,ysum(:,12))
% title('radon transform of 11 degrees')
% This is how to do it with the hough transform of the edge image
edgefft = edge(fftedit,'canny');
[H,theta,rho] = hough(edgefft);
figure
imshow(imadjust(mat2gray(H)),[],...
       'XData',theta,...
       'YData',rho,...
       'InitialMagnification','fit');
xlabel('\theta (degrees)')
ylabel('\rho')
axis on
axis normal
hold on
colormap(hot)
title('hough detets strongest lines at 11 degrees')
P = houghpeaks(H,5); %the best lines should be the longest ones
motionangle = median(theta(P(:,2)));
% assume that the median of the 5 is the direction of the motion angle
% now that angle is estimated, estimate length
figure
cepstral = ifftshift(ifft(log((fftblurred))));
% rotatecepstral = imrotate(cepstral,motionangle);
imagesc(abs(rotatecepstral))
title('rotated cepstral, cepstral=ifft(log(abs(fftblurred)))')
sumrc=real(sum((cepstral)));
figure
plot(sumrc)
hold on
width = length(cepstral(1,:));
maxsumrc2=max(sumrc(:))/2;
plot(1:width,zeros(width))
title('summed columns of the rotated cepstral, with max/2')
lower = 0; upper = width;
for i=1:floor(width/2)
    if sumrc(i)<0
        lower=i;
    end
end
for i=width:-1:ceil(width/2)
    if sumrc(i)<0
        upper=i;
    end
end
motionlength = (upper - lower)/2;
fprintf('estimated motion length is %f',motionlength);
fprintf(', esimated motion angle is %f\n',motionangle);


