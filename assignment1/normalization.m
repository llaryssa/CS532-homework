% Normalization of x: Compute a similarity transformation T, consisting 
% of a translation and scaling, that takes points xi to a new set of points 
% ?xi such that the centroid of the points ?xi is the coordinate origin (0, 0)', 
% and their average distance from the origin is ?2.

function [T, pp] = normalization (p)

    % centroid is the origin
    pp = p(1:2, :);
    centroid = [mean(p(1,:)); mean(p(2,:))];
    pp = pp - repmat(centroid, 1, 4);
    
    % average distance is sqrt(2)
    mean_norm = norm(pp(:,1)) + norm(pp(:,2)) + norm(pp(:,3)) + norm(pp(:,4));
    mean_norm = sqrt(2)/(mean_norm/4);
    pp = pp.*mean_norm;
    
    pp = [pp; 1 1 1 1];
    
    T = [mean_norm 0 -mean_norm*centroid(1)
         0 mean_norm -mean_norm*centroid(2)
         0         0           1];
end