clc; clear all;

for i = 1:7
  data(:,:,i) = imread(['cloth3/view' num2str(i-1) '.pgm']); 
end

disp1 = imread('cloth3/disp1.pgm');
disp5 = imread('cloth3/disp5.pgm');
disp1 = double(disp1)./3;
disp5 = double(disp5)./3;

baseline = 40;
focal_length = 1247;
px = size(disp1,2)/2;
py = size(disp1,1)/2;
c1 = [0 0 0]';
c2 = [40 0 0]';
c3 = [80 0 0]';
c5 = [160 0 0]';

cloud1 = get3dPoints(disp1, 4*baseline, focal_length);
cloud31 = projectInCamera(cloud1, c3, focal_length);
depth31 = getDispFrom3d(cloud31, 4*baseline, focal_length, size(disp1));

cloud5 = get3dPoints(disp5, -4*baseline, focal_length);
cloud35 = projectInCamera(cloud5, c5-c3, focal_length);
depth35 = getDispFrom3d(cloud35, -4*baseline, focal_length, size(disp1));

depth3 = zeros(size(depth31));

for i = 1:size(depth31,1)
    for j = 1:size(depth31,2)
        depth3(i,j) = max([depth31(i,j) depth35(i,j)]);
    end
end

% figure, imagesc(data(:,:,3)); colormap gray
% figure, imagesc(disp35); colormap gray
% figure, imagesc(disp3); colormap gray

%%%%%%%%%%%%%%%%%%

% [d1,cost1] = stereoMatching(data(:,:,1), data(:,:,2), 1, 64, 0, 9);
% [d3,cost3] = stereoMatching(data(:,:,3), data(:,:,4), 1, 64, 0, 9);
% [d5,cost5] = stereoMatching(data(:,:,5), data(:,:,6), 1, 64, 0, 9);
% imwrite(uint8(d1), 'd1.pgm');
% imwrite(uint8(d3), 'd3.pgm');
% imwrite(uint8(d5), 'd5.pgm');
% imwrite(uint8(cost1), 'c1.pgm');
% imwrite(uint8(cost3), 'c3.pgm');
% imwrite(uint8(cost5), 'c5.pgm');

d1 = double(imread('d1.pgm'));
d3 = double(imread('d3.pgm'));
d5 = double(imread('d5.pgm'));
cost1 = double(imread('c1.pgm'));
cost3 = double(imread('c3.pgm'));
cost5 = double(imread('c5.pgm'));

figure, imagesc(d1), colormap gray
figure, imagesc(d3), colormap gray
figure, imagesc(d5), colormap gray

% combining to generate disp 3

cloudd1 = get3dPoints(d1, baseline, focal_length);
cloudd31 = projectInCamera(cloudd1, c3, focal_length);
depthd31 = getDispFrom3d(cloudd31, baseline, focal_length, size(disp1));

cloudd3 = get3dPoints(d3, baseline, focal_length);
cloudd33 = projectInCamera(cloudd3, [0 0 0]', focal_length);
depthd33 = getDispFrom3d(cloudd33, baseline, focal_length, size(disp1));

cloudd5 = get3dPoints(d5, -baseline, focal_length);
cloudd35 = projectInCamera(cloudd5, c5-c3, focal_length);
depthd35 = getDispFrom3d(cloudd35, -baseline, focal_length, size(disp1));


% answers to disp3 using d1,d3,d5
dd1 = zeros(size(depth31));
dd2 = zeros(size(depth31));

for i = 1:size(disp1,1)
    for j = 1:size(disp1,2)
        dd1(i,j) = min([depthd33(i,j) depthd35(i,j) depthd33(i,j)]);
        
        [~,idx] = min([cost1(i,j) cost3(i,j) cost5(i,j)]);
        switch(idx)
            case 1, dd2(i,j) = depthd33(i,j);
            case 2, dd2(i,j) = depthd35(i,j);
            case 3, dd2(i,j) = depthd33(i,j);
        end
    end
end



err1 = sum(abs((dd1(:) - depth3(:))) > baseline*focal_length);
err1 = err1/(size(dd1,1)*size(dd1,2))

err2 = sum(abs((dd2(:) - depth3(:))) > baseline*focal_length);
err2 = err2/(size(dd1,1)*size(dd1,2))

% figure, imagesc(dd1), colormap gray
% figure, imagesc(dd2), colormap gray


