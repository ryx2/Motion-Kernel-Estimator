im=im2double(imread('cameraman.tif'));
nsr=0.1;
[ogmag,ogdir]=imgradient(im);
kern=zeros(9,9);
kern(2:5,5)=1/7;
kern(5,2:5)=1/7;
iblur=conv2(im,kern);
iblur=iblur(9:(end-8),9:(end-8));
[gmag,gdir]=imgradient(iblur);
edges=edge(iblur,'canny',0.05);
edgenum=sum(sum(edges==1));
notedgenum=sum(sum(edges==0));
oedges=edge(im,'canny',0.05);
%blurry metric
edgesum=sum(sum(gmag.*edges));
notedgepoints=gmag.*(1-edges);
notedgesum=sum(sum(notedgepoints));
vnotedge=var(notedgepoints(:));
%non blurry metric
oedgesum=sum(sum(ogmag.*oedges));
onotedgepoints=ogmag.*(1-oedges);
onotedgesum=sum(sum(onotedgepoints));
vonotedge=var(onotedgepoints(:));
%sharpened image metric
sharp=imsharpen(iblur,'amount',3);
[sgmag,sgdir]=imgradient(sharp);
sedgesum=sum(sum(sgmag.*edges));
snotedgepoints=sgmag.*(1-edges);
snotedgesum=sum(sum(snotedgepoints));
vsnotedge=var(snotedgepoints(:));
%form an initial estimation
[trykernel,motionangle]=kernel_estimation(iblur);
%deblur using the initial estimation
deblur=deconvwnr(iblur,trykernel,nsr);
% deblur metric
[dgmag,dgdir]=imgradient(deblur);
dedgesum=sum(sum(dgmag.*edges));
dnotedgepoints=dgmag.*(1-edges);
dnotedgesum=sum(sum(dnotedgepoints));
vdnotedge=var(dnotedgepoints(:));
%try shifts
cx=(size(trykernel,2)+1)/2;
cy=(size(trykernel,1)+1)/2; %know the origin
bestxshift=0;
bestyshift=0;
bestmetric=0;
besttrykernel=trykernel;
bestdeblur=iblur;
bestgmag=gmag;
bestgdir=gdir;
for y=1:size(trykernel,1)
    for x=1:size(trykernel,2)
        %try shifting every kernel pixel into the center
        xshift=x-cx;
        yshift=y-cy;
        shkern=padarray(zeros(size(trykernel)),[abs(yshift),abs(xshift)]);
        shkern((1+abs(yshift)+yshift):(end-abs(yshift)+yshift),(1+abs(xshift)+xshift):(end-abs(xshift)+xshift))=trykernel;
        shdeblur=deconvwnr(iblur,shkern,nsr);
        [shgmag,shgdir]=imgradient(shdeblur);
        shedgesum=sum(sum(shgmag.*edges));
        shnotedgepoints=shgmag.*(1-edges);
        shnotedgesum=sum(sum(shnotedgepoints));
        metric=(shedgesum-edgesum)/edgenum-(shnotedgesum-notedgesum)/notedgenum;
        if metric>bestmetric
            bestxshift=xshift;
            bestyshift=yshift;
            bestmetric=metric;
            besttrykernel=shkern;
            bestdeblur=shdeblur;
            bestshmag=shgmag;
            bestshdir=shgdir;
        end
    end
end
% sort gmag by direction, find which edges are thick
edgelengthmap=zeros(size(edges));
for y=1:size(edges,1)
    for x=1:size(edges,2)
        if edges(y,x)==1
            theta=bestshdir(y,x);
            range=1;
            while bestshmag < 0.3
                bestshmag
            end
        end
    end
end

