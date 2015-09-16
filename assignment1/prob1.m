% Algorithm 4.2. The normalized DLT for 2D homographies.
% Algorithm:
% (i) Normalization of x: Compute a similarity transformation T, consisting 
% of a translation and scaling, that takes points xi to a new set of points 
% ?xi such that the centroid of the points ?xi is the coordinate origin (0, 0)', 
% and their average distance from the origin is ?2.
% (ii) Normalization of x: Compute a similar transformation T for the points 
% in the second image, transforming points xi to ?xi.
% (iii) DLT: Apply algorithm 4.1(p91) to the correspondences ?xi ? ?xi' to 
% obtain a homographyH.
% (iv) Denormalization: Set H = T'-1*H*T.

% Algorithm 4.1. The basic DLT for H
% Algorithm:
% (i) For each correspondence xi ? xi' compute the matrix Ai from (4.1). 
% Only the first two rows need be used in general.
% (ii) Assemble the n 2 × 9 matrices Ai into a single 2n × 9 matrix A.
% (iii) Obtain the SVD of A . The unit singular vector corresponding to
% the smallest singular value is the solution h. Specifically, if A = UDV' 
% with D diagonal with positive diagonal entries, arranged in descending 
% order down the diagonal, then h is the last column of V.
% (iv) The matrix H is determined from h as in (4.2).

%%

% clc; clear all;
srcimg = imread('basketball-court.ppm');
blkimg = zeros(940, 500);

% corners of the blank image / correspondences
pp = [1   500   500   1
      1   1     940   940
      1   1     1     1];

figure, imshow(srcimg); hold on;
[x,y] = ginput(4);
pix = [x'; y'; 1 1 1 1];

% pix = [243  403  278   23
%        50   73   278  194
%        1    1     1     1];

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

% plot(p(1,:), p(2,:), 'LineWidth', 2);

%% DLT algorithm

% % normalization
% [T1,p1] = normalization(p);
% [T2,p2] = normalization(pp);

p1 = p; p2 = pp;

% compute A
A = zeros(8,9); j = 1;
for i = 1:4
    A(j,:) = [0 0 0 -p2(3,i)*p1(:,i)' p2(2,i).*p1(:,i)'];
    A(j+1,:) = [p2(3,i)*p1(:,i)' 0 0 0 -p2(1,i).*p1(:,i)'];
    j = j+2;
end

% svd of A
[U,D,V] = svd(A);
h = V(:,9);
H = reshape(h,3,3)';

% % denormalization
% H = inv(T2)*H*T1;

%% Applying the transformation to the source image

srcimg = double(srcimg);

for i = 1:size(blkimg,2)
    for j = 1:size(blkimg,1)
        pt_tgt = [i j 1]';
        pt_src = inv(H)*pt_tgt;
        % setting the last coordinate to 1
        pt_src = pt_src/pt_src(3);
        
        
% % fill colors simply rounding      
% %         check if the point is inside the picture
%         if (pt_src(1) > 0) && (pt_src(2) > 0) && ...
%            (pt_src(1) <= size(srcimg,2)) && ...
%            (pt_src(2) <= size(srcimg,1))
%             pt_src = round(pt_src);
%             color_r = srcimg(pt_src(2), pt_src(1), 1)/255;
%             color_g = srcimg(pt_src(2), pt_src(1), 2)/255;
%             color_b = srcimg(pt_src(2), pt_src(1), 3)/255;
%             blkimg(j,i,1) = color_r;
%             blkimg(j,i,2) = color_g;
%             blkimg(j,i,3) = color_b;
%         end


% fill colors with bilinear interpolation       
         % check if the point is inside the picture
        if (pt_src(1) > 0) && (pt_src(2) > 0) && ...
           (pt_src(1) <= size(srcimg,2)) && ...
           (pt_src(2) <= size(srcimg,1))
       
           box = [floor(pt_src(1)) ceil(pt_src(1)) floor(pt_src(1)) ceil(pt_src(1))
                  ceil(pt_src(2))  ceil(pt_src(2)) floor(pt_src(2)) floor(pt_src(2))];
           a = pt_src(1) - box(1,1);
           b = pt_src(2) - box(2,3);

           color_r = (1-a) * (1-b) * srcimg(box(2,3), box(1,3), 1) ...
                + a * (1-b) * srcimg(box(2,4), box(1,4), 1) ...
                + a * b * srcimg(box(2,2), box(1,2), 1) ...
                + (1-a) * b * srcimg(box(2,1), box(1,1), 1);
            
           color_g = (1-a) * (1-b) * srcimg(box(2,3), box(1,3), 2) ...
                + a * (1-b) * srcimg(box(2,4), box(1,4), 2) ...
                + a * b * srcimg(box(2,2), box(1,2), 2) ...
                + (1-a) * b * srcimg(box(2,1), box(1,1), 2);

           color_b = (1-a) * (1-b) * srcimg(box(2,3), box(1,3), 3) ...
                + a * (1-b) * srcimg(box(2,4), box(1,4), 3) ...
                + a * b * srcimg(box(2,2), box(1,2), 3) ...
                + (1-a) * b * srcimg(box(2,1), box(1,1), 3);
       
            blkimg(j,i,1) = color_r/255;
            blkimg(j,i,2) = color_g/255;
            blkimg(j,i,3) = color_b/255;
        end   
        
    end
end

figure, imshow(blkimg);



