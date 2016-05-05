folder = {'Aloe', 'Baby1', 'Baby2', 'Baby3', 'Bowling1', 'Bowling2', 'Cloth1', 'Cloth2', 'Cloth3', 'Cloth4', 'Flowerpots', 'Lampshade1', 'Lampshade2', 'Midd1', 'Midd2', 'Monopoly', 'Plastic', 'Rocks1', 'Rocks2', 'Wood1', 'Wood2'};
windowsize = 9;
disparity = 63;
spacc = 0;


for i = 1:21

    namelft = sprintf('/Users/llaryssa/Documents/Stevens/CS559-Learning/project/middleburry-third/%s/view1.png', char(folder(i)));
    namergt = sprintf('/Users/llaryssa/Documents/Stevens/CS559-Learning/project/middleburry-third/%s/view5.png', char(folder(i)));
    lft = imread(namelft);
    rgt = imread(namergt);
    lft = rgb2gray(lft);
    rgt = rgb2gray(rgt);
    
    [spdmap, dcost, pcost, wcost] = stereomatch(lft, rgt, windowsize, disparity, spacc);
    
    output = sprintf('/Users/llaryssa/Documents/Stevens/CS559-Learning/project/middleburry-third/%s/est1.png', char(folder(i)));
    
    imwrite(uint8(spdmap), output);

%     namedsp = sprintf('/Users/llaryssa/Documents/Stevens/CS559-Learning/project/middleburry-third/%s/disp1.png', char(folder(i)));
%     dsp = imread(namedsp);
% 
%     dsp = round(double(dsp)./3);
%  
%     output = sprintf('/Users/llaryssa/Documents/Stevens/CS559-Learning/project/middleburry-third/%s/dispthird.png', char(folder(i)));
%     
%     imwrite(uint8(dsp), output);

end



regionLeft = [16, 16, 16, 16, 16, 16, 16, 16, 16;
  16, 16, 16, 16, 16, 16, 16, 16, 16;
  16, 16, 16, 16, 16, 16, 16, 16, 16;
  16, 16, 16, 16, 16, 16, 16, 16, 16;
  16, 16, 16, 16, 16, 16, 16, 16, 16;
  16, 16, 16, 16, 16, 16, 16, 16, 16;
  16, 16, 16, 16, 16, 16, 16, 16, 16;
  16, 16, 16, 16, 16, 16, 16, 16, 16;
  16, 16, 16, 16, 16, 16, 16, 16, 16];
regionRight = [16, 16, 16, 16, 16, 16, 16, 32, 33;
  16, 16, 16, 16, 16, 16, 32, 32, 33;
  16, 16, 16, 16, 16, 16, 32, 32, 33;
  16, 16, 16, 16, 16, 31, 32, 32, 55;
  16, 16, 16, 16, 16, 16, 59, 55, 55;
  16, 16, 16, 16, 16, 16, 55, 55, 55;
  16, 16, 16, 16, 16, 16, 55, 55, 55;
  16, 16, 16, 16, 16, 16, 63, 63, 55;
  16, 16, 16, 16, 16, 63, 63, 63, 55];

meanLeft = mean2(regionLeft);
meanRight = mean2(regionRight);

den = sqrt(sum(sum(regionLeft.^2))*sum(sum(regionRight.^2)));
tempCorrScore = regionLeft.*regionRight/den;
score = sum(tempCorrScore(:))