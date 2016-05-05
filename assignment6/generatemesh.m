disparity = imread('cloth3/disp1.pgm');
img = imread('cloth3/view1.png');

disparity = double(disparity);

baseline = 4*40;
focal_length = 1247;
px = size(disparity,2)/2;
py = size(disparity,1)/2;

z = baseline*focal_length./disparity;
[x,y] = meshgrid(1:size(disparity,2), 1:size(disparity,1));
im = [x(:) y(:)];
xx = baseline.*(x-px)./disparity;
yy = baseline.*(y-py)./disparity;
cloud = [xx(:) yy(:) z(:)];
colors = reshape(img,numel(disparity),size(img,3));

a1 = sum(isinf(cloud),2);
b1 = cloud(:,3) > mean(cloud(~isinf(cloud(:,3)),3));
c1 = disparity(:) == 0;

a1 = find(a1);
b1 = find(b1);
c1 = find(c1);

d = unique([a1;b1;c1]);

% cloud(d,:) = [];
% colors(d,:) = [];
% im(d,:) = [];

tri = 1:numel(disparity);
tri = reshape(tri, size(disparity,1), size(disparity,2));

tri(d) = 0;
idx = sum(tri,2) == 0;
tri(idx,:) = [];

faces = [];

cnt = 1;
for i = 1:size(tri,1)-1
    for j = 1:size(tri,2)-1
       itemp = i;
       if tri(i,j) == 0
       else
           offj = 1;
           while tri(i,j+offj) == 0 && j+offj < size(tri,2)
               offj = offj + 1; 
           end
           while tri(itemp+1,j) == 0 && i < size(tri,1)
               itemp = itemp + 1;
           end
           if j+offj < size(tri,2) && i < size(tri,1) && ...
              tri(itemp,j)~=0 && tri(itemp,j+offj)~=0 && ...
              tri(itemp+1,j+offj)~=0 && tri(itemp+1,j)~=0
               faces(cnt,:) = [tri(itemp,j) tri(itemp,j+offj) tri(itemp+1,j+offj)];
               faces(cnt+1,:) = [tri(itemp,j) tri(itemp+1,j) tri(itemp+1,j+offj)];
               cnt = cnt + 2;
           end
       end
       
    end
end

cloud(isinf(cloud)) = 0;
writeplyfaces(cloud,double(colors),faces-1,'cloud.ply');