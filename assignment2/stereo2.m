function [] = stereo2()

lft = imread('teddyL.pgm');
rgt = imread('teddyR.pgm');

% figure;
% subplot(1,2,1), subimage(lft);
% subplot(1,2,2), subimage(rgt);

height = size(lft, 1);
width  = size(lft, 2);

min_disp = 0;
max_disp = 63;

window = 5;

disp = zeros(size(lft));

for i = 1:height
    for j = 1:width % all pixels
        curr_disp = inf(max_disp -  min_disp + 1);
       for d = min_disp:max_disp % all disparities
           for win = 1:window % inside window
           end
           end
       end
    end
end

end
