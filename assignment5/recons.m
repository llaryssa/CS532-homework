clc; clear all;
addpath('findPointNormals')

rawP = [ 776.649963  -298.408539 -32.048386  993.1581875 132.852554  120.885834  -759.210876 1982.174000 0.744869  0.662592  -0.078377 4.629312012;
    431.503540  586.251892  -137.094040 1982.053375 23.799522   1.964373    -657.832764 1725.253500 -0.321776 0.869462  -0.374826 5.538025391;
    -153.607925 722.067139  -127.204468 2182.4950   141.564346  74.195686   -637.070984 1551.185125 -0.769772 0.354474  -0.530847 4.737782227;
    -823.909119 55.557896   -82.577644  2498.20825  -31.429972  42.725830   -777.534546 2083.363250 -0.484634 -0.807611 -0.335998 4.934550781;
    -715.434998 -351.073730 -147.460815 1978.534875 29.429260   -2.156084   -779.121704 2028.892750 0.030776  -0.941587 -0.335361 4.141203125;
    -417.221649 -700.318726 -27.361042  1599.565000 111.925537  -169.101776 -752.020142 1982.983750 0.542421  -0.837170 -0.070180 3.929336426;
    94.934860   -668.213623 -331.895508 769.8633125 -549.403137 -58.174614  -342.555359 1286.971000 0.196630  -0.136065 -0.970991 3.574729736;
    452.159027  -658.943909 -279.703522 883.495000  -262.442566 1.231108    -751.532349 1884.149625 0.776201  0.215114  -0.592653 4.235517090];

P = zeros(3,4,8);

for i=1:8
    for j=1:3
        P(j,1:4,i) = rawP(i,4*(j-1)+1:4*(j-1)+4);
    end
    
    filename = sprintf('cs532hw5/silh_cam0%s_00023_0000008550.pbm', num2str(i-1));
    silh(:,:,i) = double(imread(filename)); 
    
    filename = sprintf('cs532hw5/cam0%s_00023_0000008550.png', num2str(i-1));
    img(:,:,:,i) = imread(filename);    
end

% create voxels
xlim = [-2.5 2.5];
ylim = [-3 3];
zlim = [0 2.5];
resolution = 0.01;
% resolution = 0.025;
x = xlim(1):resolution:xlim(2);
y = ylim(1):resolution:ylim(2);
z = zlim(1):resolution:zlim(2);
[xx,yy,zz] = meshgrid(x,y,z);
voxels = [xx(:) yy(:) zz(:)];

disp(['initial voxel size: ' num2str(length(voxels))]);

for i = 1:size(P,3)
    cam = P(:,:,i);
    sil = silh(:,:,i);
    
    vxp = cam*[voxels ones(size(voxels(:,1)))]';
    xx = ceil(vxp(1,:)./vxp(3,:));
    yy = ceil(vxp(2,:)./vxp(3,:));
    
    s1 = size(silh(:,:,i),1);
    s2 = size(silh(:,:,i),2);
    
    % out of image
    idx = (xx > 0) & (yy > 0) & (xx <= s2) & (yy <= s1);
    % get linear idx
    idx = find(idx);

    xx = xx(idx);
    yy = yy(idx); 
    
    % out of silhouette
    % get matrix idx
    idx2 = sub2ind(size(sil),yy,xx);
    idx3 = sil(idx2) == 1;
    
    idx = idx(idx3);
    voxels = voxels(idx,:);
    
    disp(['camera ' num2str(i) ', voxel size: ' num2str(length(voxels))]);
end



% coloring
for i = 1:size(P,3)
% for i = 1:1
    cam = P(:,:,i);
    im = img(:,:,:,i);
    
    vxp = cam*[voxels ones(size(voxels(:,1)))]';
    xx = ceil(vxp(1,:)./vxp(3,:));
    yy = ceil(vxp(2,:)./vxp(3,:));
    
%     idx = sub2ind([size(im,1) size(im,2)],yy,xx);
    idx = sub2ind(size(im),yy,xx,repmat(1,size(yy,1), size(yy,2)));
    colorR(:,i) = im(idx);
    
    idx = sub2ind(size(im),yy,xx,repmat(2,size(yy,1), size(yy,2)));
    colorG(:,i) = im(idx);
    
    idx = sub2ind(size(im),yy,xx,repmat(3,size(yy,1), size(yy,2)));
    colorB(:,i) = im(idx);
end

r = mean(colorR,2);
g = mean(colorG,2);
b = mean(colorB,2);

% writeply(voxels, [], 'dancer0.ply');
% writeply(voxels, [r g b], 'dancer1.ply');

r = colorR(:,1);
g = colorG(:,1);
b = colorB(:,1);

% writeply(voxels, double([r g b]), 'dancer2.ply');





% coloring second try
[normals,~] = findPointNormals(voxels,[],[],true);

for i = 1:size(P,3)
   tempP = P(:,:,i);
   C(1:4,i) = null(tempP);
   C(1:4,i) = C(1:4,i)/C(4,i);
end

% figure, hold on; grid on;
% set(gca, 'DataAspectRatio', [1 1 1]);
% scatter3(voxels(:,1), voxels(:,2), voxels(:,3), '.', 'g');
% scatter3(C(1,:), C(2,:), C(3,:), 'd','r');
% quiver3(voxels(:,1), voxels(:,2), voxels(:,3), ...
%         normals(:,1), normals(:,2), normals(:,3));

for j = 1:8
    p = P(:,:,j);
    z = p(3,1:3);
    z = z./norm(z);
    N(:,j) = z';
    
%     c = C(:,j);
%     quiver3(c(1), c(2), c(3), z(1), z(2), z(3), 'b');
    
end


for i = 1:size(P,3)
    dist(:,i) = ddist(normals, N(:,i));
end
% get minimum distance idx
[~, mindistidx] = min(dist,[],2);

for i = 1:size(P,3)
   bestidx(:,i) = (mindistidx == i);
end

colors = zeros(size(voxels));

for i = 1:size(P,3)
    idx = bestidx(:,i);
    vox = voxels(idx,:);
    if size(vox,1)~=0
        cam = P(:,:,i);
        im = img(:,:,:,i);

        vxp = cam*[vox ones(size(vox(:,1)))]';
        xx = ceil(vxp(1,:)./vxp(3,:));
        yy = ceil(vxp(2,:)./vxp(3,:));

        idxr = sub2ind(size(im),yy,xx,repmat(1,size(yy,1), size(yy,2)));
        colors(idx,1) = im(idxr);

        idxg = sub2ind(size(im),yy,xx,repmat(2,size(yy,1), size(yy,2)));
        colors(idx,2) = im(idxg);

        idxb = sub2ind(size(im),yy,xx,repmat(3,size(yy,1), size(yy,2)));
        colors(idx,3) = im(idxb);
    end
end

writeply(voxels, colors, 'try.ply');

% figure, scatter3(voxels(:,1), voxels(:,2), voxels(:,3), 5, cc./255);
% set(gca, 'DataAspectRatio', [1 1 1]);
% colormap gray;
