% im=im2double(imread('cameraman.tif'));
im=im2double(imread('pears.png'));
im=rgb2gray(im);
% im=im2double(imread('circlesbrightdark.png'));
% im=zeros(9,9);
% im(5,5)=1;
% im=imresize(im,4*size(im)); % magnify image to enlarge edges
nsr=0.1;
[ogmag,ogdir]=imgradient(im);
kern=zeros(9,9);
kern(1:5,5)=1/9;
kern(5,1:5)=1/9;
% kern=imresize(kern,4*size(kern)); %magnify kernel also
% kern=imresize(kern,[20 20]);
iblur=conv2(im,kern);
sides=1;
iblur=iblur(sides:(end+1-sides),sides:(end+1-sides)); 

[gmag,gdir]=imgradient(iblur);
gdir=conv2(gdir,ones(3,3)/9);
sgmag=sort(gmag(:));
thresh=sgmag(ceil(length(sgmag)*.97));
% edges=edge(iblur);
edges=gmag>=thresh;
edgenum=sum(sum(edges==1));
notedgenum=sum(sum(edges==0));
oedges=edge(im,'canny',0.05);
% blurred metric
edgesum=sum(sum(gmag.*edges))/edgenum;
notedgepoints=gmag.*(1-edges);
notedgesum=sum(sum(notedgepoints))/notedgenum;
vnotedge=var(notedgepoints(:));
% original metric
oedgesum=sum(sum(ogmag.*oedges))/edgenum;
onotedgepoints=ogmag.*(1-oedges);
onotedgesum=sum(sum(onotedgepoints))/notedgenum;
vonotedge=var(onotedgepoints(:));
% run edge searcher
maxrange=8;
radonarray=zeros(ceil((maxrange*2+1)),ceil((maxrange*2+1))); % x vals are degrees
radonarraystorage=zeros(ceil(sqrt(2)*maxrange*2+10),361);
cpix=ceil(size(radonarray,1)/2);
shiftamt=zeros(size(edges));
% do a radon transform around every edge location, in all directions
for y=(1+maxrange):(size(edges,1)-maxrange)
    for x=(1+maxrange):(size(edges,2)-maxrange)
        radonarray=zeros(ceil((maxrange*2+1)),1);
        if edges(y,x)==1 %on edge. start detecting length
            thisdir=round(gdir(y,x));
            rads=gdir(y,x)*3.14/180;
            yy=y; xx=x; 
            %radonarray(cpix)=gmag(y,x);
            range=0;
            while (range <= maxrange && yy<=size(gmag,1) &&...
                    yy>=1 && xx<=size(gmag,2) && xx>=1 && gmag(yy,xx)>.1) %while you're still on an edge, keep looking
                radonarray(cpix+range)=gmag(yy,xx); % gmag filter can be changed
                range=range+1;
                yy=round(y-range*sin(rads)); % 0 val for y is at the top of the image
                xx=round(x+range*cos(rads));
            end
            if yy<=size(gmag,1) || yy>=1 || xx<=size(gmag,2) || xx>=1 || edges(yy,xx)==1
                stop1=maxrange;
            else
                stop1=range;
            end
            yy=y; xx=x;
            range=0;
            while (abs(range) <= maxrange && yy<=size(gmag,1) &&...
                    yy>=1 && xx<=size(gmag,2) && xx>=1 && gmag(yy,xx)>.1) %while you're still on an edge, keep looking
                radonarray(cpix+range)=gmag(yy,xx); %gmag filter can be changed
                range=range-1;
                yy=round(y-range*sin(rads)); % 0 val for y is at the top of the image
                xx=round(x+range*cos(rads));
            end
            if yy<=size(gmag,1) || yy>=1 || xx<=size(gmag,2) || xx>=1 || edges(yy,xx)==1
                stop2=-maxrange;
            else
                stop2=range;
            end
%             cradonarray=radon(radonarray,thisdir+90);
            cradonarray=radonarray;
            crix=ceil(size(cradonarray,1)/2);
%             sradonarray=zeros(size(radonarray));
            wavg=sum(((1:length(cradonarray)).').*cradonarray)./sum(cradonarray);
            shiftamt(y,x)=-round(crix-wavg);
            pradonarray=padarray(cradonarray,[maxrange 0]);
            sradonarray=pradonarray((1+maxrange+shiftamt(y,x)):(end-maxrange+shiftamt(y,x)));
            srix=ceil(size(radonarraystorage,1)/2);
            cc=srix-crix;
            radonarraystorage((1+cc):(end-cc),thisdir+181)=radonarraystorage((1+cc):(end-cc),thisdir+181)+sradonarray;
        end
    end
end
numtheta=360;
sumangles=zeros(1,361);
for x=1:size(radonarraystorage,2)
    sumangles(x)=sum(radonarraystorage(:,x));
end
[sortedsumangles,thetas]=sort(sumangles); %sort how much activitiy there is for each direction
smallstorage=zeros(size(radonarraystorage,1),numtheta);
for m=1:numtheta
    smallstorage(:,m)=radonarraystorage(:,thetas(362-m));%/sum(radonarraystorage(:,thetas(182-m)));
end
projection=iradon((smallstorage),thetas(361:-1:(361-numtheta+1))-180);
figure; imagesc(projection)
title(sprintf('projection using best %i angles',numtheta));
figure; (imagesc(radonarraystorage));
title('the supposed radon transform')
projection2=projection>.8;
figure; imagesc(projection2);
nprojection2=projection2/sum(sum(projection2));
figure; imagesc(deconvwnr(iblur,nprojection2,0.01)); colormap gray
% sumangles2=zeros(size(radonarraystorage));
% for n=1:181
%     sumangles2(:,n)=radonarraystorage(:,n)/sum(radonarraystorage(:,n));
% end
% figure; imagesc(sumangles2)
% title('the supposed radon transform, normalized')
% high pass it with another ramp
% ramp=zeros(size(projection));
% for y=1:size(ramp,1)
%     for x=1:size(ramp,2)
%         ramp(y,x)=sqrt(abs(y-ceil(size(ramp,1)/2))^2+abs(x-ceil(size(ramp,2)/2))^2);
%     end
% end
% filter it
% projectionramp=fftshift(ramp.*fftshift(fft2(projection)));
% projectionramp1=ifft2(projectionramp);
