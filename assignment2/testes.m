
%% Inicialization

min_disp = 0;
max_disp = 63;
window = 3;

lft = imread('teddyL.pgm');
rgt = imread('teddyR.pgm');

% figure;
% subplot(1,2,1), subimage(lft);
% subplot(1,2,2), subimage(rgt);

height = size(lft, 1);
width  = size(lft, 2);

%% Rank transform



%% SAD stereo matching

half = (window-1)/2;
disparity = inf(size(lft));

for i = 1:height
    height - i
    for j = 1:width  % all pixels
       curr_min_disp = Inf;
       min_disparity = inf(1,max_disp+1);
       for d = min_disp:max_disp  % all disparities
           if (j+half-d) > 0
               lims = [max(1,i-half);
                       min(height, i+half);
                       max(1,j-half);
                       min(width, j+half);
                       max(1,j-half-d);
                       min(width, j+half-d)];
                offs = min(lims(6) - lims(5), lims(4) - lims(3));
                sumwin = sum(sum( ...
                   abs(double(lft(lims(1):lims(2), lims(3):lims(3)+offs)) - ...
                             double(rgt(lims(1):lims(2), lims(5):lims(5)+offs)) ...
                            )));


               min_disparity(d+1) = sumwin; 
           else
               break; % exit the for loop
           end
       end
        [~, idxx] = min(min_disparity);
        disparity(i,j) = idxx-1;
    end
end

gt = imread('disp2.pgm');
gt = double(gt)./4;
disparity = double(disparity);

erro = sum(sum(abs(gt - disparity) > 1));
erro = erro / (size(gt,1)*size(gt,2))

figure, imshow(disparity, [min_disp max_disp]);