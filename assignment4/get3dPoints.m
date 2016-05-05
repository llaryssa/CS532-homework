function cloud = get3dPoints(disparity, baseline, focal_length)
    z = baseline*focal_length./disparity;
    [x,y] = meshgrid(1:size(disparity,2), 1:size(disparity,1));
    x = baseline.*x./disparity;
    y = baseline.*y./disparity;
    cloud = [x(:) y(:) z(:)]';
end