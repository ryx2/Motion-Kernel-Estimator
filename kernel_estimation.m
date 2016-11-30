function [kernel,motionangle] = kernel_estimation(image)
% Raymond Xu, 11/24/2016
% this example script shows how to estimate the motion kernel of a blurred
% image

fftblurred = fft2(image);
% figure
fftedit = log(abs(fftshift(fftblurred)));
% imagesc(fftedit);
% title('fft of blurred')
%%%%%%%%%%%
% This is how to do it with the radon transform
% [ysum,x]=radon(log(abs(fftshift(fftblurred))),[0:90]);
% figure
% plot(x,ysum(:,12))
% title('radon transform of 11 degrees')
% This is how to do it with the hough transform of the edge image
zerosfftedit=fftedit<0;
edgefft = edge(zerosfftedit);
[H,theta,rho] = hough(zerosfftedit);
% figure
% imshow(imadjust(mat2gray(H)),[],...
%        'XData',theta,...
%        'YData',rho,...
%        'InitialMagnification','fit');
% xlabel('\theta (degrees)')
% ylabel('\rho')
% axis on
% axis normal
% hold on
% colormap(hot)
% title('hough detets strongest lines')
H=round(conv2(H,ones(3,3)*1/9));
P = houghpeaks(H,1); %the best lines should be the longest ones
motionangle = (theta(P(:,2)));
% assume that the median of the 5 is the direction of the motion angle
% now that angle is estimated, estimate length

cepstral = ifftshift(ifft(log((fftblurred))));
% imagesc(abs(cepstral))
% title('cepstral=ifft(log(abs(fftblurred)))')
sumrc=real(sum((cepstral)));
% figure
% plot(sumrc)
% hold on
width = length(cepstral(1,:));
maxsumrc2=max(sumrc(:))/2;
% plot(1:width,zeros(width))
% title('summed columns of the rotated cepstral, with 0 plotted')
lower = 0; upper = width;
for i=1:floor(width/2)
    if sumrc(i)<(max(sumrc(:))+min(sumrc(:)))/2
        lower=i;
    end
end
for i=width:-1:ceil(width/2)
    if sumrc(i)<(max(sumrc(:))+min(sumrc(:)))/2
        upper=i;
    end
end
motionlength = (upper - lower)/2;
% fprintf('estimated motion length is %f',motionlength);
% fprintf(', esimated motion angle is %f\n',motionangle);

kernel = fspecial('motion', motionlength/2, motionangle);
