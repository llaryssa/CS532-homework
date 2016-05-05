im = imread('output_prob1.png');

blkimg = zeros(940, 500);
srcimg = double(im);

H1 = [1 0 -size(im,2)/2
      0 1 -size(im,1)/2
      0 0 1];

H2 = [-1 0 size(im,2)/2
      0 1 size(im,1)/2
      0 0 1];
  
Href = H2*H1;

for i = 1:(size(blkimg,2))
    for j = 1:(size(blkimg,1))
        if ((i < (size(blkimg,2))/2) && (j > (size(blkimg,1))/2)) || ...
           ((i > (size(blkimg,2))/2) && (j < (size(blkimg,1))/2))
            H = Href;
        else
            H = eye(3);
        end   
        pt_tgt = [i j 1]';        
        pt_src = inv(H)*pt_tgt;
        % setting the last coordinate to 1
        pt_src = pt_src/pt_src(3);
        
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
imwrite(blkimg, 'output_prob2.png')