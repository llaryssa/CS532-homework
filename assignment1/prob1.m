clc; clear all;
srcimg = imread('basketball-court.ppm');
blkimg = zeros(940, 500);

figure, imshow(srcimg); hold on;

[x,y] = ginput(4);
pix = [x'; y'];

%% sort the points so the correspondences make sense

% first point: min Y
[v, idx1] = min(pix(2,:));
% second point: max X
[v, idx2] = max(pix(1,:));
% third point: max Y
[v, idx3] = max(pix(2,:));
% fourth point: min X
[v, idx4] = min(pix(1,:));

p = [pix(:,idx1) pix(:,idx2) pix(:,idx3) pix(:,idx4)];

