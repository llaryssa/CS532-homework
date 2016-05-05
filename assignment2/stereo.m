clc; clear all;

%% Inicialization

min_disp = 0;
max_disp = 63;
rank = 5;
% window = 3;
window = 9;

lft = imread('teddyL.pgm');
rgt = imread('teddyR.pgm');

height = size(lft, 1);
width  = size(lft, 2);

%% Rank transform
% 
% rnklft = zeros(size(lft));
% rnkrgt = zeros(size(rgt));
% half_rnk = (rank-1)/2;
% 
% for i = rank:height-rank
%     for j = rank:width-rank  % all pixels       
%         lims = [max(1,i-half_rnk); min(height, i+half_rnk);
%                max(1,j-half_rnk); min(width, j+half_rnk)];
%         lftwin = double(lft(lims(1):lims(2), lims(3):lims(4)));
%         rnklft(i,j) = sum(sum(lftwin < lft(i,j)));
%         
%         rgtwin = double(rgt(lims(1):lims(2), lims(3):lims(4)));
%         rnkrgt(i,j) = sum(sum(rgtwin < rgt(i,j)));
%     end
% end
% 
% disp('Rank transformed');

%% SAD stereo matching

rnklft = lft;
rnkrgt = rgt;

half_win = (window-1)/2;
disparity = ones(size(lft));
pkrn = inf(size(lft,1)*size(lft,2), 3);
count = 1;

% figure, imshow(disparity)

for i = window:height-window
    for j = window:width-window  % all pixels
       curr_min_disp = inf(1,max_disp-min_disp+1);
       for d = min_disp:max_disp  % all disparities
           if (j-half_win-d) > 0
                sumwin = sum(sum( ...
                    abs(double(rnklft(i-half_win:i+half_win,j-half_win:j+half_win)) - ...
                       double(rnkrgt(i-half_win:i+half_win,j-half_win-d:j+half_win-d)) ...
                         )));
                curr_min_disp(d+1) = sumwin;
           else
%                break; % exit the for loop
           end
       end
       [c1, idx] = min(curr_min_disp);
       curr_min_disp(idx) = [];
       [c2, ~] = min(curr_min_disp);
       disparity(i,j) = idx-1;
       pkrn(count, :) = [c2/c1 i j];
       
       count = count+1;
       
       
%        imagesc(disparity), drawnow; 
       
    end
end

%% Computing errors

disparity = double(disparity);
gt = imread('disp2.pgm');
gt = double(gt)./4;
erro = sum(sum(abs(gt - disparity) > 1)) / ...
       (size(lft,1)*size(lft,2))
   
figure, imshow(disparity, [min_disp max_disp]);

%% PKRN error

pkrn = sortrows(pkrn);
pkrn(isinf(pkrn(:,1)), :) = [];
pkrn(isnan(pkrn(:,1)), :) = [];
pkrn = pkrn(length(pkrn)/2:end, :);

idx = false(size(lft));

for k = 1:length(pkrn)
   idx(pkrn(k,2), pkrn(k,3)) = true; 
end

erro2 = sum(sum(abs(gt(idx) - disparity(idx)) > 1)) / sum(sum(idx))
