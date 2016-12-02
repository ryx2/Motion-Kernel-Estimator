im=im2double(imread('cameraman.tif'));
nsr=0.1;
[ogmag,ogdir]=imgradient(im);
kern=zeros(9,9);
kern(2:5,5)=1/7;
kern(5,2:5)=1/7;
iblur=conv2(im,kern);
iblur=iblur(9:(end-8),9:(end-8));
[gmag,gdir]=imgradient(iblur);
edges=edge(iblur);
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
radonarraystorage=zeros(ceil(sqrt(2)*maxrange*2+10),181);
cpix=ceil(size(radonarray,1)/2);
shiftamt=zeros(size(edges));
for y=(1+maxrange):(size(edges,1)-maxrange)
    for x=(1+maxrange):(size(edges,2)-maxrange)
        radonarray=zeros(ceil((maxrange*2+1)),ceil((maxrange*2+1)));
        if edges(y,x)==1 %on edge. start detecting length
            thisdir=round(gdir(y,x)+(gdir(y,x)<0)*180)+1;
            yy=y; xx=x; 
            %radonarray(cpix)=gmag(y,x);
            range=0;
            while (range <= maxrange && yy<=size(gmag,1) && yy>=1 && xx<=size(gmag,2) && xx>=1 && gmag(yy,xx)>.1 && (edges(yy,xx)~=1||range==0)) %while you're still on an edge, keep looking
                radonarray(cpix+yy-y,cpix+xx-x)=gmag(yy,xx);
                range=range+1;
                yy=round(y-range*sin(thisdir)); % 0 val for y is at the top of the image
                xx=round(x+range*cos(thisdir));
            end
            if yy<=size(gmag,1) || yy>=1 || xx<=size(gmag,2) || xx>=1 || edges(yy,xx)==1
                stop1=maxrange;
            else
                stop1=range;
            end
            yy=y; xx=x;
            range=0;
            while (abs(range) <= maxrange && yy<=size(gmag,1) && yy>=1 && xx<=size(gmag,2) && xx>=1 && gmag(yy,xx)>.1 && (edges(yy,xx)~=1||range==0)) %while you're still on an edge, keep looking
                radonarray(cpix+yy-y,cpix+xx-x)=gmag(yy,xx);
                range=range-1;
                yy=round(y-range*sin(thisdir)); % 0 val for y is at the top of the image
                xx=round(x+range*cos(thisdir));
            end
            if yy<=size(gmag,1) || yy>=1 || xx<=size(gmag,2) || xx>=1 || edges(yy,xx)==1
                stop2=maxrange;
            else
                stop2=range;
            end
            cradonarray=radon(radonarray,thisdir+90);
            crix=ceil(size(cradonarray,1)/2);
%             sradonarray=zeros(size(radonarray));
%             shiftamt(y,x)=round((stop1-stop2)/2)-stop1;
%             pradonarray=padarray(radonarray,[maxrange 0]);
%             sradonarray(:)=pradonarray((1+maxrange+shiftamt(y,x)):(end-maxrange+shiftamt(y,x)));
            cix=ceil(size(radonarraystorage,1)/2);
            cc=cix-crix;
            radonarraystorage((1+cc):(end-cc),thisdir)=radonarraystorage((1+cc):(end-cc),thisdir)+cradonarray;
        end
    end
end
numtheta=15;
sumangles=zeros(1,180);
for x=1:size(radonarraystorage,2)
    sumangles(x)=sum(radonarraystorage(:,x));
end
[sortedsumangles,thetas]=sort(sumangles); %sort how much activitiy there is for each direction
smallstorage=zeros(size(radonarraystorage,1),numtheta);
for m=1:numtheta
    smallstorage(:,m)=radonarraystorage(:,thetas(182-m))/sum(radonarraystorage(:,thetas(182-m)));
end
projection=iradon((smallstorage),thetas(181:-1:(181-numtheta+1)));
figure; imagesc(projection)
