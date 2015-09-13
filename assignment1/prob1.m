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

clc; clear all;
srcimg = imread('basketball-court.ppm');
blkimg = zeros(940, 500);

% corners of the blank image / correspondences
pp = [0 500 500 0; 0 0 940 940; 1 1 1 1];

% figure, imshow(srcimg); hold on;
% 
% [x,y] = ginput(4);
% pix = [x'; y'; 1 1 1 1];

pix = [243  403  278   23
       50   73   278  194
       1    1     1     1];

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

% normalization
[T1,p1] = normalization(p);
[T2,p2] = normalization(pp);

% compute A
j = 1;
for i = 1:4
    A(j,:) = [0 0 0 -p2(3,i)*p1(:,i)' p2(2,i).*p1(:,i)'];
    A(j+1,:) = [p2(3,i)*p1(:,i)' 0 0 0 -p2(1,i).*p1(:,i)'];
    j = j+2;
end

% svd of A
[U,D,V] = svd(A);
h = V(:,9);
h = reshape(h,3,3)';

% denormalization
H = inv(T2)*h*T1;

%% Applying the transformation to the source image

T = maketform('projective', H);
image = imtransform(srcimg, T);
figure, imshow(image);






