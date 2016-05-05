function disparity = getDispFrom3d(cloud,baseline,focal_length, sz)
    disparity = zeros(sz);
    for i = 1:length(cloud)
        a = round(cloud(1,i));
        b = round(cloud(2,i));
        c = cloud(3,i);
        if a > 0 && b > 0 && ~isnan(a) && ~isnan(b) && ...
           a < size(disparity,2) && b < size(disparity,1) && c~=0
            disparity(b,a) = baseline*focal_length/c;
        end
    end
end

